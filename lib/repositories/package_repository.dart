import '../core/errors/failure.dart';
import '../models/package_model.dart';
import '../services/package_service.dart';

class PackageRepository {
  final PackageService _service;

  PackageRepository({PackageService? service}) : _service = service ?? PackageService();

  Future<void> savePackage(PackageModel package) async {
    try {
      await _service.savePackage(package);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<List<PackageModel>> getAvailablePackages(String propertyId, String roomTypeId) async {
    try {
      return await _service.getAvailablePackages(propertyId, roomTypeId);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
