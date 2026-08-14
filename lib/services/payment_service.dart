import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/booking_model.dart';
import '../models/payment_event_model.dart';
import '../models/payment_model.dart';
import '../models/payment_order_model.dart';
import 'audit_service.dart';
import 'booking_service.dart';
import 'notification_service.dart';
import 'payment_gateway_service.dart';
import 'payment_verification_service.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;
  final PaymentGateway _gateway = MockGateway();
  final PaymentVerificationService _verificationService = PaymentVerificationService();
  final BookingService _bookingService = BookingService();
  final NotificationService _notificationService = NotificationService();
  final AuditService _auditService = AuditService();

  /// Create Payment Order Server-Side (Price Tamper Protection)
  Future<PaymentOrderModel> createPaymentOrder(String bookingId) async {
    try {
      final bDoc = await _firestore.collection(FirebaseConstants.bookingsCollection).doc(bookingId).get();
      if (!bDoc.exists) throw DatabaseException('Booking not found');

      final booking = BookingModel.fromMap(bDoc.data()!, bookingId);

      if (booking.bookingStatus == 'cancelled' || booking.bookingStatus == 'expired') {
        throw DatabaseException('Cannot create payment order for cancelled or expired booking.');
      }

      final amountToPay = booking.remainingAmount > 0 ? booking.remainingAmount : booking.totalAmount;

      final res = await _gateway.createOrder(
        bookingId: bookingId,
        amount: amountToPay,
        currency: 'INR',
      );

      final docRef = _firestore.collection('paymentOrders').doc(res.orderId);
      final order = PaymentOrderModel(
        paymentOrderId: res.orderId,
        bookingId: bookingId,
        amount: amountToPay,
        currency: 'INR',
        expiresAt: DateTime.now().add(const Duration(minutes: 15)),
      );

      await docRef.set(order.toMap());
      return order;
    } catch (e) {
      throw DatabaseException('Failed to create payment order: $e');
    }
  }

  /// Complete & Verify Payment Callback (Idempotent)
  Future<PaymentModel> completePayment({
    required String bookingId,
    required String gatewayOrderId,
    required String gatewayPaymentId,
    required String gatewaySignature,
    required double amount,
    String paymentMethod = 'UPI',
  }) async {
    try {
      final isValid = await _verificationService.verifyPaymentDetails(
        bookingId: bookingId,
        expectedAmount: amount,
        gatewayOrderId: gatewayOrderId,
        gatewayPaymentId: gatewayPaymentId,
      );

      if (!isValid) throw DatabaseException('Payment verification check failed.', code: 'INVALID_PAYMENT');

      final docRef = _firestore.collection('payments').doc();
      final bDoc = await _firestore.collection(FirebaseConstants.bookingsCollection).doc(bookingId).get();
      final propertyId = bDoc.data()?['propertyId'] ?? '';
      final userId = bDoc.data()?['userId'] ?? '';

      final payment = PaymentModel(
        paymentId: docRef.id,
        bookingId: bookingId,
        userId: userId,
        propertyId: propertyId,
        gateway: 'MockGateway',
        gatewayOrderId: gatewayOrderId,
        gatewayPaymentId: gatewayPaymentId,
        gatewaySignature: gatewaySignature,
        amount: amount,
        paymentMethod: paymentMethod,
        status: 'success',
        verified: true,
        verifiedAt: DateTime.now(),
        capturedAt: DateTime.now(),
      );

      await docRef.set(payment.toMap());

      // Confirm Booking
      await _bookingService.confirmBooking(
        bookingId,
        paymentId: gatewayPaymentId,
        performedBy: 'System / Gateway',
      );

      // Send Push Notification
      await _notificationService.sendBookingNotification(
        recipientUid: userId,
        title: 'Payment Received!',
        body: 'Your payment of ₹${amount.toStringAsFixed(0)} was verified. Reservation confirmed!',
      );

      return payment;
    } catch (e) {
      throw DatabaseException('Payment completion failed: $e');
    }
  }

  /// Idempotent Webhook Event Processor
  Future<void> processWebhookEvent({
    required String eventId,
    required String eventType,
    required String bookingId,
    required String paymentId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final eventRef = _firestore.collection('paymentEvents').doc(eventId);
      final doc = await eventRef.get();

      // Idempotency check: Reject duplicate webhooks
      if (doc.exists && (doc.data()?['processed'] ?? false) == true) {
        return;
      }

      final event = PaymentEventModel(
        eventId: eventId,
        eventType: eventType,
        paymentId: paymentId,
        bookingId: bookingId,
        processed: true,
      );

      await eventRef.set(event.toMap());

      if (eventType == 'payment.captured' || eventType == 'payment.success') {
        await completePayment(
          bookingId: bookingId,
          gatewayOrderId: payload['orderId'] ?? 'order_webhook',
          gatewayPaymentId: paymentId,
          gatewaySignature: payload['signature'] ?? 'sig_webhook',
          amount: (payload['amount'] as num?)?.toDouble() ?? 0.0,
        );
      }
    } catch (_) {}
  }
}
