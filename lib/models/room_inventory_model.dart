import 'package:cloud_firestore/cloud_firestore.dart';

class RoomInventoryModel {
  final String inventoryId;
  final String propertyId;
  final String roomTypeId;
  final String? roomId;
  final DateTime date;
  final String status;
  final int available;
  final int blocked;
  final int reserved;
  final int maintenance;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoomInventoryModel({
    required this.inventoryId,
    required this.propertyId,
    required this.roomTypeId,
    this.roomId,
    required this.date,
    this.status = 'open',
    this.available = 0,
    this.blocked = 0,
    this.reserved = 0,
    this.maintenance = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory RoomInventoryModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return RoomInventoryModel(
      inventoryId: docId.isNotEmpty ? docId : (map['inventoryId'] ?? ''),
      propertyId: map['propertyId'] ?? '',
      roomTypeId: map['roomTypeId'] ?? '',
      roomId: map['roomId'],
      date: parseDate(map['date']),
      status: map['status'] ?? 'open',
      available: (map['available'] as num?)?.toInt() ?? 0,
      blocked: (map['blocked'] as num?)?.toInt() ?? 0,
      reserved: (map['reserved'] as num?)?.toInt() ?? 0,
      maintenance: (map['maintenance'] as num?)?.toInt() ?? 0,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'inventoryId': inventoryId,
      'propertyId': propertyId,
      'roomTypeId': roomTypeId,
      'roomId': roomId,
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'status': status,
      'available': available,
      'blocked': blocked,
      'reserved': reserved,
      'maintenance': maintenance,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
