#!/bin/bash

mkdir -p app/src/main/java/com/example/companionmusic
mkdir -p app/src/main/res
mkdir -p app/src/main

# AndroidManifest.xml
cat > app/src/main/AndroidManifest.xml <<EOF
<manifest package="com.example.companionmusic" xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <uses-permission android:name="android.permission.INTERNET"/>

    <application
        android:allowBackup="true"
        android:label="Companion Music App">
        <activity android:name=".MainActivity" android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        <service android:name=".MusicService" android:exported="false"/>
    </application>
</manifest>
EOF

# MainActivity.kt
cat > app/src/main/java/com/example/companionmusic/MainActivity.kt <<EOF
package com.example.companionmusic

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        startService(Intent(this, MusicService::class.java))
        finish()
    }
}
EOF

# MusicService.kt
cat > app/src/main/java/com/example/companionmusic/MusicService.kt <<EOF
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
EOF

# SupabaseClient.kt
cat > app/src/main/java/com/example/companionmusic/SupabaseClient.kt <<EOF
package com.example.companionmusic

object SupabaseClient {
    fun getLatestSongUrl(): String {
        return "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
    }
}
EOF

# NotificationUtils.kt
cat > app/src/main/java/com/example/companionmusic/NotificationUtils.kt <<EOF
package com.example.companionmusic

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat

object NotificationUtils {
    private const val CHANNEL_ID = "music_playback"

    fun createMediaNotification(context: Context, title: String, artist: String) =
        NotificationCompat.Builder(context, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(artist)
            .setSmallIcon(android.R.drawable.ic_media_play)
            .build().also {
                createChannel(context)
            }

    private fun createChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = context.getSystemService(NotificationManager::class.java)
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Music Playback",
                NotificationManager.IMPORTANCE_LOW
            )
            manager.createNotificationChannel(channel)
        }
    }
}
EOF

# settings.gradle
cat > settings.gradle <<EOF
rootProject.name = "CompanionMusicApp"
EOF

# Top-level build.gradle
cat > build.gradle <<EOF
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
    }
}
EOF

# app/build.gradle
mkdir -p app
cat > app/build.gradle <<EOF
apply plugin: 'com.android.application'

android {
    compileSdkVersion 34
    defaultConfig {
        applicationId "com.example.companionmusic"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
    }
    buildTypes {
        release {
            minifyEnabled false
        }
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
}
EOF

echo "✅ All files created successfully!"
