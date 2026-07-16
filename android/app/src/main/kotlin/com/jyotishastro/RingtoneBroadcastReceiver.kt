package com.jyotishastro

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * BroadcastReceiver that starts/stops RingtoneService.
 * Triggered from Flutter (background Dart isolate) via android_intent_plus sendBroadcast().
 */
class RingtoneBroadcastReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_PLAY = "com.jyotishastro.PLAY_RINGTONE"
        const val ACTION_STOP = "com.jyotishastro.STOP_RINGTONE"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d("RingtoneBroadcastReceiver", "Received action: ${intent.action}")

        when (intent.action) {
            ACTION_PLAY -> {
                val serviceIntent = Intent(context, RingtoneService::class.java).apply {
                    action = RingtoneService.ACTION_PLAY
                }
                context.startService(serviceIntent)
                Log.d("RingtoneBroadcastReceiver", "RingtoneService START triggered")
            }
            ACTION_STOP -> {
                val serviceIntent = Intent(context, RingtoneService::class.java).apply {
                    action = RingtoneService.ACTION_STOP
                }
                context.startService(serviceIntent)
                Log.d("RingtoneBroadcastReceiver", "RingtoneService STOP triggered")
            }
        }
    }
}
