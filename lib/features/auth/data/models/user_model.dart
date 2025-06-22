import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:renal_care_app/features/auth/domain/entities/user.dart';

/// Model pentru Firestore / API, responsabil de mapare JSON ↔ entitate
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? fcmToken;
  final String? phone;
  final String? county;
  final String? city;
  final String? street;
  final String? houseNumber;
  final Timestamp? dateOfBirth; // Firestore Timestamp
  final bool profileComplete; // stocat ca bool în Firestore

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.fcmToken,
    this.phone,
    this.county,
    this.city,
    this.street,
    this.houseNumber,
    this.dateOfBirth,
    this.profileComplete = false,
  });

  /// Creează un UserModel dintr-un document Firestore
  factory UserModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      name: data['name'] as String,
      email: data['email'] as String,
      role: data['role'] as String,
      fcmToken: data['fcmToken'] as String?,
      phone: data['phone'] as String?,
      county: data['county'],
      city: data['city'],
      street: data['street'],
      houseNumber: data['houseNumber'],
      dateOfBirth: data['dateOfBirth'] as Timestamp?,
      profileComplete: data['profileComplete'] as bool? ?? false,
    );
  }

  /// Creează un UserModel dintr-un JSON generic
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  /// Convertim în JSON pentru a salva în Firestore / API
  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'role': role,
    if (fcmToken != null) 'fcmToken': fcmToken,
    if (phone != null) 'phone': phone,
    if (county != null) 'county': county,
    if (city != null) 'city': city,
    if (street != null) 'street': street,
    if (houseNumber != null) 'houseNumber': houseNumber,
    if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
    'profileComplete': profileComplete,
  };

  /// Convertim în entitatea de domain
  User toEntity() {
    return User(
      uid: uid,
      name: name,
      email: email,
      role: role,
      phone: phone,
      county: county,
      city: city,
      street: street,
      houseNumber: houseNumber,
      dateOfBirth: dateOfBirth?.toDate(),
      profileComplete: profileComplete,
    );
  }

  /// Creează un UserModel din entitatea de domain (dacă ai nevoie)
  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      name: user.name,
      email: user.email,
      role: user.role,
      phone: user.phone,
      county: user.county,
      city: user.city,
      street: user.street,
      houseNumber: user.houseNumber,
      dateOfBirth:
          user.dateOfBirth != null
              ? Timestamp.fromDate(user.dateOfBirth!)
              : null,
      profileComplete: user.profileComplete,
    );
  }
}
