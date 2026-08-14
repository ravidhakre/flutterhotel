import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import '../../../models/cms_banner_model.dart';
import '../../../models/cms_legal_model.dart';
import '../../../services/cms_service.dart';

class AdminCMSScreen extends StatefulWidget {
  static const String routeName = '/admin/cms';
  final AdminModel admin;

  const AdminCMSScreen({Key? key, required this.admin}) : super(key: key);

  @override
  State<AdminCMSScreen> createState() => _AdminCMSScreenState();
}

class _AdminCMSScreenState extends State<AdminCMSScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CMSService _cmsService = CMSService();

  List<CMSBannerModel> _banners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCMSData();
  }

  Future<void> _loadCMSData() async {
    setState(() => _isLoading = true);
    try {
      final bSnapshot = await FirebaseFirestore.instance.collection('cmsBanners').get();
      final bList = bSnapshot.docs.map((d) => CMSBannerModel.fromMap(d.data(), d.id)).toList();
      setState(() {
        _banners = bList;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addBannerDialog() async {
    final titleCtrl = TextEditingController(text: 'Monsoon Retreat 25% Off');
    final subCtrl = TextEditingController(text: 'Experience luxury amidst lush Lansdowne hills');
    final imgCtrl = TextEditingController(text: 'https://images.unsplash.com/photo-1566073771259-6a8506099945');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Homepage Hero Banner'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Banner Title *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subCtrl,
              decoration: const InputDecoration(labelText: 'Subtitle', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: imgCtrl,
              decoration: const InputDecoration(labelText: 'Image URL *', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              try {
                final banner = CMSBannerModel(
                  bannerId: '',
                  title: titleCtrl.text.trim(),
                  subtitle: subCtrl.text.trim(),
                  image: imgCtrl.text.trim(),
                  startDate: DateTime.now(),
                  endDate: DateTime.now().add(const Duration(days: 180)),
                );
                await _cmsService.saveBanner(banner);
                Navigator.pop(ctx, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Save Banner'),
          ),
        ],
      ),
    );

    if (result == true) _loadCMSData();
  }

  Future<void> _updateLegalDialog(String title) async {
    final contentCtrl = TextEditingController(text: 'Standard $title terms and conditions apply to all hotel reservations.');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update $title Content'),
        content: TextField(
          controller: contentCtrl,
          maxLines: 8,
          decoration: const InputDecoration(labelText: 'Markdown / HTML Content *', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (contentCtrl.text.trim().isEmpty) return;
              try {
                final legal = CMSLegalModel(
                  legalId: title.replaceAll(' ', '_').toLowerCase(),
                  title: title,
                  content: contentCtrl.text.trim(),
                  updatedBy: widget.admin.email,
                );
                await _cmsService.saveLegalDocument(legal);
                Navigator.pop(ctx, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Save & Increment Version'),
          ),
        ],
      ),
    );

    if (result == true) _loadCMSData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Management System (CMS)'),
        backgroundColor: const Color(0xFF162234),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.view_carousel), text: 'Homepage Banners'),
            Tab(icon: Icon(Icons.help_outline), text: 'FAQs'),
            Tab(icon: Icon(Icons.gavel), text: 'Legal Versioning'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Banners Tab
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Hero Banner Carousels', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('New Banner'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5F86C1), foregroundColor: Colors.white),
                      onPressed: _addBannerDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _banners.length,
                    itemBuilder: (context, index) {
                      final b = _banners[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.image, color: Colors.blue),
                          title: Text(b.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(b.subtitle),
                          trailing: Chip(label: Text(b.status.toUpperCase(), style: const TextStyle(fontSize: 10))),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // FAQs Tab
          const Center(child: Text('FAQ Category Configurator')),

          // Legal Documents Tab
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                const Text('Version-Controlled Legal Policies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Terms & Conditions'),
                  subtitle: const Text('Governs guest bookings & resort rules'),
                  trailing: ElevatedButton(onPressed: () => _updateLegalDialog('Terms & Conditions'), child: const Text('Edit Version')),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Cancellation & Refund Policy'),
                  subtitle: const Text('Governs cancellation windows and refund fees'),
                  trailing: ElevatedButton(onPressed: () => _updateLegalDialog('Cancellation Policy'), child: const Text('Edit Version')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
