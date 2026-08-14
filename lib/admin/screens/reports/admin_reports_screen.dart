import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../services/report_export_service.dart';

class AdminReportsScreen extends StatefulWidget {
  static const String routeName = '/admin/reports';
  final AdminModel admin;

  const AdminReportsScreen({Key? key, required this.admin}) : super(key: key);

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final ReportExportService _exportService = ReportExportService();
  String? _exportedCSV;
  bool _isExporting = false;

  Future<void> _exportBookings() async {
    setState(() => _isExporting = true);
    try {
      final csv = await _exportService.generateBookingsCSV('All');
      setState(() {
        _exportedCSV = csv;
        _isExporting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bookings CSV Generated Successfully!')));
    } catch (e) {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportPayments() async {
    setState(() => _isExporting = true);
    try {
      final csv = await _exportService.generatePaymentsCSV('All');
      setState(() {
        _exportedCSV = csv;
        _isExporting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payments CSV Generated Successfully!')));
    } catch (e) {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports Center & Data Exporter'),
        backgroundColor: const Color(0xFF162234),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            const Text('Export Authorized Data Ledgers (CSV / Excel Format)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.book_online, color: Colors.green),
                      title: const Text('Bookings Master Report'),
                      subtitle: const Text('Export reservations, guests, dates & statuses'),
                      trailing: ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Export CSV'),
                        onPressed: _exportBookings,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.payments, color: Colors.teal),
                      title: const Text('Payments Ledger Report'),
                      subtitle: const Text('Export transaction IDs, gateways & verification'),
                      trailing: ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Export CSV'),
                        onPressed: _exportPayments,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_isExporting) const Center(child: CircularProgressIndicator()),

            if (_exportedCSV != null) ...[
              const Text('Generated Raw CSV Preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(8)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText(
                    _exportedCSV!,
                    style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
