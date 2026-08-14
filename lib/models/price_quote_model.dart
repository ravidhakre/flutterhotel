import 'package:cloud_firestore/cloud_firestore.dart';

class PriceQuoteModel {
  final String quoteId;
  final String userId;
  final String propertyId;
  final String roomTypeId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final int rooms;
  final Map<String, dynamic> breakdown;
  final double total;
  final DateTime expiresAt;
  final DateTime createdAt;

  PriceQuoteModel({
    required this.quoteId,
    required this.userId,
    required this.propertyId,
    required this.roomTypeId,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.rooms,
    required this.breakdown,
    required this.total,
    required this.expiresAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PriceQuoteModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return PriceQuoteModel(
      quoteId: docId.isNotEmpty ? docId : (map['quoteId'] ?? ''),
      userId: map['userId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      roomTypeId: map['roomTypeId'] ?? '',
      checkIn: parseDate(map['checkIn']),
      checkOut: parseDate(map['checkOut']),
      guests: (map['guests'] as num?)?.toInt() ?? 1,
      rooms: (map['rooms'] as num?)?.toInt() ?? 1,
      breakdown: Map<String, dynamic>.from(map['breakdown'] ?? {}),
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      expiresAt: parseDate(map['expiresAt']),
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quoteId': quoteId,
      'userId': userId,
      'propertyId': propertyId,
      'roomTypeId': roomTypeId,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'guests': guests,
      'rooms': rooms,
      'breakdown': breakdown,
      'total': total,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
