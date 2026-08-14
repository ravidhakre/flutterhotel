import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  final String offerId;
  final String name;
  final String description;
  final String offerType; // percentageDiscount, fixedDiscount, freeNight, earlyBird, lastMinute, weekendOffer, weekdayOffer, seasonalOffer, longStay, newUserOffer
  final String discountType; // percentage, fixed
  final double discountValue;
  final List<String> propertyIds;
  final List<String> roomTypeIds;
  final DateTime startDate;
  final DateTime endDate;
  final int minimumNights;
  final int maximumNights;
  final double minimumBookingAmount;
  final bool newUserOnly;
  final bool existingUserOnly;
  final bool weekendOnly;
  final bool weekdayOnly;
  final int usageLimit;
  final int perUserLimit;
  final int priority;
  final bool allowStacking;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  OfferModel({
    required this.offerId,
    required this.name,
    required this.description,
    this.offerType = 'percentageDiscount',
    this.discountType = 'percentage',
    required this.discountValue,
    this.propertyIds = const [],
    this.roomTypeIds = const [],
    required this.startDate,
    required this.endDate,
    this.minimumNights = 1,
    this.maximumNights = 30,
    this.minimumBookingAmount = 0.0,
    this.newUserOnly = false,
    this.existingUserOnly = false,
    this.weekendOnly = false,
    this.weekdayOnly = false,
    this.usageLimit = 1000,
    this.perUserLimit = 1,
    this.priority = 1,
    this.allowStacking = false,
    this.status = 'active',
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.createdBy,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory OfferModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return OfferModel(
      offerId: docId.isNotEmpty ? docId : (map['offerId'] ?? ''),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      offerType: map['offerType'] ?? 'percentageDiscount',
      discountType: map['discountType'] ?? 'percentage',
      discountValue: (map['discountValue'] as num?)?.toDouble() ?? 0.0,
      propertyIds: List<String>.from(map['propertyIds'] ?? []),
      roomTypeIds: List<String>.from(map['roomTypeIds'] ?? []),
      startDate: parseDate(map['startDate']),
      endDate: parseDate(map['endDate']),
      minimumNights: (map['minimumNights'] as num?)?.toInt() ?? 1,
      maximumNights: (map['maximumNights'] as num?)?.toInt() ?? 30,
      minimumBookingAmount: (map['minimumBookingAmount'] as num?)?.toDouble() ?? 0.0,
      newUserOnly: map['newUserOnly'] ?? false,
      existingUserOnly: map['existingUserOnly'] ?? false,
      weekendOnly: map['weekendOnly'] ?? false,
      weekdayOnly: map['weekdayOnly'] ?? false,
      usageLimit: (map['usageLimit'] as num?)?.toInt() ?? 1000,
      perUserLimit: (map['perUserLimit'] as num?)?.toInt() ?? 1,
      priority: (map['priority'] as num?)?.toInt() ?? 1,
      allowStacking: map['allowStacking'] ?? false,
      status: map['status'] ?? 'active',
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
      createdBy: map['createdBy'] ?? 'Admin',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'offerId': offerId,
      'name': name,
      'description': description,
      'offerType': offerType,
      'discountType': discountType,
      'discountValue': discountValue,
      'propertyIds': propertyIds,
      'roomTypeIds': roomTypeIds,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'minimumNights': minimumNights,
      'maximumNights': maximumNights,
      'minimumBookingAmount': minimumBookingAmount,
      'newUserOnly': newUserOnly,
      'existingUserOnly': existingUserOnly,
      'weekendOnly': weekendOnly,
      'weekdayOnly': weekdayOnly,
      'usageLimit': usageLimit,
      'perUserLimit': perUserLimit,
      'priority': priority,
      'allowStacking': allowStacking,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
    };
  }
}
