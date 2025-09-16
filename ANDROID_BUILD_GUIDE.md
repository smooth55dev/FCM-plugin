# Android Build Guide for FCM Plugin

This guide will walk you through building and using the FCM plugin for Android.

## Prerequisites

Before building, ensure you have:

1. **Android Studio** (latest version)
2. **Android SDK** (API level 24 or higher)
3. **Java Development Kit (JDK)** 8 or higher
4. **Tauri CLI** installed globally
5. **Firebase Project** set up with FCM enabled

## Step 1: Firebase Setup

### 1.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name (e.g., "FCM Example App")
4. Enable Google Analytics (optional)
5. Create the project

### 1.2 Add Android App to Firebase

1. In Firebase Console, click "Add app" → Android
2. Enter package name: `com.smooth55dev.fcm`
3. Enter app nickname: "FCM Example"
4. Download `google-services.json`
5. Place the file in `android/app/` directory

### 1.3 Enable FCM

1. In Firebase Console, go to "Project Settings" → "Cloud Messaging"
2. Ensure FCM is enabled
3. Note down your Server Key (for sending messages)

## Step 2: Project Configuration

### 2.1 Update Android Build Configuration

The project is already configured, but verify these files:

**android/build.gradle** (Project level):
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

**android/app/build.gradle** (App level):
```gradle
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
    id 'com.google.gms.google-services'
}

dependencies {
    // Firebase
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
    implementation 'com.google.firebase:firebase-analytics'
    
    // Tauri
    implementation 'app.tauri:tauri-android:2.0.0'
}
```

### 2.2 Update Tauri Configuration

**src-tauri/tauri.conf.json**:
```json
{
  "tauri": {
    "plugins": {
      "fcm": {
        "timeout": 3000
      }
    }
  }
}
```

## Step 3: Build Commands

### 3.1 Development Build

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Or specifically for Android
npm run android
```

### 3.2 Production Build

```bash
# Build APK
npm run android:build

# Or using Tauri CLI directly
tauri android build --apk
```

### 3.3 Debug Build

```bash
# Build debug APK
tauri android build --debug
```

## Step 4: Usage Examples

### 4.1 Basic Setup in Your App

**src-tauri/src/main.rs**:
```rust
use tauri_plugin_fcm::Fcm;

fn main() {
    tauri::Builder::default()
        .plugin(Fcm::init())
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

### 4.2 Frontend Usage (JavaScript/TypeScript)

**Create a new file: `src/fcm-example.js`**:

```javascript
import { createFcm } from '@tauri-apps/plugin-fcm';

class FcmManager {
    constructor() {
        this.fcm = createFcm();
        this.setupEventListeners();
    }

    async initialize() {
        try {
            // Request notification permission
            const granted = await this.fcm.requestNotificationPermission();
            console.log('Permission granted:', granted);

            // Get FCM token
            const token = await this.fcm.getToken();
            console.log('FCM Token:', token);

            // Subscribe to a topic
            await this.fcm.subscribeToTopic('news');
            console.log('Subscribed to news topic');

            return token;
        } catch (error) {
            console.error('FCM initialization error:', error);
            throw error;
        }
    }

    setupEventListeners() {
        // Listen for token received
        this.fcm.onTokenReceived((event) => {
            console.log('Token received:', event.token);
            // Send token to your server
            this.sendTokenToServer(event.token);
        });

        // Listen for token refresh
        this.fcm.onTokenRefresh((event) => {
            console.log('Token refreshed:', event.token);
            // Update token on your server
            this.updateTokenOnServer(event.token);
        });

        // Listen for messages
        this.fcm.onMessageReceived((message) => {
            console.log('Message received:', message);
            this.handleMessage(message);
        });

        // Listen for topic changes
        this.fcm.onTopicChanged((event) => {
            console.log(`Topic ${event.topic} ${event.action}`);
        });

        // Listen for errors
        this.fcm.onTokenError((event) => {
            console.error('FCM Error:', event.error);
        });
    }

    async sendTokenToServer(token) {
        try {
            // Send token to your backend server
            const response = await fetch('https://your-server.com/api/fcm-token', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ token, platform: 'android' })
            });
            
            if (response.ok) {
                console.log('Token sent to server successfully');
            }
        } catch (error) {
            console.error('Failed to send token to server:', error);
        }
    }

    async updateTokenOnServer(token) {
        // Similar to sendTokenToServer but for updates
        console.log('Updating token on server:', token);
    }

    handleMessage(message) {
        // Handle incoming FCM message
        if (message.notification) {
            // Show notification in your app
            this.showInAppNotification(message.notification);
        }

        if (message.data) {
            // Handle data payload
            console.log('Message data:', message.data);
        }
    }

    showInAppNotification(notification) {
        // Create a simple in-app notification
        const notificationElement = document.createElement('div');
        notificationElement.className = 'fcm-notification';
        notificationElement.innerHTML = `
            <h3>${notification.title || 'Notification'}</h3>
            <p>${notification.body || ''}</p>
        `;
        
        document.body.appendChild(notificationElement);
        
        // Remove after 5 seconds
        setTimeout(() => {
            notificationElement.remove();
        }, 5000);
    }

    // Topic management
    async subscribeToTopic(topic) {
        try {
            await this.fcm.subscribeToTopic(topic);
            console.log(`Subscribed to topic: ${topic}`);
        } catch (error) {
            console.error(`Failed to subscribe to topic ${topic}:`, error);
        }
    }

    async unsubscribeFromTopic(topic) {
        try {
            await this.fcm.unsubscribeFromTopic(topic);
            console.log(`Unsubscribed from topic: ${topic}`);
        } catch (error) {
            console.error(`Failed to unsubscribe from topic ${topic}:`, error);
        }
    }

    // Utility methods
    async checkNotificationStatus() {
        const enabled = await this.fcm.areNotificationsEnabled();
        console.log('Notifications enabled:', enabled);
        return enabled;
    }

    async getLastMessage() {
        const message = await this.fcm.getLastMessage();
        console.log('Last message:', message);
        return message;
    }

    async deleteToken() {
        try {
            await this.fcm.deleteToken();
            console.log('FCM token deleted');
        } catch (error) {
            console.error('Failed to delete token:', error);
        }
    }
}

// Initialize FCM when DOM is loaded
document.addEventListener('DOMContentLoaded', async () => {
    const fcmManager = new FcmManager();
    
    try {
        const token = await fcmManager.initialize();
        console.log('FCM initialized successfully with token:', token);
        
        // Make fcmManager available globally for testing
        window.fcmManager = fcmManager;
    } catch (error) {
        console.error('Failed to initialize FCM:', error);
    }
});
```

### 4.3 HTML Example

**Create `dist/index.html`**:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FCM Example App</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .fcm-notification {
            background: #4CAF50;
            color: white;
            padding: 15px;
            margin: 10px 0;
            border-radius: 5px;
            animation: slideIn 0.3s ease-out;
        }
        
        @keyframes slideIn {
            from { transform: translateX(-100%); }
            to { transform: translateX(0); }
        }
        
        button {
            background: #2196F3;
            color: white;
            border: none;
            padding: 10px 20px;
            margin: 5px;
            border-radius: 5px;
            cursor: pointer;
        }
        
        button:hover {
            background: #1976D2;
        }
        
        .status {
            margin: 10px 0;
            padding: 10px;
            background: #f5f5f5;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <h1>FCM Example App</h1>
    
    <div class="status">
        <h3>Status</h3>
        <p id="status">Initializing...</p>
        <p id="token">Token: Not available</p>
    </div>
    
    <div>
        <h3>Topic Management</h3>
        <button onclick="subscribeToNews()">Subscribe to News</button>
        <button onclick="unsubscribeFromNews()">Unsubscribe from News</button>
        <button onclick="subscribeToWeather()">Subscribe to Weather</button>
        <button onclick="unsubscribeFromWeather()">Unsubscribe from Weather</button>
    </div>
    
    <div>
        <h3>Actions</h3>
        <button onclick="checkNotificationStatus()">Check Notification Status</button>
        <button onclick="getLastMessage()">Get Last Message</button>
        <button onclick="deleteToken()">Delete Token</button>
    </div>
    
    <div>
        <h3>Messages</h3>
        <div id="messages"></div>
    </div>

    <script type="module" src="./fcm-example.js"></script>
    <script>
        // Update status display
        function updateStatus(message) {
            document.getElementById('status').textContent = message;
        }
        
        function updateToken(token) {
            document.getElementById('token').textContent = `Token: ${token}`;
        }
        
        function addMessage(message) {
            const messagesDiv = document.getElementById('messages');
            const messageElement = document.createElement('div');
            messageElement.className = 'fcm-notification';
            messageElement.innerHTML = `
                <h4>${message.title || 'Message'}</h4>
                <p>${message.body || JSON.stringify(message)}</p>
                <small>${new Date().toLocaleTimeString()}</small>
            `;
            messagesDiv.insertBefore(messageElement, messagesDiv.firstChild);
        }
        
        // Topic management functions
        async function subscribeToNews() {
            if (window.fcmManager) {
                await window.fcmManager.subscribeToTopic('news');
                updateStatus('Subscribed to news topic');
            }
        }
        
        async function unsubscribeFromNews() {
            if (window.fcmManager) {
                await window.fcmManager.unsubscribeFromTopic('news');
                updateStatus('Unsubscribed from news topic');
            }
        }
        
        async function subscribeToWeather() {
            if (window.fcmManager) {
                await window.fcmManager.subscribeToTopic('weather');
                updateStatus('Subscribed to weather topic');
            }
        }
        
        async function unsubscribeFromWeather() {
            if (window.fcmManager) {
                await window.fcmManager.unsubscribeFromTopic('weather');
                updateStatus('Unsubscribed from weather topic');
            }
        }
        
        // Action functions
        async function checkNotificationStatus() {
            if (window.fcmManager) {
                const enabled = await window.fcmManager.checkNotificationStatus();
                updateStatus(`Notifications ${enabled ? 'enabled' : 'disabled'}`);
            }
        }
        
        async function getLastMessage() {
            if (window.fcmManager) {
                const message = await window.fcmManager.getLastMessage();
                if (message) {
                    addMessage(message);
                } else {
                    updateStatus('No last message available');
                }
            }
        }
        
        async function deleteToken() {
            if (window.fcmManager) {
                await window.fcmManager.deleteToken();
                updateStatus('Token deleted');
                updateToken('Deleted');
            }
        }
        
        // Override FCM manager methods to update UI
        document.addEventListener('DOMContentLoaded', () => {
            // Wait for FCM manager to be available
            const checkFcmManager = setInterval(() => {
                if (window.fcmManager) {
                    clearInterval(checkFcmManager);
                    
                    // Override methods to update UI
                    const originalHandleMessage = window.fcmManager.handleMessage;
                    window.fcmManager.handleMessage = function(message) {
                        originalHandleMessage.call(this, message);
                        addMessage(message);
                    };
                    
                    const originalSendTokenToServer = window.fcmManager.sendTokenToServer;
                    window.fcmManager.sendTokenToServer = function(token) {
                        originalSendTokenToServer.call(this, token);
                        updateToken(token);
                    };
                }
            }, 100);
        });
    </script>
</body>
</html>
```

## Step 5: Testing

### 5.1 Test Token Generation

1. Build and run the app
2. Check console logs for FCM token
3. Verify token is received and displayed

### 5.2 Test Topic Subscription

1. Use the UI buttons to subscribe/unsubscribe from topics
2. Check console logs for confirmation
3. Verify topic change events are triggered

### 5.3 Test Message Reception

1. Use Firebase Console to send a test message
2. Or use a tool like Postman to send FCM messages
3. Verify messages are received and displayed

### 5.4 Send Test Message via Firebase Console

1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter notification title and text
4. Select your app
5. Send the message
6. Check if it's received in your app

## Step 6: Troubleshooting

### Common Issues:

1. **Token not generated**:
   - Check Firebase configuration
   - Verify `google-services.json` is in correct location
   - Check internet connectivity

2. **Messages not received**:
   - Verify notification permissions
   - Check if app is in foreground/background
   - Verify FCM service is properly registered

3. **Build errors**:
   - Ensure all dependencies are correctly added
   - Check Android SDK version compatibility
   - Verify Kotlin version compatibility

### Debug Commands:

```bash
# Check Android logs
adb logcat | grep -i fcm

# Check Tauri logs
tauri android dev --verbose

# Clean build
tauri android build --debug --verbose
```

## Step 7: Production Deployment

### 7.1 Sign APK

```bash
# Generate signed APK
tauri android build --apk --target aarch64-linux-android
```

### 7.2 Upload to Play Store

1. Generate signed APK/AAB
2. Upload to Google Play Console
3. Configure app permissions
4. Test on different devices

## Next Steps

1. **Server Integration**: Set up your backend to send FCM messages
2. **Analytics**: Integrate Firebase Analytics for message tracking
3. **Custom Notifications**: Implement custom notification handling
4. **Background Processing**: Handle messages when app is in background

This completes the Android build and usage guide for the FCM plugin!
