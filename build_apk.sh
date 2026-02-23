#!/bin/bash
# Build script for Linux/Mac
# Make sure JAVA_HOME is set and Flutter is installed

echo "Building AMS Mobile APK..."
echo

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter not found. Please install Flutter and add it to PATH."
    exit 1
fi

flutter --version
echo

# Check Java
if [ -z "$JAVA_HOME" ]; then
    echo "ERROR: JAVA_HOME is not set. Please set JAVA_HOME environment variable."
    exit 1
fi
echo "JAVA_HOME: $JAVA_HOME"
echo

# Get dependencies
echo "Installing dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install dependencies."
    exit 1
fi
echo

# Build APK
echo "Building release APK..."
flutter build apk --release
if [ $? -ne 0 ]; then
    echo "ERROR: Build failed."
    exit 1
fi

echo
echo "========================================"
echo "Build completed successfully!"
echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
echo "========================================"
