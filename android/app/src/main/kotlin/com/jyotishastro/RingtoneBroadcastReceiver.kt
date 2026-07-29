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
        Log.i("RingtoneBroadcastReceiver", "Received action: ${intent.action}")

        when (intent.action) {
            ACTION_PLAY -> {
                RingtoneHelper.play(context)
                Log.i("RingtoneBroadcastReceiver", "RingtoneHelper PLAY triggered")
            }
            ACTION_STOP -> {
                RingtoneHelper.stop()
                Log.i("RingtoneBroadcastReceiver", "RingtoneHelper STOP triggered")
            }
        }
    }
}
