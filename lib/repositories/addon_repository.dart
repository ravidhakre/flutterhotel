import '../core/errors/failure.dart';
import '../models/addon_model.dart';
import '../services/addon_service.dart';

class AddonRepository {
  final AddonService _service;

  AddonRepository({AddonService? service}) : _service = service ?? AddonService();

  Future<void> saveAddon(AddonModel addon) async {
    try {
      await _service.saveAddon(addon);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<List<AddonModel>> getAvailableAddons(String propertyId) async {
    try {
      return await _service.getAvailableAddons(propertyId);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
