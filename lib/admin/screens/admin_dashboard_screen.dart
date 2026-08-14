import 'package:flutter/material.dart';
import '../../models/admin_model.dart';
import 'bookings/admin_bookings_list_screen.dart';
import 'bookings/admin_new_booking_screen.dart';
import 'commercial/admin_addons_screen.dart';
import 'commercial/admin_coupons_screen.dart';
import 'commercial/admin_offers_screen.dart';
import 'commercial/admin_packages_screen.dart';
import 'commercial/admin_pricing_simulator_screen.dart';
import 'front_desk/admin_front_desk_screen.dart';
import 'guests/admin_guests_list_screen.dart';
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
        title: Text('Executive Control Portal — ${admin.role.toUpperCase()}'),
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
              'Phase 5 — Commercial Pricing & Promotion Engine Portal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    context,
                    'Front Desk Operations',
                    Icons.concierge,
                    Colors.orange.shade900,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminFrontDeskScreen(admin: admin))),
                  ),
                  _buildDashboardCard(
                    context,
                    'Reservations Center',
                    Icons.book_online,
                    Colors.green,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminBookingsListScreen(admin: admin))),
                  ),
                  _buildDashboardCard(
                    context,
                    'Promotional Offers',
                    Icons.local_offer,
                    Colors.pink,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminOffersScreen(admin: admin))),
                  ),
                  _buildDashboardCard(
                    context,
                    'Discount Coupons',
                    Icons.confirmation_number,
                    Colors.purple,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminCouponsScreen(admin: admin))),
                  ),
                  _buildDashboardCard(
                    context,
                    'Vacation Packages',
                    Icons.card_giftcard,
                    Colors.teal,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPackagesScreen(admin: admin))),
                  ),
                  _buildDashboardCard(
                    context,
                    'Add-on Services',
                    Icons.room_service,
                    Colors.indigo,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminAddonsScreen(admin: admin))),
                  ),
                  _buildDashboardCard(
                    context,
                    'Pricing Simulator',
                    Icons.calculate,
                    Colors.deepOrange,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPricingSimulatorScreen(admin: admin))),
                  ),
                  _buildDashboardCard(
                    context,
                    'Property Portfolio',
                    Icons.business,
                    Colors.blue,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPropertyListScreen(admin: admin))),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
