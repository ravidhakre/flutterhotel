import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/addon_model.dart';

class AddonService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;

  /// Save or update add-on item
  Future<void> saveAddon(AddonModel addon) async {
    try {
      final docRef = addon.addonId.isNotEmpty
          ? _firestore.collection('addons').doc(addon.addonId)
          : _firestore.collection('addons').doc();

      await docRef.set(addon.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw DatabaseException('Failed to save add-on: $e');
    }
  }

  /// Get active add-ons for property
  Future<List<AddonModel>> getAvailableAddons(String propertyId) async {
    try {
      final snapshot = await _firestore
          .collection('addons')
          .where('propertyId', isEqualTo: propertyId)
          .where('status', isEqualTo: 'active')
          .get();

      return snapshot.docs.map((d) => AddonModel.fromMap(d.data(), d.id)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch add-ons: $e');
    }
  }
}
