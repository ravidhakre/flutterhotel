import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/addon_model.dart';
import '../models/coupon_model.dart';
import '../models/nightly_rate_model.dart';
import '../models/offer_model.dart';
import '../models/package_model.dart';
import '../models/price_quote_model.dart';
import '../models/property_model.dart';
import '../models/room_type_model.dart';
import 'tax_service.dart';

class PricingBreakdown {
  final List<NightlyRateModel> nightlyRates;
  final double roomBaseTotal;
  final double extraGuestCharges;
  final double packageCharges;
  final double addonCharges;
  final double offerDiscount;
  final double couponDiscount;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;

  PricingBreakdown({
    required this.nightlyRates,
    required this.roomBaseTotal,
    required this.extraGuestCharges,
    required this.packageCharges,
    required this.addonCharges,
    required this.offerDiscount,
    required this.couponDiscount,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'nightlyRates': nightlyRates.map((r) => r.toMap()).toList(),
      'roomBaseTotal': roomBaseTotal,
      'extraGuestCharges': extraGuestCharges,
      'packageCharges': packageCharges,
      'addonCharges': addonCharges,
      'offerDiscount': offerDiscount,
      'couponDiscount': couponDiscount,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
    };
  }
}

class PricingService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;
  final TaxService _taxService = TaxService();

  /// Calculate Price Breakdown following strict 10-step pricing hierarchy
  PricingBreakdown calculateAdvancedPrice({
    required PropertyModel property,
    required RoomTypeModel roomType,
    required DateTime checkIn,
    required DateTime checkOut,
    required int rooms,
    required int adults,
    required int children,
    OfferModel? selectedOffer,
    CouponModel? selectedCoupon,
    PackageModel? selectedPackage,
    List<AddonModel> selectedAddons = const [],
  }) {
    if (checkOut.isBefore(checkIn) || checkOut.isAtSameMomentAs(checkIn)) {
      throw DatabaseException('Check-out date must be after check-in date.', code: 'INVALID_DATES');
    }

    final nights = checkOut.difference(checkIn).inDays;
    if (nights <= 0) {
      throw DatabaseException('Stay must be at least 1 night.', code: 'ZERO_NIGHTS');
    }

    // 1-4. Calculate Nightly Base/Weekend/Seasonal Rate Breakdown
    final nightlyRates = <NightlyRateModel>[];
    double roomBaseTotal = 0.0;

    for (int i = 0; i < nights; i++) {
      final nightDate = checkIn.add(Duration(days: i));
      final isWeekend = nightDate.weekday == DateTime.friday ||
          nightDate.weekday == DateTime.saturday ||
          nightDate.weekday == DateTime.sunday;

      final rate = isWeekend ? roomType.weekendPrice : roomType.basePrice;
      nightlyRates.add(NightlyRateModel(date: nightDate, rate: rate));
      roomBaseTotal += (rate * rooms);
    }

    // 5. Occupancy / Extra Guest Charges
    double extraGuestCharges = 0.0;
    final includedAdults = (roomType.maxAdults > 2 ? 2 : roomType.maxAdults) * rooms;
    if (adults > includedAdults) {
      final extraCount = adults - includedAdults;
      extraGuestCharges = (extraCount * roomType.extraAdultPrice * nights);
    }

    // 6. Package Addition
    double packageCharges = 0.0;
    if (selectedPackage != null) {
      if (selectedPackage.priceType == 'perBooking') {
        packageCharges = selectedPackage.price;
      } else if (selectedPackage.priceType == 'perNight') {
        packageCharges = selectedPackage.price * nights;
      } else {
        packageCharges = selectedPackage.price * rooms;
      }
    }

    // 7. Add-on Additions
    double addonCharges = 0.0;
    for (final addon in selectedAddons) {
      if (addon.pricingType == 'perNight') {
        addonCharges += (addon.price * nights);
      } else {
        addonCharges += addon.price;
      }
    }

    final rawSubtotal = roomBaseTotal + extraGuestCharges + packageCharges + addonCharges;

    // 8. Offer & Coupon Promotional Discounts
    double offerDiscount = 0.0;
    if (selectedOffer != null) {
      if (selectedOffer.discountType == 'percentage') {
        offerDiscount = (rawSubtotal * selectedOffer.discountValue) / 100.0;
      } else {
        offerDiscount = selectedOffer.discountValue;
      }
    }

    double couponDiscount = 0.0;
    if (selectedCoupon != null) {
      if (selectedCoupon.discountType == 'percentage') {
        final calc = (rawSubtotal * selectedCoupon.discountValue) / 100.0;
        couponDiscount = calc > selectedCoupon.maximumDiscount ? selectedCoupon.maximumDiscount : calc;
      } else {
        couponDiscount = selectedCoupon.discountValue;
      }
    }

    // Stacking Check
    if (selectedOffer != null && selectedCoupon != null) {
      if (!selectedOffer.allowStacking && !selectedCoupon.allowStacking) {
        // Take the larger discount
        if (offerDiscount >= couponDiscount) {
          couponDiscount = 0.0;
        } else {
          offerDiscount = 0.0;
        }
      }
    }

    final totalDiscount = offerDiscount + couponDiscount;
    final taxableSubtotal = (rawSubtotal - totalDiscount) > 0 ? (rawSubtotal - totalDiscount) : 0.0;

    // 9. Tax Calculation (18% GST)
    final taxBreakdown = _taxService.calculateTax(
      taxableAmount: taxableSubtotal,
      taxPercentage: property.taxPercentage,
    );

    // 10. Final Price
    final totalAmount = taxableSubtotal + taxBreakdown.totalTaxAmount;

    return PricingBreakdown(
      nightlyRates: nightlyRates,
      roomBaseTotal: roomBaseTotal,
      extraGuestCharges: extraGuestCharges,
      packageCharges: packageCharges,
      addonCharges: addonCharges,
      offerDiscount: offerDiscount,
      couponDiscount: couponDiscount,
      subtotal: taxableSubtotal,
      taxAmount: taxBreakdown.totalTaxAmount,
      totalAmount: totalAmount,
    );
  }

  /// Create Temporary Verified Price Quote
  Future<PriceQuoteModel> createPriceQuote({
    required String userId,
    required String propertyId,
    required String roomTypeId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required int rooms,
    required PricingBreakdown breakdown,
    int validMinutes = 15,
  }) async {
    try {
      final docRef = _firestore.collection('priceQuotes').doc();
      final quote = PriceQuoteModel(
        quoteId: docRef.id,
        userId: userId,
        propertyId: propertyId,
        roomTypeId: roomTypeId,
        checkIn: checkIn,
        checkOut: checkOut,
        guests: guests,
        rooms: rooms,
        breakdown: breakdown.toMap(),
        total: breakdown.totalAmount,
        expiresAt: DateTime.now().add(Duration(minutes: validMinutes)),
      );

      await docRef.set(quote.toMap());
      return quote;
    } catch (e) {
      throw DatabaseException('Failed to create price quote: $e');
    }
  }

  /// Original calculatePrice overload for backwards compatibility
  PricingResult calculatePrice({
    required PropertyModel property,
    required RoomTypeModel roomType,
    required DateTime checkIn,
    required DateTime checkOut,
    required int rooms,
    required int adults,
    required int children,
    double discount = 0.0,
  }) {
    final breakdown = calculateAdvancedPrice(
      property: property,
      roomType: roomType,
      checkIn: checkIn,
      checkOut: checkOut,
      rooms: rooms,
      adults: adults,
      children: children,
    );

    return PricingResult(
      nightlyRates: breakdown.nightlyRates,
      roomPrice: breakdown.roomBaseTotal,
      extraGuestCharges: breakdown.extraGuestCharges,
      subtotal: breakdown.subtotal,
      taxAmount: breakdown.taxAmount,
      totalAmount: breakdown.totalAmount,
    );
  }
}

class PricingResult {
  final List<NightlyRateModel> nightlyRates;
  final double roomPrice;
  final double extraGuestCharges;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;

  PricingResult({
    required this.nightlyRates,
    required this.roomPrice,
    required this.extraGuestCharges,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
  });
}
