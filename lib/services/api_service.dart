import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';
import '../models/user.dart';
import 'auth_service.dart';

class ApiService {
  // Update this with your actual API base URL
  static const String baseUrl = 'https://ams.dxbmarine.com';
  
  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    List<http.MultipartFile>? files,
  }) async {
    try {
      final token = await AuthService().getToken();
      print('API Request - Endpoint: $endpoint');
      print('API Request - Token: ${token != null ? "${token.substring(0, 20)}..." : "NULL"}');
      final url = Uri.parse('$baseUrl/$endpoint');
      
      http.StreamedResponse streamedResponse;
      
      if (files != null) {
        // Multipart request for file uploads
        final multipartRequest = http.MultipartRequest(method, url);
        if (token != null) {
          multipartRequest.headers['Authorization'] = 'Bearer $token';
        }
        
        if (body != null) {
          body.forEach((key, value) {
            if (value != null) {
              multipartRequest.fields[key] = value.toString();
            }
          });
        }
        
        multipartRequest.files.addAll(files);
        streamedResponse = await multipartRequest.send();
      } else {
        // Regular request - add token to URL as query param if needed (fallback for servers that don't read headers)
        Uri requestUrl = url;
        if (token != null && token.isNotEmpty) {
          final queryParams = Map<String, String>.from(url.queryParameters);
          queryParams['token'] = token;
          requestUrl = url.replace(queryParameters: queryParams);
        }
        
        final request = http.Request(method, requestUrl);
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        
        // For PUT requests, send as form data, otherwise JSON
        if (method == 'PUT' && body != null) {
          request.headers['Content-Type'] = 'application/x-www-form-urlencoded';
          request.body = body.entries
              .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
              .join('&');
        } else {
          request.headers['Content-Type'] = 'application/json';
          if (body != null) {
            request.body = jsonEncode(body);
          }
        }
        streamedResponse = await request.send();
      }
      
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {'success': true, 'data': null};
        }
        try {
          return jsonDecode(response.body);
        } catch (e) {
          throw Exception('Invalid JSON response: ${response.body}');
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['message'] ?? 'Request failed with status ${response.statusCode}');
        } catch (e) {
          throw Exception('Request failed with status ${response.statusCode}: ${response.body}');
        }
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login(String name, String employeeId) async {
    // Login endpoint - try form data first, then JSON as fallback
    final url = Uri.parse('$baseUrl/api/auth/login');
    
    try {
      // First try: Form data
      final formRequest = http.Request('POST', url);
      formRequest.headers['Content-Type'] = 'application/x-www-form-urlencoded';
      formRequest.body = 'name=${Uri.encodeComponent(name)}&employee_id=${Uri.encodeComponent(employeeId)}';
      
      print('Login request - URL: $url');
      print('Login request - Name: $name, Employee ID: $employeeId');
      print('Login request - Body: ${formRequest.body}');
      
      final streamedResponse = await formRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Login response - Status: ${response.statusCode}');
      print('Login response - Body: ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {'success': true, 'data': null};
        }
        try {
          final result = jsonDecode(response.body);
          return result;
        } catch (e) {
          throw Exception('Invalid JSON response: ${response.body}');
        }
      } else {
        // If form data fails, try JSON
        try {
          final jsonRequest = http.Request('POST', url);
          jsonRequest.headers['Content-Type'] = 'application/json';
          jsonRequest.body = jsonEncode({
            'name': name,
            'employee_id': employeeId,
          });
          
          print('Trying JSON format...');
          final jsonStreamedResponse = await jsonRequest.send();
          final jsonResponse = await http.Response.fromStream(jsonStreamedResponse);
          
          print('JSON response - Status: ${jsonResponse.statusCode}');
          print('JSON response - Body: ${jsonResponse.body}');
          
          if (jsonResponse.statusCode >= 200 && jsonResponse.statusCode < 300) {
            return jsonDecode(jsonResponse.body);
          } else {
            final error = jsonDecode(jsonResponse.body);
            throw Exception(error['message'] ?? 'Request failed with status ${jsonResponse.statusCode}');
          }
        } catch (e) {
          // If both fail, return the original error
          try {
            final error = jsonDecode(response.body);
            throw Exception(error['message'] ?? 'Request failed with status ${response.statusCode}');
          } catch (e2) {
            throw Exception('Request failed with status ${response.statusCode}: ${response.body}');
          }
        }
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> logout() async {
    return await _request('POST', 'api/auth/logout');
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    return await _request('GET', 'api/auth/me');
  }

  // Ticket endpoints
  Future<List<Ticket>> getTickets() async {
    final response = await _request('GET', 'api/tickets');
    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> ticketsJson = response['data'];
      return ticketsJson.map((json) => Ticket.fromJson(json)).toList();
    }
    return [];
  }

  Future<Ticket> getTicket(int id) async {
    final response = await _request('GET', 'api/tickets/$id');
    if (response['success'] == true && response['data'] != null) {
      return Ticket.fromJson(response['data']);
    }
    throw Exception('Failed to load ticket');
  }

  Future<Ticket> updateTicket(int id, Map<String, dynamic> updates) async {
    final response = await _request('PUT', 'api/tickets/$id', body: updates);
    if (response['success'] == true && response['data'] != null) {
      return Ticket.fromJson(response['data']);
    }
    throw Exception(response['message'] ?? 'Failed to update ticket');
  }

  Future<Ticket> resolveTicket(int id, String resolutionNote) async {
    // Resolve endpoint requires form data, not JSON
    try {
      final token = await AuthService().getToken();
      final url = Uri.parse('$baseUrl/api/tickets/$id/resolve');
      
      // Add token to query parameter
      final requestUrl = url.replace(queryParameters: {
        ...url.queryParameters,
        if (token != null && token.isNotEmpty) 'token': token,
      });
      
      final request = http.Request('POST', requestUrl);
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Content-Type'] = 'application/x-www-form-urlencoded';
      request.body = 'resolution_note=${Uri.encodeComponent(resolutionNote)}';
      
      print('Resolve ticket - URL: $requestUrl');
      print('Resolve ticket - Body: ${request.body}');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Resolve ticket response - Status: ${response.statusCode}');
      print('Resolve ticket response - Body: ${response.body}');
      
      // Check if response is HTML (error page)
      if (response.body.trim().startsWith('<!DOCTYPE') || response.body.trim().startsWith('<html')) {
        throw Exception('Server error: Please ensure the ticket has tags and area assigned before resolving.');
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final result = jsonDecode(response.body);
          if (result['success'] == true && result['data'] != null) {
            return Ticket.fromJson(result['data']);
          }
          // Check for validation errors
          if (result['errors'] != null) {
            final errors = result['errors'] as Map<String, dynamic>;
            final errorMessages = errors.values.map((e) => e.toString()).join(', ');
            throw Exception(errorMessages.isNotEmpty ? errorMessages : result['message'] ?? 'Failed to resolve ticket');
          }
          throw Exception(result['message'] ?? 'Failed to resolve ticket');
        } catch (e) {
          if (e is FormatException) {
            throw Exception('Server returned invalid response. Please check that the ticket has tags and area assigned.');
          }
          rethrow;
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          if (error['errors'] != null) {
            final errors = error['errors'] as Map<String, dynamic>;
            final errorMessages = errors.values.map((e) => e.toString()).join(', ');
            throw Exception(errorMessages.isNotEmpty ? errorMessages : error['message'] ?? 'Request failed');
          }
          throw Exception(error['message'] ?? 'Request failed with status ${response.statusCode}');
        } catch (e) {
          if (e is FormatException) {
            throw Exception('Server error (${response.statusCode}). Please ensure the ticket has tags and area assigned.');
          }
          rethrow;
        }
      }
    } catch (e) {
      print('Resolve ticket error: $e');
      rethrow;
    }
  }

  Future<Ticket> uploadAttachment(int ticketId, File file) async {
    final fileStream = http.ByteStream(file.openRead());
    final fileLength = await file.length();
    final multipartFile = http.MultipartFile(
      'attachment',
      fileStream,
      fileLength,
      filename: file.path.split('/').last,
    );

    final response = await _request(
      'POST',
      'api/tickets/$ticketId/attachments',
      files: [multipartFile],
    );
    
    if (response['success'] == true && response['data'] != null) {
      return Ticket.fromJson(response['data']);
    }
    throw Exception(response['message'] ?? 'Failed to upload attachment');
  }

  Future<Ticket> updateTags(int ticketId, List<int> tagIds) async {
    final response = await _request('PUT', 'api/tickets/$ticketId/tags', body: {
      'tag_ids': tagIds,
    });
    if (response['success'] == true && response['data'] != null) {
      return Ticket.fromJson(response['data']);
    }
    throw Exception(response['message'] ?? 'Failed to update tags');
  }

  Future<List<User>> getAssignees() async {
    final response = await _request('GET', 'api/tickets/assignees');
    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> usersJson = response['data'];
      return usersJson.map((json) => User.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<Area>> getAreas() async {
    final response = await _request('GET', 'api/tickets/areas');
    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> areasJson = response['data'];
      return areasJson.map((json) => Area.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<Tag>> getTags() async {
    final response = await _request('GET', 'api/tickets/tags');
    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> tagsJson = response['data'];
      return tagsJson.map((json) => Tag.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> registerDeviceToken(String deviceToken) async {
    // Register endpoint requires form data, not JSON
    try {
      final token = await AuthService().getToken();
      if (token == null || token.isEmpty) {
        print('Cannot register device token: user not logged in');
        return;
      }
      
      final url = Uri.parse('$baseUrl/api/notifications/register');
      
      // Add token to query parameter
      final requestUrl = url.replace(queryParameters: {
        ...url.queryParameters,
        'token': token,
      });
      
      final request = http.Request('POST', requestUrl);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'application/x-www-form-urlencoded';
      request.body = 'device_token=${Uri.encodeComponent(deviceToken)}&platform=Android';
      
      print('Register device token - URL: $requestUrl');
      print('Register device token - Body: ${request.body}');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Register device token response - Status: ${response.statusCode}');
      print('Register device token response - Body: ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Device token registered successfully');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to register device token');
      }
    } catch (e) {
      print('Register device token error: $e');
      rethrow;
    }
  }
}
