# FCM Plugin for Android

A comprehensive Firebase Cloud Messaging (FCM) plugin for Android applications that provides easy-to-use functionality for push notifications, topic subscriptions, and token management.

## Features

- ✅ **Token Management**: Get, refresh, and delete FCM tokens
- ✅ **Topic Subscriptions**: Subscribe and unsubscribe from FCM topics
- ✅ **Message Handling**: Handle both foreground and background messages
- ✅ **Notification Display**: Automatic notification display with custom styling
- ✅ **Permission Handling**: Automatic notification permission requests for Android 13+
- ✅ **Coroutine Support**: Built with Kotlin coroutines for async operations
- ✅ **Singleton Pattern**: Easy-to-use singleton implementation

## Project Structure

```
app/src/main/java/com/mori/fcmplugin/
├── FCMPlugin.kt          # Main plugin class with all FCM functionality
├── FCMService.kt         # Firebase messaging service for handling messages
├── FCMApplication.kt     # Application class for initialization
└── MainActivity.kt       # Demo activity showing plugin usage
```

## Setup Instructions

### 1. Firebase Configuration

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your Android app to the project
3. Download the `google-services.json` file and place it in `app/src/main/`
4. Enable Cloud Messaging in the Firebase Console

### 2. Dependencies

The project already includes all necessary dependencies in `app/build.gradle`:

```gradle
// Firebase
implementation platform('com.google.firebase:firebase-bom:32.3.1')
implementation 'com.google.firebase:firebase-messaging-ktx'
implementation 'com.google.firebase:firebase-analytics-ktx'

// Coroutines
implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3'
```

### 3. Permissions

The `AndroidManifest.xml` includes all necessary permissions:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
```

## Usage Guide

### 1. Basic Initialization

```kotlin
// In your Application class
class MyApplication : Application() {
    private lateinit var fcmPlugin: FCMPlugin
    
    override fun onCreate() {
        super.onCreate()
        
        // Initialize FCM Plugin
        fcmPlugin = FCMPlugin.getInstance(this)
        
        // Setup callbacks
        setupFCMCallbacks()
        
        // Get initial token
        initializeFCM()
    }
    
    private fun setupFCMCallbacks() {
        fcmPlugin.setTokenCallback { token ->
            // Handle token updates
            sendTokenToServer(token)
        }
        
        fcmPlugin.setMessageCallback { message ->
            // Handle foreground messages
            handleMessage(message)
        }
    }
    
    private fun initializeFCM() {
        lifecycleScope.launch {
            try {
                val token = fcmPlugin.getToken()
                sendTokenToServer(token)
            } catch (e: Exception) {
                Log.e("FCM", "Failed to get token", e)
            }
        }
    }
}
```

### 2. Getting FCM Token

```kotlin
// Get current FCM token
lifecycleScope.launch {
    try {
        val token = fcmPlugin.getToken()
        Log.d("FCM", "Token: $token")
        // Send token to your server
    } catch (e: Exception) {
        Log.e("FCM", "Failed to get token", e)
    }
}
```

### 3. Topic Subscriptions

```kotlin
// Subscribe to a topic
lifecycleScope.launch {
    try {
        val success = fcmPlugin.subscribeToTopic("news")
        if (success) {
            Log.d("FCM", "Subscribed to news topic")
        }
    } catch (e: Exception) {
        Log.e("FCM", "Failed to subscribe", e)
    }
}

// Unsubscribe from a topic
lifecycleScope.launch {
    try {
        val success = fcmPlugin.unsubscribeFromTopic("news")
        if (success) {
            Log.d("FCM", "Unsubscribed from news topic")
        }
    } catch (e: Exception) {
        Log.e("FCM", "Failed to unsubscribe", e)
    }
}
```

### 4. Handling Messages

```kotlin
// Set up message callback in your Application class
fcmPlugin.setMessageCallback { message ->
    // Handle the message
    val title = message.notification?.title
    val body = message.notification?.body
    val data = message.data
    
    Log.d("FCM", "Received message: $title - $body")
    Log.d("FCM", "Data: $data")
    
    // Custom handling logic here
}
```

### 5. Showing Custom Notifications

```kotlin
// Show a custom notification
fcmPlugin.showNotification(
    title = "Custom Title",
    body = "Custom message body",
    data = mapOf(
        "key1" to "value1",
        "key2" to "value2"
    )
)
```

### 6. Token Management

```kotlin
// Delete FCM token
lifecycleScope.launch {
    try {
        val success = fcmPlugin.deleteToken()
        if (success) {
            Log.d("FCM", "Token deleted successfully")
        }
    } catch (e: Exception) {
        Log.e("FCM", "Failed to delete token", e)
    }
}

// Enable/disable auto initialization
fcmPlugin.setAutoInitEnabled(false) // Disable auto init
fcmPlugin.setAutoInitEnabled(true)  // Enable auto init
```

### 7. Notification Management

```kotlin
// Clear all notifications
fcmPlugin.clearAllNotifications()
```

## API Reference

### FCMPlugin Class

#### Methods

| Method | Description | Return Type |
|--------|-------------|-------------|
| `getInstance(context)` | Get singleton instance | `FCMPlugin` |
| `getToken()` | Get current FCM token | `suspend String` |
| `subscribeToTopic(topic)` | Subscribe to a topic | `suspend Boolean` |
| `unsubscribeFromTopic(topic)` | Unsubscribe from a topic | `suspend Boolean` |
| `setTokenCallback(callback)` | Set token update callback | `Unit` |
| `setMessageCallback(callback)` | Set message received callback | `Unit` |
| `showNotification(title, body, data)` | Show custom notification | `Unit` |
| `clearAllNotifications()` | Clear all notifications | `Unit` |
| `setAutoInitEnabled(enabled)` | Enable/disable auto initialization | `Unit` |
| `deleteToken()` | Delete FCM token | `suspend Boolean` |

#### Callbacks

```kotlin
// Token callback
fcmPlugin.setTokenCallback { token: String ->
    // Handle token updates
}

// Message callback
fcmPlugin.setMessageCallback { message: RemoteMessage ->
    // Handle received messages
}
```

## Testing the Plugin

The project includes a demo `MainActivity` that demonstrates all plugin features:

1. **Get FCM Token**: Retrieves and displays the current FCM token
2. **Topic Subscriptions**: Subscribe/unsubscribe from "news" and "sports" topics
3. **Test Notification**: Send a test notification
4. **Clear Notifications**: Clear all notifications
5. **Delete Token**: Delete the current FCM token

## Sending Test Messages

### Using Firebase Console

1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter notification title and text
4. Select your app as the target
5. Click "Send test message" and enter your FCM token

### Using cURL

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "YOUR_FCM_TOKEN",
    "notification": {
      "title": "Test Title",
      "body": "Test message body"
    },
    "data": {
      "key1": "value1",
      "key2": "value2"
    }
  }'
```

### Sending to Topics

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "/topics/news",
    "notification": {
      "title": "News Update",
      "body": "Breaking news alert!"
    }
  }'
```

## Troubleshooting

### Common Issues

1. **Token not generated**: Ensure `google-services.json` is properly placed and Firebase is initialized
2. **Notifications not showing**: Check notification permissions for Android 13+
3. **Messages not received**: Verify FCM service is properly registered in manifest
4. **Build errors**: Ensure all dependencies are properly added and Google Services plugin is applied

### Debug Tips

- Check logcat for FCM-related logs
- Verify FCM token is valid using Firebase Console
- Test with Firebase Console's "Send test message" feature
- Ensure app is properly signed for release builds

## Requirements

- Android API level 24+ (Android 7.0)
- Kotlin 1.9.10+
- Firebase BOM 32.3.1+
- Google Services 4.4.0+

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
