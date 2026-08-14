import 'package:flutter/material.dart';
import '../../../core/validators/form_validators.dart';
import '../../../models/admin_model.dart';
import '../../../models/room_type_model.dart';
import '../../../services/booking_service.dart';
import '../../../services/room_service.dart';

class AdminNewBookingScreen extends StatefulWidget {
  final AdminModel admin;
  final String propertyId;

  const AdminNewBookingScreen({
    Key? key,
    required this.admin,
    this.propertyId = 'prop_default',
  }) : super(key: key);

  @override
  State<AdminNewBookingScreen> createState() => _AdminNewBookingScreenState();
}

class _AdminNewBookingScreenState extends State<AdminNewBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookingService _bookingService = BookingService();
  final RoomService _roomService = RoomService();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _adultsCtrl = TextEditingController(text: '2');
  final _childrenCtrl = TextEditingController(text: '0');

  DateTime _checkIn = DateTime.now();
  DateTime _checkOut = DateTime.now().add(const Duration(days: 1));
  List<RoomTypeModel> _roomTypes = [];
  String? _selectedRoomTypeId;
  String _source = 'walkIn';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRoomTypes();
  }

  Future<void> _loadRoomTypes() async {
    try {
      final list = await _roomService.getRoomTypes(widget.propertyId);
      if (list.isNotEmpty) {
        setState(() {
          _roomTypes = list;
          _selectedRoomTypeId = list.first.roomTypeId;
        });
      }
    } catch (_) {}
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate() || _selectedRoomTypeId == null) return;

    setState(() => _isLoading = true);
    try {
      final booking = await _bookingService.createBookingHoldTransaction(
        userId: 'walkin_${DateTime.now().millisecondsSinceEpoch}',
        propertyId: widget.propertyId,
        roomTypeId: _selectedRoomTypeId!,
        checkIn: _checkIn,
        checkOut: _checkOut,
        adults: int.tryParse(_adultsCtrl.text) ?? 2,
        children: int.tryParse(_childrenCtrl.text) ?? 0,
        rooms: 1,
        guestDetails: {
          'fullName': _nameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
        },
        source: _source,
      );

      // Confirm Booking
      await _bookingService.confirmBooking(
        booking.bookingId,
        paymentId: 'PAY_${_source.toUpperCase()}_MANUAL',
        performedBy: widget.admin.email,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Walk-in Reservation #${booking.bookingId} created & confirmed!')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Manual / Walk-in Booking'),
        backgroundColor: const Color(0xFF162234),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Container(
            maxWidth: 600,
            child: Column(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                const Text('Guest Profile Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  validator: (v) => FormValidators.validateRequired(v, 'Guest Name'),
                  decoration: const InputDecoration(labelText: 'Guest Full Name *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phoneCtrl,
                        validator: FormValidators.validatePhone,
                        decoration: const InputDecoration(labelText: 'Phone Number *', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Reservation Parameters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (_roomTypes.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _selectedRoomTypeId,
                    decoration: const InputDecoration(labelText: 'Select Room Type *', border: OutlineInputBorder()),
                    items: _roomTypes
                        .map((rt) => DropdownMenuItem(
                              value: rt.roomTypeId,
                              child: Text('${rt.name} (₹${rt.basePrice.toStringAsFixed(0)}/night)'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedRoomTypeId = v),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Check-In'),
                        subtitle: Text('${_checkIn.day}/${_checkIn.month}/${_checkIn.year}'),
                        onTap: () async {
                          final p = await showDatePicker(context: context, initialDate: _checkIn, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                          if (p != null) setState(() => _checkIn = p);
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('Check-Out'),
                        subtitle: Text('${_checkOut.day}/${_checkOut.month}/${_checkOut.year}'),
                        onTap: () async {
                          final p = await showDatePicker(context: context, initialDate: _checkOut, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                          if (p != null) setState(() => _checkOut = p);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _source,
                  decoration: const InputDecoration(labelText: 'Booking Source', border: OutlineInputBorder()),
                  items: ['walkIn', 'phone', 'admin']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                      .toList(),
                  onChanged: (v) => setState(() => _source = v!),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: Text(_isLoading ? 'CREATING...' : 'CREATE & CONFIRM BOOKING'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F86C1),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _isLoading ? null : _submitBooking,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
