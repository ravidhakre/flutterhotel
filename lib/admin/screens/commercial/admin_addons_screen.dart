import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/addon_model.dart';
import '../../../models/admin_model.dart';
import '../../../services/addon_service.dart';

class AdminAddonsScreen extends StatefulWidget {
  static const String routeName = '/admin/addons';
  final AdminModel admin;
  final String propertyId;

  const AdminAddonsScreen({
    Key? key,
    required this.admin,
    this.propertyId = 'prop_default',
  }) : super(key: key);

  @override
  State<AdminAddonsScreen> createState() => _AdminAddonsScreenState();
}

class _AdminAddonsScreenState extends State<AdminAddonsScreen> {
  final AddonService _addonService = AddonService();
  List<AddonModel> _addons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddons();
  }

  Future<void> _loadAddons() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance.collection('addons').get();
      final list = snapshot.docs.map((d) => AddonModel.fromMap(d.data(), d.id)).toList();
      setState(() {
        _addons = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addAddonDialog() async {
    final nameCtrl = TextEditingController(text: 'Airport Pickup (SUV)');
    final descCtrl = TextEditingController(text: 'Chauffeur driven SUV pickup from Dehradun Jolly Grant Airport');
    final priceCtrl = TextEditingController(text: '2800');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Guest Experience Add-on'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Add-on Title *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price (₹) *', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              try {
                final addon = AddonModel(
                  addonId: '',
                  propertyId: widget.propertyId,
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  price: double.tryParse(priceCtrl.text) ?? 2800.0,
                );
                await _addonService.saveAddon(addon);
                Navigator.pop(ctx, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Save Add-on'),
          ),
        ],
      ),
    );

    if (result == true) _loadAddons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Amenities & Services Add-ons'),
        backgroundColor: const Color(0xFF162234),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('New Add-on'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5F86C1), foregroundColor: Colors.white),
            onPressed: _addAddonDialog,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _addons.isEmpty
                ? const Center(child: Text('No add-on services created yet.'))
                : ListView.builder(
                    itemCount: _addons.length,
                    itemBuilder: (context, index) {
                      final a = _addons[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.indigo,
                            child: Icon(Icons.room_service, color: Colors.white),
                          ),
                          title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${a.description} • Price: ₹${a.price.toStringAsFixed(0)} (${a.pricingType})'),
                          trailing: Chip(
                            label: Text(a.status.toUpperCase(), style: const TextStyle(fontSize: 10)),
                            backgroundColor: a.status == 'active' ? Colors.green.shade100 : Colors.grey.shade200,
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
