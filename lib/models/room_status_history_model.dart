import 'package:cloud_firestore/cloud_firestore.dart';

class RoomStatusHistoryModel {
  final String historyId;
  final String roomId;
  final String propertyId;
  final String oldStatus;
  final String newStatus;
  final String reason;
  final String changedBy;
  final DateTime changedAt;

  RoomStatusHistoryModel({
    required this.historyId,
    required this.roomId,
    required this.propertyId,
    required this.oldStatus,
    required this.newStatus,
    required this.reason,
    required this.changedBy,
    DateTime? changedAt,
  }) : changedAt = changedAt ?? DateTime.now();

  factory RoomStatusHistoryModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return RoomStatusHistoryModel(
      historyId: docId.isNotEmpty ? docId : (map['historyId'] ?? ''),
      roomId: map['roomId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      oldStatus: map['oldStatus'] ?? '',
      newStatus: map['newStatus'] ?? '',
      reason: map['reason'] ?? '',
      changedBy: map['changedBy'] ?? 'Admin',
      changedAt: parseTimestamp(map['changedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'historyId': historyId,
      'roomId': roomId,
      'propertyId': propertyId,
      'oldStatus': oldStatus,
      'newStatus': newStatus,
      'reason': reason,
      'changedBy': changedBy,
      'changedAt': Timestamp.fromDate(changedAt),
    };
  }
}
