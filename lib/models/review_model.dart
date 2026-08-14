import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final String bookingId;
  final String userId;
  final String propertyId;
  final String roomTypeId;
  final int rating; // 1 to 5 stars
  final String reviewText;
  final String status; // pending, approved, rejected, hidden
  final String? replyText;
  final String? repliedBy;
  final DateTime? repliedAt;
  final DateTime createdAt;

  ReviewModel({
    required this.reviewId,
    required this.bookingId,
    required this.userId,
    required this.propertyId,
    required this.roomTypeId,
    required this.rating,
    required this.reviewText,
    this.status = 'pending',
    this.replyText,
    this.repliedBy,
    this.repliedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ReviewModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    DateTime? parseNullableDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return ReviewModel(
      reviewId: docId.isNotEmpty ? docId : (map['reviewId'] ?? ''),
      bookingId: map['bookingId'] ?? '',
      userId: map['userId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      roomTypeId: map['roomTypeId'] ?? '',
      rating: (map['rating'] as num?)?.toInt() ?? 5,
      reviewText: map['reviewText'] ?? '',
      status: map['status'] ?? 'pending',
      replyText: map['replyText'],
      repliedBy: map['repliedBy'],
      repliedAt: parseNullableDate(map['repliedAt']),
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'bookingId': bookingId,
      'userId': userId,
      'propertyId': propertyId,
      'roomTypeId': roomTypeId,
      'rating': rating,
      'reviewText': reviewText,
      'status': status,
      'replyText': replyText,
      'repliedBy': repliedBy,
      'repliedAt': repliedAt != null ? Timestamp.fromDate(repliedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
