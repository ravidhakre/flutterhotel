import 'package:firebase_auth/firebase_auth.dart';
import '../core/errors/failure.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthRepository {
  final AuthService _authService;
  final UserService _userService;

  AuthRepository({AuthService? authService, UserService? userService})
      : _authService = authService ?? AuthService(),
        _userService = userService ?? UserService();

  Stream<User?> get authStateChanges => _authService.authStateChanges;
  User? get currentUser => _authService.currentUser;

  /// Clean register flow with Firestore User document creation
  Future<UserModel> registerGuest({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final creds = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = creds.user!.uid;
      final newUser = UserModel(
        uid: uid,
        fullName: fullName,
        email: email,
        phone: phone,
        role: 'guest',
        status: 'active',
        emailVerified: creds.user?.emailVerified ?? false,
      );

      await _userService.createUserDoc(newUser);
      return newUser;
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  /// Clean login flow returning user profile
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final creds = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = creds.user!.uid;
      final profile = await _userService.getUserProfile(uid);
      
      if (profile == null) {
        // Create fallback if profile doc missing
        final fallback = UserModel(
          uid: uid,
          fullName: creds.user?.displayName ?? 'Guest User',
          email: email,
          emailVerified: creds.user?.emailVerified ?? false,
        );
        await _userService.createUserDoc(fallback);
        return fallback;
      }

      await _userService.updateLastLogin(uid);
      return profile;
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  /// Forgot password
  Future<void> sendPasswordReset(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
