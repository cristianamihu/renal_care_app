import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:renal_care_app/core/utils/alarm_permission.dart';
import 'package:renal_care_app/core/utils/notification_helper.dart';
import 'package:renal_care_app/core/theme/app_theme.dart';
import 'package:renal_care_app/core/router/app_router.dart';
import 'package:renal_care_app/core/services/messaging_handler.dart';

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

// cheia de navigator pe care o va folosi GoRouter pentru callback-uri
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Callback pentru răspunsuri pe background (Android)
// trebuie marcat astfel pentru a fi găsit la runtime
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse resp) {
  if (resp.actionId == 'TAKEN_ACTION' && resp.payload != null) {
    FlutterLocalNotificationsPlugin().cancel(int.parse(resp.payload!));
  }
}

/// Configurează plugin-ul de notificări locale
Future<void> _initLocalNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

  await _localNotifications.initialize(
    const InitializationSettings(android: androidSettings),
    // când primești un răspuns în foreground
    onDidReceiveNotificationResponse: (NotificationResponse resp) {
      if (resp.actionId == 'TAKEN_ACTION' && resp.payload != null) {
        final id = int.parse(resp.payload!);
        _localNotifications.cancel(id);

        // trimitem broadcast către RingAlarmActivity
        const MethodChannel(
          'renal_care_app/alarms',
        ).invokeMethod('stopAlarm', id);
      } else {
        // tap normal pe notificare
        final roomId = resp.payload;
        if (roomId != null) {
          rootNavigatorKey.currentContext?.go('/chat/$roomId');
        }
      }
    },
    // captează și în background
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  // creare canal Android pentru notificări de chat
  const channel = AndroidNotificationChannel(
    'chat_channel_id',
    'Mesaje noi',
    description: 'Notificări când primești un mesaj nou',
    importance: Importance.max,
  );
  await _localNotifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}

/// Handler FCM pentru mesaje primite când app e în background sau kill-uită
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // cold‐start (tap pe notificare când app e închis)
  final n = message.notification;
  if (n != null) {
    const androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Mesaje noi',
      channelDescription: 'Notificări pentru mesaje noi',
      importance: Importance.max,
      priority: Priority.high,
    );
    // payload = roomId
    final roomId = message.data['roomId'];
    await _localNotifications.show(
      n.hashCode,
      n.title,
      n.body,
      NotificationDetails(android: androidDetails),
      payload: roomId, // transmite roomId ca payload
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // initialize timezone database
  tz.initializeTimeZones();
  // pick your local zone (here Bucharest as an example)
  tz.setLocalLocation(tz.getLocation('Europe/Bucharest'));

  await initializeDateFormatting(
    'ro',
  ); // inițializează formatarea pentru limba română

  //notificări locale
  await _initLocalNotifications(); // Initialize local notifications
  NotificationHelper.setPlugin(_localNotifications);
  await NotificationHelper.init();

  //permisiuni Android
  if (Platform.isAndroid) {
    await Permission.notification.request();
  }
  await AlarmPermission.ensureExactAlarmPermission();

  // cold-start handling: dacă aplicația a fost deschis din tap pe notificare
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    final roomId = initialMessage.data['roomId'];
    if (roomId != null) {
      // după prima montare a arborelui de widgeturi:
      WidgetsBinding.instance.addPostFrameCallback((_) {
        rootNavigatorKey.currentContext!.go('/chat/$roomId');
      });
    }
  }

  // Setează handler-ul pentru background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Pornim app-ul și transmitem instanța în RenalCareApp
  runApp(
    ProviderScope(
      child: RenalCareApp(
        localNotifications: _localNotifications,
        navigatorKey: rootNavigatorKey,
      ),
    ),
  );
}

class RenalCareApp extends ConsumerWidget {
  final FlutterLocalNotificationsPlugin localNotifications;
  final GlobalKey<NavigatorState> navigatorKey;

  const RenalCareApp({
    required this.localNotifications,
    required this.navigatorKey,
    super.key,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // trecem cheia de navigator mai jos în router config
    final router = ref.watch(appRouterProvider(navigatorKey));

    return MaterialApp.router(
      title: 'RenalCare',
      theme: AppTheme.light,
      routerConfig: router,
      // Îl împachetăm cu MessagingHandler, căruia îi dăm plugin-ul
      builder:
          (context, child) => MessagingHandler(
            localNotifications: localNotifications,
            child: child!,
          ),
    );
  }
}
