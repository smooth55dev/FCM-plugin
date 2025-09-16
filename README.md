# Tauri FCM Plugin

A comprehensive Firebase Cloud Messaging (FCM) plugin for Tauri applications, providing push notification capabilities for both Android and iOS platforms.

## Features

- 🔥 **Firebase Cloud Messaging Integration**: Full FCM support for Android and iOS
- 📱 **Cross-Platform**: Works on both Android and iOS
- 🎯 **Topic Management**: Subscribe and unsubscribe from FCM topics
- 🔐 **Permission Handling**: Built-in notification permission management
- 📨 **Message Handling**: Receive and process push notifications
- 🎧 **Event System**: Real-time events for token changes, messages, and errors
- 🛡️ **Type Safety**: Full TypeScript support with comprehensive type definitions

## Installation

### 1. Add the Plugin to Your Tauri Project

Add the plugin to your `Cargo.toml`:

```toml
[dependencies]
tauri-plugin-fcm = { path = "../tauri-plugin-fcm" }
```

### 2. Initialize the Plugin

In your `src-tauri/src/main.rs`:

```rust
use tauri_plugin_fcm::Fcm;

fn main() {
    tauri::Builder::default()
        .plugin(Fcm::init())
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

### 3. Android Setup

#### Add Firebase to Your Android Project

1. Add the Google Services plugin to your `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

2. Apply the plugin in your `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'
```

3. Add Firebase dependencies:

```gradle
dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
    implementation 'com.google.firebase:firebase-analytics'
}
```

4. Add the `google-services.json` file to your `android/app/` directory.

#### Update AndroidManifest.xml

Add the required permissions and service:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<application>
    <service
        android:name="app.tauri.plugin.fcm.FcmService"
        android:exported="false">
        <intent-filter>
            <action android:name="com.google.firebase.MESSAGING_EVENT" />
        </intent-filter>
    </service>
</application>
```

### 4. iOS Setup

#### Add Firebase to Your iOS Project

1. Add Firebase dependencies to your `ios/Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0")
]
```

2. Add the `GoogleService-Info.plist` file to your iOS project.

3. Initialize Firebase in your iOS app delegate.

## Usage

### JavaScript/TypeScript

```typescript
import { createFcm } from '@tauri-apps/plugin-fcm';

const fcm = createFcm();

// Get FCM token
const token = await fcm.getToken();
console.log('FCM Token:', token);

// Subscribe to a topic
await fcm.subscribeToTopic('news');

// Unsubscribe from a topic
await fcm.unsubscribeFromTopic('news');

// Check notification permissions
const enabled = await fcm.areNotificationsEnabled();
console.log('Notifications enabled:', enabled);

// Request notification permission
const granted = await fcm.requestNotificationPermission();
console.log('Permission granted:', granted);

// Delete FCM token
await fcm.deleteToken();

// Get last received message
const lastMessage = await fcm.getLastMessage();
console.log('Last message:', lastMessage);
```

### Event Listeners

```typescript
// Listen for token received events
const tokenListener = await fcm.onTokenReceived((event) => {
    console.log('Token received:', event.token);
    console.log('Timestamp:', event.timestamp);
});

// Listen for message received events
const messageListener = await fcm.onMessageReceived((message) => {
    console.log('Message received:', message);
    console.log('Title:', message.notification?.title);
    console.log('Body:', message.notification?.body);
    console.log('Data:', message.data);
});

// Listen for topic change events
const topicListener = await fcm.onTopicChanged((event) => {
    console.log(`Topic ${event.topic} ${event.action}`);
});

// Listen for token refresh events
const refreshListener = await fcm.onTokenRefresh((event) => {
    console.log('Token refreshed:', event.token);
});

// Listen for errors
const errorListener = await fcm.onTokenError((event) => {
    console.error('FCM Error:', event.error);
});

// Clean up listeners
tokenListener.unlisten();
messageListener.unlisten();
topicListener.unlisten();
refreshListener.unlisten();
errorListener.unlisten();
```

### Rust

```rust
use tauri_plugin_fcm::Fcm;

// Get FCM instance
let fcm = Fcm::new(handle);

// Get token
let token = fcm.get_token()?;
println!("FCM Token: {}", token);

// Subscribe to topic
fcm.subscribe_to_topic("news".to_string())?;

// Unsubscribe from topic
fcm.unsubscribe_from_topic("news".to_string())?;

// Check notifications
let enabled = fcm.are_notifications_enabled()?;
println!("Notifications enabled: {}", enabled);

// Request permission
let granted = fcm.request_notification_permission()?;
println!("Permission granted: {}", granted);

// Delete token
fcm.delete_token()?;

// Get last message
let last_message = fcm.get_last_message()?;
println!("Last message: {:?}", last_message);
```

## API Reference

### Methods

#### `getToken(): Promise<string>`
Gets the current FCM registration token.

#### `subscribeToTopic(topic: string): Promise<void>`
Subscribes to an FCM topic.

#### `unsubscribeFromTopic(topic: string): Promise<void>`
Unsubscribes from an FCM topic.

#### `areNotificationsEnabled(): Promise<boolean>`
Checks if notifications are enabled on the device.

#### `requestNotificationPermission(): Promise<boolean>`
Requests notification permission from the user.

#### `deleteToken(): Promise<void>`
Deletes the current FCM token.

#### `getLastMessage(): Promise<FcmMessage | null>`
Gets the last received FCM message.

### Events

#### `tokenReceived`
Fired when a new FCM token is received.

```typescript
{
  token: string;
  timestamp: number;
}
```

#### `tokenRefresh`
Fired when the FCM token is refreshed.

```typescript
{
  token: string;
  timestamp: number;
}
```

#### `messageReceived`
Fired when a new FCM message is received.

```typescript
{
  messageId?: string;
  from?: string;
  to?: string;
  messageType?: string;
  sentTime?: number;
  ttl?: number;
  notification?: {
    title?: string;
    body?: string;
    icon?: string;
    color?: string;
    sound?: string;
    tag?: string;
    clickAction?: string;
  };
  data?: Record<string, string>;
}
```

#### `topicChanged`
Fired when topic subscription status changes.

```typescript
{
  topic: string;
  action: 'subscribed' | 'unsubscribed';
}
```

#### `tokenDeleted`
Fired when the FCM token is deleted.

```typescript
{
  action: string;
}
```

#### `tokenError`
Fired when an FCM error occurs.

```typescript
{
  error: string;
}
```

## Permissions

The plugin automatically handles the following permissions:

- `POST_NOTIFICATIONS` - Required for push notifications
- `INTERNET` - Required for FCM communication
- `WAKE_LOCK` - Required for background message processing

## Configuration

### Android

The plugin uses the standard Firebase configuration through `google-services.json`.

### iOS

The plugin uses the standard Firebase configuration through `GoogleService-Info.plist`.

## Troubleshooting

### Common Issues

1. **Token not received**: Ensure Firebase is properly configured and the app has internet connectivity.

2. **Messages not received**: Check notification permissions and ensure the app is properly registered with FCM.

3. **Build errors**: Ensure all Firebase dependencies are correctly added and the configuration files are in place.

### Debug Mode

Enable debug logging by setting the log level in your Tauri configuration:

```json
{
  "tauri": {
    "allowlist": {
      "all": false,
      "log": {
        "all": true
      }
    }
  }
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, please open an issue on the GitHub repository or check the Tauri documentation.