import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final List<String> propertyIds;
  final List<String> permissions;
  final String status;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  AdminModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.propertyIds = const [],
    this.permissions = const [],
    this.status = 'active',
    this.profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastLoginAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory AdminModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return AdminModel(
      uid: docId.isNotEmpty ? docId : (map['uid'] ?? ''),
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      role: map['role'] ?? 'propertyAdmin',
      propertyIds: List<String>.from(map['propertyIds'] ?? []),
      permissions: List<String>.from(map['permissions'] ?? []),
      status: map['status'] ?? 'active',
      profileImage: map['profileImage'],
      createdAt: parseTimestamp(map['createdAt']) ?? DateTime.now(),
      updatedAt: parseTimestamp(map['updatedAt']) ?? DateTime.now(),
      lastLoginAt: parseTimestamp(map['lastLoginAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'propertyIds': propertyIds,
      'permissions': permissions,
      'status': status,
      'profileImage': profileImage,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  AdminModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    List<String>? propertyIds,
    List<String>? permissions,
    String? status,
    String? profileImage,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return AdminModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      propertyIds: propertyIds ?? this.propertyIds,
      permissions: permissions ?? this.permissions,
      status: status ?? this.status,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
