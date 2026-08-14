import 'package:cloud_firestore/cloud_firestore.dart';

class UserDeviceModel {
  final String deviceId;
  final String userId;
  final String deviceToken;
  final String platform;
  final String appVersion;
  final DateTime lastActiveAt;
  final DateTime createdAt;

  UserDeviceModel({
    required this.deviceId,
    required this.userId,
    required this.deviceToken,
    this.platform = 'web',
    this.appVersion = '1.0.0',
    DateTime? lastActiveAt,
    DateTime? createdAt,
  })  : lastActiveAt = lastActiveAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  factory UserDeviceModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return UserDeviceModel(
      deviceId: docId.isNotEmpty ? docId : (map['deviceId'] ?? ''),
      userId: map['userId'] ?? '',
      deviceToken: map['deviceToken'] ?? '',
      platform: map['platform'] ?? 'web',
      appVersion: map['appVersion'] ?? '1.0.0',
      lastActiveAt: parseDate(map['lastActiveAt']),
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'userId': userId,
      'deviceToken': deviceToken,
      'platform': platform,
      'appVersion': appVersion,
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
