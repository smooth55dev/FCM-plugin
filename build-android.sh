#!/bin/bash

# FCM Plugin Android Build Script
# This script builds the FCM plugin for Android

set -e  # Exit on any error

echo "🚀 Building FCM Plugin for Android..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_requirements() {
    print_status "Checking requirements..."
    
    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed. Please install Node.js and npm."
        exit 1
    fi
    
    if ! command -v tauri &> /dev/null; then
        print_error "Tauri CLI is not installed. Please install it with: npm install -g @tauri-apps/cli"
        exit 1
    fi
    
    if ! command -v adb &> /dev/null; then
        print_warning "adb is not found. Make sure Android SDK is installed and added to PATH."
    fi
    
    print_success "Requirements check completed"
}

# Install dependencies
install_dependencies() {
    print_status "Installing dependencies..."
    
    if [ -f "package.json" ]; then
        npm install
        print_success "Dependencies installed"
    else
        print_warning "No package.json found, skipping npm install"
    fi
}

# Check Firebase configuration
check_firebase_config() {
    print_status "Checking Firebase configuration..."
    
    if [ ! -f "android/app/google-services.json" ]; then
        print_error "google-services.json not found in android/app/"
        print_error "Please download it from Firebase Console and place it in android/app/"
        exit 1
    fi
    
    print_success "Firebase configuration found"
}

# Build the project
build_project() {
    local build_type=${1:-debug}
    
    print_status "Building project (${build_type})..."
    
    case $build_type in
        "debug")
            tauri android build --debug
            ;;
        "release")
            tauri android build --apk
            ;;
        "dev")
            tauri android dev
            ;;
        *)
            print_error "Invalid build type: $build_type"
            print_error "Valid options: debug, release, dev"
            exit 1
            ;;
    esac
    
    print_success "Build completed"
}

# Install APK on device
install_apk() {
    if command -v adb &> /dev/null; then
        print_status "Installing APK on connected device..."
        
        # Find the latest APK
        APK_PATH=$(find . -name "*.apk" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2-)
        
        if [ -n "$APK_PATH" ]; then
            adb install -r "$APK_PATH"
            print_success "APK installed successfully"
        else
            print_warning "No APK found to install"
        fi
    else
        print_warning "adb not found, skipping APK installation"
    fi
}

# Show build information
show_build_info() {
    print_status "Build Information:"
    echo "  - Project: FCM Plugin Example"
    echo "  - Platform: Android"
    echo "  - Package: com.smooth55dev.fcm"
    echo "  - Min SDK: 24"
    echo "  - Target SDK: 34"
    echo ""
}

# Main function
main() {
    local build_type=${1:-debug}
    local install=${2:-false}
    
    show_build_info
    
    check_requirements
    install_dependencies
    check_firebase_config
    
    if [ "$build_type" = "dev" ]; then
        print_status "Starting development server..."
        build_project "dev"
    else
        build_project "$build_type"
        
        if [ "$install" = "true" ] || [ "$install" = "install" ]; then
            install_apk
        fi
    fi
    
    print_success "Build process completed!"
    
    if [ "$build_type" != "dev" ]; then
        print_status "APK location:"
        find . -name "*.apk" -type f | head -5
    fi
}

# Help function
show_help() {
    echo "FCM Plugin Android Build Script"
    echo ""
    echo "Usage: $0 [BUILD_TYPE] [INSTALL]"
    echo ""
    echo "BUILD_TYPE options:"
    echo "  debug     Build debug APK (default)"
    echo "  release   Build release APK"
    echo "  dev       Start development server"
    echo ""
    echo "INSTALL options:"
    echo "  install   Install APK on connected device after build"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build debug APK"
    echo "  $0 release            # Build release APK"
    echo "  $0 debug install      # Build debug APK and install"
    echo "  $0 dev                # Start development server"
    echo ""
}

# Parse command line arguments
case "${1:-}" in
    "help"|"-h"|"--help")
        show_help
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
