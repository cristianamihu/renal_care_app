import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'dart:developer' as developer;

import 'package:renal_care_app/features/auth/data/models/user_model.dart';
import 'package:renal_care_app/features/auth/data/services/auth_remote_service.dart';
import 'package:renal_care_app/features/auth/domain/entities/user.dart';
import 'package:renal_care_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteService _remote;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthRepositoryImpl(this._remote);

  @override
  Future<User> signIn({required String email, required String password}) async {
    // Autentificăm în FirebaseAuth
    final cred = await _remote.signIn(email: email, password: password);
    final fb.User fbUser = cred.user!;

    // Citim profilul din Firestore
    final doc = await _firestore.collection('users').doc(fbUser.uid).get();

    // Mapăm la DTO
    final userModel = UserModel.fromDocument(doc);

    // **DEBUG**: print doc JSON
    developer.log(
      '[AuthRepositoryImpl.signIn] read from Firestore: ${doc.data()}',
      name: 'AuthRepositoryImpl.signIn',
    );

    // **DEBUG**: print DTO.toJson()
    developer.log(
      '[AuthRepositoryImpl.signIn] DTO.toJson(): ${userModel.toJson()}',
      name: 'AuthRepositoryImpl.signIn',
      // level: 0,  // poți adăuga un nivel de log, dacă vrei
    );

    // DTO → entitate
    final userEntity = userModel.toEntity();
    developer.log(
      '[AuthRepositoryImpl.signIn] returning entity: $userEntity',
      name: 'AuthRepositoryImpl.signIn',
    );

    return userModel.toEntity();
  }

  @override
  Future<User> signInWithGoogle() async {
    // Autentificăm prin Google
    final cred = await _remote.signInWithGoogle();
    final fb.User fbUser = cred.user!;

    // Citim (sau scriem dacă e nou) profilul Google în Firestore
    final ref = _firestore.collection('users').doc(fbUser.uid);
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      // scriem un UserModel nou
      final newModel = UserModel(
        uid: fbUser.uid,
        email: fbUser.email!,
        role: 'patient',
        name: fbUser.displayName ?? '',
      );
      await ref.set(newModel.toJson());
    }

    // Citim datele actualizate și mapăm tot cu UserModel
    final userModel = UserModel.fromDocument(await ref.get());
    return userModel.toEntity();
  }

  @override
  Future<User> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    // Creăm contul de user în FirebaseAuth
    final cred = await _remote.signUp(email: email, password: password);
    final fb.User fbUser = cred.user!;

    // Setăm displayName pe contul FirebaseAuth
    await fbUser.updateDisplayName(name);

    // Cream modelul și îl salvăm în Firestore folosind DTO
    final userModel = UserModel(
      uid: fbUser.uid,
      email: email,
      role: role.name,
      name: name,
    );
    await _firestore
        .collection('users')
        .doc(fbUser.uid)
        .set(userModel.toJson());

    // **DEBUG**: print JSON-ul care s-a scris
    developer.log(
      '[AuthRepositoryImpl.signUp] wrote to Firestore: ${userModel.toJson()}',
      name: 'AuthRepositoryImpl.signUp',
    );

    // Convertim DTO în entitate și o întoarcem
    final userEntity = userModel.toEntity();

    developer.log(
      '[AuthRepositoryImpl.signUp] returning entity: $userEntity',
      name: 'AuthRepositoryImpl.signUp',
    );

    return userModel.toEntity();
  }

  @override
  Future<void> signOut() => _remote.signOut();

  @override
  Future<User> updateProfile({
    required String uid,
    required String phone,
    required String county,
    required String city,
    required String street,
    required String houseNumber,
    required DateTime dateOfBirth,
  }) async {
    final ref = _firestore.collection('users').doc(uid);
    final data = {
      'phone': phone,
      'county': county,
      'city': city,
      'street': street,
      'houseNumber': houseNumber,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'profileComplete': true,
    };
    await ref.update(data);

    final doc = await ref.get();
    final userModel = UserModel.fromDocument(doc);
    return userModel.toEntity();
  }
}
