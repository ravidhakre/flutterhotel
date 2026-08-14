import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;

  /// Create new booking record
  Future<void> createBooking(BookingModel booking) async {
    try {
      await _firestore
          .collection(FirebaseConstants.bookingsCollection)
          .doc(booking.bookingId)
          .set(booking.toMap());
    } catch (e) {
      throw DatabaseException('Failed to create booking: $e');
    }
  }

  /// Get bookings for a specific guest user
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.bookingsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => BookingModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch user bookings: $e');
    }
  }

  /// Get bookings for a specific property (Admin access)
  Future<List<BookingModel>> getPropertyBookings(String propertyId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.bookingsCollection)
          .where('propertyId', isEqualTo: propertyId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => BookingModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch property bookings: $e');
    }
  }

  /// Update booking status (Admin / System)
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore
          .collection(FirebaseConstants.bookingsCollection)
          .doc(bookingId)
          .update({
        'bookingStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DatabaseException('Failed to update booking status: $e');
    }
  }
}
