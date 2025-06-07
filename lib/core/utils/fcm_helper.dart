import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FCMHelper {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  /// Initializare FCM: cere permisiuni și salvează token-ul în Firestore
  static Future<void> initFCM(String uid) async {
    // Cere permisiuni (iOS)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
    );

    // Obține token-ul
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveTokenToFirestore(uid, token);
      // În flames de securitate, salvează token-ul și local (secure storage)
      await _secureStorage.write(key: 'fcm_token', value: token);
    }

    // Dacă token-ul se schimbă, actualizează-l în Firestore
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await _saveTokenToFirestore(uid, newToken);
      await _secureStorage.write(key: 'fcm_token', value: newToken);
    });
  }

  static Future<void> _saveTokenToFirestore(String uid, String token) async {
    final firestore = FirebaseFirestore.instance;
    final userTokensCol = firestore
        .collection('users')
        .doc(uid)
        .collection('fcm_tokens');

    // Putem folosi token-ul însuși drept document ID
    await userTokensCol.doc(token).set({
      'token': token,
      'platform': await _detectPlatform(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<String> _detectPlatform() async {
    // Simplu: detectăm Android / iOS
    if (Platform.isAndroid) {
      return 'android';
    } else {
      return 'unknown';
    }
  }

  /// Elimina token-ul FCM din Firestore (la logout)
  static Future<void> removeFCMToken(String uid) async {
    final token = await _secureStorage.read(key: 'fcm_token');
    if (token != null) {
      final firestore = FirebaseFirestore.instance;
      await firestore
          .collection('users')
          .doc(uid)
          .collection('fcm_tokens')
          .doc(token)
          .delete();
      await _secureStorage.delete(key: 'fcm_token');
    }
  }
}
