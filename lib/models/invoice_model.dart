import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceModel {
  final String invoiceId;
  final String bookingId;
  final String propertyId;
  final String guestId;
  final String invoiceNumber;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final double paid;
  final double balance;
  final String currency;
  final DateTime issuedAt;
  final String status;

  InvoiceModel({
    required this.invoiceId,
    required this.bookingId,
    required this.propertyId,
    required this.guestId,
    required this.invoiceNumber,
    this.items = const [],
    required this.subtotal,
    this.discount = 0.0,
    required this.tax,
    required this.total,
    required this.paid,
    required this.balance,
    this.currency = 'INR',
    DateTime? issuedAt,
    this.status = 'issued',
  }) : issuedAt = issuedAt ?? DateTime.now();

  factory InvoiceModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return InvoiceModel(
      invoiceId: docId.isNotEmpty ? docId : (map['invoiceId'] ?? ''),
      bookingId: map['bookingId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      guestId: map['guestId'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (map['tax'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      paid: (map['paid'] as num?)?.toDouble() ?? 0.0,
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] ?? 'INR',
      issuedAt: parseDate(map['issuedAt']),
      status: map['status'] ?? 'issued',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invoiceId': invoiceId,
      'bookingId': bookingId,
      'propertyId': propertyId,
      'guestId': guestId,
      'invoiceNumber': invoiceNumber,
      'items': items,
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
      'paid': paid,
      'balance': balance,
      'currency': currency,
      'issuedAt': Timestamp.fromDate(issuedAt),
      'status': status,
    };
  }

  static String generateInvoiceNumber() {
    final now = DateTime.now();
    final randomSuffix = (100000 + (now.microsecondsSinceEpoch % 900000)).toString();
    return "INV-${now.year}-$randomSuffix";
  }
}
