import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../services/reconciliation_service.dart';

class AdminReconciliationScreen extends StatefulWidget {
  static const String routeName = '/admin/reconciliation';
  final AdminModel admin;
  final String propertyId;

  const AdminReconciliationScreen({
    Key? key,
    required this.admin,
    this.propertyId = 'prop_default',
  }) : super(key: key);

  @override
  State<AdminReconciliationScreen> createState() => _AdminReconciliationScreenState();
}

class _AdminReconciliationScreenState extends State<AdminReconciliationScreen> {
  final ReconciliationService _service = ReconciliationService();
  List<ReconciliationResult> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _runAudit();
  }

  Future<void> _runAudit() async {
    setState(() => _isLoading = true);
    try {
      final list = await _service.runReconciliationAudit(widget.propertyId);
      setState(() {
        _results = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Reconciliation Audit'),
        backgroundColor: const Color(0xFF162234),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _runAudit),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _results.isEmpty
                ? const Center(child: Text('No reconciliation mismatches found. Internal and gateway ledgers match!'))
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final item = _results[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Icon(
                            item.status == 'Matched' ? Icons.check_circle : Icons.warning,
                            color: item.status == 'Matched' ? Colors.green : Colors.red,
                          ),
                          title: Text('Payment #${item.paymentId} — Booking ${item.bookingId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Internal: ₹${item.internalAmount.toStringAsFixed(2)} | Gateway: ₹${item.gatewayAmount.toStringAsFixed(2)}'),
                          trailing: Chip(
                            label: Text(item.status.toUpperCase(), style: const TextStyle(fontSize: 10)),
                            backgroundColor: item.status == 'Matched' ? Colors.green.shade100 : Colors.red.shade100,
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
