import 'package:cloud_firestore/cloud_firestore.dart';

class BookingEventModel {
  final String eventId;
  final String bookingId;
  final String eventType;
  final String description;
  final String performedBy;
  final String performedByRole;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  BookingEventModel({
    required this.eventId,
    required this.bookingId,
    required this.eventType,
    required this.description,
    required this.performedBy,
    required this.performedByRole,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  factory BookingEventModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return BookingEventModel(
      eventId: docId.isNotEmpty ? docId : (map['eventId'] ?? ''),
      bookingId: map['bookingId'] ?? '',
      eventType: map['eventType'] ?? '',
      description: map['description'] ?? '',
      performedBy: map['performedBy'] ?? 'System',
      performedByRole: map['performedByRole'] ?? 'guest',
      timestamp: parseDate(map['timestamp']),
      metadata: map['metadata'] != null ? Map<String, dynamic>.from(map['metadata']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'bookingId': bookingId,
      'eventType': eventType,
      'description': description,
      'performedBy': performedBy,
      'performedByRole': performedByRole,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }
}
