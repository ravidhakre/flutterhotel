import '../core/errors/failure.dart';
import '../services/reservation_service.dart';

class ReservationRepository {
  final ReservationService _service;

  ReservationRepository({ReservationService? service}) : _service = service ?? ReservationService();

  Future<void> releaseAllocations(String bookingId) async {
    try {
      await _service.releaseAllocations(bookingId);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
