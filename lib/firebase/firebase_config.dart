import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../core/utils/logger.dart';
import '../firebase_options.dart';

/// Centralized production initialization for Firebase services.
class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      AppLogger.log('Initializing Firebase Core for flutter-3f849...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      AppLogger.log('Firebase initialized successfully for flutter-3f849.');
    } catch (e, stack) {
      AppLogger.error('Firebase initialization warning: $e', stackTrace: stack);
    }
  }
}
