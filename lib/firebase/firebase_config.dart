import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../core/utils/logger.dart';

/// Centralized production initialization for Firebase services.
class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      AppLogger.log('Initializing Firebase Core...');
      await Firebase.initializeApp();
      AppLogger.log('Firebase initialized successfully.');
    } catch (e, stack) {
      AppLogger.error('Firebase initialization warning: $e', stackTrace: stack);
      // Allows offline or default fallback startup without crashing
    }
  }
}
