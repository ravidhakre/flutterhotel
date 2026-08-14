import '../core/errors/failure.dart';
import '../services/notification_service.dart';

class NotificationRepository {
  final NotificationService _service;

  NotificationRepository({NotificationService? service}) : _service = service ?? NotificationService();

  Future<void> sendNotification({
    required String recipientUid,
    required String title,
    required String body,
  }) async {
    try {
      await _service.sendBookingNotification(recipientUid: recipientUid, title: title, body: body);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
