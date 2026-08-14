import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../firebase/firebase_services.dart';

class ReportExportService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;

  /// Generate CSV Report for Bookings
  Future<String> generateBookingsCSV(String propertyId) async {
    final buf = StringBuffer();
    buf.writeln('Booking ID,Guest,Property,Check-In,Check-Out,Nights,Total Amount,Paid Amount,Status,Created At');

    Query query = _firestore.collection(FirebaseConstants.bookingsCollection);
    if (propertyId != 'All') {
      query = query.where('propertyId', isEqualTo: propertyId);
    }

    final snapshot = await query.get();

    for (final doc in snapshot.docs) {
      final d = doc.data() as Map<String, dynamic>;
      buf.writeln(
        '${doc.id},${d['guestName'] ?? 'Guest'},${d['propertyId']},${d['checkIn']},${d['checkOut']},${d['nights']},${d['totalAmount']},${d['paidAmount']},${d['bookingStatus']},${d['createdAt']}',
      );
    }

    return buf.toString();
  }

  /// Generate CSV Report for Payments
  Future<String> generatePaymentsCSV(String propertyId) async {
    final buf = StringBuffer();
    buf.writeln('Payment ID,Booking ID,Amount,Method,Gateway,Verified,Status,Created At');

    Query query = _firestore.collection('payments');
    if (propertyId != 'All') {
      query = query.where('propertyId', isEqualTo: propertyId);
    }

    final snapshot = await query.get();

    for (final doc in snapshot.docs) {
      final d = doc.data() as Map<String, dynamic>;
      buf.writeln(
        '${doc.id},${d['bookingId']},${d['amount']},${d['paymentMethod']},${d['gateway']},${d['verified']},${d['status']},${d['createdAt']}',
      );
    }

    return buf.toString();
  }
}
