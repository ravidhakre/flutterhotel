import '../core/errors/app_exceptions.dart';
import '../models/nightly_rate_model.dart';
import '../models/property_model.dart';
import '../models/room_type_model.dart';

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

class PricingService {
  /// Server-Authoritative Price Recalculation
  /// Protects against client-side price tampering
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
    if (checkOut.isBefore(checkIn) || checkOut.isAtSameMomentAs(checkIn)) {
      throw DatabaseException('Check-out date must be after check-in date.', code: 'INVALID_DATES');
    }

    final nights = checkOut.difference(checkIn).inDays;
    if (nights <= 0) {
      throw DatabaseException('Booking must be for at least 1 night.', code: 'ZERO_NIGHTS');
    }

    final nightlyRates = <NightlyRateModel>[];
    double totalRoomBasePrice = 0.0;

    for (int i = 0; i < nights; i++) {
      final nightDate = checkIn.add(Duration(days: i));
      // Check if night falls on Weekend (Friday / Saturday / Sunday)
      final isWeekend = nightDate.weekday == DateTime.friday ||
          nightDate.weekday == DateTime.saturday ||
          nightDate.weekday == DateTime.sunday;

      final rateForNight = isWeekend ? roomType.weekendPrice : roomType.basePrice;
      nightlyRates.add(NightlyRateModel(date: nightDate, rate: rateForNight));
      totalRoomBasePrice += rateForNight;
    }

    // Multiply room price by number of requested rooms
    final aggregateRoomPrice = totalRoomBasePrice * rooms;

    // Extra guest charges calculation
    double extraGuestCharges = 0.0;
    final includedAdultsPerRoom = roomType.maxAdults > 2 ? 2 : roomType.maxAdults;
    final totalIncludedAdults = includedAdultsPerRoom * rooms;

    if (adults > totalIncludedAdults) {
      final extraAdults = adults - totalIncludedIncludedAdults(totalIncludedAdults);
      extraGuestCharges += (extraAdults * roomType.extraAdultPrice * nights);
    }

    final subtotal = aggregateRoomPrice + extraGuestCharges - discount;
    final taxableSubtotal = subtotal > 0 ? subtotal : 0.0;
    final taxAmount = (taxableSubtotal * property.taxPercentage) / 100.0;
    final totalAmount = taxableSubtotal + taxAmount;

    return PricingResult(
      nightlyRates: nightlyRates,
      roomPrice: aggregateRoomPrice,
      extraGuestCharges: extraGuestCharges,
      subtotal: subtotal,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
    );
  }

  int totalIncludedIncludedAdults(int val) => val;
}
