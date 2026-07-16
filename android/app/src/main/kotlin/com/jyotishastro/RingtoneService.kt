package com.jyotishastro

import android.app.Service
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import android.util.Log

/**
 * A simple (non-foreground) Service that plays ringtone.
 * - Started via Intent from background Dart isolate (via MethodChannel from main thread)
 *   OR via platform channel
 * - Automatically destroyed when app process is killed → ringtone stops
 * - Use action "PLAY" to start ringing, "STOP" to stop
 */
class RingtoneService : Service() {

    companion object {
        const val TAG = "RingtoneService"
        const val ACTION_PLAY = "PLAY_RINGTONE"
        const val ACTION_STOP = "STOP_RINGTONE"
    }

    private var mediaPlayer: MediaPlayer? = null
    private var audioFocusRequest: AudioFocusRequest? = null
    private var audioManager: AudioManager? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_PLAY -> startRingtone()
            ACTION_STOP -> {
                stopRingtone()
                stopSelf()
            }
        }
        return START_NOT_STICKY // Don't restart if killed
    }

    private fun startRingtone() {
        if (mediaPlayer?.isPlaying == true) return

        try {
            val am = getSystemService(AUDIO_SERVICE) as AudioManager
            audioManager = am

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val req = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                    .setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                    )
                    .build()
                audioFocusRequest = req
                am.requestAudioFocus(req)
            } else {
                @Suppress("DEPRECATION")
                am.requestAudioFocus(null, AudioManager.STREAM_RING, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
            }

            val rawId = resources.getIdentifier("ringtone", "raw", packageName)
            val player = if (rawId != 0) {
                MediaPlayer.create(this, rawId)
            } else {
                val uri = android.provider.Settings.System.DEFAULT_RINGTONE_URI
                MediaPlayer.create(this, uri)
            }

            if (player == null) {
                Log.e(TAG, "MediaPlayer.create returned null")
                stopSelf()
                return
            }

            player.isLooping = true
            player.setOnErrorListener { _, what, extra ->
                Log.e(TAG, "MediaPlayer error: what=$what extra=$extra")
                false
            }
            player.start()
            mediaPlayer = player
            Log.d(TAG, "RingtoneService: started playing")

        } catch (e: Exception) {
            Log.e(TAG, "Error starting ringtone: $e")
            stopSelf()
        }
    }

    private fun stopRingtone() {
        try {
            mediaPlayer?.let {
                if (it.isPlaying) it.stop()
                it.release()
            }
            mediaPlayer = null

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                audioFocusRequest?.let { audioManager?.abandonAudioFocusRequest(it) }
            } else {
                @Suppress("DEPRECATION")
                audioManager?.abandonAudioFocus(null)
            }
            Log.d(TAG, "RingtoneService: stopped")
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping ringtone: $e")
        }
    }

    override fun onDestroy() {
        stopRingtone()
        super.onDestroy()
    }
}
