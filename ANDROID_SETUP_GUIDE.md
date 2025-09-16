# 🚀 Android Build Setup Guide

## Current Status
✅ **FCM Plugin Code**: Complete and ready  
✅ **Android Project Structure**: Complete  
✅ **Firebase Configuration**: Ready (`google-services.json`)  
⚠️ **Android Development Environment**: Needs setup  

## Required Software Installation

### 1. Install Android Studio
1. Download from: https://developer.android.com/studio
2. Install with default settings
3. During installation, make sure to install:
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device
   - Performance (Intel HAXM)

### 2. Install Android NDK
1. Open Android Studio
2. Go to **Tools** → **SDK Manager**
3. Click **SDK Tools** tab
4. Check **NDK (Side by side)**
5. Click **Apply** and install

### 3. Set Environment Variables
Add these to your system environment variables:

```bash
# Android SDK
ANDROID_HOME=C:\Users\%USERNAME%\AppData\Local\Android\Sdk
ANDROID_SDK_ROOT=C:\Users\%USERNAME%\AppData\Local\Android\Sdk

# Android NDK
NDK_HOME=C:\Users\%USERNAME%\AppData\Local\Android\Sdk\ndk\25.2.9519653

# Add to PATH
%ANDROID_HOME%\platform-tools
%ANDROID_HOME%\tools
%ANDROID_HOME%\tools\bin
%NDK_HOME%
```

### 4. Install Java Development Kit (JDK)
1. Download JDK 17 from: https://adoptium.net/
2. Install with default settings
3. Set `JAVA_HOME` environment variable

## Build Commands

### Option 1: Using Tauri CLI (Recommended)
```bash
# Initialize Android project
tauri android init

# Build debug APK
tauri android build --debug

# Build release APK
tauri android build --apk

# Run on device/emulator
tauri android dev
```

### Option 2: Using Build Scripts
```bash
# Windows
.\build-android.bat debug
.\build-android.bat release
.\build-android.bat dev

# Linux/Mac
./build-android.sh debug
./build-android.sh release
./build-android.sh dev
```

### Option 3: Using npm Scripts
```bash
npm run android:build:debug
npm run android:build:release
npm run android
```

## Quick Setup Script

Create and run this PowerShell script to set up environment variables:

```powershell
# Set Android environment variables
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$env:ANDROID_SDK_ROOT = "$env:LOCALAPPDATA\Android\Sdk"
$env:NDK_HOME = "$env:LOCALAPPDATA\Android\Sdk\ndk\25.2.9519653"
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.9.9-hotspot"

# Add to PATH
$env:PATH += ";$env:ANDROID_HOME\platform-tools"
$env:PATH += ";$env:ANDROID_HOME\tools"
$env:PATH += ";$env:ANDROID_HOME\tools\bin"
$env:PATH += ";$env:NDK_HOME"

# Verify installation
Write-Host "Android SDK: $env:ANDROID_HOME"
Write-Host "Android NDK: $env:NDK_HOME"
Write-Host "Java Home: $env:JAVA_HOME"

# Test commands
adb version
java -version
```

## Troubleshooting

### Common Issues:

1. **"NDK_HOME not set"**
   - Install NDK from Android Studio SDK Manager
   - Set NDK_HOME environment variable

2. **"Android SDK not found"**
   - Install Android Studio
   - Set ANDROID_HOME environment variable

3. **"Java not found"**
   - Install JDK 17
   - Set JAVA_HOME environment variable

4. **"Gradle build failed"**
   - Check internet connection
   - Clear Gradle cache: `./gradlew clean`

### Verification Commands:
```bash
# Check if tools are installed
adb version
java -version
gradle --version

# Check environment variables
echo $ANDROID_HOME
echo $NDK_HOME
echo $JAVA_HOME
```

## Project Structure
```
FCM plugin/
├── android/                 # Android project
│   ├── app/
│   │   ├── build.gradle
│   │   ├── google-services.json
│   │   └── src/main/
│   └── build.gradle
├── src-tauri/              # Tauri app
├── dist/                   # Frontend
└── build-android.bat       # Build script
```

## Next Steps After Setup

1. **Install required software** (Android Studio, NDK, JDK)
2. **Set environment variables**
3. **Run**: `tauri android init`
4. **Build**: `tauri android build --debug`
5. **Test**: Install APK on device or emulator

## APK Output Location
After successful build, find your APK at:
```
gen/android/app/build/outputs/apk/debug/app-debug.apk
```

## Testing the App
1. Install APK on Android device
2. Grant notification permissions
3. Test FCM features:
   - Get FCM token
   - Subscribe to topics
   - Send test messages from Firebase Console
   - Receive notifications

---

**Need help?** Check the troubleshooting section or refer to the main README.md for detailed usage instructions.
