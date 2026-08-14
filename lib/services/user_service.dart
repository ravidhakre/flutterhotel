import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/logger.dart';
import '../firebase/firebase_services.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;

  /// Create new user document in Firestore on registration
  Future<void> createUserDoc(UserModel user) async {
    try {
      AppLogger.log('Creating Firestore user profile for UID: ${user.uid}');
      // Security Check: Force guest role for client registration
      final safeUser = user.copyWith(role: 'guest');
      
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .set(safeUser.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw DatabaseException('Failed to create user document: $e');
    }
  }

  /// Get user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw DatabaseException('Failed to fetch user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      // Prevent updating role via normal user profile updates
      data.remove('role');
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .update(data);
    } catch (e) {
      throw DatabaseException('Failed to update user profile: $e');
    }
  }

  /// Update last login timestamp
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .update({'lastLoginAt': FieldValue.serverTimestamp()});
    } catch (_) {}
  }
}
