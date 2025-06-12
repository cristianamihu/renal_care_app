package com.example.renal_care_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.app.NotificationManager
import android.util.Log

class AlarmStopReceiver : BroadcastReceiver() {
  companion object {
    // folosit de MainActivity când trimite broadcast-ul
    const val ACTION_STOP_ALARM = "com.example.renal_care_app.ACTION_STOP_ALARM"
  }
  
  override fun onReceive(context: Context, intent: Intent) {
    val id = intent.getIntExtra("notificationId", -1)
    Log.d("AlarmStopReceiver", "Stopping alarm notification $id")

    // Cancelăm notificarea
    val notifMgr = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    notifMgr.cancel(id)

    // Trimitem același intent către RingAlarmActivity ca să oprească MediaPlayer-ul
    val stopIntent = Intent(context, RingAlarmActivity::class.java).apply {
      action = RingAlarmActivity.ACTION_TAKEN
      flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
      putExtra("notificationId", id)
    }
    context.startActivity(stopIntent)
  }
}
