import '../core/errors/failure.dart';
import '../services/front_desk_service.dart';

class FrontDeskRepository {
  final FrontDeskService _service;

  FrontDeskRepository({FrontDeskService? service}) : _service = service ?? FrontDeskService();

  Future<void> checkInGuest({required String bookingId, required String performedBy}) async {
    try {
      await _service.checkInGuest(bookingId: bookingId, performedBy: performedBy);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> checkOutGuest({required String bookingId, required String performedBy}) async {
    try {
      await _service.checkOutGuest(bookingId: bookingId, performedBy: performedBy);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> moveRoom({
    required String bookingId,
    required String newRoomId,
    required String reason,
    required String performedBy,
  }) async {
    try {
      await _service.moveRoom(bookingId: bookingId, newRoomId: newRoomId, reason: reason, performedBy: performedBy);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
