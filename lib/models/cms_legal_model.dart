import 'package:cloud_firestore/cloud_firestore.dart';

class CMSLegalModel {
  final String legalId;
  final String title;
  final int version;
  final String content;
  final String updatedBy;
  final DateTime updatedAt;
  final String status;

  CMSLegalModel({
    required this.legalId,
    required this.title,
    this.version = 1,
    required this.content,
    required this.updatedBy,
    DateTime? updatedAt,
    this.status = 'active',
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory CMSLegalModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return CMSLegalModel(
      legalId: docId.isNotEmpty ? docId : (map['legalId'] ?? ''),
      title: map['title'] ?? 'Terms & Conditions',
      version: (map['version'] as num?)?.toInt() ?? 1,
      content: map['content'] ?? '',
      updatedBy: map['updatedBy'] ?? 'Admin',
      updatedAt: parseDate(map['updatedAt']),
      status: map['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'legalId': legalId,
      'title': title,
      'version': version,
      'content': content,
      'updatedBy': updatedBy,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status,
    };
  }
}
