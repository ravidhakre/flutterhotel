import 'package:cloud_firestore/cloud_firestore.dart';

class RefundModel {
  final String refundId;
  final String bookingId;
  final String paymentId;
  final String userId;
  final String propertyId;
  final double requestedAmount;
  final double approvedAmount;
  final double processedAmount;
  final String reason;
  final String refundType; // full, partial
  final String status; // requested, approved, processing, success, failed, cancelled, partiallyRefunded
  final String requestedBy;
  final String? approvedBy;
  final String? processedBy;
  final String? gatewayRefundId;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? processedAt;

  RefundModel({
    required this.refundId,
    required this.bookingId,
    required this.paymentId,
    required this.userId,
    required this.propertyId,
    required this.requestedAmount,
    this.approvedAmount = 0.0,
    this.processedAmount = 0.0,
    required this.reason,
    this.refundType = 'full',
    this.status = 'requested',
    required this.requestedBy,
    this.approvedBy,
    this.processedBy,
    this.gatewayRefundId,
    DateTime? createdAt,
    this.approvedAt,
    this.processedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory RefundModel.fromMap(Map<String, dynamic> map, String docId) {
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

    return RefundModel(
      refundId: docId.isNotEmpty ? docId : (map['refundId'] ?? ''),
      bookingId: map['bookingId'] ?? '',
      paymentId: map['paymentId'] ?? '',
      userId: map['userId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      requestedAmount: (map['requestedAmount'] as num?)?.toDouble() ?? 0.0,
      approvedAmount: (map['approvedAmount'] as num?)?.toDouble() ?? 0.0,
      processedAmount: (map['processedAmount'] as num?)?.toDouble() ?? 0.0,
      reason: map['reason'] ?? '',
      refundType: map['refundType'] ?? 'full',
      status: map['status'] ?? 'requested',
      requestedBy: map['requestedBy'] ?? 'Guest',
      approvedBy: map['approvedBy'],
      processedBy: map['processedBy'],
      gatewayRefundId: map['gatewayRefundId'],
      createdAt: parseDate(map['createdAt']),
      approvedAt: parseNullableDate(map['approvedAt']),
      processedAt: parseNullableDate(map['processedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'refundId': refundId,
      'bookingId': bookingId,
      'paymentId': paymentId,
      'userId': userId,
      'propertyId': propertyId,
      'requestedAmount': requestedAmount,
      'approvedAmount': approvedAmount,
      'processedAmount': processedAmount,
      'reason': reason,
      'refundType': refundType,
      'status': status,
      'requestedBy': requestedBy,
      'approvedBy': approvedBy,
      'processedBy': processedBy,
      'gatewayRefundId': gatewayRefundId,
      'createdAt': Timestamp.fromDate(createdAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'processedAt': processedAt != null ? Timestamp.fromDate(processedAt!) : null,
    };
  }
}
