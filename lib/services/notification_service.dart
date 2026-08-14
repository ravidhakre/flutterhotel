import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/logger.dart';
import '../firebase/firebase_services.dart';
import '../models/notification_model.dart';
import '../models/user_device_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;

  /// Dispatch Push & Inbox Notification
  Future<void> sendBookingNotification({
    required String recipientUid,
    required String title,
    required String body,
    String type = 'booking',
    String referenceType = 'booking',
    String referenceId = '',
  }) async {
    try {
      AppLogger.log('Sending Notification to $recipientUid: $title - $body');

      final docRef = _firestore.collection('notifications').doc();
      final notification = NotificationModel(
        notificationId: docRef.id,
        userId: recipientUid,
        type: type,
        title: title,
        body: body,
        referenceType: referenceType,
        referenceId: referenceId,
      );

      await docRef.set(notification.toMap());
    } catch (e) {
      AppLogger.error('Notification dispatch error: $e');
    }
  }

  /// Register or update user device FCM token
  Future<void> registerDeviceToken({
    required String userId,
    required String deviceToken,
    String platform = 'web',
  }) async {
    try {
      final docRef = _firestore.collection('userDevices').doc(deviceToken);
      final device = UserDeviceModel(
        deviceId: deviceToken,
        userId: userId,
        deviceToken: deviceToken,
        platform: platform,
      );

      await docRef.set(device.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  /// Mark notification as read
  Future<void> markNotificationRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({'read': true});
    } catch (_) {}
  }
}
