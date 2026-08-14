import 'package:flutter/material.dart';
import '../../models/admin_model.dart';

class AdminDashboardScreen extends StatelessWidget {
  static const String routeName = '/admin/dashboard';
  final AdminModel admin;

  const AdminDashboardScreen({Key? key, required this.admin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard - ${admin.role.toUpperCase()}'),
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
              'Admin Modules & Permissions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard('Properties & Inventory', Icons.business, Colors.blue),
                  _buildDashboardCard('Reservations & Bookings', Icons.book_online, Colors.green),
                  _buildDashboardCard('Guest Management', Icons.people, Colors.orange),
                  _buildDashboardCard('Offers & Packages', Icons.local_offer, Colors.purple),
                  _buildDashboardCard('Financial Reports', Icons.analytics, Colors.teal),
                  _buildDashboardCard('System Security & Logs', Icons.security, Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
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
