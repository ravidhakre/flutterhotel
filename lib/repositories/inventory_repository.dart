import '../core/errors/failure.dart';
import '../models/maintenance_block_model.dart';
import '../models/room_inventory_model.dart';
import '../services/inventory_service.dart';

class InventoryRepository {
  final InventoryService _service;

  InventoryRepository({InventoryService? service}) : _service = service ?? InventoryService();

  Future<void> saveInventory(RoomInventoryModel inventory) async {
    try {
      await _service.saveInventory(inventory);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<List<RoomInventoryModel>> getInventoryForRange({
    required String propertyId,
    String? roomTypeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _service.getInventoryForRange(
        propertyId: propertyId,
        roomTypeId: roomTypeId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> createMaintenanceBlock(MaintenanceBlockModel block) async {
    try {
      await _service.createMaintenanceBlock(block);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> removeMaintenanceBlock(String blockId, {required String performedBy}) async {
    try {
      await _service.removeMaintenanceBlock(blockId, performedBy: performedBy);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
