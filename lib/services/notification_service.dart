import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      // Check if Firebase is available with timeout
      try {
        await _firebaseMessaging.getToken().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            throw TimeoutException('Firebase token request timeout');
          },
        );
      } catch (e) {
        print('Firebase not available or timeout, skipping notification setup: $e');
        return; // Exit early if Firebase isn't configured or times out
      }
      
      // Request permission
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Initialize local notifications
        const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
        const iosSettings = DarwinInitializationSettings();
        const initSettings = InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        );

        await _localNotifications.initialize(
          initSettings,
          onDidReceiveNotificationResponse: _onNotificationTap,
        );

        // Get FCM token (don't block on this)
        _firebaseMessaging.getToken().then((token) {
          if (token != null) {
            ApiService().registerDeviceToken(token).catchError((error) {
              print('Failed to register device token: $error');
            });
          }
        }).catchError((error) {
          print('Failed to get FCM token: $error');
        });

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          ApiService().registerDeviceToken(newToken).catchError((error) {
            print('Failed to register refreshed token: $error');
          });
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          _showLocalNotification(message);
        });

        // Handle background messages (when app is in background)
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          _handleNotificationTap(message);
        });

        // Check if app was opened from notification
        _firebaseMessaging.getInitialMessage().then((initialMessage) {
          if (initialMessage != null) {
            _handleNotificationTap(initialMessage);
          }
        }).catchError((error) {
          print('Failed to get initial message: $error');
        });
      }
    } catch (e) {
      print('Notification service initialization error: $e');
      // Don't throw - allow app to continue without notifications
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'ticket_channel',
            'Ticket Notifications',
            channelDescription: 'Notifications for ticket assignments',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: message.data['ticket_id']?.toString(),
      );
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final ticketId = int.tryParse(response.payload!);
      if (ticketId != null) {
        // Navigate to ticket - this will be handled by the app
        // You can use a navigator key or callback here
      }
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final ticketId = message.data['ticket_id'];
    if (ticketId != null) {
      // Navigate to ticket - this will be handled by the app
      // You can use a navigator key or callback here
    }
  }
}
