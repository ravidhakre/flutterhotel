import '../core/errors/failure.dart';
import '../models/booking_model.dart';
import '../models/invoice_model.dart';
import '../services/invoice_service.dart';

class InvoiceRepository {
  final InvoiceService _service;

  InvoiceRepository({InvoiceService? service}) : _service = service ?? InvoiceService();

  Future<InvoiceModel> generateInvoice(BookingModel booking, {required String issuedBy}) async {
    try {
      return await _service.generateInvoice(booking, issuedBy: issuedBy);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<InvoiceModel?> getBookingInvoice(String bookingId) async {
    try {
      return await _service.getBookingInvoice(bookingId);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
