import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../models/room_type_model.dart';
import '../../../services/room_service.dart';
import 'admin_add_edit_room_type_screen.dart';
import 'admin_rooms_list_screen.dart';

class AdminRoomTypesListScreen extends StatefulWidget {
  static const String routeName = '/admin/room-types';
  final AdminModel admin;
  final String propertyId;

  const AdminRoomTypesListScreen({
    Key? key,
    required this.admin,
    this.propertyId = 'prop_default',
  }) : super(key: key);

  @override
  State<AdminRoomTypesListScreen> createState() => _AdminRoomTypesListScreenState();
}

class _AdminRoomTypesListScreenState extends State<AdminRoomTypesListScreen> {
  final RoomService _roomService = RoomService();
  List<RoomTypeModel> _roomTypes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoomTypes();
  }

  Future<void> _loadRoomTypes() async {
    setState(() => _isLoading = true);
    try {
      final list = await _roomService.getRoomTypes(widget.propertyId);
      setState(() {
        _roomTypes = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Types & Pricing Catalog'),
        backgroundColor: const Color(0xFF162234),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('New Room Type'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5F86C1),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final res = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AdminAddEditRoomTypeScreen(
                    admin: widget.admin,
                    propertyId: widget.propertyId,
                  ),
                ),
              );
              if (res == true) _loadRoomTypes();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _roomTypes.isEmpty
                ? const Center(child: Text('No room types defined yet.'))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _roomTypes.length,
                    itemBuilder: (context, index) {
                      final rt = _roomTypes[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(rt.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text('₹${rt.basePrice.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF5F86C1))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(rt.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const Divider(height: 20),
                              Row(
                                children: [
                                  const Icon(Icons.king_bed, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('${rt.bedCount} ${rt.bedType}', style: const TextStyle(fontSize: 12)),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.people, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('Max ${rt.maxGuests} Guests', style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.door_sliding, size: 16),
                                      label: const Text('Manage Rooms', style: TextStyle(fontSize: 11)),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => AdminRoomsListScreen(
                                              admin: widget.admin,
                                              roomType: rt,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () async {
                                      final res = await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => AdminAddEditRoomTypeScreen(
                                            admin: widget.admin,
                                            propertyId: widget.propertyId,
                                            roomType: rt,
                                          ),
                                        ),
                                      );
                                      if (res == true) _loadRoomTypes();
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
