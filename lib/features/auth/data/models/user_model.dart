import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:renal_care_app/features/auth/domain/entities/user.dart';

/// Model pentru Firestore / API, responsabil de mapare JSON ↔ entitate
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  /// Creează un UserModel dintr-un document Firestore
  factory UserModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      name: data['name'] as String,
      email: data['email'] as String,
      role: data['role'] as String,
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
  Map<String, dynamic> toJson() => {'name': name, 'email': email, 'role': role};

  /// Convertim în entitatea de domain
  User toEntity() {
    return User(uid: uid, name: name, email: email, role: role);
  }

  /// Creează un UserModel din entitatea de domain (dacă ai nevoie)
  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      name: user.name,
      email: user.email,
      role: user.role,
    );
  }
}
