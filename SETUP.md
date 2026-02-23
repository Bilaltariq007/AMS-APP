# AMS Mobile App Setup Guide

## Backend Setup

### 1. Database Migration

Run the SQL migration files to create required tables:

```sql
-- Run these SQL files in your MySQL database:
-- protected/modules/api/migrations/create_api_tokens_table.sql
-- protected/modules/api/migrations/create_device_tokens_table.sql
```

Or run manually:

```sql
CREATE TABLE IF NOT EXISTS `api_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token` varchar(255) NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `user_id` (`user_id`),
  KEY `expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `device_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token` varchar(255) NOT NULL,
  `platform` varchar(50) NOT NULL DEFAULT 'Android',
  `status` varchar(20) NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `user_id` (`user_id`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

### 2. API Module

The API module is already created at `protected/modules/api/`. The routes are configured in `protected/config/routes.php`.

### 3. API Base URL

Update the API base URL in `mobile_app/lib/services/api_service.dart`:

```dart
static const String baseUrl = 'https://ams.dxbmarine.com';
```

## Flutter App Setup

### 1. Prerequisites

- Flutter SDK (latest stable version)
- Android Studio or VS Code with Flutter extensions
- Android SDK (API level 21 or higher)

### 2. Install Dependencies

```bash
cd mobile_app
flutter pub get
```

### 3. Firebase Setup (for Push Notifications)

1. Create a Firebase project at https://console.firebase.google.com
2. Add Android app to Firebase project
3. Download `google-services.json` and place it in `android/app/`
4. Update `android/build.gradle` to include Firebase dependencies

### 4. Build APK

```bash
flutter build apk --release
```

The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`

### 5. Install APK

Transfer the APK to Android device and install manually (enable "Install from Unknown Sources" if needed).

## Features

- ✅ One-time login with name and employee ID
- ✅ Persistent login (stays logged in until logout)
- ✅ View tickets assigned to user
- ✅ Update ticket (status, priority, area, cost, notes, assignment)
- ✅ Resolve ticket with resolution note (required, min 3 words)
- ✅ Upload attachments (images, files)
- ✅ Manage tags
- ✅ Push notifications for new ticket assignments
- ✅ Offline detection (prevents actions when offline)

## API Endpoints

- `POST /api/auth/login` - Login with name and employee_id
- `POST /api/auth/logout` - Logout
- `GET /api/auth/me` - Get current user info
- `GET /api/tickets` - Get user's assigned tickets
- `GET /api/tickets/:id` - Get ticket details
- `PUT /api/tickets/:id` - Update ticket
- `POST /api/tickets/:id/resolve` - Resolve ticket
- `POST /api/tickets/:id/attachments` - Upload attachment
- `PUT /api/tickets/:id/tags` - Update tags
- `GET /api/tickets/assignees` - Get assignee list
- `GET /api/tickets/areas` - Get areas list
- `GET /api/tickets/tags` - Get tags list
- `POST /api/notifications/register` - Register device token

## Testing

1. Login with a valid user's name and employee_id
2. View assigned tickets
3. Open a ticket and test all update features
4. Resolve a ticket (ensure tags and area are set first)
5. Upload an attachment
6. Test offline detection by turning off internet
