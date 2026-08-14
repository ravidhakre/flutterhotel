import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../models/audit_log_model.dart';

class AdminActivityLogsScreen extends StatefulWidget {
  static const String routeName = '/admin/activity-logs';
  final AdminModel admin;

  const AdminActivityLogsScreen({Key? key, required this.admin}) : super(key: key);

  @override
  State<AdminActivityLogsScreen> createState() => _AdminActivityLogsScreenState();
}

class _AdminActivityLogsScreenState extends State<AdminActivityLogsScreen> {
  List<AuditLogModel> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('auditLogs')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      final list = snapshot.docs.map((d) => AuditLogModel.fromMap(d.data(), d.id)).toList();
      setState(() {
        _logs = list;
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
        title: const Text('Administrative System Audit Trail'),
        backgroundColor: const Color(0xFF162234),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadLogs),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _logs.isEmpty
                ? const Center(child: Text('No audit logs recorded yet.'))
                : ListView.builder(
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF5F86C1),
                            child: Icon(Icons.security, color: Colors.white),
                          ),
                          title: Text('${log.action} • Module: ${log.module}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('By: ${log.performedBy} • Target ID: ${log.recordId} • Time: ${log.timestamp}'),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
