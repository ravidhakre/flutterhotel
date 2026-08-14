import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLogModel {
  final String logId;
  final String action;
  final String module;
  final String recordId;
  final String? propertyId;
  final String performedBy;
  final DateTime timestamp;
  final Map<String, dynamic>? oldData;
  final Map<String, dynamic>? newData;

  AuditLogModel({
    required this.logId,
    required this.action,
    required this.module,
    required this.recordId,
    this.propertyId,
    required this.performedBy,
    DateTime? timestamp,
    this.oldData,
    this.newData,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AuditLogModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return AuditLogModel(
      logId: docId.isNotEmpty ? docId : (map['logId'] ?? ''),
      action: map['action'] ?? '',
      module: map['module'] ?? '',
      recordId: map['recordId'] ?? '',
      propertyId: map['propertyId'],
      performedBy: map['performedBy'] ?? 'System',
      timestamp: parseDate(map['timestamp']),
      oldData: map['oldData'] != null ? Map<String, dynamic>.from(map['oldData']) : null,
      newData: map['newData'] != null ? Map<String, dynamic>.from(map['newData']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'logId': logId,
      'action': action,
      'module': module,
      'recordId': recordId,
      'propertyId': propertyId,
      'performedBy': performedBy,
      'timestamp': Timestamp.fromDate(timestamp),
      'oldData': oldData,
      'newData': newData,
    };
  }
}
