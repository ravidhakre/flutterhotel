import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../services/availability_service.dart';

class AdminAvailabilityCalendarScreen extends StatefulWidget {
  static const String routeName = '/admin/inventory-calendar';
  final AdminModel admin;
  final String propertyId;

  const AdminAvailabilityCalendarScreen({
    Key? key,
    required this.admin,
    this.propertyId = 'prop_default',
  }) : super(key: key);

  @override
  State<AdminAvailabilityCalendarScreen> createState() => _AdminAvailabilityCalendarScreenState();
}

class _AdminAvailabilityCalendarScreenState extends State<AdminAvailabilityCalendarScreen> {
  final AvailabilityService _availabilityService = AvailabilityService();
  Map<String, Map<String, int>> _matrixData = {};
  bool _isLoading = true;
  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMatrix();
  }

  Future<void> _loadMatrix() async {
    setState(() => _isLoading = true);
    try {
      final matrix = await _availabilityService.getInventoryCalendar(
        propertyId: widget.propertyId,
        startDate: _startDate,
        days: 7,
      );
      setState(() {
        _matrixData = matrix;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dates = _matrixData.keys.toList();
    final roomTypeNames = _matrixData.isNotEmpty ? _matrixData.values.first.keys.toList() : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability & Inventory Matrix Calendar'),
        backgroundColor: const Color(0xFF162234),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => _startDate = picked);
                _loadMatrix();
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF5F86C1)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Live Availability Matrix for Property ${widget.propertyId} starting ${_startDate.day}/${_startDate.month}/${_startDate.year}. Counts reflect physically bookable rooms.',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : dates.isEmpty || roomTypeNames.isEmpty
                      ? const Center(child: Text('No active room types found to render inventory matrix.'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Table(
                              border: TableBorder.all(color: Colors.grey.shade300),
                              defaultColumnWidth: const FixedColumnWidth(120),
                              children: [
                                // Header Row: Dates
                                TableRow(
                                  decoration: const BoxDecoration(color: Color(0xFF162234)),
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text('Room Category',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                    ...dates.map((d) => Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(d,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        )),
                                  ],
                                ),
                                // Body Rows: Room Type vs Date counts
                                ...roomTypeNames.map((rtName) {
                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(rtName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                      ...dates.map((d) {
                                        final count = _matrixData[d]?[rtName] ?? 0;
                                        final isSoldOut = count == 0;
                                        return Container(
                                          color: isSoldOut ? Colors.red.shade50 : Colors.green.shade50,
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(
                                            '$count Avail',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isSoldOut ? Colors.red.shade900 : Colors.green.shade900,
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
