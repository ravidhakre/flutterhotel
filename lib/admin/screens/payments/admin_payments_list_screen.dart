import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../models/payment_model.dart';

class AdminPaymentsListScreen extends StatefulWidget {
  static const String routeName = '/admin/payments';
  final AdminModel admin;

  const AdminPaymentsListScreen({Key? key, required this.admin}) : super(key: key);

  @override
  State<AdminPaymentsListScreen> createState() => _AdminPaymentsListScreenState();
}

class _AdminPaymentsListScreenState extends State<AdminPaymentsListScreen> {
  List<PaymentModel> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('payments')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final list = snapshot.docs.map((d) => PaymentModel.fromMap(d.data(), d.id)).toList();
      setState(() {
        _payments = list;
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
        title: const Text('Payment Transactions Ledger'),
        backgroundColor: const Color(0xFF162234),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPayments),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _payments.isEmpty
                ? const Center(child: Text('No payment transactions recorded yet.'))
                : SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(const Color(0xFFF4F7FC)),
                        columns: const [
                          DataColumn(label: Text('Transaction ID', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Booking ID', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Method / Gateway', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Verified', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _payments.map((p) {
                          return DataRow(cells: [
                            DataCell(Text(p.paymentId, style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(p.bookingId, style: const TextStyle(color: Color(0xFF5F86C1)))),
                            DataCell(Text('${p.paymentMethod} (${p.gateway})')),
                            DataCell(Text('₹${p.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Icon(
                              p.verified ? Icons.verified : Icons.error_outline,
                              color: p.verified ? Colors.green : Colors.red,
                              size: 18,
                            )),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: p.status == 'success' ? Colors.green.shade100 : Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(p.status.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
      ),
    );
  }
}
