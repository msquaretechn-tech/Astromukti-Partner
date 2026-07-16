package com.jyotishastro
import android.content.Intent
import android.os.Bundle
import androidx.core.content.ContextCompat
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
class MainActivity  : FlutterActivity(){
    companion object {
        var instance: MainActivity? = null

        // Channels
        private const val LOGIN_CHANNEL = "login_channel"             // Android → Flutter
        private const val LOGIN_SERVICE_CHANNEL = "login_service_channel" // Flutter → Android
        private const val CALL_CHANNEL = "com.bookmyastro.app.channel"   // CallService
        private const val SERVICE_CHANNEL = "com.astro.hanumanta/service"      // MyService
        private const val RINGTONE_CHANNEL = "com.astro.hanumanta/ringtone"   // Native Ringtone
    }

    private var loginChannel: MethodChannel? = null
    private var loginServiceChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        instance = this
        Log.d("MainActivity", "MainActivity created")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // -------------------------------
        // 1️⃣ CallService Channel
        // -------------------------------
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CALL_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startCallService" -> {
                        val intent = Intent(this, CallService::class.java)
                        ContextCompat.startForegroundService(this, intent)
                        Log.d("MainActivity", "CallService started")
                        result.success("CallService started")
                    }
                    "stopCallService" -> {
                        stopService(Intent(this, CallService::class.java))
                        Log.d("MainActivity", "CallService stopped")
                        result.success("CallService stopped")
                    }
                    else -> result.notImplemented()
                }
            }

        // -------------------------------
        // 2️⃣ MyService Channel
        // -------------------------------
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SERVICE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startService" -> {
                        val url = call.argument<String>("url") ?: ""
                        val token = call.argument<String>("token") ?: ""
                        val isOnline = call.argument<Boolean>("isOnline") ?: false

                        val intent = Intent(this, MyService::class.java).apply {
                            putExtra("url", url)
                            putExtra("token", token)
                            putExtra("isOnline", isOnline)
                        }
                        ContextCompat.startForegroundService(this, intent)
                        Log.d("MainActivity", "MyService started with url=$url")
                        result.success("MyService started with url=$url")
                    }
                    "stopService" -> {
                        stopService(Intent(this, MyService::class.java))
                        Log.d("MainActivity", "MyService stopped")
                        result.success("MyService stopped")
                    }
                    else -> result.notImplemented()
                }
            }

        // -------------------------------
        // 3️⃣ Native Ringtone Channel
        // -------------------------------
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, RINGTONE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "playRingtone" -> {
                        val intent = Intent(applicationContext, RingtoneService::class.java).apply {
                            action = RingtoneService.ACTION_PLAY
                        }
                        applicationContext.startService(intent)
                        result.success(true)
                    }
                    "stopRingtone" -> {
                        val intent = Intent(applicationContext, RingtoneService::class.java).apply {
                            action = RingtoneService.ACTION_STOP
                        }
                        applicationContext.startService(intent)
                        result.success(true)
                    }
                    "isRinging" -> {
                        result.success(RingtoneHelper.isRinging())
                    }
                    else -> result.notImplemented()
                }
            }

        // -------------------------------
        // 3️⃣ LoginHours Channels
        // -------------------------------
        loginChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LOGIN_CHANNEL)
        loginServiceChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LOGIN_SERVICE_CHANNEL)

        loginServiceChannel?.setMethodCallHandler { call, result ->
            if (call.method == "startLoginService") {

                val vendorId = call.argument<String>("vendorId") ?: ""
                val token = call.argument<String>("token") ?: "" // ✅ ADD THIS LINE

                Log.d(
                    "MainActivity",
                    "Starting LoginHoursService vendorId=$vendorId"
                )

                val intent = Intent(this, LoginHoursService::class.java).apply {
                    putExtra("vendorId", vendorId)
                    putExtra("token", token) // ✅ NOW VALID
                }

                ContextCompat.startForegroundService(this, intent)
                result.success("LoginHoursService started")

            } else {
                result.notImplemented()
            }
        }

    }

    // -------------------------------
    // Helper: Send login hours back to Flutter
    // -------------------------------
    fun updateLoginHoursNative(vendorId: String, startMillis: Long, endMillis: Long) {
        loginChannel?.invokeMethod(
            "updateLoginHours",
            mapOf(
                "vendorId" to vendorId,
                "startTime" to startMillis.toString(),
                "endTime" to endMillis.toString()
            )
        )
        Log.d("MainActivity", "LoginHours sent to Flutter: $vendorId")
    }
}
