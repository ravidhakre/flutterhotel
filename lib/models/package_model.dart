import 'package:cloud_firestore/cloud_firestore.dart';

class PackageModel {
  final String packageId;
  final String propertyId;
  final String name;
  final String description;
  final List<String> images;
  final List<String> roomTypeIds;
  final List<Map<String, dynamic>> includedItems; // [{name: "Breakfast", quantity: 2, unit: "persons"}]
  final String priceType; // perBooking, perRoom, perNight, perPerson
  final double price;
  final String discountType;
  final double discountValue;
  final int minimumNights;
  final int maximumNights;
  final DateTime validFrom;
  final DateTime validTo;
  final int maxGuests;
  final String? termsAndConditions;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  PackageModel({
    required this.packageId,
    required this.propertyId,
    required this.name,
    required this.description,
    this.images = const [],
    this.roomTypeIds = const [],
    this.includedItems = const [],
    this.priceType = 'perBooking',
    required this.price,
    this.discountType = 'fixed',
    this.discountValue = 0.0,
    this.minimumNights = 1,
    this.maximumNights = 30,
    required this.validFrom,
    required this.validTo,
    this.maxGuests = 4,
    this.termsAndConditions,
    this.status = 'active',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory PackageModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return PackageModel(
      packageId: docId.isNotEmpty ? docId : (map['packageId'] ?? ''),
      propertyId: map['propertyId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      roomTypeIds: List<String>.from(map['roomTypeIds'] ?? []),
      includedItems: List<Map<String, dynamic>>.from(map['includedItems'] ?? []),
      priceType: map['priceType'] ?? 'perBooking',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      discountType: map['discountType'] ?? 'fixed',
      discountValue: (map['discountValue'] as num?)?.toDouble() ?? 0.0,
      minimumNights: (map['minimumNights'] as num?)?.toInt() ?? 1,
      maximumNights: (map['maximumNights'] as num?)?.toInt() ?? 30,
      validFrom: parseDate(map['validFrom']),
      validTo: parseDate(map['validTo']),
      maxGuests: (map['maxGuests'] as num?)?.toInt() ?? 4,
      termsAndConditions: map['termsAndConditions'],
      status: map['status'] ?? 'active',
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'packageId': packageId,
      'propertyId': propertyId,
      'name': name,
      'description': description,
      'images': images,
      'roomTypeIds': roomTypeIds,
      'includedItems': includedItems,
      'priceType': priceType,
      'price': price,
      'discountType': discountType,
      'discountValue': discountValue,
      'minimumNights': minimumNights,
      'maximumNights': maximumNights,
      'validFrom': Timestamp.fromDate(validFrom),
      'validTo': Timestamp.fromDate(validTo),
      'maxGuests': maxGuests,
      'termsAndConditions': termsAndConditions,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
