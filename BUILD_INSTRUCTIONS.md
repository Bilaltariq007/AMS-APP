# Build Instructions for AMS Mobile APK

## Prerequisites

1. **Flutter SDK** - Install from https://flutter.dev/docs/get-started/install
2. **Java JDK** - Install JDK 8 or higher and set JAVA_HOME environment variable
3. **Android Studio** (optional but recommended) - For Android SDK setup

## Quick Build (Windows)

1. Open Command Prompt in the `mobile_app` directory
2. Make sure JAVA_HOME is set: `echo %JAVA_HOME%`
3. Run: `build_apk.bat`

## Quick Build (Linux/Mac)

1. Open terminal in the `mobile_app` directory
2. Make sure JAVA_HOME is set: `echo $JAVA_HOME`
3. Make script executable: `chmod +x build_apk.sh`
4. Run: `./build_apk.sh`

## Manual Build Steps

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Build APK:**
   ```bash
   flutter build apk --release
   ```

3. **Find APK:**
   The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## Troubleshooting

### Flutter not found
- Add Flutter to your PATH
- Restart terminal/command prompt

### JAVA_HOME not set
- Windows: Set in System Environment Variables
- Linux/Mac: Add to ~/.bashrc or ~/.zshrc:
  ```bash
  export JAVA_HOME=/path/to/java
  export PATH=$PATH:$JAVA_HOME/bin
  ```

### Android SDK issues
- Install Android Studio
- Run `flutter doctor` to check setup
- Accept Android licenses: `flutter doctor --android-licenses`

### Build errors
- Run `flutter clean`
- Run `flutter pub get` again
- Check `flutter doctor` for issues

## Current Status

✅ Database migrations completed
✅ API module created and configured
✅ Flutter app code complete
✅ Dependencies installed
⏳ APK build requires Java/JDK and Android SDK

The APK can be built on any machine with Flutter and Java installed.
