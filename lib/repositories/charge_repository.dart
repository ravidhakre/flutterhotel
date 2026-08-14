import '../core/errors/failure.dart';
import '../models/booking_charge_model.dart';
import '../services/charge_service.dart';

class ChargeRepository {
  final ChargeService _service;

  ChargeRepository({ChargeService? service}) : _service = service ?? ChargeService();

  Future<void> addCharge(BookingChargeModel charge) async {
    try {
      await _service.addCharge(charge);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<List<BookingChargeModel>> getBookingCharges(String bookingId) async {
    try {
      return await _service.getBookingCharges(bookingId);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
