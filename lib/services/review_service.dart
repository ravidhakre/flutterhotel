import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/review_model.dart';
import 'audit_service.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;
  final AuditService _auditService = AuditService();

  /// Create Review (Guest submit after verified completed stay)
  Future<void> submitReview(ReviewModel review) async {
    try {
      // Verification: Check completed booking
      final bDoc = await _firestore.collection(FirebaseConstants.bookingsCollection).doc(review.bookingId).get();
      if (!bDoc.exists) throw DatabaseException('Booking not found');

      final bookingStatus = bDoc.data()?['bookingStatus'];
      if (bookingStatus != 'checkedOut' && bookingStatus != 'confirmed') {
        throw DatabaseException('Only guests with completed stays can submit reviews.', code: 'INELIGIBLE_STAY');
      }

      final docRef = _firestore.collection('reviews').doc();
      final newReview = ReviewModel(
        reviewId: docRef.id,
        bookingId: review.bookingId,
        userId: review.userId,
        propertyId: review.propertyId,
        roomTypeId: review.roomTypeId,
        rating: review.rating,
        reviewText: review.reviewText,
        status: 'pending',
      );

      await docRef.set(newReview.toMap());
    } catch (e) {
      throw DatabaseException('Failed to submit review: $e');
    }
  }

  /// Update Review Moderation Status (Approve / Reject / Hide)
  Future<void> updateReviewStatus(String reviewId, String status, {required String performedBy}) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({'status': status});

      await _auditService.logAction(
        action: 'REVIEW_MODERATED',
        module: 'REVIEWS',
        recordId: reviewId,
        performedBy: performedBy,
        newData: {'status': status},
      );
    } catch (e) {
      throw DatabaseException('Failed to moderate review: $e');
    }
  }

  /// Admin Reply to Guest Review
  Future<void> replyToReview(String reviewId, String replyText, {required String repliedBy}) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({
        'replyText': replyText,
        'repliedBy': repliedBy,
        'repliedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DatabaseException('Failed to reply to review: $e');
    }
  }
}
