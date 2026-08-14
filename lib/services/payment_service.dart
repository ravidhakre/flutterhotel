import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/payment_record_model.dart';
import 'audit_service.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;
  final AuditService _auditService = AuditService();

  /// Record front desk payment collection (Cash, Card, UPI, etc.)
  Future<void> recordPayment(PaymentRecordModel payment) async {
    try {
      final docRef = _firestore.collection('payments').doc();
      final newPayment = PaymentRecordModel(
        paymentId: docRef.id,
        bookingId: payment.bookingId,
        amount: payment.amount,
        method: payment.method,
        transactionId: payment.transactionId,
        status: 'success',
        collectedBy: payment.collectedBy,
      );

      await docRef.set(newPayment.toMap());

      // Update paidAmount & remainingAmount on booking doc
      final bookingRef = _firestore.collection('bookings').doc(payment.bookingId);
      final bookingDoc = await bookingRef.get();
      if (bookingDoc.exists) {
        final currentPaid = (bookingDoc.data()?['paidAmount'] as num?)?.toDouble() ?? 0.0;
        final total = (bookingDoc.data()?['totalAmount'] as num?)?.toDouble() ?? 0.0;
        final newPaid = currentPaid + payment.amount;
        final newRemaining = (total - newPaid) > 0 ? (total - newPaid) : 0.0;

        await bookingRef.update({
          'paidAmount': newPaid,
          'remainingAmount': newRemaining,
          'paymentStatus': newRemaining == 0 ? 'success' : 'partiallyPaid',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await _auditService.logAction(
        action: 'PAYMENT_COLLECTED',
        module: 'FRONT_DESK',
        recordId: docRef.id,
        performedBy: payment.collectedBy,
        newData: newPayment.toMap(),
      );
    } catch (e) {
      throw DatabaseException('Failed to record payment: $e');
    }
  }

  /// Get payment history for a booking
  Future<List<PaymentRecordModel>> getBookingPayments(String bookingId) async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('bookingId', isEqualTo: bookingId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => PaymentRecordModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch payments: $e');
    }
  }
}
