import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../models/property_model.dart';
import '../../../models/room_type_model.dart';
import '../../../services/pricing_service.dart';

class AdminPricingSimulatorScreen extends StatefulWidget {
  static const String routeName = '/admin/pricing-simulator';
  final AdminModel admin;

  const AdminPricingSimulatorScreen({Key? key, required this.admin}) : super(key: key);

  @override
  State<AdminPricingSimulatorScreen> createState() => _AdminPricingSimulatorScreenState();
}

class _AdminPricingSimulatorScreenState extends State<AdminPricingSimulatorScreen> {
  final PricingService _pricingService = PricingService();

  final _roomsCtrl = TextEditingController(text: '1');
  final _adultsCtrl = TextEditingController(text: '2');
  final _childrenCtrl = TextEditingController(text: '0');

  DateTime _checkIn = DateTime.now();
  DateTime _checkOut = DateTime.now().add(const Duration(days: 2));
  PricingBreakdown? _result;

  void _runSimulation() {
    final mockProp = PropertyModel(
      propertyId: 'prop_ Agra',
      propertyName: 'Agra Resort',
      description: 'Luxury Resort',
      address: 'Agra',
      city: 'Agra',
      state: 'UP',
      country: 'India',
      pincode: '282001',
      phone: '+91 9999999999',
      email: 'info@agra.com',
      taxPercentage: 18.0,
    );

    final mockRoomType = RoomTypeModel(
      roomTypeId: 'rt_deluxe',
      propertyId: 'prop_Agra',
      name: 'Deluxe Room',
      description: 'King Bed Deluxe Room',
      basePrice: 4000.0,
      weekendPrice: 4800.0,
      extraAdultPrice: 800.0,
    );

    final res = _pricingService.calculateAdvancedPrice(
      property: mockProp,
      roomType: mockRoomType,
      checkIn: _checkIn,
      checkOut: _checkOut,
      rooms: int.tryParse(_roomsCtrl.text) ?? 1,
      adults: int.tryParse(_adultsCtrl.text) ?? 2,
      children: int.tryParse(_childrenCtrl.text) ?? 0,
    );

    setState(() => _result = res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commercial Pricing Simulator'),
        backgroundColor: const Color(0xFF162234),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            const Text('Test Pricing Hierarchy & Rate Calculations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Check-In Date'),
                    subtitle: Text('${_checkIn.day}/${_checkIn.month}/${_checkIn.year}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final p = await showDatePicker(context: context, initialDate: _checkIn, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                      if (p != null) setState(() => _checkIn = p);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Check-Out Date'),
                    subtitle: Text('${_checkOut.day}/${_checkOut.month}/${_checkOut.year}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final p = await showDatePicker(context: context, initialDate: _checkOut, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                      if (p != null) setState(() => _checkOut = p);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _roomsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Rooms Count', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _adultsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Adults', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _childrenCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Children', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('RUN PRICING ENGINE SIMULATION'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5F86C1),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _runSimulation,
            ),
            const SizedBox(height: 32),

            if (_result != null) ...[
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAlignment.start,
                    children: [
                      const Text('Engine Price Breakdown Result', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Divider(),
                      ..._result!.nightlyRates.map((r) => ListTile(
                            dense: true,
                            title: Text('Night of ${r.date.day}/${r.date.month}/${r.date.year}'),
                            trailing: Text('₹${r.rate.toStringAsFixed(2)}'),
                          )),
                      const Divider(),
                      _buildRow('Room Base Subtotal', _result!.roomBaseTotal),
                      _buildRow('Extra Guest Charges', _result!.extraGuestCharges),
                      _buildRow('Tax & GST (18%)', _result!.taxAmount),
                      const Divider(),
                      _buildRow('FINAL TOTAL PRICE', _result!.totalAmount, isBold: true),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, double val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text('₹${val.toStringAsFixed(2)}', style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 16 : 14)),
        ],
      ),
    );
  }
}
