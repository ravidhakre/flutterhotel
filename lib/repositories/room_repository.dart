import '../core/errors/failure.dart';
import '../models/room_model.dart';
import '../models/room_type_model.dart';
import '../services/room_service.dart';

class RoomRepository {
  final RoomService _service;

  RoomRepository({RoomService? service}) : _service = service ?? RoomService();

  Future<List<RoomTypeModel>> getRoomTypes(String propertyId) async {
    try {
      return await _service.getRoomTypes(propertyId);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<List<RoomModel>> getRooms(String propertyId) async {
    try {
      return await _service.getRooms(propertyId);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
