import 'package:flutter/material.dart';
import '../../models/admin_model.dart';
import 'inventory/admin_availability_calendar_screen.dart';
import 'inventory/admin_maintenance_screen.dart';
import 'properties/admin_property_list_screen.dart';
import 'rooms/admin_room_types_list_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  static const String routeName = '/admin/dashboard';
  final AdminModel admin;

  const AdminDashboardScreen({Key? key, required this.admin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Executive Dashboard — ${admin.role.toUpperCase()}'),
        backgroundColor: const Color(0xFF162234),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout Admin',
            onPressed: () => Navigator.of(context).pushReplacementNamed('/admin/login'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF5F86C1),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(admin.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${admin.email} • Role: ${admin.role} • Status: ${admin.status}'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Phase 2 — Property, Room Inventory & Availability Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    context,
                    'Property Portfolio',
                    Icons.business,
                    Colors.blue,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPropertyListScreen(admin: admin))),
                  ),
                  _buildDashboardCard(
                    context,
                    'Room Types & Pricing',
                    Icons.king_bed,
                    Colors.indigo,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminRoomTypesListScreen(admin: admin))),
                  ),
                  _buildDashboardCard(
                    context,
                    'Availability Matrix Calendar',
                    Icons.calendar_month,
                    Colors.teal,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminAvailabilityCalendarScreen(admin: admin))),
                  ),
                  _buildDashboardCard(
                    context,
                    'Room Maintenance Blocks',
                    Icons.block,
                    Colors.amber.shade900,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminMaintenanceScreen(admin: admin))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
