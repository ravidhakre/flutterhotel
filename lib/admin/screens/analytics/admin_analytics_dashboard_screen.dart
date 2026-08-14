import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../models/analytics_summary_model.dart';
import '../../../models/property_model.dart';
import '../../../services/analytics_service.dart';

class AdminAnalyticsDashboardScreen extends StatefulWidget {
  static const String routeName = '/admin/analytics-dashboard';
  final AdminModel admin;

  const AdminAnalyticsDashboardScreen({Key? key, required this.admin}) : super(key: key);

  @override
  State<AdminAnalyticsDashboardScreen> createState() => _AdminAnalyticsDashboardScreenState();
}

class _AdminAnalyticsDashboardScreenState extends State<AdminAnalyticsDashboardScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();

  String _selectedPropertyId = 'All';
  List<PropertyModel> _properties = [];

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  AnalyticsSummaryModel? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProperties();
    _loadAnalytics();
  }

  Future<void> _loadProperties() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('properties').get();
      final list = snapshot.docs.map((d) => PropertyModel.fromMap(d.data(), d.id)).toList();
      setState(() => _properties = list);
    } catch (_) {}
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final res = await _analyticsService.getAnalyticsSummary(
        propertyId: _selectedPropertyId,
        startDate: _startDate,
        endDate: _endDate,
      );
      setState(() {
        _summary = res;
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
        title: const Text('Executive Revenue & Hospitality Analytics'),
        backgroundColor: const Color(0xFF162234),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAnalytics),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            // Filters Bar
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text('Property: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: _selectedPropertyId,
                      items: [
                        const DropdownMenuItem(value: 'All', child: Text('All Properties (Super Admin)')),
                        ..._properties.map((p) => DropdownMenuItem(value: p.propertyId, child: Text(p.propertyName))),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedPropertyId = val);
                          _loadAnalytics();
                        }
                      },
                    ),
                    const SizedBox(width: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text('Range: ${_startDate.day}/${_startDate.month} - ${_endDate.day}/${_endDate.month}'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5F86C1), foregroundColor: Colors.white),
                      onPressed: () async {
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
                        );
                        if (range != null) {
                          setState(() {
                            _startDate = range.start;
                            _endDate = range.end;
                          });
                          _loadAnalytics();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _summary == null
                    ? const Center(child: Text('Failed to calculate metrics'))
                    : Column(
                        children: [
                          // Primary Financial KPI Grid
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: [
                              _buildMetricCard('Gross Booking Value (GBV)', '₹${_summary!.grossBookingValue.toStringAsFixed(0)}', Colors.indigo, Icons.payments),
                              _buildMetricCard('Collected Net Revenue', '₹${_summary!.collectedRevenue.toStringAsFixed(0)}', Colors.teal, Icons.account_balance_wallet),
                              _buildMetricCard('ADR (Avg Daily Rate)', '₹${_summary!.adr.toStringAsFixed(0)}', Colors.blue, Icons.local_hotel),
                              _buildMetricCard('RevPAR', '₹${_summary!.revpar.toStringAsFixed(0)}', Colors.purple, Icons.trending_up),
                              _buildMetricCard('Current Occupancy %', '${_summary!.occupancyRate.toStringAsFixed(1)}%', Colors.orange.shade900, Icons.pie_chart),
                              _buildMetricCard('Total Bookings', '${_summary!.totalBookings}', Colors.green, Icons.book_online),
                              _buildMetricCard('Cancellation Rate', '${_summary!.cancellationRate.toStringAsFixed(1)}%', Colors.red, Icons.cancel),
                              _buildMetricCard('Avg Length of Stay (ALOS)', '${_summary!.alos.toStringAsFixed(1)} Nights', Colors.deepOrange, Icons.timelapse),
                            ],
                          ),
                        ],
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                const Icon(Icons.arrow_upward, color: Colors.green, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
