import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../models/offer_model.dart';
import '../../../services/offer_service.dart';

class AdminOffersScreen extends StatefulWidget {
  static const String routeName = '/admin/offers';
  final AdminModel admin;

  const AdminOffersScreen({Key? key, required this.admin}) : super(key: key);

  @override
  State<AdminOffersScreen> createState() => _AdminOffersScreenState();
}

class _AdminOffersScreenState extends State<AdminOffersScreen> {
  final OfferService _offerService = OfferService();
  List<OfferModel> _offers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance.collection('offers').get();
      final list = snapshot.docs.map((d) => OfferModel.fromMap(d.data(), d.id)).toList();
      setState(() {
        _offers = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addOfferDialog() async {
    final nameCtrl = TextEditingController();
    final valCtrl = TextEditingController(text: '15');
    final descCtrl = TextEditingController(text: 'Monsoon Special Discount');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Commercial Offer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Offer Title *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Discount Percentage (%) *', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              try {
                final offer = OfferModel(
                  offerId: '',
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  discountValue: double.tryParse(valCtrl.text) ?? 15.0,
                  startDate: DateTime.now(),
                  endDate: DateTime.now().add(const Duration(days: 90)),
                  createdBy: widget.admin.email,
                );
                await _offerService.saveOffer(offer);
                Navigator.pop(ctx, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Save Offer'),
          ),
        ],
      ),
    );

    if (result == true) _loadOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotional Offers & Campaign Engine'),
        backgroundColor: const Color(0xFF162234),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('New Offer'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5F86C1), foregroundColor: Colors.white),
            onPressed: _addOfferDialog,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _offers.isEmpty
                ? const Center(child: Text('No promotional offers created yet.'))
                : ListView.builder(
                    itemCount: _offers.length,
                    itemBuilder: (context, index) {
                      final offer = _offers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF5F86C1),
                            child: Icon(Icons.local_offer, color: Colors.white),
                          ),
                          title: Text(offer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${offer.description} • Discount: ${offer.discountValue.toStringAsFixed(0)}% • Priority: P${offer.priority}'),
                          trailing: Chip(
                            label: Text(offer.status.toUpperCase(), style: const TextStyle(fontSize: 10)),
                            backgroundColor: offer.status == 'active' ? Colors.green.shade100 : Colors.grey.shade200,
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
