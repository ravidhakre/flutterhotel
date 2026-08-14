import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/coupon_model.dart';
import '../models/coupon_usage_model.dart';
import 'audit_service.dart';

class CouponService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;
  final AuditService _auditService = AuditService();

  /// Create or update coupon code
  Future<void> saveCoupon(CouponModel coupon) async {
    try {
      final docRef = coupon.couponId.isNotEmpty
          ? _firestore.collection('coupons').doc(coupon.couponId)
          : _firestore.collection('coupons').doc();

      await docRef.set(coupon.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw DatabaseException('Failed to save coupon: $e');
    }
  }

  /// Server-Authoritative Coupon Code Validation
  Future<CouponModel> validateCoupon({
    required String code,
    required String userId,
    required String propertyId,
    required String roomTypeId,
    required double bookingAmount,
    required int nights,
  }) async {
    try {
      final normalizedCode = code.trim().toUpperCase();
      final snapshot = await _firestore
          .collection('coupons')
          .where('code', isEqualTo: normalizedCode)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw DatabaseException('Invalid or expired coupon code.', code: 'INVALID_COUPON');
      }

      final coupon = CouponModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
      final now = DateTime.now();

      if (now.isBefore(coupon.startDate) || now.isAfter(coupon.endDate.add(const Duration(days: 1)))) {
        throw DatabaseException('Coupon code has expired.', code: 'COUPON_EXPIRED');
      }

      if (bookingAmount < coupon.minimumBookingAmount) {
        throw DatabaseException('Booking amount must be at least ₹${coupon.minimumBookingAmount.toStringAsFixed(0)} to apply code.', code: 'MIN_AMOUNT_NOT_MET');
      }

      if (nights < coupon.minimumNights || nights > coupon.maximumNights) {
        throw DatabaseException('Stay duration does not satisfy coupon night requirements.', code: 'NIGHTS_MISMATCH');
      }

      if (coupon.usedCount >= coupon.usageLimit) {
        throw DatabaseException('Coupon usage limit has been reached.', code: 'GLOBAL_LIMIT_REACHED');
      }

      // Per-user usage limit check
      final userUsagesSnapshot = await _firestore
          .collection('couponUsages')
          .where('couponId', isEqualTo: coupon.couponId)
          .where('userId', isEqualTo: userId)
          .get();

      if (userUsagesSnapshot.docs.length >= coupon.perUserLimit) {
        throw DatabaseException('You have already used this coupon code maximum times allowed.', code: 'USER_LIMIT_REACHED');
      }

      return coupon;
    } catch (e) {
      throw DatabaseException('Coupon validation failed: $e');
    }
  }

  /// Record Coupon Usage after booking hold/confirmation
  Future<void> recordCouponUsage({
    required String couponId,
    required String couponCode,
    required String userId,
    required String bookingId,
    required double discountAmount,
  }) async {
    try {
      final docRef = _firestore.collection('couponUsages').doc();
      final usage = CouponUsageModel(
        usageId: docRef.id,
        couponId: couponId,
        couponCode: couponCode.toUpperCase(),
        userId: userId,
        bookingId: bookingId,
        discountAmount: discountAmount,
      );

      await docRef.set(usage.toMap());

      // Increment usedCount on coupon doc
      await _firestore.collection('coupons').doc(couponId).update({
        'usedCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DatabaseException('Failed to record coupon usage: $e');
    }
  }
}
