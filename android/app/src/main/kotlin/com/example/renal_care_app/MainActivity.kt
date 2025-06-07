package com.example.renal_care_app

import android.app.AlarmManager
import android.content.Context
import android.content.Intent 
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

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
          // trimitem broadcast către RingAlarmActivity
          val intent = Intent("renal_care_app.ACTION_STOP_ALARM")
          intent.putExtra("notificationId", id)
          sendBroadcast(intent)
          result.success(null)
        }
        else -> result.notImplemented()
      }
    }
  }
}
