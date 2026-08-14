import 'package:flutter/material.dart';
import '../../../core/validators/form_validators.dart';
import '../../../models/admin_model.dart';
import '../../../models/property_model.dart';
import '../../../services/property_service.dart';

class AdminAddEditPropertyScreen extends StatefulWidget {
  final AdminModel admin;
  final PropertyModel? property;

  const AdminAddEditPropertyScreen({
    Key? key,
    required this.admin,
    this.property,
  }) : super(key: key);

  @override
  State<AdminAddEditPropertyScreen> createState() => _AdminAddEditPropertyScreenState();
}

class _AdminAddEditPropertyScreenState extends State<AdminAddEditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final PropertyService _propertyService = PropertyService();

  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _pincodeCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _checkInCtrl;
  late TextEditingController _checkOutCtrl;
  late TextEditingController _gstCtrl;
  late TextEditingController _taxCtrl;

  String _propertyType = 'resort';
  String _status = 'active';
  List<String> _selectedAmenities = [];
  bool _isLoading = false;

  final List<String> _allAmenities = [
    'Free Wi-Fi', 'Swimming Pool', 'Free Parking', 'Restaurant', 'Room Service',
    'Spa & Wellness', 'Gym / Fitness', 'Conference Room', 'Airport Transfer',
    'Complimentary Breakfast', 'Laundry Service', '24x7 Reception', 'Air Conditioning',
    'Pet Friendly', 'Kids Play Area', 'Bonfire & DJ'
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.property;
    _nameCtrl = TextEditingController(text: p?.propertyName ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _addressCtrl = TextEditingController(text: p?.address ?? '');
    _cityCtrl = TextEditingController(text: p?.city ?? 'Lansdowne');
    _stateCtrl = TextEditingController(text: p?.state ?? 'Uttarakhand');
    _countryCtrl = TextEditingController(text: p?.country ?? 'India');
    _pincodeCtrl = TextEditingController(text: p?.pincode ?? '246155');
    _phoneCtrl = TextEditingController(text: p?.phone ?? '+91 89 2923 2740');
    _emailCtrl = TextEditingController(text: p?.email ?? 'sales@flutterhotel.com');
    _checkInCtrl = TextEditingController(text: p?.checkInTime ?? '12:00 PM');
    _checkOutCtrl = TextEditingController(text: p?.checkOutTime ?? '10:00 AM');
    _gstCtrl = TextEditingController(text: p?.gstNumber ?? '');
    _taxCtrl = TextEditingController(text: p?.taxPercentage.toString() ?? '18.0');

    if (p != null) {
      _propertyType = p.propertyType;
      _status = p.status;
      _selectedAmenities = List.from(p.amenities);
    }
  }

  Future<void> _saveProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final id = widget.property?.propertyId ?? 'prop_${DateTime.now().millisecondsSinceEpoch}';
      final newProp = PropertyModel(
        propertyId: id,
        propertyName: _nameCtrl.text.trim(),
        propertyType: _propertyType,
        description: _descCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
        pincode: _pincodeCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        checkInTime: _checkInCtrl.text.trim(),
        checkOutTime: _checkOutCtrl.text.trim(),
        gstNumber: _gstCtrl.text.trim(),
        taxPercentage: double.tryParse(_taxCtrl.text) ?? 18.0,
        amenities: _selectedAmenities,
        status: _status,
      );

      await _propertyService.saveProperty(newProp);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.property == null ? 'Add New Property' : 'Edit Property Details'),
        backgroundColor: const Color(0xFF162234),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAlignment.start,
            children: [
              const Text('Basic Property Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                validator: (v) => FormValidators.validateRequired(v, 'Property Name'),
                decoration: const InputDecoration(labelText: 'Property Name *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _propertyType,
                      decoration: const InputDecoration(labelText: 'Property Type', border: OutlineInputBorder()),
                      items: ['hotel', 'resort', 'villa', 'apartment', 'guestHouse', 'homestay']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase())))
                          .toList(),
                      onChanged: (v) => setState(() => _propertyType = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(labelText: 'Operational Status', border: OutlineInputBorder()),
                      items: ['active', 'inactive', 'maintenance']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                          .toList(),
                      onChanged: (v) => setState(() => _status = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Property Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),

              const Text('Location & Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Street Address', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityCtrl,
                      validator: (v) => FormValidators.validateRequired(v, 'City'),
                      decoration: const InputDecoration(labelText: 'City *', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stateCtrl,
                      decoration: const InputDecoration(labelText: 'State / Province', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _countryCtrl,
                      validator: (v) => FormValidators.validateRequired(v, 'Country'),
                      decoration: const InputDecoration(labelText: 'Country *', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text('Property Amenities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: _allAmenities.map((amenity) {
                  final isSelected = _selectedAmenities.contains(amenity);
                  return FilterChip(
                    label: Text(amenity),
                    selected: isSelected,
                    selectedColor: const Color(0xFF5F86C1),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAmenities.add(amenity);
                        } else {
                          _selectedAmenities.remove(amenity);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(_isLoading ? 'SAVING...' : 'SAVE & PUBLISH PROPERTY'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5F86C1),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _isLoading ? null : _saveProperty,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
