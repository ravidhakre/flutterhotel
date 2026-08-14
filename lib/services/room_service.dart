import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/room_model.dart';
import '../models/room_status_history_model.dart';
import 'audit_service.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;
  final AuditService _auditService = AuditService();

  /// Verify if a room number is unique within a property
  Future<bool> isRoomNumberUnique({
    required String propertyId,
    required String roomNumber,
    String? currentRoomId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.roomsCollection)
          .where('propertyId', isEqualTo: propertyId)
          .where('roomNumber', isEqualTo: roomNumber)
          .get();

      if (snapshot.docs.isEmpty) return true;
      if (currentRoomId != null) {
        return snapshot.docs.every((doc) => doc.id == currentRoomId);
      }
      return false;
    } catch (e) {
      throw DatabaseException('Failed to check room number uniqueness: $e');
    }
  }

  /// Create a new physical room with uniqueness validation
  Future<void> createRoom(RoomModel room, {required String performedBy}) async {
    try {
      final isUnique = await isRoomNumberUnique(
        propertyId: room.propertyId,
        roomNumber: room.roomNumber,
      );

      if (!isUnique) {
        throw DatabaseException(
          'Room Number ${room.roomNumber} already exists in this property.',
          code: 'DUPLICATE_ROOM_NUMBER',
        );
      }

      final docRef = room.roomId.isNotEmpty
          ? _firestore.collection(FirebaseConstants.roomsCollection).doc(room.roomId)
          : _firestore.collection(FirebaseConstants.roomsCollection).doc();

      final newRoom = RoomModel(
        roomId: docRef.id,
        propertyId: room.propertyId,
        roomTypeId: room.roomTypeId,
        roomNumber: room.roomNumber,
        floor: room.floor,
        status: room.status,
        notes: room.notes,
      );

      await docRef.set(newRoom.toMap());

      await _auditService.logAction(
        action: 'ROOM_CREATED',
        module: 'ROOM_MANAGEMENT',
        recordId: docRef.id,
        propertyId: room.propertyId,
        performedBy: performedBy,
        newData: newRoom.toMap(),
      );
    } catch (e) {
      throw DatabaseException('Failed to create room: $e');
    }
  }

  /// Get rooms by property with multi-property filtering
  Future<List<RoomModel>> getRoomsByProperty(String propertyId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.roomsCollection)
          .where('propertyId', isEqualTo: propertyId)
          .get();

      return snapshot.docs.map((doc) => RoomModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch property rooms: $e');
    }
  }

  /// Get rooms by room type
  Future<List<RoomModel>> getRoomsByRoomType(String roomTypeId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.roomsCollection)
          .where('roomTypeId', isEqualTo: roomTypeId)
          .get();

      return snapshot.docs.map((doc) => RoomModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch room type rooms: $e');
    }
  }

  /// Update room status and record status history
  Future<void> updateRoomStatus({
    required String roomId,
    required String newStatus,
    required String reason,
    required String changedBy,
  }) async {
    try {
      final roomRef = _firestore.collection(FirebaseConstants.roomsCollection).doc(roomId);
      final roomDoc = await roomRef.get();
      if (!roomDoc.exists) throw DatabaseException('Room not found');

      final oldStatus = roomDoc.data()?['status'] ?? 'available';
      final propertyId = roomDoc.data()?['propertyId'] ?? '';

      await roomRef.update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Record History entry
      final historyRef = _firestore.collection('roomStatusHistory').doc();
      final history = RoomStatusHistoryModel(
        historyId: historyRef.id,
        roomId: roomId,
        propertyId: propertyId,
        oldStatus: oldStatus,
        newStatus: newStatus,
        reason: reason,
        changedBy: changedBy,
      );
      await historyRef.set(history.toMap());

      await _auditService.logAction(
        action: 'ROOM_STATUS_CHANGED',
        module: 'ROOM_MANAGEMENT',
        recordId: roomId,
        propertyId: propertyId,
        performedBy: changedBy,
        oldData: {'status': oldStatus},
        newData: {'status': newStatus, 'reason': reason},
      );
    } catch (e) {
      throw DatabaseException('Failed to update room status: $e');
    }
  }

  /// Bulk Room Status update
  Future<void> bulkUpdateRoomStatus({
    required List<String> roomIds,
    required String newStatus,
    required String reason,
    required String changedBy,
  }) async {
    try {
      for (final id in roomIds) {
        await updateRoomStatus(
          roomId: id,
          newStatus: newStatus,
          reason: reason,
          changedBy: changedBy,
        );
      }
    } catch (e) {
      throw DatabaseException('Failed bulk status update: $e');
    }
  }
}
