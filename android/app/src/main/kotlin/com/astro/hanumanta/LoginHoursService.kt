
package com.jyotishastro

import android.app.*
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import com.android.volley.Request
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

class LoginHoursService : Service() {

    private val CHANNEL_ID = "LoginHoursServiceChannel"
    private val NOTIFICATION_ID = 1002

    private var vendorId: String = ""
    private var token: String = ""

    // ✅ REAL time
    private var startTimeMillis: Long = 0L

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())

        // ✅ REAL clock time
        startTimeMillis = System.currentTimeMillis()
        Log.d("LoginHoursService", "Login tracking started at $startTimeMillis")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        vendorId = intent?.getStringExtra("vendorId") ?: ""
        token = intent?.getStringExtra("token") ?: ""

        Log.d("LoginHoursService", "Service started vendorId=$vendorId")
        return START_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        Log.d("LoginHoursService", "App removed from recent tasks")
        sendLoginHours()
        stopSelf()
    }

    override fun onDestroy() {
        Log.d("LoginHoursService", "Service destroyed")
        sendLoginHours()
        super.onDestroy()
    }

    private fun sendLoginHours() {
        val endTimeMillis = System.currentTimeMillis()

        val isoFormat =
            SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).apply {
                timeZone = TimeZone.getTimeZone("UTC")
            }

        val startTimeIso = isoFormat.format(Date(startTimeMillis))
        val endTimeIso = isoFormat.format(Date(endTimeMillis))

        val jsonBody = JSONObject().apply {
            put("vendorId", vendorId)
            put("startTime", startTimeIso)
            put("endTime", endTimeIso)
        }

        Log.d("LoginHoursService", "📤 Sending login hours: $jsonBody")

        val url = "https://app.astromukti.com/api/vendor/login-histories"
        val queue = Volley.newRequestQueue(this)

        val request = object : StringRequest(
            Method.POST, url,
            { response ->
                Log.d("LoginHoursService", "✅ API Success: $response")
            },
            { error ->
                Log.e(
                    "LoginHoursService",
                    "❌ API Error: ${error.message}\nSent Data: $jsonBody",
                    error
                )
            }
        ) {
            override fun getBody(): ByteArray =
                jsonBody.toString().toByteArray(Charsets.UTF_8)

            override fun getBodyContentType(): String =
                "application/json; charset=utf-8"

            // ✅ AUTH HEADER (FIXES 401)
            override fun getHeaders(): MutableMap<String, String> =
                hashMapOf(
                    "Authorization" to "Bearer $token",
                    "Content-Type" to "application/json"
                )
        }

        queue.add(request)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Login Tracking",
                NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification =
        NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Online")
            .setContentText("Tracking login time")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .build()
}

