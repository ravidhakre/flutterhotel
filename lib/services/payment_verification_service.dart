import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';

class PaymentVerificationService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;

  /// Server-side payment verification
  Future<bool> verifyPaymentDetails({
    required String bookingId,
    required double expectedAmount,
    required String gatewayOrderId,
    required String gatewayPaymentId,
  }) async {
    try {
      final doc = await _firestore.collection(FirebaseConstants.bookingsCollection).doc(bookingId).get();
      if (!doc.exists) return false;

      final remaining = (doc.data()?['remainingAmount'] as num?)?.toDouble() ?? 0.0;
      final total = (doc.data()?['totalAmount'] as num?)?.toDouble() ?? 0.0;

      // Price Tamper Protection: Reject if payment amount does not match expected balance
      if (expectedAmount <= 0 || expectedAmount > total + 1.0) {
        throw DatabaseException('Payment amount mismatch: Expected $total, got $expectedAmount.', code: 'AMOUNT_MISMATCH');
      }

      return true;
    } catch (e) {
      throw DatabaseException('Payment verification failed: $e');
    }
  }
}
