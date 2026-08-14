import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/property_model.dart';

class PropertyService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;

  /// Fetch active properties
  Future<List<PropertyModel>> getActiveProperties() async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.propertiesCollection)
          .where('status', isEqualTo: 'active')
          .get();

      return snapshot.docs.map((doc) => PropertyModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch properties: $e');
    }
  }

  /// Get single property by ID
  Future<PropertyModel?> getPropertyById(String propertyId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.propertiesCollection)
          .doc(propertyId)
          .get();
      if (!doc.exists || doc.data() == null) return null;
      return PropertyModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw DatabaseException('Failed to fetch property details: $e');
    }
  }

  /// Create/Update property (Admin only)
  Future<void> saveProperty(PropertyModel property) async {
    try {
      await _firestore
          .collection(FirebaseConstants.propertiesCollection)
          .doc(property.propertyId)
          .set(property.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw DatabaseException('Failed to save property: $e');
    }
  }
}
