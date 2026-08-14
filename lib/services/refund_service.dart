import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/refund_model.dart';
import 'audit_service.dart';
import 'notification_service.dart';

class RefundService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;
  final AuditService _auditService = AuditService();
  final NotificationService _notificationService = NotificationService();

  /// Request or Process Refund
  Future<RefundModel> processRefund({
    required String bookingId,
    required String paymentId,
    required double amount,
    required String reason,
    required String performedBy,
  }) async {
    try {
      final bDoc = await _firestore.collection(FirebaseConstants.bookingsCollection).doc(bookingId).get();
      if (!bDoc.exists) throw DatabaseException('Booking not found');

      final paidAmount = (bDoc.data()?['paidAmount'] as num?)?.toDouble() ?? 0.0;
      final propertyId = bDoc.data()?['propertyId'] ?? '';
      final userId = bDoc.data()?['userId'] ?? '';

      // Check refundable balance
      final existingRefunds = await _firestore
          .collection('refunds')
          .where('bookingId', isEqualTo: bookingId)
          .where('status', isEqualTo: 'success')
          .get();

      double alreadyRefunded = 0.0;
      for (final doc in existingRefunds.docs) {
        alreadyRefunded += (doc.data()['processedAmount'] as num?)?.toDouble() ?? 0.0;
      }

      final maxRefundable = paidAmount - alreadyRefunded;
      if (amount > maxRefundable) {
        throw DatabaseException(
          'Requested refund of ₹$amount exceeds refundable balance of ₹$maxRefundable.',
          code: 'REFUND_EXCEEDS_BALANCE',
        );
      }

      final docRef = _firestore.collection('refunds').doc();
      final refundId = docRef.id;
      final gatewayRefundId = "rfnd_mock_${DateTime.now().millisecondsSinceEpoch}";

      final refund = RefundModel(
        refundId: refundId,
        bookingId: bookingId,
        paymentId: paymentId,
        userId: userId,
        propertyId: propertyId,
        requestedAmount: amount,
        approvedAmount: amount,
        processedAmount: amount,
        reason: reason,
        refundType: amount == paidAmount ? 'full' : 'partial',
        status: 'success',
        requestedBy: performedBy,
        approvedBy: performedBy,
        processedBy: performedBy,
        gatewayRefundId: gatewayRefundId,
        approvedAt: DateTime.now(),
        processedAt: DateTime.now(),
      );

      await docRef.set(refund.toMap());

      // Update Booking Refund Status
      final isFull = (alreadyRefunded + amount) >= paidAmount;
      await _firestore.collection(FirebaseConstants.bookingsCollection).doc(bookingId).update({
        'cancellationStatus': isFull ? 'refunded' : 'partiallyRefunded',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _auditService.logAction(
        action: 'REFUND_PROCESSED',
        module: 'PAYMENTS',
        recordId: refundId,
        propertyId: propertyId,
        performedBy: performedBy,
        newData: refund.toMap(),
      );

      await _notificationService.sendBookingNotification(
        recipientUid: userId,
        title: 'Refund Processed',
        body: 'A refund of ₹${amount.toStringAsFixed(0)} has been processed for Booking #$bookingId.',
      );

      return refund;
    } catch (e) {
      throw DatabaseException('Failed to process refund: $e');
    }
  }
}
