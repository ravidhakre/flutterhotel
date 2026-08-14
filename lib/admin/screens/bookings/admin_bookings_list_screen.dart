import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../models/booking_model.dart';
import '../../../services/booking_service.dart';
import 'admin_booking_detail_screen.dart';

class AdminBookingsListScreen extends StatefulWidget {
  static const String routeName = '/admin/bookings';
  final AdminModel admin;
  final String propertyId;

  const AdminBookingsListScreen({
    Key? key,
    required this.admin,
    this.propertyId = 'prop_default',
  }) : super(key: key);

  @override
  State<AdminBookingsListScreen> createState() => _AdminBookingsListScreenState();
}

class _AdminBookingsListScreenState extends State<AdminBookingsListScreen> {
  final BookingService _bookingService = BookingService();
  List<BookingModel> _bookings = [];
  List<BookingModel> _filteredBookings = [];
  bool _isLoading = true;

  final _searchController = TextEditingController();
  String _selectedStatusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final list = await _bookingService.getPropertyBookings(widget.propertyId);
      setState(() {
        _bookings = list;
        _filteredBookings = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _filterBookings() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBookings = _bookings.where((b) {
        final matchesSearch = b.bookingId.toLowerCase().contains(query) ||
            (b.guestDetails['fullName'] ?? '').toString().toLowerCase().contains(query) ||
            (b.guestDetails['phone'] ?? '').toString().toLowerCase().contains(query);

        final matchesStatus = _selectedStatusFilter == 'All' ||
            b.bookingStatus.toLowerCase() == _selectedStatusFilter.toLowerCase();

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations & Booking Management'),
        backgroundColor: const Color(0xFF162234),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Filter Bar
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => _filterBookings(),
                        decoration: const InputDecoration(
                          hintText: 'Search by Booking ID, Guest Name, or Phone...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _selectedStatusFilter,
                      items: ['All', 'confirmed', 'paymentPending', 'checkedIn', 'checkedOut', 'cancelled', 'expired']
                          .map((s) => DropdownMenuItem(value: s, child: Text('Status: $s')))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          _selectedStatusFilter = val;
                          _filterBookings();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bookings Data Table
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredBookings.isEmpty
                      ? const Center(child: Text('No bookings found matching criteria.'))
                      : SingleChildScrollView(
                          child: Container(
                            width: double.infinity,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(const Color(0xFFF4F7FC)),
                              columns: const [
                                DataColumn(label: Text('Booking ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Guest Info', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Stay Dates', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Assigned Room', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: _filteredBookings.map((b) {
                                final guestName = b.guestDetails['fullName'] ?? 'Guest';
                                final checkInStr = "${b.checkIn.day}/${b.checkIn.month}/${b.checkIn.year}";
                                final checkOutStr = "${b.checkOut.day}/${b.checkOut.month}/${b.checkOut.year}";

                                return DataRow(cells: [
                                  DataCell(Text(b.bookingId, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5F86C1)))),
                                  DataCell(Column(
                                    crossAxisAlignment: CrossAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(guestName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(b.guestDetails['phone'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  )),
                                  DataCell(Text('$checkInStr - $checkOutStr (${b.nights}n)')),
                                  DataCell(Chip(
                                    label: Text(b.roomId != null ? 'Room ${b.roomId}' : 'UNASSIGNED',
                                        style: const TextStyle(fontSize: 10)),
                                    backgroundColor: b.roomId != null ? Colors.blue.shade50 : Colors.amber.shade50,
                                  )),
                                  DataCell(Text('₹${b.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusBg(b.bookingStatus),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        b.bookingStatus.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: _getStatusText(b.bookingStatus),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.visibility, color: Colors.blue),
                                      tooltip: 'View Booking Details',
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => AdminBookingDetailScreen(
                                              admin: widget.admin,
                                              booking: b,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case 'confirmed': return Colors.green.shade100;
      case 'paymentPending': return Colors.amber.shade100;
      case 'checkedIn': return Colors.purple.shade100;
      case 'checkedOut': return Colors.grey.shade200;
      case 'cancelled': return Colors.red.shade100;
      default: return Colors.blue.shade100;
    }
  }

  Color _getStatusText(String status) {
    switch (status) {
      case 'confirmed': return Colors.green.shade900;
      case 'paymentPending': return Colors.amber.shade900;
      case 'checkedIn': return Colors.purple.shade900;
      case 'checkedOut': return Colors.grey.shade900;
      case 'cancelled': return Colors.red.shade900;
      default: return Colors.blue.shade900;
    }
  }
}
