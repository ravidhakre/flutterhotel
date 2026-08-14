import '../core/errors/failure.dart';
import '../models/payment_model.dart';
import '../models/payment_order_model.dart';
import '../services/payment_service.dart';

class PaymentRepository {
  final PaymentService _service;

  PaymentRepository({PaymentService? service}) : _service = service ?? PaymentService();

  Future<PaymentOrderModel> createPaymentOrder(String bookingId) async {
    try {
      return await _service.createPaymentOrder(bookingId);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<PaymentModel> completePayment({
    required String bookingId,
    required String gatewayOrderId,
    required String gatewayPaymentId,
    required String gatewaySignature,
    required double amount,
  }) async {
    try {
      return await _service.completePayment(
        bookingId: bookingId,
        gatewayOrderId: gatewayOrderId,
        gatewayPaymentId: gatewayPaymentId,
        gatewaySignature: gatewaySignature,
        amount: amount,
      );
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
