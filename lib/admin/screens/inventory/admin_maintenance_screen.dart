import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../models/maintenance_block_model.dart';
import '../../../services/inventory_service.dart';

class AdminMaintenanceScreen extends StatefulWidget {
  static const String routeName = '/admin/maintenance';
  final AdminModel admin;
  final String propertyId;

  const AdminMaintenanceScreen({
    Key? key,
    required this.admin,
    this.propertyId = 'prop_default',
  }) : super(key: key);

  @override
  State<AdminMaintenanceScreen> createState() => _AdminMaintenanceScreenState();
}

class _AdminMaintenanceScreenState extends State<AdminMaintenanceScreen> {
  final InventoryService _inventoryService = InventoryService();
  final _roomIdCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController(text: 'AC repair and painting');
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 2));
  bool _isLoading = false;

  Future<void> _scheduleBlock() async {
    if (_roomIdCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room ID is required')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final block = MaintenanceBlockModel(
        blockId: '',
        roomId: _roomIdCtrl.text.trim(),
        propertyId: widget.propertyId,
        startDate: _startDate,
        endDate: _endDate,
        reason: _reasonCtrl.text.trim(),
        createdBy: widget.admin.email,
      );

      await _inventoryService.createMaintenanceBlock(block);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maintenance block scheduled successfully!')));
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Maintenance Block'),
        backgroundColor: const Color(0xFF162234),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          maxWidth: 600,
          child: Column(
            crossAxisAlignment: CrossAlignment.start,
            children: [
              const Text('Block Room for Maintenance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _roomIdCtrl,
                decoration: const InputDecoration(labelText: 'Room ID / Number *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _reasonCtrl,
                decoration: const InputDecoration(labelText: 'Reason for Maintenance *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Start Date'),
                      subtitle: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final p = await showDatePicker(context: context, initialDate: _startDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                        if (p != null) setState(() => _startDate = p);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('End Date'),
                      subtitle: Text('${_endDate.day}/${_endDate.month}/${_endDate.year}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final p = await showDatePicker(context: context, initialDate: _endDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                        if (p != null) setState(() => _endDate = p);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.block),
                label: Text(_isLoading ? 'SCHEDULING...' : 'APPLY MAINTENANCE BLOCK'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade900,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _isLoading ? null : _scheduleBlock,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
