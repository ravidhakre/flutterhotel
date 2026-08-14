import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notificationId;
  final String? userId;
  final String? adminId;
  final String? propertyId;
  final String type; // booking, payment, stay, system
  final String title;
  final String body;
  final String referenceType; // booking, payment, refund
  final String referenceId;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.notificationId,
    this.userId,
    this.adminId,
    this.propertyId,
    this.type = 'booking',
    required this.title,
    required this.body,
    required this.referenceType,
    required this.referenceId,
    this.read = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return NotificationModel(
      notificationId: docId.isNotEmpty ? docId : (map['notificationId'] ?? ''),
      userId: map['userId'],
      adminId: map['adminId'],
      propertyId: map['propertyId'],
      type: map['type'] ?? 'booking',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      referenceType: map['referenceType'] ?? 'booking',
      referenceId: map['referenceId'] ?? '',
      read: map['read'] ?? false,
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'adminId': adminId,
      'propertyId': propertyId,
      'type': type,
      'title': title,
      'body': body,
      'referenceType': referenceType,
      'referenceId': referenceId,
      'read': read,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
