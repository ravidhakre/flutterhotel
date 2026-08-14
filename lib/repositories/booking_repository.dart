import '../core/errors/failure.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingRepository {
  final BookingService _service;

  BookingRepository({BookingService? service}) : _service = service ?? BookingService();

  Future<void> createBooking(BookingModel booking) async {
    try {
      await _service.createBooking(booking);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      return await _service.getUserBookings(userId);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<List<BookingModel>> getPropertyBookings(String propertyId) async {
    try {
      return await _service.getPropertyBookings(propertyId);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
