import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/maintenance_block_model.dart';
import '../models/room_inventory_model.dart';
import 'audit_service.dart';

class InventoryService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;
  final AuditService _auditService = AuditService();

  /// Create or update date-wise inventory for a room type
  Future<void> saveInventory(RoomInventoryModel inventory) async {
    try {
      final docRef = inventory.inventoryId.isNotEmpty
          ? _firestore.collection('roomInventory').doc(inventory.inventoryId)
          : _firestore.collection('roomInventory').doc();

      await docRef.set(inventory.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw DatabaseException('Failed to save room inventory: $e');
    }
  }

  /// Fetch inventory records for a date range
  Future<List<RoomInventoryModel>> getInventoryForRange({
    required String propertyId,
    String? roomTypeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);

      Query query = _firestore
          .collection('roomInventory')
          .where('propertyId', isEqualTo: propertyId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end));

      if (roomTypeId != null && roomTypeId.isNotEmpty) {
        query = query.where('roomTypeId', isEqualTo: roomTypeId);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => RoomInventoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to query inventory range: $e');
    }
  }

  /// Add Maintenance Block with date range & conflict validation
  Future<void> createMaintenanceBlock(MaintenanceBlockModel block) async {
    try {
      // Conflict Check: Ensure no active reservation overlaps
      final existingBookings = await _firestore
          .collection(FirebaseConstants.bookingsCollection)
          .where('roomId', isEqualTo: block.roomId)
          .where('bookingStatus', whereIn: ['confirmed', 'checkedIn', 'pending'])
          .get();

      for (final doc in existingBookings.docs) {
        final checkIn = (doc.data()['checkIn'] as Timestamp).toDate();
        final checkOut = (doc.data()['checkOut'] as Timestamp).toDate();

        if (block.startDate.isBefore(checkOut) && block.endDate.isAfter(checkIn)) {
          throw DatabaseException(
            'Cannot block room: Overlaps with existing Booking #${doc.id}',
            code: 'BOOKING_CONFLICT',
          );
        }
      }

      final docRef = _firestore.collection('maintenanceBlocks').doc();
      final newBlock = MaintenanceBlockModel(
        blockId: docRef.id,
        roomId: block.roomId,
        propertyId: block.propertyId,
        startDate: block.startDate,
        endDate: block.endDate,
        reason: block.reason,
        notes: block.notes,
        createdBy: block.createdBy,
        status: 'active',
      );

      await docRef.set(newBlock.toMap());

      await _auditService.logAction(
        action: 'MAINTENANCE_BLOCKED',
        module: 'INVENTORY_MANAGEMENT',
        recordId: docRef.id,
        propertyId: block.propertyId,
        performedBy: block.createdBy,
        newData: newBlock.toMap(),
      );
    } catch (e) {
      throw DatabaseException('Failed to create maintenance block: $e');
    }
  }

  /// Unblock room / Remove maintenance block
  Future<void> removeMaintenanceBlock(String blockId, {required String performedBy}) async {
    try {
      final docRef = _firestore.collection('maintenanceBlocks').doc(blockId);
      final doc = await docRef.get();
      if (!doc.exists) return;

      final propertyId = doc.data()?['propertyId'];

      await docRef.update({'status': 'completed'});

      await _auditService.logAction(
        action: 'MAINTENANCE_UNBLOCKED',
        module: 'INVENTORY_MANAGEMENT',
        recordId: blockId,
        propertyId: propertyId,
        performedBy: performedBy,
      );
    } catch (e) {
      throw DatabaseException('Failed to remove maintenance block: $e');
    }
  }
}
