import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase/firebase_services.dart';
import '../models/booking_event_model.dart';

class BookingEventService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;

  /// Log booking event timeline entry
  Future<void> logEvent({
    required String bookingId,
    required String eventType,
    required String description,
    required String performedBy,
    required String performedByRole,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final docRef = _firestore.collection('bookingEvents').doc();
      final event = BookingEventModel(
        eventId: docRef.id,
        bookingId: bookingId,
        eventType: eventType,
        description: description,
        performedBy: performedBy,
        performedByRole: performedByRole,
        metadata: metadata,
      );
      await docRef.set(event.toMap());
    } catch (_) {}
  }

  /// Get timeline events for a booking
  Future<List<BookingEventModel>> getBookingTimeline(String bookingId) async {
    try {
      final snapshot = await _firestore
          .collection('bookingEvents')
          .where('bookingId', isEqualTo: bookingId)
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs.map((doc) => BookingEventModel.fromMap(doc.data(), doc.id)).toList();
    } catch (_) {
      return [];
    }
  }
}
