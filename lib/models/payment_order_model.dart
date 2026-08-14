import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentOrderModel {
  final String paymentOrderId;
  final String bookingId;
  final double amount;
  final String currency;
  final String gateway;
  final String status; // created, processing, completed, expired
  final DateTime createdAt;
  final DateTime expiresAt;

  PaymentOrderModel({
    required this.paymentOrderId,
    required this.bookingId,
    required this.amount,
    this.currency = 'INR',
    this.gateway = 'MockGateway',
    this.status = 'created',
    DateTime? createdAt,
    required this.expiresAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PaymentOrderModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return PaymentOrderModel(
      paymentOrderId: docId.isNotEmpty ? docId : (map['paymentOrderId'] ?? ''),
      bookingId: map['bookingId'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] ?? 'INR',
      gateway: map['gateway'] ?? 'MockGateway',
      status: map['status'] ?? 'created',
      createdAt: parseDate(map['createdAt']),
      expiresAt: parseDate(map['expiresAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentOrderId': paymentOrderId,
      'bookingId': bookingId,
      'amount': amount,
      'currency': currency,
      'gateway': gateway,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }
}
