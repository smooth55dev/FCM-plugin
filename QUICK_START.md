# 🚀 FCM Plugin Quick Start Guide

Get your FCM plugin up and running in minutes!

## Prerequisites

- ✅ Node.js and npm installed
- ✅ Android Studio and Android SDK
- ✅ Tauri CLI: `npm install -g @tauri-apps/cli`
- ✅ Firebase project with FCM enabled

## Step 1: Firebase Setup (5 minutes)

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Create a project"
   - Follow the setup wizard

2. **Add Android App**
   - Click "Add app" → Android
   - Package name: `com.smooth55dev.fcm`
   - Download `google-services.json`
   - Place it in `android/app/` directory

## Step 2: Build & Run (2 minutes)

### Option A: Using Build Scripts (Recommended)

**Linux/Mac:**
```bash
# Development mode
./build-android.sh dev

# Build debug APK
./build-android.sh debug

# Build and install
./build-android.sh debug install
```

**Windows:**
```cmd
# Development mode
build-android.bat dev

# Build debug APK
build-android.bat debug

# Build and install
build-android.bat debug install
```

### Option B: Using npm Scripts

```bash
# Development mode
npm run android

# Build debug APK
npm run android:build:debug

# Build release APK
npm run android:build:release
```

### Option C: Direct Tauri Commands

```bash
# Development mode
tauri android dev

# Build debug APK
tauri android build --debug

# Build release APK
tauri android build --apk
```

## Step 3: Test the Plugin (1 minute)

1. **Run the app** using any method above
2. **Check the console** for FCM token
3. **Test topic subscription** using the UI buttons
4. **Send test message** from Firebase Console

## Step 4: Send Test Message

1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter title and text
4. Select your app
5. Send the message
6. Check if it appears in your app!

## 🎯 Quick Commands Reference

| Command | Description |
|---------|-------------|
| `./build-android.sh dev` | Start development server |
| `./build-android.sh debug` | Build debug APK |
| `./build-android.sh release` | Build release APK |
| `./build-android.sh debug install` | Build and install APK |
| `npm run android` | Start development server |
| `npm run android:build:debug` | Build debug APK |

## 🔧 Troubleshooting

### Common Issues:

1. **"google-services.json not found"**
   - Download from Firebase Console
   - Place in `android/app/` directory

2. **"Tauri CLI not found"**
   - Install: `npm install -g @tauri-apps/cli`

3. **"adb not found"**
   - Install Android SDK
   - Add to PATH: `export PATH=$PATH:$ANDROID_HOME/platform-tools`

4. **Build fails**
   - Check Android SDK version (API 24+)
   - Verify Java version (JDK 8+)

### Debug Commands:

```bash
# Check Android logs
adb logcat | grep -i fcm

# Verbose build
tauri android build --debug --verbose

# Clean build
rm -rf android/app/build
tauri android build --debug
```

## 📱 What You'll See

When the app runs successfully, you should see:

1. **FCM Token** in the status section
2. **Permission status** (Granted/Denied)
3. **Topic management buttons** working
4. **Console log** showing FCM events
5. **Messages section** for received notifications

## 🎉 Next Steps

1. **Integrate with your backend** to send messages
2. **Customize notification handling**
3. **Add analytics** for message tracking
4. **Deploy to Play Store**

## 📚 Full Documentation

- [Complete Android Build Guide](ANDROID_BUILD_GUIDE.md)
- [Plugin API Documentation](README.md)
- [Tauri Mobile Plugin Guide](https://v2.tauri.app/develop/plugins/develop-mobile/)

---

**Need help?** Check the troubleshooting section or open an issue on GitHub!
