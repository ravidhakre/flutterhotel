import '../core/errors/failure.dart';
import '../models/coupon_model.dart';
import '../services/coupon_service.dart';

class CouponRepository {
  final CouponService _service;

  CouponRepository({CouponService? service}) : _service = service ?? CouponService();

  Future<void> saveCoupon(CouponModel coupon) async {
    try {
      await _service.saveCoupon(coupon);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<CouponModel> validateCoupon({
    required String code,
    required String userId,
    required String propertyId,
    required String roomTypeId,
    required double bookingAmount,
    required int nights,
  }) async {
    try {
      return await _service.validateCoupon(
        code: code,
        userId: userId,
        propertyId: propertyId,
        roomTypeId: roomTypeId,
        bookingAmount: bookingAmount,
        nights: nights,
      );
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
