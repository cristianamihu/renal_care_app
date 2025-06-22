// lib/core/utils/alarm_permission.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';

class AlarmPermission {
  static const _channel = MethodChannel('renal_care_app/alarms');

  /// Nu deschide setările decât dacă nu ai voie să programezi exact alarms.
  static Future<void> ensureExactAlarmPermission() async {
    if (!Platform.isAndroid) return;

    final can =
        await _channel.invokeMethod<bool>('canScheduleExactAlarms') ?? false;
    if (!can) {
      await const AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      ).launch();
    }

    // solicită excluderea din optimizările de baterie
    await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
  }
}
