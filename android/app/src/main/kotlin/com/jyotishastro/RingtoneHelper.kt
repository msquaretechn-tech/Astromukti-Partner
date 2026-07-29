package com.jyotishastro

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.util.Log

/**
 * Native ringtone player using MediaPlayer.
 * - Plays assets/sounds/ringtone.mp3 from res/raw/
 * - Automatically stops when the app process is killed (no service dependency)
 * - Works reliably in background context
 */
object RingtoneHelper {

    private const val TAG = "RingtoneHelper"

    private var mediaPlayer: MediaPlayer? = null
    private var audioFocusRequest: AudioFocusRequest? = null
    private var audioManager: AudioManager? = null
    private var isPlaying = false

    fun play(context: Context) {
        if (isPlaying) {
            Log.i(TAG, "Already playing, skipping")
            return
        }

        try {
            val am = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
            audioManager = am

            // Request audio focus
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val focusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                    .setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                    )
                    .build()
                audioFocusRequest = focusRequest
                am.requestAudioFocus(focusRequest)
            } else {
                @Suppress("DEPRECATION")
                am.requestAudioFocus(null, AudioManager.STREAM_RING, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
            }

            // Get raw resource ID for ringtone.mp3 (must be in res/raw/)
            val rawId = context.resources.getIdentifier("ringtone", "raw", context.packageName)

            val player = if (rawId != 0) {
                MediaPlayer.create(context, rawId)
            } else {
                // Fallback: use default notification ringtone
                val uri = android.provider.Settings.System.DEFAULT_RINGTONE_URI
                MediaPlayer.create(context, uri)
            }

            if (player == null) {
                Log.e(TAG, "MediaPlayer.create returned null")
                return
            }

            player.isLooping = true
            player.setOnErrorListener { _, what, extra ->
                Log.e(TAG, "MediaPlayer error: what=$what extra=$extra")
                isPlaying = false
                false
            }
            player.start()

            mediaPlayer = player
            isPlaying = true
            Log.i(TAG, "Ringtone started (rawId=$rawId)")

        } catch (e: Exception) {
            Log.e(TAG, "Error playing ringtone: $e")
            isPlaying = false
        }
    }

    fun stop() {
        try {
            mediaPlayer?.let {
                if (it.isPlaying) it.stop()
                it.release()
            }
            mediaPlayer = null

            // Release audio focus
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                audioFocusRequest?.let { audioManager?.abandonAudioFocusRequest(it) }
            } else {
                @Suppress("DEPRECATION")
                audioManager?.abandonAudioFocus(null)
            }

            isPlaying = false
            Log.i(TAG, "Ringtone stopped")
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping ringtone: $e")
            isPlaying = false
        }
    }

    fun isRinging(): Boolean = isPlaying
}
