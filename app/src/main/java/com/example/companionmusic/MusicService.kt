package com.example.companionmusic

import android.app.Service
import android.content.Intent
import android.media.MediaPlayer
import android.os.IBinder

class MusicService : Service() {
    private lateinit var player: MediaPlayer

    override fun onCreate() {
        super.onCreate()
        val songUrl = SupabaseClient.getLatestSongUrl()
        player = MediaPlayer().apply {
            setDataSource(songUrl)
            prepare()
            start()
        }

        val notification = NotificationUtils.createMediaNotification(this, "Song Title", "Artist")
        startForeground(1, notification)
    }

    override fun onDestroy() {
        super.onDestroy()
        player.stop()
        player.release()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
