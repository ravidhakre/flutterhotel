import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/room_model.dart';
import '../models/room_type_model.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;

  /// Get room types for a property
  Future<List<RoomTypeModel>> getRoomTypes(String propertyId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.roomTypesCollection)
          .where('propertyId', isEqualTo: propertyId)
          .where('status', isEqualTo: 'active')
          .get();

      return snapshot.docs.map((doc) => RoomTypeModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch room types: $e');
    }
  }

  /// Get individual rooms for a property
  Future<List<RoomModel>> getRooms(String propertyId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.roomsCollection)
          .where('propertyId', isEqualTo: propertyId)
          .get();

      return snapshot.docs.map((doc) => RoomModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch rooms: $e');
    }
  }

  /// Save room type
  Future<void> saveRoomType(RoomTypeModel roomType) async {
    try {
      await _firestore
          .collection(FirebaseConstants.roomTypesCollection)
          .doc(roomType.roomTypeId)
          .set(roomType.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw DatabaseException('Failed to save room type: $e');
    }
  }

  /// Save room
  Future<void> saveRoom(RoomModel room) async {
    try {
      await _firestore
          .collection(FirebaseConstants.roomsCollection)
          .doc(room.roomId)
          .set(room.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw DatabaseException('Failed to save room: $e');
    }
  }
}
