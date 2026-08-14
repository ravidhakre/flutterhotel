import 'package:flutter/material.dart';
import '../../../core/validators/form_validators.dart';
import '../../../models/admin_model.dart';
import '../../../models/room_type_model.dart';
import '../../../services/room_service.dart';

class AdminAddEditRoomTypeScreen extends StatefulWidget {
  final AdminModel admin;
  final String propertyId;
  final RoomTypeModel? roomType;

  const AdminAddEditRoomTypeScreen({
    Key? key,
    required this.admin,
    required this.propertyId,
    this.roomType,
  }) : super(key: key);

  @override
  State<AdminAddEditRoomTypeScreen> createState() => _AdminAddEditRoomTypeScreenState();
}

class _AdminAddEditRoomTypeScreenState extends State<AdminAddEditRoomTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  final RoomService _roomService = RoomService();

  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _sizeCtrl;
  late TextEditingController _bedCountCtrl;
  late TextEditingController _maxAdultsCtrl;
  late TextEditingController _maxChildrenCtrl;
  late TextEditingController _maxGuestsCtrl;
  late TextEditingController _basePriceCtrl;
  late TextEditingController _weekendPriceCtrl;
  late TextEditingController _extraAdultCtrl;
  late TextEditingController _extraChildCtrl;
  late TextEditingController _extraBedCtrl;

  String _bedType = 'King Bed';
  String _status = 'active';
  bool _isLoading = false;

  final List<String> _bedTypesList = [
    'Single', 'Twin', 'Double', 'Queen', 'King Bed', 'California King', 'Bunk', 'Sofa Bed', 'Multiple Beds'
  ];

  @override
  void initState() {
    super.initState();
    final rt = widget.roomType;
    _nameCtrl = TextEditingController(text: rt?.name ?? '');
    _descCtrl = TextEditingController(text: rt?.description ?? '');
    _sizeCtrl = TextEditingController(text: rt?.roomSize ?? '180 sq. ft.');
    _bedCountCtrl = TextEditingController(text: (rt?.bedCount ?? 1).toString());
    _maxAdultsCtrl = TextEditingController(text: (rt?.maxAdults ?? 2).toString());
    _maxChildrenCtrl = TextEditingController(text: (rt?.maxChildren ?? 1).toString());
    _maxGuestsCtrl = TextEditingController(text: (rt?.maxGuests ?? 3).toString());
    _basePriceCtrl = TextEditingController(text: (rt?.basePrice ?? 3200.0).toString());
    _weekendPriceCtrl = TextEditingController(text: (rt?.weekendPrice ?? 3600.0).toString());
    _extraAdultCtrl = TextEditingController(text: (rt?.extraAdultPrice ?? 800.0).toString());
    _extraChildCtrl = TextEditingController(text: (rt?.extraChildPrice ?? 400.0).toString());
    _extraBedCtrl = TextEditingController(text: (rt?.extraBedPrice ?? 1000.0).toString());

    if (rt != null) {
      _bedType = rt.bedType;
      _status = rt.status;
    }
  }

  Future<void> _saveRoomType() async {
    if (!_formKey.currentState!.validate()) return;

    final basePrice = double.tryParse(_basePriceCtrl.text) ?? -1;
    if (basePrice < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Price cannot be negative.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final id = widget.roomType?.roomTypeId ?? 'rt_${DateTime.now().millisecondsSinceEpoch}';
      final newRt = RoomTypeModel(
        roomTypeId: id,
        propertyId: widget.propertyId,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        roomSize: _sizeCtrl.text.trim(),
        bedType: _bedType,
        bedCount: int.tryParse(_bedCountCtrl.text) ?? 1,
        maxAdults: int.tryParse(_maxAdultsCtrl.text) ?? 2,
        maxChildren: int.tryParse(_maxChildrenCtrl.text) ?? 1,
        maxGuests: int.tryParse(_maxGuestsCtrl.text) ?? 3,
        basePrice: basePrice,
        weekendPrice: double.tryParse(_weekendPriceCtrl.text) ?? basePrice,
        extraAdultPrice: double.tryParse(_extraAdultCtrl.text) ?? 800.0,
        extraChildPrice: double.tryParse(_extraChildCtrl.text) ?? 400.0,
        extraBedPrice: double.tryParse(_extraBedCtrl.text) ?? 1000.0,
        status: _status,
      );

      await _roomService.saveRoomType(newRt);
      if (!mounted) return;
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
        title: Text(widget.roomType == null ? 'Create Room Type' : 'Edit Room Type'),
        backgroundColor: const Color(0xFF162234),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAlignment.start,
            children: [
              TextFormField(
                controller: _nameCtrl,
                validator: (v) => FormValidators.validateRequired(v, 'Room Type Name'),
                decoration: const InputDecoration(labelText: 'Room Type Name *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _bedType,
                      decoration: const InputDecoration(labelText: 'Bed Type', border: OutlineInputBorder()),
                      items: _bedTypesList
                          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (v) => setState(() => _bedType = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _sizeCtrl,
                      decoration: const InputDecoration(labelText: 'Room Size', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _maxAdultsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Max Adults', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _maxChildrenCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Max Children', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _maxGuestsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Max Total Guests', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Pricing Configuration (₹)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _basePriceCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) => FormValidators.validateRequired(v, 'Base Price'),
                      decoration: const InputDecoration(labelText: 'Base Price (₹) *', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _weekendPriceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Weekend Price (₹)', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(_isLoading ? 'SAVING...' : 'SAVE ROOM TYPE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5F86C1),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _isLoading ? null : _saveRoomType,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
