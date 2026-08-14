import 'package:cloud_firestore/cloud_firestore.dart';
import 'nightly_rate_model.dart';

class BookingModel {
  final String bookingId;
  final String userId;
  final String propertyId;
  final String roomTypeId;
  final String? roomId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final int adults;
  final int children;
  final int rooms;
  final Map<String, dynamic> guestDetails;
  final double roomPrice;
  final List<NightlyRateModel> nightlyRates;
  final double extraGuestCharges;
  final double addonCharges;
  final double packageCharges;
  final double discount;
  final double tax;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String? couponCode;
  final String? offerId;
  final String paymentStatus;
  final String bookingStatus;
  final String holdStatus;
  final DateTime? holdExpiresAt;
  final String? cancellationStatus;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;

  BookingModel({
    required this.bookingId,
    required this.userId,
    required this.propertyId,
    required this.roomTypeId,
    this.roomId,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    this.adults = 2,
    this.children = 0,
    this.rooms = 1,
    this.guestDetails = const {},
    required this.roomPrice,
    this.nightlyRates = const [],
    this.extraGuestCharges = 0.0,
    this.addonCharges = 0.0,
    this.packageCharges = 0.0,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.totalAmount,
    this.paidAmount = 0.0,
    required this.remainingAmount,
    this.couponCode,
    this.offerId,
    this.paymentStatus = 'pending',
    this.bookingStatus = 'pending',
    this.holdStatus = 'active',
    this.holdExpiresAt,
    this.cancellationStatus,
    this.source = 'website',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.confirmedAt,
    this.cancelledAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory BookingModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final rawRates = map['nightlyRates'] as List<dynamic>? ?? [];
    final rates = rawRates.map((r) => NightlyRateModel.fromMap(Map<String, dynamic>.from(r))).toList();

    return BookingModel(
      bookingId: docId.isNotEmpty ? docId : (map['bookingId'] ?? ''),
      userId: map['userId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      roomTypeId: map['roomTypeId'] ?? '',
      roomId: map['roomId'],
      checkIn: parseDate(map['checkIn']) ?? DateTime.now(),
      checkOut: parseDate(map['checkOut']) ?? DateTime.now(),
      nights: (map['nights'] as num?)?.toInt() ?? 1,
      adults: (map['adults'] as num?)?.toInt() ?? 2,
      children: (map['children'] as num?)?.toInt() ?? 0,
      rooms: (map['rooms'] as num?)?.toInt() ?? 1,
      guestDetails: Map<String, dynamic>.from(map['guestDetails'] ?? {}),
      roomPrice: (map['roomPrice'] as num?)?.toDouble() ?? 0.0,
      nightlyRates: rates,
      extraGuestCharges: (map['extraGuestCharges'] as num?)?.toDouble() ?? 0.0,
      addonCharges: (map['addonCharges'] as num?)?.toDouble() ?? 0.0,
      packageCharges: (map['packageCharges'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (map['tax'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (map['paidAmount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (map['remainingAmount'] as num?)?.toDouble() ?? 0.0,
      couponCode: map['couponCode'],
      offerId: map['offerId'],
      paymentStatus: map['paymentStatus'] ?? 'pending',
      bookingStatus: map['bookingStatus'] ?? 'pending',
      holdStatus: map['holdStatus'] ?? 'active',
      holdExpiresAt: parseDate(map['holdExpiresAt']),
      cancellationStatus: map['cancellationStatus'],
      source: map['source'] ?? 'website',
      createdAt: parseDate(map['createdAt']) ?? DateTime.now(),
      updatedAt: parseDate(map['updatedAt']) ?? DateTime.now(),
      confirmedAt: parseDate(map['confirmedAt']),
      cancelledAt: parseDate(map['cancelledAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'propertyId': propertyId,
      'roomTypeId': roomTypeId,
      'roomId': roomId,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'nights': nights,
      'adults': adults,
      'children': children,
      'rooms': rooms,
      'guestDetails': guestDetails,
      'roomPrice': roomPrice,
      'nightlyRates': nightlyRates.map((r) => r.toMap()).toList(),
      'extraGuestCharges': extraGuestCharges,
      'addonCharges': addonCharges,
      'packageCharges': packageCharges,
      'discount': discount,
      'tax': tax,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'couponCode': couponCode,
      'offerId': offerId,
      'paymentStatus': paymentStatus,
      'bookingStatus': bookingStatus,
      'holdStatus': holdStatus,
      'holdExpiresAt': holdExpiresAt != null ? Timestamp.fromDate(holdExpiresAt!) : null,
      'cancellationStatus': cancellationStatus,
      'source': source,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
    };
  }

  static String generateBookingId() {
    final now = DateTime.now();
    final dateStr = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    final randomSuffix = (100000 + (now.microsecondsSinceEpoch % 900000)).toString();
    return "HTL-$dateStr-$randomSuffix";
  }
}
