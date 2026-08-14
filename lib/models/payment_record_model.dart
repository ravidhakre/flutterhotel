import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentRecordModel {
  final String paymentId;
  final String bookingId;
  final double amount;
  final String method; // Cash, Card, UPI, Online, Bank Transfer
  final String? transactionId;
  final String status;
  final String collectedBy;
  final DateTime createdAt;

  PaymentRecordModel({
    required this.paymentId,
    required this.bookingId,
    required this.amount,
    required this.method,
    this.transactionId,
    this.status = 'success',
    required this.collectedBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PaymentRecordModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return PaymentRecordModel(
      paymentId: docId.isNotEmpty ? docId : (map['paymentId'] ?? ''),
      bookingId: map['bookingId'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      method: map['method'] ?? 'Cash',
      transactionId: map['transactionId'],
      status: map['status'] ?? 'success',
      collectedBy: map['collectedBy'] ?? 'Admin',
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'bookingId': bookingId,
      'amount': amount,
      'method': method,
      'transactionId': transactionId,
      'status': status,
      'collectedBy': collectedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
