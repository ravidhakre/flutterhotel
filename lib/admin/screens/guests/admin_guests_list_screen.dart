import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../models/user_model.dart';

class AdminGuestsListScreen extends StatefulWidget {
  static const String routeName = '/admin/guests';
  final AdminModel admin;

  const AdminGuestsListScreen({Key? key, required this.admin}) : super(Key: key);

  @override
  State<AdminGuestsListScreen> createState() => _AdminGuestsListScreenState();
}

class _AdminGuestsListScreenState extends State<AdminGuestsListScreen> {
  List<UserModel> _guests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGuests();
  }

  Future<void> _loadGuests() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').limit(50).get();
      final list = snapshot.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
      setState(() {
        _guests = list;
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
        title: const Text('Guest CRM Directory'),
        backgroundColor: const Color(0xFF162234),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _guests.isEmpty
                ? const Center(child: Text('No registered guests found.'))
                : ListView.builder(
                    itemCount: _guests.length,
                    itemBuilder: (context, index) {
                      final guest = _guests[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF5F86C1),
                            child: Text(guest.fullName.isNotEmpty ? guest.fullName[0].toUpperCase() : 'G',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(guest.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${guest.email} • ${guest.phone ?? "No phone"}'),
                          trailing: Chip(
                            label: Text(guest.role.toUpperCase(), style: const TextStyle(fontSize: 10)),
                            backgroundColor: Colors.blue.shade50,
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
