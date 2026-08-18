import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for project flutter-3f849
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAOZgBDJWktmesqLnjfXleiw185Ma7cZ0M',
    appId: '1:707109012803:web:947f58cc0143140fe65bf6',
    messagingSenderId: '707109012803',
    projectId: 'flutter-3f849',
    authDomain: 'flutter-3f849.firebaseapp.com',
    storageBucket: 'flutter-3f849.firebasestorage.app',
    measurementId: 'G-HTHJL542PR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAOZgBDJWktmesqLnjfXleiw185Ma7cZ0M',
    appId: '1:707109012803:web:947f58cc0143140fe65bf6',
    messagingSenderId: '707109012803',
    projectId: 'flutter-3f849',
    authDomain: 'flutter-3f849.firebaseapp.com',
    storageBucket: 'flutter-3f849.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAOZgBDJWktmesqLnjfXleiw185Ma7cZ0M',
    appId: '1:707109012803:web:947f58cc0143140fe65bf6',
    messagingSenderId: '707109012803',
    projectId: 'flutter-3f849',
    authDomain: 'flutter-3f849.firebaseapp.com',
    storageBucket: 'flutter-3f849.firebasestorage.app',
  );
}
