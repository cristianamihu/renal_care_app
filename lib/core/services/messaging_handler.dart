import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_state.dart';
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
  String? _lastUid;
  bool _permissionsRequested = false;

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;
  StreamSubscription<String>? _tokenRefreshSub;

  @override
  void initState() {
    super.initState();
    _requestPermissions();

    _foregroundSub = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    _openedAppSub = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleMessageOpenedApp,
    );

    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((
      token,
    ) async {
      if (_lastUid != null) {
        await FCMHelper.saveTokenToFirestore(_lastUid!, token);
      }
    });
  }

  /// cere permisiunile Firebase + Android13+
  Future<void> _requestPermissions() async {
    if (_permissionsRequested) return;
    _permissionsRequested = true;

    // Android 13+ runtime notification
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final newStatus = await Permission.notification.request();
        if (!newStatus.isGranted) return; // fără permisiune nu continuăm
      }
    }

    // iOS & Android Firebase Messaging
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return;
    }
  }

  /// notificări primite când aplicația e în foreground
  void _handleForegroundMessage(RemoteMessage msg) {
    if (!mounted) return;
    final notification = msg.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'chat_channel_id',
      'New message',
      channelDescription: 'Notifications for new messages',
      importance: Importance.max,
      priority: Priority.high,
    );

    // foloseşte plugin-ul pentru a arăta efectiv notificarea
    widget.localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(android: androidDetails),
      payload: msg.data['roomId'],
    );
  }

  /// dacă user-ul a dat tap pe notificare când era backgrounded/killed
  void _handleMessageOpenedApp(RemoteMessage msg) {
    if (!mounted) return;
    final roomId = msg.data['roomId'];
    if (roomId != null) {
      GoRouter.of(context).push('/chat/$roomId');
    }
  }

  @override
  void dispose() {
    _foregroundSub?.cancel();
    _openedAppSub?.cancel();
    _tokenRefreshSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewModelProvider, (_, next) async {
      final newUid = next.user?.uid;

      // user-ul a dat logout
      if (newUid == null) {
        _lastUid = null;
      }
      // user-ul tocmai s-a logat sau s-a schimbat
      else if (newUid != _lastUid) {
        _lastUid = newUid;

        // apoi initializezi FCM și salvezi token-ul
        await FCMHelper.initFCM(newUid);
      }
    });

    return widget.child;
  }
}
