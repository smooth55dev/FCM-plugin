# Android Environment Setup Script for FCM Plugin
# Run this script in PowerShell as Administrator

Write-Host "🚀 Setting up Android development environment for FCM Plugin..." -ForegroundColor Green

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script requires Administrator privileges. Please run PowerShell as Administrator." -ForegroundColor Red
    exit 1
}

# Set Android environment variables
Write-Host "📱 Setting up Android environment variables..." -ForegroundColor Yellow

$androidSdkPath = "$env:LOCALAPPDATA\Android\Sdk"
$ndkPath = "$env:LOCALAPPDATA\Android\Sdk\ndk\25.2.9519653"
$javaPath = "C:\Program Files\Eclipse Adoptium\jdk-17.0.9.9-hotspot"

# Set system environment variables
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $androidSdkPath, "Machine")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $androidSdkPath, "Machine")
[Environment]::SetEnvironmentVariable("NDK_HOME", $ndkPath, "Machine")
[Environment]::SetEnvironmentVariable("JAVA_HOME", $javaPath, "Machine")

# Update PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$newPaths = @(
    "$androidSdkPath\platform-tools",
    "$androidSdkPath\tools",
    "$androidSdkPath\tools\bin",
    $ndkPath,
    "$javaPath\bin"
)

foreach ($path in $newPaths) {
    if ($currentPath -notlike "*$path*") {
        $currentPath += ";$path"
    }
}

[Environment]::SetEnvironmentVariable("PATH", $currentPath, "Machine")

Write-Host "✅ Environment variables set successfully!" -ForegroundColor Green

# Check if Android Studio is installed
Write-Host "🔍 Checking for Android Studio..." -ForegroundColor Yellow
$androidStudioPath = "${env:ProgramFiles}\Android\Android Studio\bin\studio64.exe"
if (Test-Path $androidStudioPath) {
    Write-Host "✅ Android Studio found at: $androidStudioPath" -ForegroundColor Green
} else {
    Write-Host "❌ Android Studio not found. Please install from: https://developer.android.com/studio" -ForegroundColor Red
}

# Check if Java is installed
Write-Host "☕ Checking for Java..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1
    Write-Host "✅ Java found: $($javaVersion[0])" -ForegroundColor Green
} catch {
    Write-Host "❌ Java not found. Please install JDK 17 from: https://adoptium.net/" -ForegroundColor Red
}

# Check if Android SDK is available
Write-Host "📱 Checking for Android SDK..." -ForegroundColor Yellow
if (Test-Path $androidSdkPath) {
    Write-Host "✅ Android SDK found at: $androidSdkPath" -ForegroundColor Green
} else {
    Write-Host "❌ Android SDK not found. Please install Android Studio and SDK." -ForegroundColor Red
}

# Check if NDK is available
Write-Host "🔧 Checking for Android NDK..." -ForegroundColor Yellow
if (Test-Path $ndkPath) {
    Write-Host "✅ Android NDK found at: $ndkPath" -ForegroundColor Green
} else {
    Write-Host "❌ Android NDK not found. Please install NDK from Android Studio SDK Manager." -ForegroundColor Red
}

Write-Host "`n🎯 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Restart your terminal/PowerShell" -ForegroundColor White
Write-Host "2. Run: tauri android init" -ForegroundColor White
Write-Host "3. Run: tauri android build --debug" -ForegroundColor White
Write-Host "4. Or use: .\build-android.bat debug" -ForegroundColor White

Write-Host "`n📚 For detailed instructions, see: ANDROID_SETUP_GUIDE.md" -ForegroundColor Cyan

Write-Host "`n🚀 Setup complete! Restart your terminal and try building the Android app." -ForegroundColor Green
