import 'package:cloud_firestore/cloud_firestore.dart';

class CouponUsageModel {
  final String usageId;
  final String couponId;
  final String couponCode;
  final String userId;
  final String bookingId;
  final double discountAmount;
  final DateTime usedAt;

  CouponUsageModel({
    required this.usageId,
    required this.couponId,
    required this.couponCode,
    required this.userId,
    required this.bookingId,
    required this.discountAmount,
    DateTime? usedAt,
  }) : usedAt = usedAt ?? DateTime.now();

  factory CouponUsageModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return CouponUsageModel(
      usageId: docId.isNotEmpty ? docId : (map['usageId'] ?? ''),
      couponId: map['couponId'] ?? '',
      couponCode: map['couponCode'] ?? '',
      userId: map['userId'] ?? '',
      bookingId: map['bookingId'] ?? '',
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      usedAt: parseDate(map['usedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usageId': usageId,
      'couponId': couponId,
      'couponCode': couponCode,
      'userId': userId,
      'bookingId': bookingId,
      'discountAmount': discountAmount,
      'usedAt': Timestamp.fromDate(usedAt),
    };
  }
}
