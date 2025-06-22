package com.example.renal_care_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val CHANNEL = "renal_care_app/alarms"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
      .setMethodCallHandler { call, result ->
        when (call.method) {

          // Verifică dacă putem programa exact alarms
          "canScheduleExactAlarms" -> {
            val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            result.success(am.canScheduleExactAlarms())
          }

          // Cere excluderea din optimizările de baterie
          "requestIgnoreBatteryOptimizations" -> {
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            if (!pm.isIgnoringBatteryOptimizations(packageName)) {
              startActivity(
                Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                  .setData(Uri.parse("package:$packageName"))
                  .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
              )
            }
            result.success(null)
          }

          // Programează full-screen alarm
          "scheduleFullScreenAlarm" -> {
            val args = call.arguments as Map<*, *>
            val id = (args["notificationId"] as Number).toInt()
            val epochMillis = (args["epochMillis"] as Number).toLong()
            val medsDesc = args["medsDescription"] as? String ?: ""

            val intent = Intent(this, RingAlarmActivity::class.java).apply {
              action = RingAlarmActivity.ACTION_RING
              flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
              putExtra("notificationId", id)
              putExtra("medsDescription", medsDesc)
            }
            val pi = PendingIntent.getActivity(
              this,
              id,
              intent,
              PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            if (am.canScheduleExactAlarms()) {
              am.setAlarmClock(
                AlarmManager.AlarmClockInfo(epochMillis, pi),
                pi
              )
            } else {
              am.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                epochMillis,
                pi
              )
            }

            result.success(null)
          }

          // Oprește o alarmă deja pornită
          "stopAlarm" -> {
            val id = call.arguments as Int
            val stopIntent = Intent(this, AlarmStopReceiver::class.java).apply {
              action = AlarmStopReceiver.ACTION_STOP_ALARM
              putExtra("notificationId", id)
            }
            sendBroadcast(stopIntent)
            result.success(null)
          }

          else -> result.notImplemented()
        }
      }
  }
}
