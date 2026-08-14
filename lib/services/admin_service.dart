import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../core/constants/role_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/logger.dart';
import '../firebase/firebase_services.dart';
import '../models/admin_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;

  /// Fetch admin document by UID
  Future<AdminModel?> getAdminDoc(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.adminsCollection)
          .doc(uid)
          .get();
      if (!doc.exists || doc.data() == null) return null;
      return AdminModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw DatabaseException('Failed to fetch admin profile: $e');
    }
  }

  /// Verify if user is an authorized active admin
  Future<bool> isAdmin(String uid) async {
    try {
      final admin = await getAdminDoc(uid);
      return admin != null && admin.status == 'active' && RoleConstants.isAdminRole(admin.role);
    } catch (_) {
      return false;
    }
  }

  /// Check property access permission for multi-property admins
  bool hasPropertyAccess(AdminModel admin, String propertyId) {
    if (admin.role == RoleConstants.superAdmin) return true;
    return admin.propertyIds.contains(propertyId);
  }

  /// Check specific permission
  bool hasPermission(AdminModel admin, String permission) {
    if (admin.role == RoleConstants.superAdmin) return true;
    return admin.permissions.contains(permission);
  }

  /// Register or assign a new admin record (Super Admin restricted)
  Future<void> createAdminRecord(AdminModel admin) async {
    try {
      AppLogger.log('Creating Admin record for ${admin.email} with role: ${admin.role}');
      await _firestore
          .collection(FirebaseConstants.adminsCollection)
          .doc(admin.uid)
          .set(admin.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw DatabaseException('Failed to create admin record: $e');
    }
  }
}
