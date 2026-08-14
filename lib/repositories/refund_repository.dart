import '../core/errors/failure.dart';
import '../models/refund_model.dart';
import '../services/refund_service.dart';

class RefundRepository {
  final RefundService _service;

  RefundRepository({RefundService? service}) : _service = service ?? RefundService();

  Future<RefundModel> processRefund({
    required String bookingId,
    required String paymentId,
    required double amount,
    required String reason,
    required String performedBy,
  }) async {
    try {
      return await _service.processRefund(
        bookingId: bookingId,
        paymentId: paymentId,
        amount: amount,
        reason: reason,
        performedBy: performedBy,
      );
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
