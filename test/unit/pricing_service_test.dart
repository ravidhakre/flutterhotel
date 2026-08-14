import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hotel/models/coupon_model.dart';
import 'package:flutter_hotel/models/offer_model.dart';
import 'package:flutter_hotel/models/property_model.dart';
import 'package:flutter_hotel/models/room_type_model.dart';
import 'package:flutter_hotel/services/pricing_service.dart';

void main() {
  group('PricingService Unit Tests', () {
    late PricingService pricingService;
    late PropertyModel testProperty;
    late RoomTypeModel testRoomType;

    setUp(() {
      pricingService = PricingService();
      testProperty = PropertyModel(
        propertyId: 'prop_lansdowne',
        propertyName: 'Flutter Resort Lansdowne',
        description: 'Luxury Hill Station Resort',
        address: 'Main Road',
        city: 'Lansdowne',
        state: 'Uttarakhand',
        country: 'India',
        pincode: '246155',
        phone: '+919999999999',
        email: 'info@lansdowne.com',
        taxPercentage: 18.0,
      );

      testRoomType = RoomTypeModel(
        roomTypeId: 'rt_deluxe',
        propertyId: 'prop_lansdowne',
        name: 'Deluxe Room',
        description: 'King Bed Room',
        basePrice: 4000.0,
        weekendPrice: 5000.0,
        extraAdultPrice: 1000.0,
        maxAdults: 2,
      );
    });

    test('Weekday calculation for 1 night returns base price + 18% GST', () {
      final checkIn = DateTime(2026, 9, 14); // Monday
      final checkOut = DateTime(2026, 9, 15); // Tuesday

      final result = pricingService.calculateAdvancedPrice(
        property: testProperty,
        roomType: testRoomType,
        checkIn: checkIn,
        checkOut: checkOut,
        rooms: 1,
        adults: 2,
        children: 0,
      );

      expect(result.roomBaseTotal, 4000.0);
      expect(result.extraGuestCharges, 0.0);
      expect(result.subtotal, 4000.0);
      expect(result.taxAmount, 720.0); // 18% of 4000
      expect(result.totalAmount, 4720.0);
    });

    test('Weekend rate is applied on Friday / Saturday nights', () {
      final checkIn = DateTime(2026, 9, 18); // Friday
      final checkOut = DateTime(2026, 9, 19); // Saturday

      final result = pricingService.calculateAdvancedPrice(
        property: testProperty,
        roomType: testRoomType,
        checkIn: checkIn,
        checkOut: checkOut,
        rooms: 1,
        adults: 2,
        children: 0,
      );

      expect(result.roomBaseTotal, 5000.0); // Weekend price
      expect(result.subtotal, 5000.0);
      expect(result.totalAmount, 5900.0); // 5000 + 18% tax
    });

    test('Extra guest charge is computed correctly', () {
      final checkIn = DateTime(2026, 9, 14);
      final checkOut = DateTime(2026, 9, 16); // 2 nights

      final result = pricingService.calculateAdvancedPrice(
        property: testProperty,
        roomType: testRoomType,
        checkIn: checkIn,
        checkOut: checkOut,
        rooms: 1,
        adults: 3, // 1 extra adult
        children: 0,
      );

      expect(result.roomBaseTotal, 8000.0); // 4000 * 2 nights
      expect(result.extraGuestCharges, 2000.0); // 1 extra adult * 1000 * 2 nights
      expect(result.subtotal, 10000.0);
      expect(result.totalAmount, 11800.0); // 10000 + 18% tax
    });

    test('Coupon discount reduces subtotal before tax calculation', () {
      final checkIn = DateTime(2026, 9, 14);
      final checkOut = DateTime(2026, 9, 15);

      final coupon = CouponModel(
        couponId: 'c1',
        code: 'WELCOME10',
        description: '10% off',
        discountType: 'percentage',
        discountValue: 10.0,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 10)),
      );

      final result = pricingService.calculateAdvancedPrice(
        property: testProperty,
        roomType: testRoomType,
        checkIn: checkIn,
        checkOut: checkOut,
        rooms: 1,
        adults: 2,
        children: 0,
        selectedCoupon: coupon,
      );

      expect(result.roomBaseTotal, 4000.0);
      expect(result.couponDiscount, 400.0); // 10% of 4000
      expect(result.subtotal, 3600.0); // 4000 - 400
      expect(result.taxAmount, 648.0); // 18% of 3600
      expect(result.totalAmount, 4248.0);
    });
  });
}
