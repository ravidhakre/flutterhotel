import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/booking_model.dart';
import '../models/invoice_model.dart';
import 'audit_service.dart';

class InvoiceService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;
  final AuditService _auditService = AuditService();

  /// Generate Invoice for booking at checkout
  Future<InvoiceModel> generateInvoice(BookingModel booking, {required String issuedBy}) async {
    try {
      final docRef = _firestore.collection('invoices').doc();
      final invoiceNum = InvoiceModel.generateInvoiceNumber();

      final items = [
        {
          'description': 'Room Accommodation (${booking.nights} nights)',
          'amount': booking.roomPrice,
        },
        if (booking.extraGuestCharges > 0)
          {
            'description': 'Extra Guest Charges',
            'amount': booking.extraGuestCharges,
          },
        if (booking.addonCharges > 0)
          {
            'description': 'Incidental & Extra Charges',
            'amount': booking.addonCharges,
          },
      ];

      final invoice = InvoiceModel(
        invoiceId: docRef.id,
        bookingId: booking.bookingId,
        propertyId: booking.propertyId,
        guestId: booking.userId,
        invoiceNumber: invoiceNum,
        items: items,
        subtotal: booking.roomPrice + booking.extraGuestCharges + booking.addonCharges,
        discount: booking.discount,
        tax: booking.tax,
        total: booking.totalAmount,
        paid: booking.paidAmount,
        balance: booking.remainingAmount,
        status: booking.remainingAmount == 0 ? 'paid' : 'partiallyPaid',
      );

      await docRef.set(invoice.toMap());

      await _auditService.logAction(
        action: 'INVOICE_GENERATED',
        module: 'FRONT_DESK',
        recordId: docRef.id,
        propertyId: booking.propertyId,
        performedBy: issuedBy,
        newData: invoice.toMap(),
      );

      return invoice;
    } catch (e) {
      throw DatabaseException('Failed to generate invoice: $e');
    }
  }

  /// Get Invoice for a booking
  Future<InvoiceModel?> getBookingInvoice(String bookingId) async {
    try {
      final snapshot = await _firestore
          .collection('invoices')
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return InvoiceModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
    } catch (e) {
      throw DatabaseException('Failed to fetch invoice: $e');
    }
  }
}
