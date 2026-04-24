package com.jyotishastro

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import com.android.volley.Request
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import org.json.JSONObject

class MyService : Service() {

    private var url: String = ""
    private var token: String = ""
    private val CHANNEL_ID = "MyServiceChannel"
    private val NOTIFICATION_ID = 1

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        url = intent?.getStringExtra("url") ?: ""
        token = intent?.getStringExtra("token") ?: ""
        return START_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)

        if (url.isBlank() || token.isBlank()) {
            Log.e("MyService", "❌ Missing URL or Token")
            stopSelf()
            return
        }

        Log.d("MyService", "📡 Preparing Volley request for $url")

        val queue = Volley.newRequestQueue(this)

        val jsonBody = JSONObject()
        jsonBody.put(
            "isOnline", "false"
        )
        jsonBody.put(
            "isChatAvailable", "false"
        )
        jsonBody.put(
            "isAudioCallAvailable", "false"
        )
        jsonBody.put(
            "isVideoCallAvailable", "false"
        )

        val request = object : StringRequest(
            Method.POST, url,
            { response ->
                Log.d("MyService", "✅ Response: $response")
                stopForeground(true)
                stopSelf()
            },
            { error ->
                Log.e("MyService", "❌ Error: ${error.message}", error)
                stopForeground(true)
                stopSelf()
            }
        ) {
            override fun getBody(): ByteArray {
                return jsonBody.toString().toByteArray(Charsets.UTF_8)
            }

            override fun getBodyContentType(): String {
                return "application/json; charset=utf-8"
            }

            override fun getHeaders(): MutableMap<String, String> {
                val headers = HashMap<String, String>()
                headers["Content-Type"] = "application/json"
                headers["Authorization"] = "Bearer $token"
                return headers
            }
        }

        queue.add(request)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "My Service Channel",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("App Status Service")
            .setContentText("Updating status...")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .build()
    }
}