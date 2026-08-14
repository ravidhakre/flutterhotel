import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../models/room_model.dart';
import '../../../models/room_type_model.dart';
import '../../../services/room_service.dart';

class AdminRoomsListScreen extends StatefulWidget {
  final AdminModel admin;
  final RoomTypeModel roomType;

  const AdminRoomsListScreen({
    Key? key,
    required this.admin,
    required this.roomType,
  }) : super(key: key);

  @override
  State<AdminRoomsListScreen> createState() => _AdminRoomsListScreenState();
}

class _AdminRoomsListScreenState extends State<AdminRoomsListScreen> {
  final RoomService _roomService = RoomService();
  List<RoomModel> _rooms = [];
  final Set<String> _selectedRoomIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => _isLoading = true);
    try {
      final list = await _roomService.getRoomsByRoomType(widget.roomType.roomTypeId);
      setState(() {
        _rooms = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addSingleRoomDialog() async {
    final numCtrl = TextEditingController();
    final floorCtrl = TextEditingController(text: '1st Floor');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Room to ${widget.roomType.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: numCtrl,
              decoration: const InputDecoration(labelText: 'Room Number (e.g. 101) *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: floorCtrl,
              decoration: const InputDecoration(labelText: 'Floor (e.g. 1st Floor)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (numCtrl.text.trim().isEmpty) return;
              try {
                final room = RoomModel(
                  roomId: '',
                  propertyId: widget.roomType.propertyId,
                  roomTypeId: widget.roomType.roomTypeId,
                  roomNumber: numCtrl.text.trim(),
                  floor: floorCtrl.text.trim(),
                  status: 'available',
                );
                await _roomService.createRoom(room, performedBy: widget.admin.email);
                Navigator.pop(ctx, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Add Room'),
          ),
        ],
      ),
    );

    if (result == true) _loadRooms();
  }

  Future<void> _changeStatusDialog(RoomModel room) async {
    String newStatus = room.status;
    final reasonCtrl = TextEditingController(text: 'Routine operational update');

    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Change Status — Room ${room.roomNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: newStatus,
              decoration: const InputDecoration(labelText: 'New Status', border: OutlineInputBorder()),
              items: ['available', 'reserved', 'occupied', 'cleaning', 'maintenance', 'blocked', 'outOfService']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                  .toList(),
              onChanged: (v) => newStatus = v!,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(labelText: 'Reason for Status Change *', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await _roomService.updateRoomStatus(
                  roomId: room.roomId,
                  newStatus: newStatus,
                  reason: reasonCtrl.text.trim(),
                  changedBy: widget.admin.email,
                );
                Navigator.pop(ctx, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Update Status'),
          )
        ],
      ),
    );

    if (res == true) _loadRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Physical Rooms — ${widget.roomType.name}'),
        backgroundColor: const Color(0xFF162234),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Physical Room'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5F86C1), foregroundColor: Colors.white),
            onPressed: _addSingleRoomDialog,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _rooms.isEmpty
                ? const Center(child: Text('No physical rooms added for this room type yet.'))
                : ListView.builder(
                    itemCount: _rooms.length,
                    itemBuilder: (context, index) {
                      final room = _rooms[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF5F86C1),
                            child: Text(room.roomNumber, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          title: Text('Room ${room.roomNumber} (${room.floor})', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Status: ${room.status.toUpperCase()}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(room.status.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                                backgroundColor: _getStatusColor(room.status),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.tune),
                                tooltip: 'Update Status',
                                onPressed: () => _changeStatusDialog(room),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available': return Colors.green;
      case 'reserved': return Colors.blue;
      case 'occupied': return Colors.purple;
      case 'cleaning': return Colors.orange;
      case 'maintenance': return Colors.amber.shade900;
      case 'blocked': return Colors.red;
      default: return Colors.grey;
    }
  }
}
