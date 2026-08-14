import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentEventModel {
  final String eventId;
  final String gateway;
  final String eventType;
  final String paymentId;
  final String bookingId;
  final String? payloadHash;
  final bool processed;
  final DateTime? processedAt;
  final DateTime createdAt;

  PaymentEventModel({
    required this.eventId,
    this.gateway = 'MockGateway',
    required this.eventType,
    required this.paymentId,
    required this.bookingId,
    this.payloadHash,
    this.processed = true,
    DateTime? processedAt,
    DateTime? createdAt,
  })  : processedAt = processedAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  factory PaymentEventModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return PaymentEventModel(
      eventId: docId.isNotEmpty ? docId : (map['eventId'] ?? ''),
      gateway: map['gateway'] ?? 'MockGateway',
      eventType: map['eventType'] ?? '',
      paymentId: map['paymentId'] ?? '',
      bookingId: map['bookingId'] ?? '',
      payloadHash: map['payloadHash'],
      processed: map['processed'] ?? true,
      processedAt: parseDate(map['processedAt']),
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'gateway': gateway,
      'eventType': eventType,
      'paymentId': paymentId,
      'bookingId': bookingId,
      'payloadHash': payloadHash,
      'processed': processed,
      'processedAt': processedAt != null ? Timestamp.fromDate(processedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
