import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../models/coupon_model.dart';
import '../../../services/coupon_service.dart';

class AdminCouponsScreen extends StatefulWidget {
  static const String routeName = '/admin/coupons';
  final AdminModel admin;

  const AdminCouponsScreen({Key? key, required this.admin}) : super(key: key);

  @override
  State<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends State<AdminCouponsScreen> {
  final CouponService _couponService = CouponService();
  List<CouponModel> _coupons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance.collection('coupons').get();
      final list = snapshot.docs.map((d) => CouponModel.fromMap(d.data(), d.id)).toList();
      setState(() {
        _coupons = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addCouponDialog() async {
    final codeCtrl = TextEditingController(text: 'WELCOME10');
    final descCtrl = TextEditingController(text: '10% Welcome Discount Code');
    final valCtrl = TextEditingController(text: '10');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Discount Coupon Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeCtrl,
              decoration: const InputDecoration(labelText: 'Coupon Code (UPPERCASE) *', border: OutlineInputBorder()),
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
              decoration: const InputDecoration(labelText: 'Discount Value *', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (codeCtrl.text.trim().isEmpty) return;
              try {
                final coupon = CouponModel(
                  couponId: '',
                  code: codeCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  discountValue: double.tryParse(valCtrl.text) ?? 10.0,
                  startDate: DateTime.now(),
                  endDate: DateTime.now().add(const Duration(days: 180)),
                );
                await _couponService.saveCoupon(coupon);
                Navigator.pop(ctx, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Save Coupon'),
          ),
        ],
      ),
    );

    if (result == true) _loadCoupons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupon Codes & Promo Vouchers'),
        backgroundColor: const Color(0xFF162234),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('New Coupon Code'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5F86C1), foregroundColor: Colors.white),
            onPressed: _addCouponDialog,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _coupons.isEmpty
                ? const Center(child: Text('No coupon codes created yet.'))
                : ListView.builder(
                    itemCount: _coupons.length,
                    itemBuilder: (context, index) {
                      final c = _coupons[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.purple,
                            child: Icon(Icons.confirmation_number, color: Colors.white),
                          ),
                          title: Text(c.code, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                          subtitle: Text('${c.description} • Used: ${c.usedCount}/${c.usageLimit}'),
                          trailing: Chip(
                            label: Text(c.status.toUpperCase(), style: const TextStyle(fontSize: 10)),
                            backgroundColor: c.status == 'active' ? Colors.green.shade100 : Colors.grey.shade200,
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
