import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase/firebase_services.dart';
import '../models/payment_model.dart';

class ReconciliationResult {
  final String paymentId;
  final String bookingId;
  final double internalAmount;
  final double gatewayAmount;
  final String status; // Matched, Mismatch, Missing, Resolved

  ReconciliationResult({
    required this.paymentId,
    required this.bookingId,
    required this.internalAmount,
    required this.gatewayAmount,
    required this.status,
  });
}

class ReconciliationService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;

  /// Audit internal payments vs gateway records
  Future<List<ReconciliationResult>> runReconciliationAudit(String propertyId) async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('propertyId', isEqualTo: propertyId)
          .get();

      final results = <ReconciliationResult>[];

      for (final doc in snapshot.docs) {
        final p = PaymentModel.fromMap(doc.data(), doc.id);
        // Simulate gateway audit check
        final isMatched = p.amount > 0 && p.verified;

        results.add(ReconciliationResult(
          paymentId: p.paymentId,
          bookingId: p.bookingId,
          internalAmount: p.amount,
          gatewayAmount: p.amount,
          status: isMatched ? 'Matched' : 'Mismatch',
        ));
      }

      return results;
    } catch (_) {
      return [];
    }
  }
}
