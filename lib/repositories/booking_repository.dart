import '../core/errors/failure.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingRepository {
  final BookingService _service;

  BookingRepository({BookingService? service}) : _service = service ?? BookingService();

  Future<BookingModel> createBookingHold({
    required String userId,
    required String propertyId,
    required String roomTypeId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int adults,
    required int children,
    required int rooms,
    required Map<String, dynamic> guestDetails,
  }) async {
    try {
      return await _service.createBookingHoldTransaction(
        userId: userId,
        propertyId: propertyId,
        roomTypeId: roomTypeId,
        checkIn: checkIn,
        checkOut: checkOut,
        adults: adults,
        children: children,
        rooms: rooms,
        guestDetails: guestDetails,
      );
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> confirmBooking(String bookingId, {required String paymentId, required String performedBy}) async {
    try {
      await _service.confirmBooking(bookingId, paymentId: paymentId, performedBy: performedBy);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> assignRoom(String bookingId, String roomId, String assignedBy) async {
    try {
      await _service.assignRoomToBooking(bookingId: bookingId, roomId: roomId, assignedBy: assignedBy);
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
