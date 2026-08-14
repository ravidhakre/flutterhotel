import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../models/package_model.dart';
import '../../../services/package_service.dart';

class AdminPackagesScreen extends StatefulWidget {
  static const String routeName = '/admin/packages';
  final AdminModel admin;
  final String propertyId;

  const AdminPackagesScreen({
    Key? key,
    required this.admin,
    this.propertyId = 'prop_default',
  }) : super(key: key);

  @override
  State<AdminPackagesScreen> createState() => _AdminPackagesScreenState();
}

class _AdminPackagesScreenState extends State<AdminPackagesScreen> {
  final PackageService _packageService = PackageService();
  List<PackageModel> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance.collection('packages').get();
      final list = snapshot.docs.map((d) => PackageModel.fromMap(d.data(), d.id)).toList();
      setState(() {
        _packages = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addPackageDialog() async {
    final nameCtrl = TextEditingController(text: 'Honeymoon Special Package');
    final descCtrl = TextEditingController(text: 'Includes Candle Light Dinner, Bed Decoration & Cake');
    final priceCtrl = TextEditingController(text: '4500');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Vacation / Special Package'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Package Name *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Inclusions Description', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Package Price (₹) *', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              try {
                final pkg = PackageModel(
                  packageId: '',
                  propertyId: widget.propertyId,
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  price: double.tryParse(priceCtrl.text) ?? 4500.0,
                  validFrom: DateTime.now(),
                  validTo: DateTime.now().add(const Duration(days: 365)),
                );
                await _packageService.savePackage(pkg);
                Navigator.pop(ctx, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Save Package'),
          ),
        ],
      ),
    );

    if (result == true) _loadPackages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vacation & Special Experience Packages'),
        backgroundColor: const Color(0xFF162234),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('New Package'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5F86C1), foregroundColor: Colors.white),
            onPressed: _addPackageDialog,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _packages.isEmpty
                ? const Center(child: Text('No vacation packages created yet.'))
                : ListView.builder(
                    itemCount: _packages.length,
                    itemBuilder: (context, index) {
                      final p = _packages[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Icon(Icons.card_giftcard, color: Colors.white),
                          ),
                          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${p.description} • Price: ₹${p.price.toStringAsFixed(0)}'),
                          trailing: Chip(
                            label: Text(p.status.toUpperCase(), style: const TextStyle(fontSize: 10)),
                            backgroundColor: p.status == 'active' ? Colors.green.shade100 : Colors.grey.shade200,
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
