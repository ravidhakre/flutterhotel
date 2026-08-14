import 'package:cloud_firestore/cloud_firestore.dart';

class CMSFAQModel {
  final String faqId;
  final String question;
  final String answer;
  final String category;
  final int priority;
  final String status;
  final DateTime createdAt;

  CMSFAQModel({
    required this.faqId,
    required this.question,
    required this.answer,
    this.category = 'General',
    this.priority = 1,
    this.status = 'active',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CMSFAQModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return CMSFAQModel(
      faqId: docId.isNotEmpty ? docId : (map['faqId'] ?? ''),
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      category: map['category'] ?? 'General',
      priority: (map['priority'] as num?)?.toInt() ?? 1,
      status: map['status'] ?? 'active',
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'faqId': faqId,
      'question': question,
      'answer': answer,
      'category': category,
      'priority': priority,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
