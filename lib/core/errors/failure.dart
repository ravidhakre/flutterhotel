/// Production failure object for user-friendly error display without exposing raw stack traces.
class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  factory Failure.fromException(dynamic e) {
    if (e.toString().contains('user-not-found')) {
      return const Failure('No user account found with this email address.', code: 'USER_NOT_FOUND');
    } else if (e.toString().contains('wrong-password')) {
      return const Failure('Incorrect password. Please try again.', code: 'WRONG_PASSWORD');
    } else if (e.toString().contains('email-already-in-use')) {
      return const Failure('An account already exists with this email address.', code: 'EMAIL_IN_USE');
    } else if (e.toString().contains('weak-password')) {
      return const Failure('Password is too weak. Please use at least 6 characters.', code: 'WEAK_PASSWORD');
    } else if (e.toString().contains('invalid-email')) {
      return const Failure('Invalid email address format.', code: 'INVALID_EMAIL');
    } else if (e.toString().contains('permission-denied')) {
      return const Failure('Access denied. You do not have permissions for this action.', code: 'PERMISSION_DENIED');
    } else if (e.toString().contains('network-request-failed')) {
      return const Failure('Network error. Please check your internet connection.', code: 'NETWORK_ERROR');
    }

    return Failure(e.toString().replaceAll('AppException:', '').trim(), code: 'GENERIC_ERROR');
  }

  @override
  String toString() => message;
}
