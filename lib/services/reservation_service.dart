import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/reservation_allocation_model.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;

  /// Allocate night-by-night reservation records
  Future<void> createAllocations(List<ReservationAllocationModel> allocations) async {
    try {
      final batch = _firestore.batch();
      for (final alloc in allocations) {
        final docRef = _firestore.collection('reservationAllocations').doc(alloc.allocationId);
        batch.set(docRef, alloc.toMap());
      }
      await batch.commit();
    } catch (e) {
      throw DatabaseException('Failed to create reservation allocations: $e');
    }
  }

  /// Release allocations for cancelled or expired booking
  Future<void> releaseAllocations(String bookingId) async {
    try {
      final snapshot = await _firestore
          .collection('reservationAllocations')
          .where('bookingId', isEqualTo: bookingId)
          .where('status', whereIn: ['held', 'reserved'])
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'status': 'released',
          'releasedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      throw DatabaseException('Failed to release reservation allocations: $e');
    }
  }
}
