import 'package:firebase_auth/firebase_auth.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/logger.dart';
import '../firebase/firebase_services.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseServices.auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Register guest user securely with email & password
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.log('Registering guest user: $email');
      final creds = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (creds.user != null) {
        await creds.user!.sendEmailVerification();
      }
      return creds;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration failed', code: e.code);
    } catch (e) {
      throw AuthException('An error occurred during registration: $e');
    }
  }

  /// Sign in with email & password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.log('Signing in user: $email');
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed', code: e.code);
    } catch (e) {
      throw AuthException('An error occurred during sign in: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      AppLogger.log('User signed out successfully.');
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }

  /// Forgot password / Password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      AppLogger.log('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to send password reset email', code: e.code);
    }
  }

  /// Email verification
  Future<void> sendEmailVerification() async {
    try {
      if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
        await _auth.currentUser!.sendEmailVerification();
      }
    } catch (e) {
      throw AuthException('Failed to send email verification: $e');
    }
  }

  /// Account Deletion
  Future<void> deleteAccount() async {
    try {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.delete();
        AppLogger.log('Account deleted successfully.');
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to delete account', code: e.code);
    }
  }

  /// Update Firebase Profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      if (_auth.currentUser != null) {
        if (displayName != null) await _auth.currentUser!.updateDisplayName(displayName);
        if (photoURL != null) await _auth.currentUser!.updatePhotoURL(photoURL);
        await _auth.currentUser!.reload();
      }
    } catch (e) {
      throw AuthException('Failed to update auth profile: $e');
    }
  }
}
