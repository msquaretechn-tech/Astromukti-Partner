package com.jyotishastro

import android.app.Application
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * Application class that keeps a shared FlutterEngine warm so that
 * MethodChannels (including RINGTONE_CHANNEL) are accessible from the
 * background Firebase messaging isolate.
 */
class App : Application() {

    companion object {
        private const val ENGINE_ID = "ringtone_engine"
        private const val RINGTONE_CHANNEL = "com.astro.hanumanta/ringtone"
        var ringtoneChannel: MethodChannel? = null

        /** Call from background Dart isolate to play ringtone natively */
        fun playRingtone(appContext: android.content.Context) {
            RingtoneHelper.play(appContext)
        }

        /** Call from background Dart isolate or anywhere to stop ringtone */
        fun stopRingtone() {
            RingtoneHelper.stop()
        }
    }

    override fun onCreate() {
        super.onCreate()
    }
}
