import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

//import 'package:renal_care_app/core/utils/seed_restricted_foods.dart';
import 'package:renal_care_app/core/utils/alarm_permission.dart';
import 'package:renal_care_app/core/utils/notification_helper.dart';
import 'package:renal_care_app/core/theme/app_theme.dart';
import 'package:renal_care_app/core/router/app_router.dart';
import 'package:renal_care_app/core/services/messaging_handler.dart';
import 'package:renal_care_app/core/di/appointments_providers.dart';
import 'package:renal_care_app/core/utils/appointment_notification_storage.dart';
import 'package:renal_care_app/features/appointments/domain/usecases/get_upcoming_appointments.dart';

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

// cheia de navigator pe care o va folosi GoRouter pentru callback-uri
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Callback pentru răspunsuri pe background (Android)
// trebuie marcat astfel pentru a fi găsit la runtime
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse resp) {
  if (resp.actionId == 'ACTION_TAKEN' && resp.payload != null) {
    FlutterLocalNotificationsPlugin().cancel(int.parse(resp.payload!));
  }
}

/// Trebuie un top‐level sau static function pentru foreground.
@pragma('vm:entry-point')
void notificationTapForeground(NotificationResponse resp) {
  if (resp.actionId == 'ACTION_TAKEN' && resp.payload != null) {
    final id = int.parse(resp.payload!);
    _localNotifications.cancel(id);
    const MethodChannel('renal_care_app/alarms').invokeMethod('stopAlarm', id);
  } else {
    final roomId = resp.payload;
    if (roomId != null) {
      rootNavigatorKey.currentContext?.go('/chat/$roomId');
    }
  }
}

/// Configurează plugin-ul de notificări locale
Future<void> _initLocalNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

  await _localNotifications.initialize(
    const InitializationSettings(android: androidSettings),
    // în foreground, apelăm top‐level callback
    onDidReceiveNotificationResponse: notificationTapForeground,
    // în background, apelăm top‐level callback
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  // creare canal Android pentru notificări de chat
  const channel = AndroidNotificationChannel(
    'chat_channel_id',
    'New message',
    description: 'Notifications for new messages',
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
      'chat_channel_id',
      'New message',
      channelDescription: 'Notifications for new messages',
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

  await dotenv.load(fileName: ".env"); // încarci .env

  // citire din dart-define (dacă există), altfel din .env
  String getEnv(String key) {
    // dart-define
    var fromDefine = String.fromEnvironment(key, defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    // .env
    final fromDotenv = dotenv.env[key];
    if (fromDotenv == null) {
      throw Exception('Missing environment variable: $key');
    }
    return fromDotenv;
  }

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: getEnv('FIREBASE_API_KEY'),
      appId: getEnv('FIREBASE_APP_ID'),
      messagingSenderId: getEnv('FIREBASE_SENDER_ID'),
      projectId: getEnv('FIREBASE_PROJECT_ID'),
      storageBucket: getEnv('FIREBASE_STORAGE_BUCKET'),
    ),
  );

  const useEmulator = bool.fromEnvironment('USE_EMULATOR', defaultValue: false);
  if (useEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  }

  // populează o singură dată lista de alimente
  //await seedRestrictedFoods();

  // timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Bucharest'));

  await initializeDateFormatting('ro');

  //notificări locale
  await _initLocalNotifications(); // Initialize local notifications
  NotificationHelper.setPlugin(_localNotifications);
  await NotificationHelper.init();

  //permisiuni Android
  if (Platform.isAndroid) {
    await Permission.notification.request();
  }
  await AlarmPermission.ensureExactAlarmPermission();

  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    // folosim un ProviderContainer pentru a citi repository-ul
    final container = ProviderContainer();
    final repo = container.read(appointmentRepositoryProvider);
    final getUpcoming = GetUpcomingAppointments(repo);

    final appts = await getUpcoming.call(currentUser.uid);
    for (var appt in appts) {
      final reminderTime = appt.dateTime.subtract(const Duration(hours: 24));
      if (reminderTime.isAfter(DateTime.now())) {
        final notifId = appt.id.hashCode;
        await NotificationHelper.scheduleExactAlarm(
          notificationId: notifId,
          scheduledTime: reminderTime,
          medsDescription:
              'Reminder: tomorrow, ${DateFormat('dd MMM yyyy, HH:mm').format(appt.dateTime)}, you have a consultation.',
        );
        await AppointmentNotificationStorage.addNotificationId(
          appt.id,
          notifId,
        );
      }
    }
  }

  // cold-start handling din FCM: dacă aplicația a fost deschis din tap pe notificare
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
