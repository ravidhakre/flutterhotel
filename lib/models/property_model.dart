import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyModel {
  final String propertyId;
  final String propertyName;
  final String propertyType;
  final String description;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final String phone;
  final String email;
  final String checkInTime;
  final String checkOutTime;
  final List<String> amenities;
  final List<String> images;
  final String? gstNumber;
  final double taxPercentage;
  final String currency;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  PropertyModel({
    required this.propertyId,
    required this.propertyName,
    this.propertyType = 'resort',
    required this.description,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    this.latitude,
    this.longitude,
    required this.phone,
    required this.email,
    this.checkInTime = '12:00 PM',
    this.checkOutTime = '10:00 AM',
    this.amenities = const [],
    this.images = const [],
    this.gstNumber,
    this.taxPercentage = 18.0,
    this.currency = 'INR',
    this.status = 'active',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory PropertyModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return PropertyModel(
      propertyId: docId.isNotEmpty ? docId : (map['propertyId'] ?? ''),
      propertyName: map['propertyName'] ?? '',
      propertyType: map['propertyType'] ?? 'resort',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? '',
      pincode: map['pincode'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      checkInTime: map['checkInTime'] ?? '12:00 PM',
      checkOutTime: map['checkOutTime'] ?? '10:00 AM',
      amenities: List<String>.from(map['amenities'] ?? []),
      images: List<String>.from(map['images'] ?? []),
      gstNumber: map['gstNumber'],
      taxPercentage: (map['taxPercentage'] as num?)?.toDouble() ?? 18.0,
      currency: map['currency'] ?? 'INR',
      status: map['status'] ?? 'active',
      createdAt: parseTimestamp(map['createdAt']) ?? DateTime.now(),
      updatedAt: parseTimestamp(map['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'propertyName': propertyName,
      'propertyType': propertyType,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'amenities': amenities,
      'images': images,
      'gstNumber': gstNumber,
      'taxPercentage': taxPercentage,
      'currency': currency,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
