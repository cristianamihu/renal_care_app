import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';

class FCMHelper {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  /// Initializare FCM: cere permisiuni și salvează token-ul în Firestore
  static Future<void> initFCM(String uid) async {
    // Android 13+ runtime notification permission
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final newStatus = await Permission.notification.request();
        if (!newStatus.isGranted) return;
      }
    }

    // Cere permisiuni iOS / Firebase Messaging
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
    );

    // Obține token-ul și salvează-l
    final newToken = await _messaging.getToken();
    if (newToken != null) {
      await saveTokenToFirestore(uid, newToken);
    }
  }

  /// Salvează token-ul nou și șterge vechiul token din Firestore + SecureStorage
  static Future<void> saveTokenToFirestore(String uid, String newToken) async {
    final firestore = FirebaseFirestore.instance;
    final userTokensCol = firestore
        .collection('users')
        .doc(uid)
        .collection('fcm_tokens');

    // Citeşte vechiul token
    final oldToken = await _secureStorage.read(key: 'fcm_token');

    // dacă există și e diferit, șterge-l
    if (oldToken != null && oldToken != newToken) {
      await userTokensCol.doc(oldToken).delete().catchError((_) {});
    }

    // Scrie token-ul nou
    await userTokensCol.doc(newToken).set({
      'token': newToken,
      'platform': await _detectPlatform(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Actualizează secure storage
    await _secureStorage.write(key: 'fcm_token', value: newToken);
  }

  /// Elimină token-ul FCM din Firestore și SecureStorage (la logout)
  static Future<void> removeFCMToken(String uid) async {
    final token = await _secureStorage.read(key: 'fcm_token');
    if (token != null) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('fcm_tokens')
          .doc(token);
      await docRef.delete().catchError((_) {});
      await _secureStorage.delete(key: 'fcm_token');
    }
  }

  static Future<String> _detectPlatform() async {
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }
}
