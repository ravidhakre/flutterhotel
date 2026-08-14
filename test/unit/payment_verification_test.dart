import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hotel/services/payment_gateway_service.dart';

void main() {
  group('PaymentGateway Verification Unit Tests', () {
    late PaymentGateway gateway;

    setUp(() {
      gateway = MockGateway();
    });

    test('MockGateway signature verification passes for valid signature pattern', () async {
      final orderId = "order_12345";
      final paymentId = "pay_67890";
      final sig = "mock_sig_999";

      final isValid = await gateway.verifySignature(
        orderId: orderId,
        paymentId: paymentId,
        signature: sig,
        secret: 'secret_key',
      );

      expect(isValid, isTrue);
    });

    test('MockGateway order creation returns valid orderId format', () async {
      final res = await gateway.createOrder(
        bookingId: 'HTL-20260814-000100',
        amount: 5000.0,
        currency: 'INR',
      );

      expect(res.success, isTrue);
      expect(res.orderId.startsWith('order_mock_'), isTrue);
    });
  });
}
