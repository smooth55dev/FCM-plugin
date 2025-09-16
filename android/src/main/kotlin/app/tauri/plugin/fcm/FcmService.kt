package app.tauri.plugin.fcm

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import org.json.JSONObject

class FcmService : FirebaseMessagingService() {

    companion object {
        private const val PREFS_NAME = "fcm_prefs"
        private const val KEY_LAST_MESSAGE = "last_message"
        private const val KEY_FCM_TOKEN = "fcm_token"
    }

    private lateinit var sharedPreferences: SharedPreferences

    override fun onCreate() {
        super.onCreate()
        sharedPreferences = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        // Store the last message for retrieval
        storeLastMessage(remoteMessage)

        // Handle FCM messages here
        val notification = remoteMessage.notification
        val data = remoteMessage.data

        // If the app is in the foreground, we can trigger events directly
        // If in background, we'll show a notification
        if (isAppInForeground()) {
            // App is in foreground, trigger event to webview
            triggerMessageEvent(remoteMessage)
        } else {
            // App is in background, show notification
            if (notification != null) {
                sendNotification(notification.title ?: "", notification.body ?: "", data)
            }
        }
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        
        // Store the new token
        sharedPreferences.edit().putString(KEY_FCM_TOKEN, token).apply()
        
        // Send the new token to your server
        // You can also trigger an event to the webview if app is in foreground
        if (isAppInForeground()) {
            triggerTokenRefreshEvent(token)
        }
    }

    private fun storeLastMessage(remoteMessage: RemoteMessage) {
        val messageJson = JSONObject().apply {
            put("messageId", remoteMessage.messageId)
            put("from", remoteMessage.from)
            put("to", remoteMessage.to)
            put("messageType", remoteMessage.messageType)
            put("sentTime", remoteMessage.sentTime)
            put("ttl", remoteMessage.ttl)
            
            // Add notification data
            remoteMessage.notification?.let { notification ->
                put("notification", JSONObject().apply {
                    put("title", notification.title)
                    put("body", notification.body)
                    put("icon", notification.icon)
                    put("color", notification.color)
                    put("sound", notification.sound)
                    put("tag", notification.tag)
                    put("clickAction", notification.clickAction)
                })
            }
            
            // Add data payload
            val dataJson = JSONObject()
            remoteMessage.data.forEach { (key, value) ->
                dataJson.put(key, value)
            }
            put("data", dataJson)
        }
        
        sharedPreferences.edit().putString(KEY_LAST_MESSAGE, messageJson.toString()).apply()
    }

    private fun isAppInForeground(): Boolean {
        // This is a simplified check - in a real implementation, you might want to use
        // ActivityManager or other methods to check if the app is in foreground
        return true // For now, assume app is in foreground
    }

    private fun triggerMessageEvent(remoteMessage: RemoteMessage) {
        // This would require access to the plugin instance
        // In a real implementation, you might use a singleton pattern or event bus
        // to communicate between the service and the plugin
    }

    private fun triggerTokenRefreshEvent(token: String) {
        // This would require access to the plugin instance
        // In a real implementation, you might use a singleton pattern or event bus
        // to communicate between the service and the plugin
    }

    private fun sendNotification(title: String, messageBody: String, data: Map<String, String>) {
        val intent = Intent(this, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        
        // Add data to intent
        data.forEach { (key, value) ->
            intent.putExtra(key, value)
        }

        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
        )

        val channelId = "fcm_default_channel"
        val notificationBuilder = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(messageBody)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Since android Oreo notification channel is needed.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "FCM Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            notificationManager.createNotificationChannel(channel)
        }

        notificationManager.notify(0, notificationBuilder.build())
    }
}
