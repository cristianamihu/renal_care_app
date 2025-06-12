package com.example.renal_care_app

import android.app.AlarmManager
import android.content.Context
import android.content.Intent 
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import com.example.renal_care_app.AlarmStopReceiver

class MainActivity : FlutterActivity() {
  private val CHANNEL = "renal_care_app/alarms"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "canScheduleExactAlarms" -> {
          val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
          result.success(am.canScheduleExactAlarms())
        }
        "stopAlarm" -> {
          val id = call.arguments as Int
          val intent = Intent(this, AlarmStopReceiver::class.java).apply {
            action = AlarmStopReceiver.ACTION_STOP_ALARM
            putExtra("notificationId", id)
          }
          sendBroadcast(intent)
          result.success(null)
        }
        else -> result.notImplemented()
      }
    }
  }
}
