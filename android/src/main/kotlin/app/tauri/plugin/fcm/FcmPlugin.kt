package app.tauri.plugin.fcm

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.webkit.WebView
import app.tauri.annotation.Command
import app.tauri.annotation.InvokeArg
import app.tauri.annotation.Permission
import app.tauri.annotation.TauriPlugin
import app.tauri.plugin.Invoke
import app.tauri.plugin.JSObject
import app.tauri.plugin.Plugin
import com.google.firebase.messaging.FirebaseMessaging
import com.google.firebase.messaging.RemoteMessage
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await

@InvokeArg
class SubscribeToTopicArgs {
    lateinit var topic: String
}

@InvokeArg
class UnsubscribeFromTopicArgs {
    lateinit var topic: String
}

@InvokeArg
class SendMessageArgs {
    var title: String? = null
    var body: String? = null
    var data: Map<String, String>? = null
}

@TauriPlugin(
    permissions = [
        Permission(
            strings = [android.Manifest.permission.POST_NOTIFICATIONS],
            alias = "postNotification"
        ),
        Permission(
            strings = [android.Manifest.permission.INTERNET],
            alias = "internet"
        ),
        Permission(
            strings = [android.Manifest.permission.WAKE_LOCK],
            alias = "wakeLock"
        )
    ]
)
class FcmPlugin(private val activity: Activity) : Plugin(activity) {

    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private var fcmToken: String? = null

    override fun load(webView: WebView) {
        super.load(webView)
        
        // Initialize FCM and get token
        initializeFcm()
        
        // Set up token refresh listener
        setupTokenRefreshListener()
        
        // Handle any pending messages from intent
        handlePendingMessages()
    }

    private fun initializeFcm() {
        scope.launch {
            try {
                val token = FirebaseMessaging.getInstance().token.await()
                fcmToken = token
                
                val event = JSObject()
                event.put("token", token)
                event.put("timestamp", System.currentTimeMillis())
                trigger("tokenReceived", event)
            } catch (e: Exception) {
                val errorEvent = JSObject()
                errorEvent.put("error", e.message ?: "Failed to get FCM token")
                trigger("tokenError", errorEvent)
            }
        }
    }

    private fun setupTokenRefreshListener() {
        FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
            if (!task.isSuccessful) {
                val errorEvent = JSObject()
                errorEvent.put("error", task.exception?.message ?: "Token refresh failed")
                trigger("tokenError", errorEvent)
                return@addOnCompleteListener
            }
            
            val newToken = task.result
            if (newToken != fcmToken) {
                fcmToken = newToken
                val event = JSObject()
                event.put("token", newToken)
                event.put("timestamp", System.currentTimeMillis())
                trigger("tokenRefresh", event)
            }
        }
    }

    private fun handlePendingMessages() {
        // Handle any pending messages from the intent
        val intent = activity.intent
        if (intent != null && intent.hasExtra("fcm_message")) {
            val messageData = intent.getStringExtra("fcm_message")
            if (messageData != null) {
                val event = JSObject()
                event.put("message", messageData)
                event.put("fromBackground", true)
                trigger("messageReceived", event)
            }
        }
    }

    @Command
    fun getToken(invoke: Invoke) {
        scope.launch {
            try {
                val token = FirebaseMessaging.getInstance().token.await()
                fcmToken = token
                invoke.resolve(token)
            } catch (e: Exception) {
                invoke.reject("Failed to get FCM token: ${e.message}")
            }
        }
    }

    @Command
    fun subscribeToTopic(invoke: Invoke) {
        val args = invoke.parseArgs(SubscribeToTopicArgs::class.java)
        
        scope.launch {
            try {
                FirebaseMessaging.getInstance().subscribeToTopic(args.topic).await()
                
                val result = JSObject()
                result.put("topic", args.topic)
                result.put("success", true)
                invoke.resolve(result)
                
                // Trigger event
                val event = JSObject()
                event.put("topic", args.topic)
                event.put("action", "subscribed")
                trigger("topicChanged", event)
            } catch (e: Exception) {
                invoke.reject("Failed to subscribe to topic: ${e.message}")
            }
        }
    }

    @Command
    fun unsubscribeFromTopic(invoke: Invoke) {
        val args = invoke.parseArgs(UnsubscribeFromTopicArgs::class.java)
        
        scope.launch {
            try {
                FirebaseMessaging.getInstance().unsubscribeFromTopic(args.topic).await()
                
                val result = JSObject()
                result.put("topic", args.topic)
                result.put("success", true)
                invoke.resolve(result)
                
                // Trigger event
                val event = JSObject()
                event.put("topic", args.topic)
                event.put("action", "unsubscribed")
                trigger("topicChanged", event)
            } catch (e: Exception) {
                invoke.reject("Failed to unsubscribe from topic: ${e.message}")
            }
        }
    }

    @Command
    fun areNotificationsEnabled(invoke: Invoke) {
        try {
            val enabled = android.provider.Settings.Secure.getString(
                activity.contentResolver,
                "notification_enabled"
            ) != "0"
            
            invoke.resolve(enabled)
        } catch (e: Exception) {
            invoke.reject("Failed to check notification status: ${e.message}")
        }
    }

    @Command
    fun requestNotificationPermission(invoke: Invoke) {
        // This will be handled by the permission system
        // The actual permission request is managed by Tauri's permission system
        invoke.resolve(true)
    }

    @Command
    fun deleteToken(invoke: Invoke) {
        scope.launch {
            try {
                FirebaseMessaging.getInstance().deleteToken().await()
                fcmToken = null
                
                val result = JSObject()
                result.put("success", true)
                invoke.resolve(result)
                
                // Trigger event
                val event = JSObject()
                event.put("action", "deleted")
                trigger("tokenDeleted", event)
            } catch (e: Exception) {
                invoke.reject("Failed to delete FCM token: ${e.message}")
            }
        }
    }

    @Command
    fun getLastMessage(invoke: Invoke) {
        // This would typically be stored in SharedPreferences or a database
        // For now, we'll return null as we don't have persistent storage
        invoke.resolve(null)
    }

    // Method to handle incoming messages from FCM service
    fun handleMessageReceived(remoteMessage: RemoteMessage) {
        val event = JSObject()
        
        // Add notification data
        val notification = remoteMessage.notification
        if (notification != null) {
            val notificationData = JSObject()
            notificationData.put("title", notification.title)
            notificationData.put("body", notification.body)
            notificationData.put("icon", notification.icon)
            notificationData.put("color", notification.color)
            notificationData.put("sound", notification.sound)
            notificationData.put("tag", notification.tag)
            notificationData.put("clickAction", notification.clickAction)
            event.put("notification", notificationData)
        }
        
        // Add data payload
        val data = JSObject()
        remoteMessage.data.forEach { (key, value) ->
            data.put(key, value)
        }
        event.put("data", data)
        
        // Add message metadata
        event.put("messageId", remoteMessage.messageId)
        event.put("from", remoteMessage.from)
        event.put("to", remoteMessage.to)
        event.put("messageType", remoteMessage.messageType)
        event.put("sentTime", remoteMessage.sentTime)
        event.put("ttl", remoteMessage.ttl)
        
        trigger("messageReceived", event)
    }

    override fun checkPermissions(invoke: Invoke) {
        val result = JSObject()
        
        // Check notification permission
        val notificationEnabled = android.provider.Settings.Secure.getString(
            activity.contentResolver,
            "notification_enabled"
        ) != "0"
        
        val notificationStatus = if (notificationEnabled) "granted" else "denied"
        result.put("postNotification", notificationStatus)
        
        // Check internet permission (usually granted by default)
        result.put("internet", "granted")
        
        // Check wake lock permission (usually granted by default)
        result.put("wakeLock", "granted")
        
        invoke.resolve(result)
    }

    override fun requestPermissions(invoke: Invoke) {
        // Permission request is handled by Tauri's permission system
        val result = JSObject()
        
        // For POST_NOTIFICATIONS, we need to check if it's already granted
        val notificationEnabled = android.provider.Settings.Secure.getString(
            activity.contentResolver,
            "notification_enabled"
        ) != "0"
        
        val notificationStatus = if (notificationEnabled) "granted" else "prompt"
        result.put("postNotification", notificationStatus)
        result.put("internet", "granted")
        result.put("wakeLock", "granted")
        
        invoke.resolve(result)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        
        // Handle FCM messages from intent
        if (intent.hasExtra("fcm_message")) {
            val messageData = intent.getStringExtra("fcm_message")
            if (messageData != null) {
                val event = JSObject()
                event.put("message", messageData)
                event.put("fromBackground", true)
                event.put("timestamp", System.currentTimeMillis())
                trigger("messageReceived", event)
            }
        }
    }
}
