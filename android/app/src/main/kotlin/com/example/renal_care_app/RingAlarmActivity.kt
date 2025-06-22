package com.example.renal_care_app

import android.app.Activity
import android.content.Intent
import android.media.MediaPlayer
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView

class RingAlarmActivity : Activity() {
    companion object {
        const val ACTION_TAKEN = "com.example.renal_care_app.ACTION_TAKEN"
        const val ACTION_RING = "com.example.renal_care_app.ACTION_RING"
    }

    private var mediaPlayer: MediaPlayer? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Dacă am fost lansat prin ACTION_TAKEN, opresc direct alarma
        if (intent?.action == ACTION_TAKEN) {
            stopAndReleasePlayer()
            finish()
            return
        }

        // Pentru a afișa această Activity chiar și peste lock screen
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )

        // Setează layout-ul (trebuie creat mai jos în res/layout)
        setContentView(R.layout.activity_ring_alarm)

        // Pornește sunetul de alarmă în buclă (în res/raw/alarm_sound.mp3)
        mediaPlayer = MediaPlayer.create(this, R.raw.alarm_sound).apply {
            isLooping = true
            start()
        }

        // Populează lista de medicamente
        val medsDesc = intent.getStringExtra("medsDescription") ?: ""
        findViewById<TextView>(R.id.medsText).text = medsDesc

        // Butonul “Oprește alarma”
        val stopButton: Button = findViewById(R.id.stopAlarmButton)
        stopButton.setOnClickListener {
            stopAndReleasePlayer()
            finish() // închide ecranul de alarmă
        }
    }

    // Când activity-ul e deja pornit și primește un intent nou (ex. din notificare)
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.action == ACTION_TAKEN) {
            stopAndReleasePlayer()
            finish()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        stopAndReleasePlayer()
    }

    private fun stopAndReleasePlayer() {
        mediaPlayer?.let {
            if (it.isPlaying) it.stop()
            it.release()
        }
        mediaPlayer = null
    }
}
