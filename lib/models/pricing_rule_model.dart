import 'package:cloud_firestore/cloud_firestore.dart';

class PricingRuleModel {
  final String pricingRuleId;
  final String propertyId;
  final List<String> roomTypeIds;
  final String ruleType; // fixedPrice, percentageIncrease, percentageDecrease, fixedIncrease, fixedDecrease
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final List<int> daysOfWeek; // 1 = Mon, ..., 7 = Sun
  final double adjustmentValue;
  final int priority;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  PricingRuleModel({
    required this.pricingRuleId,
    required this.propertyId,
    this.roomTypeIds = const [],
    required this.ruleType,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
    required this.adjustmentValue,
    this.priority = 1,
    this.status = 'active',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory PricingRuleModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return PricingRuleModel(
      pricingRuleId: docId.isNotEmpty ? docId : (map['pricingRuleId'] ?? ''),
      propertyId: map['propertyId'] ?? '',
      roomTypeIds: List<String>.from(map['roomTypeIds'] ?? []),
      ruleType: map['ruleType'] ?? 'fixedPrice',
      name: map['name'] ?? '',
      startDate: parseDate(map['startDate']),
      endDate: parseDate(map['endDate']),
      daysOfWeek: List<int>.from(map['daysOfWeek'] ?? [1, 2, 3, 4, 5, 6, 7]),
      adjustmentValue: (map['adjustmentValue'] as num?)?.toDouble() ?? 0.0,
      priority: (map['priority'] as num?)?.toInt() ?? 1,
      status: map['status'] ?? 'active',
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pricingRuleId': pricingRuleId,
      'propertyId': propertyId,
      'roomTypeIds': roomTypeIds,
      'ruleType': ruleType,
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'daysOfWeek': daysOfWeek,
      'adjustmentValue': adjustmentValue,
      'priority': priority,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
