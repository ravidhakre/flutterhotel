import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationAllocationModel {
  final String allocationId;
  final String bookingId;
  final String propertyId;
  final String roomTypeId;
  final String? roomId;
  final DateTime date;
  final String status; // "held", "reserved", "released"
  final DateTime createdAt;
  final DateTime? releasedAt;

  ReservationAllocationModel({
    required this.allocationId,
    required this.bookingId,
    required this.propertyId,
    required this.roomTypeId,
    this.roomId,
    required this.date,
    this.status = 'held',
    DateTime? createdAt,
    this.releasedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ReservationAllocationModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return ReservationAllocationModel(
      allocationId: docId.isNotEmpty ? docId : (map['allocationId'] ?? ''),
      bookingId: map['bookingId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      roomTypeId: map['roomTypeId'] ?? '',
      roomId: map['roomId'],
      date: parseDate(map['date']),
      status: map['status'] ?? 'held',
      createdAt: parseDate(map['createdAt']),
      releasedAt: map['releasedAt'] != null ? parseDate(map['releasedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'allocationId': allocationId,
      'bookingId': bookingId,
      'propertyId': propertyId,
      'roomTypeId': roomTypeId,
      'roomId': roomId,
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'releasedAt': releasedAt != null ? Timestamp.fromDate(releasedAt!) : null,
    };
  }
}
