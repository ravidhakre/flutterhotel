import '../core/errors/failure.dart';
import '../models/payment_record_model.dart';
import '../services/payment_service.dart';

class PaymentRepository {
  final PaymentService _service;

  PaymentRepository({PaymentService? service}) : _service = service ?? PaymentService();

  Future<void> recordPayment(PaymentRecordModel payment) async {
    try {
      await _service.recordPayment(payment);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<List<PaymentRecordModel>> getBookingPayments(String bookingId) async {
    try {
      return await _service.getBookingPayments(bookingId);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
