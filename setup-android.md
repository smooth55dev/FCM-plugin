# Android Setup Guide for FCM Plugin

## Prerequisites

1. **Install Rust** (if not already installed):
   - Go to https://rustup.rs/
   - Download and run the installer
   - Restart your terminal

2. **Install Android Studio**:
   - Download from https://developer.android.com/studio
   - Install with default settings
   - Open Android Studio and install Android SDK

3. **Install Node.js** (if not already installed):
   - Download from https://nodejs.org/
   - Install the LTS version

## Step 1: Install Dependencies

```bash
# Install Tauri CLI
npm install -g @tauri-apps/cli

# Install project dependencies
npm install
```

## Step 2: Set up Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing one
3. Add Android app with package name: `com.smooth55dev.fcm`
4. Download `google-services.json`
5. Place it in `android/app/google-services.json`

## Step 3: Initialize Android Project

```bash
# Initialize Tauri Android project
npm run android:init
```

## Step 4: Build and Run

### For Development (with hot reload):
```bash
npm run android
```

### For Production Build:
```bash
npm run android:build
```

## Step 5: Test on Device/Emulator

1. **Enable USB Debugging** on your Android device:
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings > Developer Options
   - Enable "USB Debugging"

2. **Connect your device** via USB

3. **Run the app**:
   ```bash
   npm run android
   ```

## Troubleshooting

### Common Issues:

1. **"cargo not found"**:
   - Install Rust from https://rustup.rs/
   - Restart terminal

2. **"Android SDK not found"**:
   - Install Android Studio
   - Set ANDROID_HOME environment variable

3. **"Device not found"**:
   - Enable USB Debugging
   - Install device drivers
   - Try `adb devices` to check connection

4. **Build errors**:
   - Check if `google-services.json` is in correct location
   - Verify package name matches Firebase project

### Environment Variables (if needed):

Add to your system environment variables:
- `ANDROID_HOME`: Path to Android SDK (usually `C:\Users\YourName\AppData\Local\Android\Sdk`)
- `JAVA_HOME`: Path to Java installation

## Testing FCM

1. Open the app on your device
2. Click "Get FCM Token" to get the registration token
3. Use Firebase Console to send test messages
4. Test topic subscriptions

## Next Steps

- Set up your Firebase project
- Configure push notification server
- Test all FCM features
- Deploy to Google Play Store (optional)
