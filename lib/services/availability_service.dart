import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/room_model.dart';
import '../models/room_type_model.dart';

class AvailabilityService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;

  /// Calculate bookable count & list of available physical rooms
  /// Bookable rooms = Total physical rooms - Active reservations - Occupied - Maintenance - Blocked
  Future<List<RoomModel>> getAvailableRooms({
    required String propertyId,
    required String roomTypeId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    try {
      // 1. Fetch all physical rooms of this room type
      final roomsSnapshot = await _firestore
          .collection(FirebaseConstants.roomsCollection)
          .where('propertyId', isEqualTo: propertyId)
          .where('roomTypeId', isEqualTo: roomTypeId)
          .get();

      final allRooms = roomsSnapshot.docs
          .map((doc) => RoomModel.fromMap(doc.data(), doc.id))
          .where((r) => r.status == 'available' || r.status == 'cleaning')
          .toList();

      if (allRooms.isEmpty) return [];

      // 2. Fetch overlapping bookings for date range
      final bookingsSnapshot = await _firestore
          .collection(FirebaseConstants.bookingsCollection)
          .where('propertyId', isEqualTo: propertyId)
          .where('roomTypeId', isEqualTo: roomTypeId)
          .where('bookingStatus', whereIn: ['confirmed', 'checkedIn', 'pending', 'paymentPending'])
          .get();

      final reservedRoomIds = <String>{};

      for (final doc in bookingsSnapshot.docs) {
        final bCheckIn = (doc.data()['checkIn'] as Timestamp).toDate();
        final bCheckOut = (doc.data()['checkOut'] as Timestamp).toDate();
        final assignedRoomId = doc.data()['roomId'] as String?;

        if (checkIn.isBefore(bCheckOut) && checkOut.isAfter(bCheckIn)) {
          if (assignedRoomId != null && assignedRoomId.isNotEmpty) {
            reservedRoomIds.add(assignedRoomId);
          }
        }
      }

      // 3. Fetch overlapping maintenance blocks
      final blocksSnapshot = await _firestore
          .collection('maintenanceBlocks')
          .where('propertyId', isEqualTo: propertyId)
          .where('status', isEqualTo: 'active')
          .get();

      for (final doc in blocksSnapshot.docs) {
        final mStart = (doc.data()['startDate'] as Timestamp).toDate();
        final mEnd = (doc.data()['endDate'] as Timestamp).toDate();
        final blockRoomId = doc.data()['roomId'] as String;

        if (checkIn.isBefore(mEnd) && checkOut.isAfter(mStart)) {
          reservedRoomIds.add(blockRoomId);
        }
      }

      // Filter out reserved or maintenance rooms
      return allRooms.where((room) => !reservedRoomIds.contains(room.roomId)).toList();
    } catch (e) {
      throw DatabaseException('Failed to calculate available rooms: $e');
    }
  }

  /// Check boolean availability for checkIn/checkOut
  Future<bool> checkRoomAvailability({
    required String propertyId,
    required String roomTypeId,
    required DateTime checkIn,
    required DateTime checkOut,
    int requestedRooms = 1,
  }) async {
    final available = await getAvailableRooms(
      propertyId: propertyId,
      roomTypeId: roomTypeId,
      checkIn: checkIn,
      checkOut: checkOut,
    );
    return available.length >= requestedRooms;
  }

  /// Get available room types with counts for search UI
  Future<List<Map<String, dynamic>>> getAvailableRoomTypes({
    required String propertyId,
    required DateTime checkIn,
    required DateTime checkOut,
    int guests = 1,
  }) async {
    try {
      final roomTypesSnapshot = await _firestore
          .collection(FirebaseConstants.roomTypesCollection)
          .where('propertyId', isEqualTo: propertyId)
          .where('status', isEqualTo: 'active')
          .get();

      final roomTypes = roomTypesSnapshot.docs
          .map((doc) => RoomTypeModel.fromMap(doc.data(), doc.id))
          .where((rt) => rt.maxGuests >= guests)
          .toList();

      final results = <Map<String, dynamic>>[];

      for (final rt in roomTypes) {
        final availableRooms = await getAvailableRooms(
          propertyId: propertyId,
          roomTypeId: rt.roomTypeId,
          checkIn: checkIn,
          checkOut: checkOut,
        );

        if (availableRooms.isNotEmpty) {
          results.add({
            'roomType': rt,
            'availableCount': availableRooms.length,
            'availableRooms': availableRooms,
          });
        }
      }

      return results;
    } catch (e) {
      throw DatabaseException('Failed to fetch available room types: $e');
    }
  }

  /// Generate Admin Inventory Matrix Calendar Data (Dates vs Room Types)
  Future<Map<String, Map<String, int>>> getInventoryCalendar({
    required String propertyId,
    required DateTime startDate,
    required int days,
  }) async {
    try {
      final matrix = <String, Map<String, int>>{};

      final roomTypesSnapshot = await _firestore
          .collection(FirebaseConstants.roomTypesCollection)
          .where('propertyId', isEqualTo: propertyId)
          .where('status', isEqualTo: 'active')
          .get();

      final roomTypes = roomTypesSnapshot.docs
          .map((doc) => RoomTypeModel.fromMap(doc.data(), doc.id))
          .toList();

      for (int i = 0; i < days; i++) {
        final day = startDate.add(Duration(days: i));
        final nextDay = day.add(const Duration(days: 1));
        final dateKey = "${day.day}/${day.month}";

        matrix[dateKey] = {};

        for (final rt in roomTypes) {
          final avail = await getAvailableRooms(
            propertyId: propertyId,
            roomTypeId: rt.roomTypeId,
            checkIn: day,
            checkOut: nextDay,
          );
          matrix[dateKey]![rt.name] = avail.length;
        }
      }

      return matrix;
    } catch (e) {
      throw DatabaseException('Failed to build inventory calendar matrix: $e');
    }
  }
}
