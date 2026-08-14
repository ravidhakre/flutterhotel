import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceBlockModel {
  final String blockId;
  final String roomId;
  final String propertyId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String? notes;
  final String createdBy;
  final String status;
  final DateTime createdAt;

  MaintenanceBlockModel({
    required this.blockId,
    required this.roomId,
    required this.propertyId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.notes,
    required this.createdBy,
    this.status = 'active',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MaintenanceBlockModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return MaintenanceBlockModel(
      blockId: docId.isNotEmpty ? docId : (map['blockId'] ?? ''),
      roomId: map['roomId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      startDate: parseDate(map['startDate']),
      endDate: parseDate(map['endDate']),
      reason: map['reason'] ?? '',
      notes: map['notes'],
      createdBy: map['createdBy'] ?? 'Admin',
      status: map['status'] ?? 'active',
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'blockId': blockId,
      'roomId': roomId,
      'propertyId': propertyId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'reason': reason,
      'notes': notes,
      'createdBy': createdBy,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
