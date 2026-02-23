# AMS Mobile App

Android mobile app for Asset Management System.

## Setup

1. Install Flutter SDK
2. Run `flutter pub get`
3. Configure API base URL in `lib/services/api_service.dart`
4. Build APK: `flutter build apk`

## Features

- One-time login with name and employee ID
- View tickets assigned to user
- Update tickets (status, priority, area, cost, notes, assignment)
- Resolve tickets with resolution note
- Upload attachments
- Manage tags
- Push notifications for new assignments
- Offline detection
