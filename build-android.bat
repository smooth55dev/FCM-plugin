@echo off
REM FCM Plugin Android Build Script for Windows
REM This script builds the FCM plugin for Android

setlocal enabledelayedexpansion

echo 🚀 Building FCM Plugin for Android...

REM Function to print colored output (simplified for Windows)
:print_status
echo [INFO] %~1
goto :eof

:print_success
echo [SUCCESS] %~1
goto :eof

:print_warning
echo [WARNING] %~1
goto :eof

:print_error
echo [ERROR] %~1
goto :eof

REM Check if required tools are installed
:check_requirements
call :print_status "Checking requirements..."

where npm >nul 2>nul
if %errorlevel% neq 0 (
    call :print_error "npm is not installed. Please install Node.js and npm."
    exit /b 1
)

where tauri >nul 2>nul
if %errorlevel% neq 0 (
    call :print_error "Tauri CLI is not installed. Please install it with: npm install -g @tauri-apps/cli"
    exit /b 1
)

where adb >nul 2>nul
if %errorlevel% neq 0 (
    call :print_warning "adb is not found. Make sure Android SDK is installed and added to PATH."
)

call :print_success "Requirements check completed"
goto :eof

REM Install dependencies
:install_dependencies
call :print_status "Installing dependencies..."

if exist "package.json" (
    npm install
    call :print_success "Dependencies installed"
) else (
    call :print_warning "No package.json found, skipping npm install"
)
goto :eof

REM Check Firebase configuration
:check_firebase_config
call :print_status "Checking Firebase configuration..."

if not exist "android\app\google-services.json" (
    call :print_error "google-services.json not found in android\app\"
    call :print_error "Please download it from Firebase Console and place it in android\app\"
    exit /b 1
)

call :print_success "Firebase configuration found"
goto :eof

REM Build the project
:build_project
set build_type=%1
if "%build_type%"=="" set build_type=debug

call :print_status "Building project (%build_type%)..."

if "%build_type%"=="debug" (
    tauri android build --debug
) else if "%build_type%"=="release" (
    tauri android build --apk
) else if "%build_type%"=="dev" (
    tauri android dev
) else (
    call :print_error "Invalid build type: %build_type%"
    call :print_error "Valid options: debug, release, dev"
    exit /b 1
)

call :print_success "Build completed"
goto :eof

REM Install APK on device
:install_apk
where adb >nul 2>nul
if %errorlevel% equ 0 (
    call :print_status "Installing APK on connected device..."
    
    REM Find the latest APK (simplified for Windows)
    for /f "delims=" %%i in ('dir /b /s *.apk 2^>nul ^| sort /r') do (
        set APK_PATH=%%i
        goto :found_apk
    )
    
    :found_apk
    if defined APK_PATH (
        adb install -r "%APK_PATH%"
        call :print_success "APK installed successfully"
    ) else (
        call :print_warning "No APK found to install"
    )
) else (
    call :print_warning "adb not found, skipping APK installation"
)
goto :eof

REM Show build information
:show_build_info
call :print_status "Build Information:"
echo   - Project: FCM Plugin Example
echo   - Platform: Android
echo   - Package: com.smooth55dev.fcm
echo   - Min SDK: 24
echo   - Target SDK: 34
echo.
goto :eof

REM Show help
:show_help
echo FCM Plugin Android Build Script
echo.
echo Usage: %0 [BUILD_TYPE] [INSTALL]
echo.
echo BUILD_TYPE options:
echo   debug     Build debug APK (default)
echo   release   Build release APK
echo   dev       Start development server
echo.
echo INSTALL options:
echo   install   Install APK on connected device after build
echo.
echo Examples:
echo   %0                    # Build debug APK
echo   %0 release            # Build release APK
echo   %0 debug install      # Build debug APK and install
echo   %0 dev                # Start development server
echo.
goto :eof

REM Main function
:main
set build_type=%1
set install=%2
if "%build_type%"=="" set build_type=debug

call :show_build_info
call :check_requirements
call :install_dependencies
call :check_firebase_config

if "%build_type%"=="dev" (
    call :print_status "Starting development server..."
    call :build_project "dev"
) else (
    call :build_project "%build_type%"
    
    if "%install%"=="true" (
        call :install_apk
    ) else if "%install%"=="install" (
        call :install_apk
    )
)

call :print_success "Build process completed!"

if not "%build_type%"=="dev" (
    call :print_status "APK location:"
    dir /b /s *.apk 2>nul
)
goto :eof

REM Parse command line arguments
if "%1"=="help" goto :show_help
if "%1"=="-h" goto :show_help
if "%1"=="--help" goto :show_help

call :main %*
