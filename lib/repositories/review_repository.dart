import '../core/errors/failure.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewRepository {
  final ReviewService _service;

  ReviewRepository({ReviewService? service}) : _service = service ?? ReviewService();

  Future<void> submitReview(ReviewModel review) async {
    try {
      await _service.submitReview(review);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> updateReviewStatus(String reviewId, String status, {required String performedBy}) async {
    try {
      await _service.updateReviewStatus(reviewId, status, performedBy: performedBy);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
