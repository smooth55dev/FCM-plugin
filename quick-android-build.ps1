# Quick Android Build Script for FCM Plugin
Write-Host "🚀 FCM Plugin Android Build Script" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Check if Android Studio is installed
Write-Host "`n📱 Checking for Android Studio..." -ForegroundColor Yellow
$androidSdkPath = "$env:LOCALAPPDATA\Android\Sdk"

if (Test-Path $androidSdkPath) {
    Write-Host "✅ Found Android SDK at: $androidSdkPath" -ForegroundColor Green
} else {
    Write-Host "❌ Android Studio/SDK not found!" -ForegroundColor Red
    Write-Host "Please install Android Studio from: https://developer.android.com/studio" -ForegroundColor Yellow
    exit 1
}

# Set environment variables
Write-Host "`n🔧 Setting up environment variables..." -ForegroundColor Yellow
$env:ANDROID_HOME = $androidSdkPath
$env:ANDROID_SDK_ROOT = $androidSdkPath

# Try to find NDK
$ndkPath = "$androidSdkPath\ndk\25.2.9519653"
if (Test-Path $ndkPath) {
    $env:NDK_HOME = $ndkPath
    Write-Host "✅ Found NDK at: $ndkPath" -ForegroundColor Green
} else {
    Write-Host "⚠️ NDK not found. Please install NDK from Android Studio SDK Manager" -ForegroundColor Yellow
}

# Add to PATH
$env:PATH += ";$androidSdkPath\platform-tools"
$env:PATH += ";$androidSdkPath\tools"
$env:PATH += ";$androidSdkPath\tools\bin"
if (Test-Path $ndkPath) {
    $env:PATH += ";$ndkPath"
}

Write-Host "`n🔨 Attempting to build Android app..." -ForegroundColor Yellow

# Try to initialize Android project
Write-Host "Initializing Android project..." -ForegroundColor Cyan
tauri android init

# Try to build
Write-Host "`nBuilding debug APK..." -ForegroundColor Cyan
tauri android build --debug

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n🎉 Build successful! APK location: gen/android/app/build/outputs/apk/debug/app-debug.apk" -ForegroundColor Green
} else {
    Write-Host "`n❌ Build failed. Please install Android Studio with NDK and try again." -ForegroundColor Red
}
