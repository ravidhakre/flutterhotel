import '../core/errors/failure.dart';
import '../models/property_model.dart';
import '../services/property_service.dart';

class PropertyRepository {
  final PropertyService _service;

  PropertyRepository({PropertyService? service}) : _service = service ?? PropertyService();

  Future<List<PropertyModel>> getActiveProperties() async {
    try {
      return await _service.getActiveProperties();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<PropertyModel?> getPropertyById(String id) async {
    try {
      return await _service.getPropertyById(id);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
