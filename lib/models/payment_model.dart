import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String paymentId;
  final String bookingId;
  final String userId;
  final String propertyId;
  final String gateway; // Razorpay, Stripe, MockGateway, Manual
  final String? gatewayOrderId;
  final String? gatewayPaymentId;
  final String? gatewaySignature;
  final double amount;
  final String currency;
  final String paymentMethod; // Cash, Card, UPI, NetBanking, BankTransfer
  final String paymentType; // bookingPayment, deposit, balancePayment, addonPayment, manualPayment, refund
  final String status; // created, pending, processing, authorized, success, failed, cancelled, expired, partiallyRefunded, refunded
  final DateTime initiatedAt;
  final DateTime? authorizedAt;
  final DateTime? capturedAt;
  final DateTime? failedAt;
  final String? failureReason;
  final bool verified;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentModel({
    required this.paymentId,
    required this.bookingId,
    required this.userId,
    required this.propertyId,
    this.gateway = 'MockGateway',
    this.gatewayOrderId,
    this.gatewayPaymentId,
    this.gatewaySignature,
    required this.amount,
    this.currency = 'INR',
    this.paymentMethod = 'UPI',
    this.paymentType = 'bookingPayment',
    this.status = 'pending',
    DateTime? initiatedAt,
    this.authorizedAt,
    this.capturedAt,
    this.failedAt,
    this.failureReason,
    this.verified = false,
    this.verifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : initiatedAt = initiatedAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory PaymentModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    DateTime? parseNullableDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return PaymentModel(
      paymentId: docId.isNotEmpty ? docId : (map['paymentId'] ?? ''),
      bookingId: map['bookingId'] ?? '',
      userId: map['userId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      gateway: map['gateway'] ?? 'MockGateway',
      gatewayOrderId: map['gatewayOrderId'],
      gatewayPaymentId: map['gatewayPaymentId'],
      gatewaySignature: map['gatewaySignature'],
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] ?? 'INR',
      paymentMethod: map['paymentMethod'] ?? 'UPI',
      paymentType: map['paymentType'] ?? 'bookingPayment',
      status: map['status'] ?? 'pending',
      initiatedAt: parseDate(map['initiatedAt']),
      authorizedAt: parseNullableDate(map['authorizedAt']),
      capturedAt: parseNullableDate(map['capturedAt']),
      failedAt: parseNullableDate(map['failedAt']),
      failureReason: map['failureReason'],
      verified: map['verified'] ?? false,
      verifiedAt: parseNullableDate(map['verifiedAt']),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'bookingId': bookingId,
      'userId': userId,
      'propertyId': propertyId,
      'gateway': gateway,
      'gatewayOrderId': gatewayOrderId,
      'gatewayPaymentId': gatewayPaymentId,
      'gatewaySignature': gatewaySignature,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'paymentType': paymentType,
      'status': status,
      'initiatedAt': Timestamp.fromDate(initiatedAt),
      'authorizedAt': authorizedAt != null ? Timestamp.fromDate(authorizedAt!) : null,
      'capturedAt': capturedAt != null ? Timestamp.fromDate(capturedAt!) : null,
      'failedAt': failedAt != null ? Timestamp.fromDate(failedAt!) : null,
      'failureReason': failureReason,
      'verified': verified,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
