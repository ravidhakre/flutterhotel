import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String couponId;
  final String code;
  final String description;
  final String discountType; // percentage, fixed
  final double discountValue;
  final double minimumBookingAmount;
  final double maximumDiscount;
  final List<String> propertyIds;
  final List<String> roomTypeIds;
  final DateTime startDate;
  final DateTime endDate;
  final int minimumNights;
  final int maximumNights;
  final bool newUserOnly;
  final bool existingUserOnly;
  final int usageLimit;
  final int perUserLimit;
  final int usedCount;
  final bool allowStacking;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  CouponModel({
    required this.couponId,
    required String code,
    required this.description,
    this.discountType = 'percentage',
    required this.discountValue,
    this.minimumBookingAmount = 0.0,
    this.maximumDiscount = 999999.0,
    this.propertyIds = const [],
    this.roomTypeIds = const [],
    required this.startDate,
    required this.endDate,
    this.minimumNights = 1,
    this.maximumNights = 30,
    this.newUserOnly = false,
    this.existingUserOnly = false,
    this.usageLimit = 1000,
    this.perUserLimit = 1,
    this.usedCount = 0,
    this.allowStacking = false,
    this.status = 'active',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : code = code.trim().toUpperCase(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory CouponModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return CouponModel(
      couponId: docId.isNotEmpty ? docId : (map['couponId'] ?? ''),
      code: (map['code'] ?? '').toString().toUpperCase(),
      description: map['description'] ?? '',
      discountType: map['discountType'] ?? 'percentage',
      discountValue: (map['discountValue'] as num?)?.toDouble() ?? 0.0,
      minimumBookingAmount: (map['minimumBookingAmount'] as num?)?.toDouble() ?? 0.0,
      maximumDiscount: (map['maximumDiscount'] as num?)?.toDouble() ?? 999999.0,
      propertyIds: List<String>.from(map['propertyIds'] ?? []),
      roomTypeIds: List<String>.from(map['roomTypeIds'] ?? []),
      startDate: parseDate(map['startDate']),
      endDate: parseDate(map['endDate']),
      minimumNights: (map['minimumNights'] as num?)?.toInt() ?? 1,
      maximumNights: (map['maximumNights'] as num?)?.toInt() ?? 30,
      newUserOnly: map['newUserOnly'] ?? false,
      existingUserOnly: map['existingUserOnly'] ?? false,
      usageLimit: (map['usageLimit'] as num?)?.toInt() ?? 1000,
      perUserLimit: (map['perUserLimit'] as num?)?.toInt() ?? 1,
      usedCount: (map['usedCount'] as num?)?.toInt() ?? 0,
      allowStacking: map['allowStacking'] ?? false,
      status: map['status'] ?? 'active',
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'couponId': couponId,
      'code': code.toUpperCase(),
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'minimumBookingAmount': minimumBookingAmount,
      'maximumDiscount': maximumDiscount,
      'propertyIds': propertyIds,
      'roomTypeIds': roomTypeIds,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'minimumNights': minimumNights,
      'maximumNights': maximumNights,
      'newUserOnly': newUserOnly,
      'existingUserOnly': existingUserOnly,
      'usageLimit': usageLimit,
      'perUserLimit': perUserLimit,
      'usedCount': usedCount,
      'allowStacking': allowStacking,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
