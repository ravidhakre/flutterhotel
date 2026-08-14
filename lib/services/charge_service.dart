import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/booking_charge_model.dart';
import 'audit_service.dart';

class ChargeService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;
  final AuditService _auditService = AuditService();

  /// Add an extra charge to a booking
  Future<void> addCharge(BookingChargeModel charge) async {
    try {
      final docRef = _firestore.collection('bookingCharges').doc();
      final newCharge = BookingChargeModel(
        chargeId: docRef.id,
        bookingId: charge.bookingId,
        propertyId: charge.propertyId,
        name: charge.name,
        category: charge.category,
        quantity: charge.quantity,
        unitPrice: charge.unitPrice,
        tax: charge.tax,
        total: charge.total,
        addedBy: charge.addedBy,
      );

      await docRef.set(newCharge.toMap());

      // Update aggregate addon charges on booking doc
      final bookingRef = _firestore.collection('bookings').doc(charge.bookingId);
      await bookingRef.update({
        'addonCharges': FieldValue.increment(charge.total),
        'totalAmount': FieldValue.increment(charge.total),
        'remainingAmount': FieldValue.increment(charge.total),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _auditService.logAction(
        action: 'CHARGE_ADDED',
        module: 'FRONT_DESK',
        recordId: docRef.id,
        propertyId: charge.propertyId,
        performedBy: charge.addedBy,
        newData: newCharge.toMap(),
      );
    } catch (e) {
      throw DatabaseException('Failed to add charge: $e');
    }
  }

  /// Get all extra charges for a booking
  Future<List<BookingChargeModel>> getBookingCharges(String bookingId) async {
    try {
      final snapshot = await _firestore
          .collection('bookingCharges')
          .where('bookingId', isEqualTo: bookingId)
          .get();

      return snapshot.docs.map((doc) => BookingChargeModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch booking charges: $e');
    }
  }
}
