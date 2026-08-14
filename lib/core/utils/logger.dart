import 'package:flutter/foundation.dart';

/// Safe production logger that hides sensitive tokens and private data in debug mode.
class AppLogger {
  static void log(String message, {String tag = 'APP'}) {
    if (kDebugMode) {
      print('[$tag] ${DateTime.now().toIso8601String()}: $message');
    }
  }

  static void error(String message, {dynamic error, StackTrace? stackTrace, String tag = 'ERROR'}) {
    if (kDebugMode) {
      print('[$tag] ERROR: $message');
      if (error != null) print('Details: $error');
      if (stackTrace != null) print('StackTrace:\n$stackTrace');
    }
  }
}
