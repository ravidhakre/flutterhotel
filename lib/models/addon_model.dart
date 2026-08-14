import 'package:cloud_firestore/cloud_firestore.dart';

class AddonModel {
  final String addonId;
  final String propertyId;
  final String name;
  final String description;
  final String? image;
  final double price;
  final String pricingType; // perBooking, perRoom, perPerson, perNight, perPersonPerNight
  final double taxPercentage;
  final List<String> roomTypeIds;
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final int maxQuantity;
  final bool requiresApproval;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  AddonModel({
    required this.addonId,
    required this.propertyId,
    required this.name,
    required this.description,
    this.image,
    required this.price,
    this.pricingType = 'perBooking',
    this.taxPercentage = 18.0,
    this.roomTypeIds = const [],
    this.availableFrom,
    this.availableTo,
    this.maxQuantity = 10,
    this.requiresApproval = false,
    this.status = 'active',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory AddonModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return AddonModel(
      addonId: docId.isNotEmpty ? docId : (map['addonId'] ?? ''),
      propertyId: map['propertyId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      image: map['image'],
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      pricingType: map['pricingType'] ?? 'perBooking',
      taxPercentage: (map['taxPercentage'] as num?)?.toDouble() ?? 18.0,
      roomTypeIds: List<String>.from(map['roomTypeIds'] ?? []),
      availableFrom: parseDate(map['availableFrom']),
      availableTo: parseDate(map['availableTo']),
      maxQuantity: (map['maxQuantity'] as num?)?.toInt() ?? 10,
      requiresApproval: map['requiresApproval'] ?? false,
      status: map['status'] ?? 'active',
      createdAt: parseDate(map['createdAt']) ?? DateTime.now(),
      updatedAt: parseDate(map['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'addonId': addonId,
      'propertyId': propertyId,
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      'pricingType': pricingType,
      'taxPercentage': taxPercentage,
      'roomTypeIds': roomTypeIds,
      'availableFrom': availableFrom != null ? Timestamp.fromDate(availableFrom!) : null,
      'availableTo': availableTo != null ? Timestamp.fromDate(availableTo!) : null,
      'maxQuantity': maxQuantity,
      'requiresApproval': requiresApproval,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
