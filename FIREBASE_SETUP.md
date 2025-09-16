# Firebase Setup Guide

This guide will help you set up Firebase Cloud Messaging for your Tauri application.

## Prerequisites

1. A Firebase project
2. Android Studio (for Android development)
3. Xcode (for iOS development)

## Android Setup

### 1. Create Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter your project name and follow the setup wizard

### 2. Add Android App

1. In the Firebase Console, click "Add app" and select Android
2. Enter your package name (e.g., `com.example.fcm`)
3. Download the `google-services.json` file
4. Place the `google-services.json` file in your `android/app/` directory

### 3. Configure Android Project

1. Add the Google Services plugin to your `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

2. Apply the plugin in your `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'
```

3. Add Firebase dependencies to your `android/app/build.gradle`:

```gradle
dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
    implementation 'com.google.firebase:firebase-analytics'
}
```

## iOS Setup

### 1. Add iOS App

1. In the Firebase Console, click "Add app" and select iOS
2. Enter your bundle identifier (e.g., `com.example.fcm`)
3. Download the `GoogleService-Info.plist` file
4. Add the `GoogleService-Info.plist` file to your iOS project in Xcode

### 2. Configure iOS Project

1. Add Firebase dependencies to your `ios/Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
            .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk")
        ]
    )
]
```

2. Initialize Firebase in your iOS app's `AppDelegate` or main app file:

```swift
import Firebase

@main
struct YourApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Testing

### 1. Test Token Generation

Use the example app to test if FCM tokens are being generated correctly.

### 2. Test Push Notifications

1. Use the Firebase Console to send test messages
2. Or use the Firebase Admin SDK to send messages programmatically

### 3. Test Topic Subscriptions

1. Subscribe to a topic using the plugin
2. Send a message to that topic from the Firebase Console
3. Verify the message is received

## Troubleshooting

### Common Issues

1. **Token not generated**: Check if Firebase is properly initialized
2. **Notifications not received**: Verify notification permissions are granted
3. **Build errors**: Ensure all dependencies are properly added

### Debug Tips

1. Check the console logs for error messages
2. Verify the `google-services.json` and `GoogleService-Info.plist` files are in the correct locations
3. Ensure the package name/bundle identifier matches your Firebase project configuration

## Security Notes

- Never commit `google-services.json` or `GoogleService-Info.plist` to version control
- Use environment variables for sensitive configuration
- Implement proper server-side validation for FCM tokens
