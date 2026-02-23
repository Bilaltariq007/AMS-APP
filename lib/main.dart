import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/ticket_list_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages here
  print('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up background message handler (with error handling)
  try {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    print('Firebase background handler setup error: $e');
  }
  
  // Initialize notifications (completely non-blocking - don't wait for it)
  Future.microtask(() {
    NotificationService().initialize().catchError((error) {
      print('Notification initialization error: $error');
      // Continue even if notifications fail
    });
  });
  
  // Run app immediately - don't wait for anything
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AMS Mobile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Error boundary - show error if something goes wrong
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
          child: child ?? const Scaffold(
            body: Center(
              child: Text('Loading...'),
            ),
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final loggedIn = await AuthService().isLoggedIn().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          print('Auth check timeout');
          return false;
        },
      );
      if (mounted) {
        setState(() {
          _isLoggedIn = loggedIn;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Auth check error: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isLoggedIn) {
      return const TicketListScreen();
    }

    return const LoginScreen();
  }
}
