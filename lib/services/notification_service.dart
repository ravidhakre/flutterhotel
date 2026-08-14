import '../core/utils/logger.dart';

class NotificationService {
  /// Trigger FCM push notification stubs
  Future<void> sendBookingNotification({
    required String recipientUid,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    try {
      AppLogger.log('Sending FCM Notification to $recipientUid: $title - $body');
      // Integration hook for Cloud Messaging / Push Service
    } catch (e) {
      AppLogger.error('Notification dispatch error: $e');
    }
  }
}
