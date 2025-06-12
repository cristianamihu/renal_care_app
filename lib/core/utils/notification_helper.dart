import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  // Instanță singleton
  static late FlutterLocalNotificationsPlugin plugin;
  static void setPlugin(FlutterLocalNotificationsPlugin p) => plugin = p;

  /// Initializează plugin-ul de notificări. Apelează-l în main() înainte de runApp()
  static Future<void> init() async {
    // Creează canalul cu sunet în res/raw
    const AndroidNotificationChannel alarmChannel = AndroidNotificationChannel(
      'medication_alarm_channel',
      'Medication Alarms',
      description: 'Medication alarm channel',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
    );

    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(alarmChannel);

    // Inițializează plugin‐ul
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await plugin.initialize(initSettings);
  }

  /// Programează o alarmă exactă
  static Future<void> scheduleExactAlarm({
    required int notificationId,
    required DateTime scheduledTime,
    required String medsDescription,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'medication_alarm_channel',
          'Medication Alarms',
          channelDescription: 'Medication alarm channel',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true, // forțează RingAlarmActivity în prim plan
          ongoing: true,
          autoCancel: false,

          // acţiunea “Taken”
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'com.example.renal_care_app.ACTION_TAKEN', // actionId
              'Taken', // butonul propriu-zis
            ),
          ],
        );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convertim în TZDateTime
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime scheduledTzDate = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    // Dacă data/oră e deja în trecut, nu programăm
    if (scheduledTzDate.isBefore(now)) {
      return;
    }

    await plugin.zonedSchedule(
      notificationId,
      "⏰ It's time to take your medication!",
      medsDescription, // body: lista medicamentelor
      scheduledTzDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: notificationId.toString(),
    );
  }

  /// Anulează toate notificările programate din plugin (folie, SHARED_PREFERENCES etc.)
  static Future<void> cancelAllAlarms() async {
    await plugin.cancelAll();
  }

  /// Anulează doar alarma cu un anumit ID (de obicei folosit dacă ștergi un medicament
  /// și vrei să anulezi numai alarmele aferente acelui medicament individual, dar
  /// în modul acesta simplificat vom anula TOT și vom reprograma din nou toate alarmele).
  static Future<void> cancelAlarmById(int notificationId) async {
    await plugin.cancel(notificationId);
  }
}
