import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/failure.dart';
import '../firebase/firebase_services.dart';
import '../models/payment_event_model.dart';

class PaymentEventRepository {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;

  Future<List<PaymentEventModel>> getPaymentEvents(String bookingId) async {
    try {
      final snapshot = await _firestore
          .collection('paymentEvents')
          .where('bookingId', isEqualTo: bookingId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((d) => PaymentEventModel.fromMap(d.data(), d.id)).toList();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
