import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase/firebase_services.dart';

class PromotionValidationService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;

  /// Check if user is a first-time guest with zero previous completed/confirmed bookings
  Future<bool> isNewUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .where('bookingStatus', whereIn: ['confirmed', 'checkedIn', 'checkedOut'])
          .limit(1)
          .get();

      return snapshot.docs.isEmpty;
    } catch (_) {
      return false;
    }
  }
}
