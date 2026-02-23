import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<bool> login(String name, String employeeId) async {
    try {
      final response = await ApiService().login(name, employeeId);
      
      print('AuthService - Response received: $response');
      print('AuthService - Success: ${response['success']}');
      print('AuthService - Data: ${response['data']}');
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final prefs = await SharedPreferences.getInstance();
        
        // Store token
        final tokenValue = data['token']?.toString() ?? '';
        if (tokenValue.isNotEmpty) {
          await prefs.setString(_tokenKey, tokenValue);
          print('AuthService - Token stored: ${tokenValue.substring(0, 20)}...');
        } else {
          print('AuthService - ERROR: Token is empty!');
        }
        
        // Store user data - handle user_id as string or int
        final userId = data['user_id'];
        if (userId is int) {
          await prefs.setInt('user_id', userId);
        } else if (userId is String) {
          await prefs.setInt('user_id', int.tryParse(userId) ?? 0);
        }
        
        await prefs.setString('user_name', data['name'] ?? '');
        await prefs.setString('user_emp_id', data['emp_id']?.toString() ?? '');
        await prefs.setString('user_email', data['email'] ?? '');
        if (data['designation'] != null) {
        await prefs.setString('user_designation', data['designation']);
      }
      
      print('AuthService - Login successful, token stored');
      
      // Register device token for notifications after successful login
      _registerDeviceTokenAfterLogin();
      
      return true;
      } else {
        print('AuthService - Login failed: success=${response['success']}, data=${response['data']}');
        return false;
      }
    } catch (e, stackTrace) {
      print('AuthService - Login exception: $e');
      print('AuthService - Stack trace: $stackTrace');
      rethrow; // Re-throw so the UI can show the error
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('AuthService - getToken() called, token: ${token != null ? "${token.substring(0, 20)}..." : "NULL"}');
    return token;
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      // Parse user data (simplified - in production use proper JSON parsing)
      try {
        // This is a simplified version - you might want to store as JSON string
        final prefs = await SharedPreferences.getInstance();
        return User(
          userId: prefs.getInt('user_id') ?? 0,
          name: prefs.getString('user_name') ?? '',
          empId: prefs.getString('user_emp_id') ?? '',
          email: prefs.getString('user_email') ?? '',
          designation: prefs.getString('user_designation'),
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> logout() async {
    try {
      // Call logout API
      await ApiService().logout();
    } catch (e) {
      // Continue with local logout even if API call fails
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_emp_id');
    await prefs.remove('user_email');
    await prefs.remove('user_designation');
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userData['user_id']);
    await prefs.setString('user_name', userData['name']);
    await prefs.setString('user_emp_id', userData['emp_id']);
    await prefs.setString('user_email', userData['email']);
    if (userData['designation'] != null) {
      await prefs.setString('user_designation', userData['designation']);
    }
  }

  void _registerDeviceTokenAfterLogin() {
    // Register device token asynchronously after login
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          print('AuthService - Registering device token after login: ${token.substring(0, 20)}...');
          await ApiService().registerDeviceToken(token);
          print('AuthService - Device token registered successfully');
        }
      } catch (e) {
        print('AuthService - Failed to register device token after login: $e');
      }
    });
  }
}
