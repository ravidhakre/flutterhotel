import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../models/refund_model.dart';
import '../../../services/refund_service.dart';

class AdminRefundsScreen extends StatefulWidget {
  static const String routeName = '/admin/refunds';
  final AdminModel admin;

  const AdminRefundsScreen({Key? key, required this.admin}) : super(key: key);

  @override
  State<AdminRefundsScreen> createState() => _AdminRefundsScreenState();
}

class _AdminRefundsScreenState extends State<AdminRefundsScreen> {
  final RefundService _refundService = RefundService();
  List<RefundModel> _refunds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRefunds();
  }

  Future<void> _loadRefunds() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance.collection('refunds').get();
      final list = snapshot.docs.map((d) => RefundModel.fromMap(d.data(), d.id)).toList();
      setState(() {
        _refunds = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processManualRefundDialog() async {
    final bookingIdCtrl = TextEditingController();
    final paymentIdCtrl = TextEditingController();
    final amountCtrl = TextEditingController(text: '1000');
    final reasonCtrl = TextEditingController(text: 'Customer requested cancellation per policy');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Process Customer Refund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: bookingIdCtrl,
              decoration: const InputDecoration(labelText: 'Booking ID *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: paymentIdCtrl,
              decoration: const InputDecoration(labelText: 'Payment ID *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Refund Amount (₹) *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(labelText: 'Refund Reason *', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (bookingIdCtrl.text.trim().isEmpty) return;
              try {
                await _refundService.processRefund(
                  bookingId: bookingIdCtrl.text.trim(),
                  paymentId: paymentIdCtrl.text.trim(),
                  amount: double.tryParse(amountCtrl.text) ?? 1000.0,
                  reason: reasonCtrl.text.trim(),
                  performedBy: widget.admin.email,
                );
                Navigator.pop(ctx, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Process Refund'),
          ),
        ],
      ),
    );

    if (result == true) _loadRefunds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refund Requests & Disbursements'),
        backgroundColor: const Color(0xFF162234),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.currency_exchange),
            label: const Text('Process Refund'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white),
            onPressed: _processManualRefundDialog,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _refunds.isEmpty
                ? const Center(child: Text('No refund records found.'))
                : ListView.builder(
                    itemCount: _refunds.length,
                    itemBuilder: (context, index) {
                      final r = _refunds[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.money_off, color: Colors.white),
                          ),
                          title: Text('Refund #${r.refundId} — Booking ${r.bookingId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Amount: ₹${r.processedAmount.toStringAsFixed(2)} • Reason: ${r.reason}'),
                          trailing: Chip(
                            label: Text(r.status.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                            backgroundColor: r.status == 'success' ? Colors.green : Colors.orange,
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
