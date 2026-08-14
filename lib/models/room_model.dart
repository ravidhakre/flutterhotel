import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  final String roomId;
  final String propertyId;
  final String roomTypeId;
  final String roomNumber;
  final String floor;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoomModel({
    required this.roomId,
    required this.propertyId,
    required this.roomTypeId,
    required this.roomNumber,
    this.floor = '1st Floor',
    this.status = 'available',
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory RoomModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return RoomModel(
      roomId: docId.isNotEmpty ? docId : (map['roomId'] ?? ''),
      propertyId: map['propertyId'] ?? '',
      roomTypeId: map['roomTypeId'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      floor: map['floor'] ?? '1st Floor',
      status: map['status'] ?? 'available',
      notes: map['notes'],
      createdAt: parseTimestamp(map['createdAt']) ?? DateTime.now(),
      updatedAt: parseTimestamp(map['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'propertyId': propertyId,
      'roomTypeId': roomTypeId,
      'roomNumber': roomNumber,
      'floor': floor,
      'status': status,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
