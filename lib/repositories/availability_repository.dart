import '../core/errors/failure.dart';
import '../models/room_model.dart';
import '../services/availability_service.dart';

class AvailabilityRepository {
  final AvailabilityService _service;

  AvailabilityRepository({AvailabilityService? service}) : _service = service ?? AvailabilityService();

  Future<List<RoomModel>> getAvailableRooms({
    required String propertyId,
    required String roomTypeId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    try {
      return await _service.getAvailableRooms(
        propertyId: propertyId,
        roomTypeId: roomTypeId,
        checkIn: checkIn,
        checkOut: checkOut,
      );
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<bool> checkRoomAvailability({
    required String propertyId,
    required String roomTypeId,
    required DateTime checkIn,
    required DateTime checkOut,
    int requestedRooms = 1,
  }) async {
    try {
      return await _service.checkRoomAvailability(
        propertyId: propertyId,
        roomTypeId: roomTypeId,
        checkIn: checkIn,
        checkOut: checkOut,
        requestedRooms: requestedRooms,
      );
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<Map<String, Map<String, int>>> getInventoryCalendar({
    required String propertyId,
    required DateTime startDate,
    required int days,
  }) async {
    try {
      return await _service.getInventoryCalendar(
        propertyId: propertyId,
        startDate: startDate,
        days: days,
      );
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
