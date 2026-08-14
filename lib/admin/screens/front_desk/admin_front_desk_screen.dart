import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../models/booking_model.dart';
import '../../../services/booking_service.dart';
import '../../../services/front_desk_service.dart';
import '../bookings/admin_booking_detail_screen.dart';

class AdminFrontDeskScreen extends StatefulWidget {
  static const String routeName = '/admin/front-desk';
  final AdminModel admin;
  final String propertyId;

  const AdminFrontDeskScreen({
    Key? key,
    required this.admin,
    this.propertyId = 'prop_default',
  }) : super(key: key);

  @override
  State<AdminFrontDeskScreen> createState() => _AdminFrontDeskScreenState();
}

class _AdminFrontDeskScreenState extends State<AdminFrontDeskScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingService _bookingService = BookingService();
  final FrontDeskService _frontDeskService = FrontDeskService();

  List<BookingModel> _allBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final list = await _bookingService.getPropertyBookings(widget.propertyId);
      setState(() {
        _allBookings = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  List<BookingModel> get _todaysArrivals {
    final now = DateTime.now();
    return _allBookings.where((b) {
      return b.bookingStatus == 'confirmed' &&
          b.checkIn.year == now.year &&
          b.checkIn.month == now.month &&
          b.checkIn.day == now.day;
    }).toList();
  }

  List<BookingModel> get _todaysDepartures {
    final now = DateTime.now();
    return _allBookings.where((b) {
      return b.bookingStatus == 'checkedIn' &&
          b.checkOut.year == now.year &&
          b.checkOut.month == now.month &&
          b.checkOut.day == now.day;
    }).toList();
  }

  List<BookingModel> get _currentlyStaying {
    return _allBookings.where((b) => b.bookingStatus == 'checkedIn').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Front Desk Operations'),
        backgroundColor: const Color(0xFF162234),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF5F86C1),
          tabs: [
            Tab(text: "Today's Arrivals (${_todaysArrivals.length})"),
            Tab(text: "Today's Departures (${_todaysDepartures.length})"),
            Tab(text: 'Currently In-House (${_currentlyStaying.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(_todaysArrivals, isArrival: true),
                _buildBookingList(_todaysDepartures, isDeparture: true),
                _buildBookingList(_currentlyStaying, isInHouse: true),
              ],
            ),
    );
  }

  Widget _buildBookingList(List<BookingModel> list, {bool isArrival = false, bool isDeparture = false, bool isInHouse = false}) {
    if (list.isEmpty) {
      return const Center(child: Text('No bookings match this category for today.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final b = list[index];
        final guest = b.guestDetails;

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF5F86C1),
              child: Text(b.roomId ?? '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text('${guest['fullName'] ?? 'Guest'} • Booking #${b.bookingId}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Room: ${b.roomId ?? 'UNASSIGNED'} • ${b.adults}A, ${b.children}C • Balance: ₹${b.remainingAmount.toStringAsFixed(0)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isArrival)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text('Check-In'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: () async {
                      try {
                        await _frontDeskService.checkInGuest(bookingId: b.bookingId, performedBy: widget.admin.email);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guest Checked In successfully!')));
                        _loadData();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                  ),
                if (isDeparture)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Check-Out'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade900, foregroundColor: Colors.white),
                    onPressed: () async {
                      try {
                        await _frontDeskService.checkOutGuest(bookingId: b.bookingId, performedBy: widget.admin.email);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guest Checked Out & Invoice Generated!')));
                        _loadData();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AdminBookingDetailScreen(admin: widget.admin, booking: b),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
