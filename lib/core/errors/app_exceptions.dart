/// Custom production exception classes wrapping backend and Firebase errors.
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: [$code] $message';
}

class AuthException extends AppException {
  AuthException(String message, {String? code}) : super(message, code: code);
}

class PermissionException extends AppException {
  PermissionException(String message, {String? code}) : super(message, code: code);
}

class DatabaseException extends AppException {
  DatabaseException(String message, {String? code}) : super(message, code: code);
}

class StorageException extends AppException {
  StorageException(String message, {String? code}) : super(message, code: code);
}
