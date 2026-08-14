import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/role_constants.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/utils/logger.dart';
import '../../firebase/firebase_services.dart';
import '../../models/admin_model.dart';

class AdminAuthService {
  final FirebaseAuth _auth = FirebaseServices.auth;

  /// Secure Admin Login with strict backend role verification
  Future<AdminModel> signInAdmin({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.log('Attempting Admin Auth for $email');
      final creds = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = creds.user!.uid;

      // 1. Fetch document from admins/{uid} collection
      final adminDoc = await FirebaseServices.firestore
          .collection('admins')
          .doc(uid)
          .get();

      if (!adminDoc.exists || adminDoc.data() == null) {
        await _auth.signOut();
        throw PermissionException('Unauthorized: No admin privileges found for this account.', code: 'NOT_AN_ADMIN');
      }

      final admin = AdminModel.fromMap(adminDoc.data()!, uid);

      // 2. Strict status and role check
      if (admin.status != 'active') {
        await _auth.signOut();
        throw PermissionException('Account disabled. Contact Super Admin.', code: 'ADMIN_DISABLED');
      }

      if (!RoleConstants.isAdminRole(admin.role)) {
        await _auth.signOut();
        throw PermissionException('Forbidden: Role does not allow admin access.', code: 'ROLE_FORBIDDEN');
      }

      // Update last login timestamp
      await FirebaseServices.firestore.collection('admins').doc(uid).update({
        'lastLoginAt': DateTime.now(),
      });

      return admin;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Admin login failed', code: e.code);
    }
  }

  Future<void> adminSignOut() async {
    await _auth.signOut();
  }
}
