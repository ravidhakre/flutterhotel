import 'package:cloud_firestore/cloud_firestore.dart';

class CMSBannerModel {
  final String bannerId;
  final String title;
  final String subtitle;
  final String image;
  final String buttonText;
  final String targetType;
  final String? targetId;
  final DateTime startDate;
  final DateTime endDate;
  final int priority;
  final String status;
  final DateTime createdAt;

  CMSBannerModel({
    required this.bannerId,
    required this.title,
    required this.subtitle,
    required this.image,
    this.buttonText = 'EXPLORE NOW',
    this.targetType = 'property',
    this.targetId,
    required this.startDate,
    required this.endDate,
    this.priority = 1,
    this.status = 'active',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CMSBannerModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return CMSBannerModel(
      bannerId: docId.isNotEmpty ? docId : (map['bannerId'] ?? ''),
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      image: map['image'] ?? '',
      buttonText: map['buttonText'] ?? 'EXPLORE NOW',
      targetType: map['targetType'] ?? 'property',
      targetId: map['targetId'],
      startDate: parseDate(map['startDate']),
      endDate: parseDate(map['endDate']),
      priority: (map['priority'] as num?)?.toInt() ?? 1,
      status: map['status'] ?? 'active',
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bannerId': bannerId,
      'title': title,
      'subtitle': subtitle,
      'image': image,
      'buttonText': buttonText,
      'targetType': targetType,
      'targetId': targetId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'priority': priority,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
