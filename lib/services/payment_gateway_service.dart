import 'dart:convert';
import 'package:crypto/crypto.dart';

class PaymentGatewayResponse {
  final bool success;
  final String orderId;
  final String? paymentId;
  final String? signature;
  final String? errorMessage;

  PaymentGatewayResponse({
    required this.success,
    required this.orderId,
    this.paymentId,
    this.signature,
    this.errorMessage,
  });
}

abstract class PaymentGateway {
  Future<PaymentGatewayResponse> createOrder({
    required String bookingId,
    required double amount,
    required String currency,
  });

  Future<bool> verifySignature({
    required String orderId,
    required String paymentId,
    required String signature,
    required String secret,
  });

  Future<PaymentGatewayResponse> processRefund({
    required String paymentId,
    required double amount,
  });
}

class MockGateway implements PaymentGateway {
  @override
  Future<PaymentGatewayResponse> createOrder({
    required String bookingId,
    required double amount,
    required String currency,
  }) async {
    final orderId = "order_mock_${DateTime.now().millisecondsSinceEpoch}";
    return PaymentGatewayResponse(
      success: true,
      orderId: orderId,
    );
  }

  @override
  Future<bool> verifySignature({
    required String orderId,
    required String paymentId,
    required String signature,
    required String secret,
  }) async {
    final payload = "$orderId|$paymentId";
    final hmac = Hmac(sha256, utf8.encode(secret));
    final expectedSignature = hmac.convert(utf8.encode(payload)).toString();
    return signature == expectedSignature || signature.startsWith("mock_sig_");
  }

  @override
  Future<PaymentGatewayResponse> processRefund({
    required String paymentId,
    required double amount,
  }) async {
    final refundId = "rfnd_mock_${DateTime.now().millisecondsSinceEpoch}";
    return PaymentGatewayResponse(
      success: true,
      orderId: paymentId,
      paymentId: refundId,
    );
  }
}
