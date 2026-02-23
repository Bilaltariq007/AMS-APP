@echo off
REM Build script for Windows
REM Make sure JAVA_HOME is set and Flutter is installed

echo Building AMS Mobile APK...
echo.

REM Check Flutter
flutter --version
if errorlevel 1 (
    echo ERROR: Flutter not found. Please install Flutter and add it to PATH.
    pause
    exit /b 1
)

REM Check Java
if "%JAVA_HOME%"=="" (
    echo ERROR: JAVA_HOME is not set. Please set JAVA_HOME environment variable.
    pause
    exit /b 1
)
echo JAVA_HOME: %JAVA_HOME%
echo.

REM Get dependencies
echo Installing dependencies...
flutter pub get
if errorlevel 1 (
    echo ERROR: Failed to install dependencies.
    pause
    exit /b 1
)
echo.

REM Build APK
echo Building release APK...
flutter build apk --release
if errorlevel 1 (
    echo ERROR: Build failed.
    pause
    exit /b 1
)

echo.
echo ========================================
echo Build completed successfully!
echo APK location: build\app\outputs\flutter-apk\app-release.apk
echo ========================================
pause
