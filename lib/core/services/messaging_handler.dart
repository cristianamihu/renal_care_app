import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:renal_care_app/core/di/chat_providers.dart';

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

  void _requestPermissions() {
    FirebaseMessaging.instance.requestPermission();
  }

  void _saveTokenToFirestore() async {
    final token = await FirebaseMessaging.instance.getToken();
    final uid = ref.read(authViewModelProvider).user?.uid;
    if (uid != null && token != null) {
      // actualizează token-ul în Firestore
      await ref.read(firestoreProvider).collection('users').doc(uid).update({
        'fcmToken': token,
      });
    }
    // Afişare token-ul pentru debug
    debugPrint('FCM token: $token');
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
