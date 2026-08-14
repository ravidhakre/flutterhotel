import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../models/property_model.dart';
import '../../../services/property_service.dart';
import 'admin_add_edit_property_screen.dart';

class AdminPropertyListScreen extends StatefulWidget {
  static const String routeName = '/admin/properties';
  final AdminModel admin;

  const AdminPropertyListScreen({Key? key, required this.admin}) : super(key: key);

  @override
  State<AdminPropertyListScreen> createState() => _AdminPropertyListScreenState();
}

class _AdminPropertyListScreenState extends State<AdminPropertyListScreen> {
  final PropertyService _propertyService = PropertyService();
  List<PropertyModel> _properties = [];
  List<PropertyModel> _filteredProperties = [];
  bool _isLoading = true;

  final _searchController = TextEditingController();
  String _selectedType = 'All';
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() => _isLoading = true);
    try {
      final list = await _propertyService.getActiveProperties();
      // Filter for propertyAdmin if not superAdmin
      final allowed = widget.admin.role == 'superAdmin'
          ? list
          : list.where((p) => widget.admin.propertyIds.contains(p.propertyId)).toList();

      setState(() {
        _properties = allowed;
        _filteredProperties = allowed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterProperties() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProperties = _properties.where((p) {
        final matchesSearch = p.propertyName.toLowerCase().contains(query) ||
            p.city.toLowerCase().contains(query) ||
            p.propertyId.toLowerCase().contains(query);
        final matchesType = _selectedType == 'All' || p.propertyType.toLowerCase() == _selectedType.toLowerCase();
        final matchesStatus = _selectedStatus == 'All' || p.status.toLowerCase() == _selectedStatus.toLowerCase();

        return matchesSearch && matchesType && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Portfolio Management'),
        backgroundColor: const Color(0xFF162234),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProperties,
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_business),
            label: const Text('Add Property'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5F86C1),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AdminAddEditPropertyScreen(admin: widget.admin),
                ),
              );
              if (result == true) _loadProperties();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Search & Filter Header Bar
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => _filterProperties(),
                        decoration: const InputDecoration(
                          hintText: 'Search by property name, city, or ID...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _selectedType,
                      items: ['All', 'Hotel', 'Resort', 'Villa', 'Apartment', 'Guest House', 'Homestay']
                          .map((t) => DropdownMenuItem(value: t, child: Text('Type: $t')))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          _selectedType = val;
                          _filterProperties();
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _selectedStatus,
                      items: ['All', 'active', 'inactive', 'maintenance']
                          .map((s) => DropdownMenuItem(value: s, child: Text('Status: $s')))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          _selectedStatus = val;
                          _filterProperties();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Data Table / List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredProperties.isEmpty
                      ? const Center(child: Text('No properties found.'))
                      : SingleChildScrollView(
                          child: Container(
                            width: double.infinity,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(const Color(0xFFF4F7FC)),
                              columns: const [
                                DataColumn(label: Text('Property Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('City / Location', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Contact', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: _filteredProperties.map((p) {
                                return DataRow(cells: [
                                  DataCell(
                                    Row(
                                      children: [
                                        const Icon(Icons.location_city, color: Color(0xFF5F86C1)),
                                        const SizedBox(width: 8),
                                        Text(p.propertyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  DataCell(Chip(label: Text(p.propertyType.toUpperCase(), style: const TextStyle(fontSize: 10)))),
                                  DataCell(Text('${p.city}, ${p.state}')),
                                  DataCell(Text(p.phone)),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: p.status == 'active' ? Colors.green.shade100 : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        p.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: p.status == 'active' ? Colors.green.shade900 : Colors.red.shade900,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          tooltip: 'Edit Property',
                                          onPressed: () async {
                                            final res = await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => AdminAddEditPropertyScreen(
                                                  admin: widget.admin,
                                                  property: p,
                                                ),
                                              ),
                                            );
                                            if (res == true) _loadProperties();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
