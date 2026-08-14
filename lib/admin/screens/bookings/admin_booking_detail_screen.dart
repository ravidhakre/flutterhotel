import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../models/booking_model.dart';
import '../../../models/room_model.dart';
import '../../../services/availability_service.dart';
import '../../../services/booking_service.dart';

class AdminBookingDetailScreen extends StatefulWidget {
  final AdminModel admin;
  final BookingModel booking;

  const AdminBookingDetailScreen({
    Key? key,
    required this.admin,
    required this.booking,
  }) : super(key: key);

  @override
  State<AdminBookingDetailScreen> createState() => _AdminBookingDetailScreenState();
}

class _AdminBookingDetailScreenState extends State<AdminBookingDetailScreen> {
  final BookingService _bookingService = BookingService();
  final AvailabilityService _availabilityService = AvailabilityService();

  late BookingModel _currentBooking;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
  }

  Future<void> _assignPhysicalRoomDialog() async {
    setState(() => _isLoading = true);
    List<RoomModel> availableRooms = [];
    try {
      availableRooms = await _availabilityService.getAvailableRooms(
        propertyId: _currentBooking.propertyId,
        roomTypeId: _currentBooking.roomTypeId,
        checkIn: _currentBooking.checkIn,
        checkOut: _currentBooking.checkOut,
      );
    } catch (_) {}
    setState(() => _isLoading = false);

    if (availableRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available physical rooms for these dates.')),
      );
      return;
    }

    String? selectedRoomId = availableRooms.first.roomId;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Physical Room'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => DropdownButtonFormField<String>(
            value: selectedRoomId,
            decoration: const InputDecoration(labelText: 'Available Rooms', border: OutlineInputBorder()),
            items: availableRooms
                .map((r) => DropdownMenuItem(
                      value: r.roomId,
                      child: Text('Room ${r.roomNumber} (${r.floor})'),
                    ))
                .toList(),
            onChanged: (v) => setDialogState(() => selectedRoomId = v),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (selectedRoomId == null) return;
              try {
                await _bookingService.assignRoomToBooking(
                  bookingId: _currentBooking.bookingId,
                  roomId: selectedRoomId!,
                  assignedBy: widget.admin.email,
                );
                Navigator.pop(ctx, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Assign Room'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _currentBooking = BookingModel.fromMap({
          ..._currentBooking.toMap(),
          'roomId': selectedRoomId,
        }, _currentBooking.bookingId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = _currentBooking;
    final guest = b.guestDetails;

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Record #${b.bookingId}'),
        backgroundColor: const Color(0xFF162234),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            // Status Header Banner
            Card(
              color: const Color(0xFFF4F7FC),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        Text('Status: ${b.bookingStatus.toUpperCase()}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('Payment: ${b.paymentStatus.toUpperCase()} • Hold: ${b.holdStatus.toUpperCase()}'),
                      ],
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.meeting_room),
                      label: Text(b.roomId != null ? 'Change Room (${b.roomId})' : 'Assign Physical Room'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5F86C1), foregroundColor: Colors.white),
                      onPressed: _assignPhysicalRoomDialog,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                // Guest & Stay Details
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAlignment.start,
                        children: [
                          const Text('Guest Information Snapshot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.person, color: Color(0xFF5F86C1)),
                            title: Text(guest['fullName'] ?? 'Guest Name'),
                            subtitle: Text('${guest['email'] ?? ''} • ${guest['phone'] ?? ''}'),
                          ),
                          const SizedBox(height: 16),
                          const Text('Stay & Occupancy Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const Divider(),
                          Text('Property: ${b.propertyId}'),
                          Text('Room Type: ${b.roomTypeId}'),
                          Text('Check-in: ${b.checkIn.day}/${b.checkIn.month}/${b.checkIn.year} (12:00 PM)'),
                          Text('Check-out: ${b.checkOut.day}/${b.checkOut.month}/${b.checkOut.year} (10:00 AM)'),
                          Text('Duration: ${b.nights} Night(s)'),
                          Text('Guests: ${b.adults} Adult(s), ${b.children} Child(ren) • ${b.rooms} Room(s)'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Pricing Summary Card
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAlignment.start,
                        children: [
                          const Text('Financial Breakdown (₹)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const Divider(),
                          _buildPriceRow('Room Charges (${b.nights} nights)', b.roomPrice),
                          if (b.extraGuestCharges > 0) _buildPriceRow('Extra Guest Charges', b.extraGuestCharges),
                          _buildPriceRow('Tax & GST (18%)', b.tax),
                          if (b.discount > 0) _buildPriceRow('Discount', -b.discount, isDiscount: true),
                          const Divider(),
                          _buildPriceRow('Total Amount', b.totalAmount, isBold: true),
                          _buildPriceRow('Paid Amount', b.paidAmount, isColor: Colors.green),
                          _buildPriceRow('Remaining Balance', b.remainingAmount, isColor: Colors.red),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double val, {bool isBold = false, bool isDiscount = false, Color? isColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            '${isDiscount ? '-' : ''}₹${val.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isColor ?? (isDiscount ? Colors.green : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
