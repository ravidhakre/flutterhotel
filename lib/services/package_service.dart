import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/package_model.dart';

class PackageService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;

  /// Save or update package
  Future<void> savePackage(PackageModel package) async {
    try {
      final docRef = package.packageId.isNotEmpty
          ? _firestore.collection('packages').doc(package.packageId)
          : _firestore.collection('packages').doc();

      await docRef.set(package.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw DatabaseException('Failed to save package: $e');
    }
  }

  /// Get active packages for property & room type
  Future<List<PackageModel>> getAvailablePackages(String propertyId, String roomTypeId) async {
    try {
      final snapshot = await _firestore
          .collection('packages')
          .where('propertyId', isEqualTo: propertyId)
          .where('status', isEqualTo: 'active')
          .get();

      return snapshot.docs
          .map((d) => PackageModel.fromMap(d.data(), d.id))
          .where((p) => p.roomTypeIds.isEmpty || p.roomTypeIds.contains(roomTypeId))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch packages: $e');
    }
  }
}
