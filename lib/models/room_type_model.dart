import 'package:cloud_firestore/cloud_firestore.dart';

class RoomTypeModel {
  final String roomTypeId;
  final String propertyId;
  final String name;
  final String description;
  final int maxAdults;
  final int maxChildren;
  final int maxGuests;
  final String bedType;
  final int bedCount;
  final String roomSize;
  final double basePrice;
  final double weekendPrice;
  final double extraAdultPrice;
  final double extraChildPrice;
  final double extraBedPrice;
  final List<String> amenities;
  final List<String> images;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoomTypeModel({
    required this.roomTypeId,
    required this.propertyId,
    required this.name,
    required this.description,
    this.maxAdults = 2,
    this.maxChildren = 1,
    this.maxGuests = 3,
    this.bedType = 'King Bed',
    this.bedCount = 1,
    this.roomSize = '180 sq. ft.',
    required this.basePrice,
    required this.weekendPrice,
    this.extraAdultPrice = 800.0,
    this.extraChildPrice = 400.0,
    this.extraBedPrice = 1000.0,
    this.amenities = const [],
    this.images = const [],
    this.status = 'active',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory RoomTypeModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return RoomTypeModel(
      roomTypeId: docId.isNotEmpty ? docId : (map['roomTypeId'] ?? ''),
      propertyId: map['propertyId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      maxAdults: (map['maxAdults'] as num?)?.toInt() ?? 2,
      maxChildren: (map['maxChildren'] as num?)?.toInt() ?? 1,
      maxGuests: (map['maxGuests'] as num?)?.toInt() ?? 3,
      bedType: map['bedType'] ?? 'King Bed',
      bedCount: (map['bedCount'] as num?)?.toInt() ?? 1,
      roomSize: map['roomSize'] ?? '180 sq. ft.',
      basePrice: (map['basePrice'] as num?)?.toDouble() ?? 0.0,
      weekendPrice: (map['weekendPrice'] as num?)?.toDouble() ?? (map['basePrice'] as num?)?.toDouble() ?? 0.0,
      extraAdultPrice: (map['extraAdultPrice'] as num?)?.toDouble() ?? 800.0,
      extraChildPrice: (map['extraChildPrice'] as num?)?.toDouble() ?? 400.0,
      extraBedPrice: (map['extraBedPrice'] as num?)?.toDouble() ?? 1000.0,
      amenities: List<String>.from(map['amenities'] ?? []),
      images: List<String>.from(map['images'] ?? []),
      status: map['status'] ?? 'active',
      createdAt: parseTimestamp(map['createdAt']) ?? DateTime.now(),
      updatedAt: parseTimestamp(map['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomTypeId': roomTypeId,
      'propertyId': propertyId,
      'name': name,
      'description': description,
      'maxAdults': maxAdults,
      'maxChildren': maxChildren,
      'maxGuests': maxGuests,
      'bedType': bedType,
      'bedCount': bedCount,
      'roomSize': roomSize,
      'basePrice': basePrice,
      'weekendPrice': weekendPrice,
      'extraAdultPrice': extraAdultPrice,
      'extraChildPrice': extraChildPrice,
      'extraBedPrice': extraBedPrice,
      'amenities': amenities,
      'images': images,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
