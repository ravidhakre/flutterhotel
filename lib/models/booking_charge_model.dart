import 'package:cloud_firestore/cloud_firestore.dart';

class BookingChargeModel {
  final String chargeId;
  final String bookingId;
  final String propertyId;
  final String name;
  final String category; // room, food, service, addon, damage, lateCheckout, extraBed, other
  final int quantity;
  final double unitPrice;
  final double tax;
  final double total;
  final String addedBy;
  final DateTime createdAt;

  BookingChargeModel({
    required this.chargeId,
    required this.bookingId,
    required this.propertyId,
    required this.name,
    this.category = 'other',
    this.quantity = 1,
    required this.unitPrice,
    this.tax = 0.0,
    required this.total,
    required this.addedBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory BookingChargeModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return BookingChargeModel(
      chargeId: docId.isNotEmpty ? docId : (map['chargeId'] ?? ''),
      bookingId: map['bookingId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? 'other',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      tax: (map['tax'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      addedBy: map['addedBy'] ?? 'Admin',
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chargeId': chargeId,
      'bookingId': bookingId,
      'propertyId': propertyId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'tax': tax,
      'total': total,
      'addedBy': addedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
