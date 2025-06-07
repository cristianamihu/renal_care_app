import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/core/utils/fcm_helper.dart';

class MessagingHandler extends ConsumerStatefulWidget {
  final Widget child;
  final FlutterLocalNotificationsPlugin localNotifications;

  const MessagingHandler({
    required this.child,
    required this.localNotifications,
    super.key,
  });

  @override
  ConsumerState<MessagingHandler> createState() => _MessagingHandlerState();
}

class _MessagingHandlerState extends ConsumerState<MessagingHandler> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _saveTokenToFirestore();
    _listenForeground();
    _listenOnTap();
  }

  Future<void> _requestPermissions() async {
    // Firebase Messaging (iOS + Android)
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Android 13+ notifications runtime permission
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isDenied || status.isRestricted) {
        final newStatus = await Permission.notification.request();
        if (newStatus.isPermanentlyDenied) {
          // Deschide setările aplicației ca user-ul să poată activa manual permisiunea
          await openAppSettings();
        }
      }
    }
  }

  void _saveTokenToFirestore() async {
    final uid = ref.read(authViewModelProvider).user?.uid;
    if (uid != null) {
      // În loc să scriem în câmpul fcmToken, apelăm helper-ul care
      // face exact ceea ce ne trebuie: cere token și îl pune în subcolecție.
      await FCMHelper.initFCM(uid);
    }
  }

  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      if (!mounted) return;
      final notification = msg.notification;
      if (notification == null) return;

      const androidDetails = AndroidNotificationDetails(
        'chat_channel_id',
        'Mesaje noi',
        channelDescription: 'Notificări pentru mesaje noi',
        importance: Importance.max,
        priority: Priority.high,
      );

      // foloseşte plugin-ul pentru a arăta efectiv notificarea
      widget.localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(android: androidDetails),
        payload: msg.data['roomId'], // dacă ai un payload
      );
    });
  }

  void _listenOnTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      if (!mounted) return;
      final roomId = msg.data['roomId'];
      if (roomId != null) {
        GoRouter.of(context).push('/chat/$roomId');
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
