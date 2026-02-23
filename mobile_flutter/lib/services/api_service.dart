import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import '../utils/app_config.dart';

class ApiService {
  late final String baseUrl;
  late final Duration timeout;
  final logger = Logger();

  ApiService() {
    // Use AppConfig for consistent configuration management
    baseUrl = AppConfig.instance.apiBaseUrl;
    timeout = AppConfig.instance.apiTimeout;
  }

  /// Login with Google token
  Future<Map<String, dynamic>> loginWithGoogle({
    required String idToken,
  }) async {
    try {
      print('DEBUG API: Sending Google login request');
      print('DEBUG API: Token length: ${idToken.length}');
      print('DEBUG API: Backend URL: $baseUrl/auth/google');
      
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/google'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id_token': idToken}),
          )
          .timeout(timeout);

      print('DEBUG API: Google login response: ${response.statusCode}');
      logger.i('Google login response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('DEBUG API: Google login error: $e');
      logger.e('Google login error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(timeout);

      logger.i('Get user response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      logger.e('Get user error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Handle API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          ...data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['detail'] ?? 'An error occurred',
          'error': data['error'] ?? data['detail'],
        };
      }
    } catch (e) {
      logger.e('Response parsing error: $e');
      return {
        'success': false,
        'message': 'Failed to parse response',
        'error': e.toString(),
      };
    }
  }

  /// Sign in or register with email only
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    String? name,
    String? googleId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/email'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              if (name != null) 'name': name,
              if (googleId != null) 'google_id': googleId,
            }),
          )
          .timeout(timeout);

      logger.i('Email sign-in response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      logger.e('Email sign-in error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Send phone OTP
  Future<Map<String, dynamic>> sendPhoneOTP({
    required String phoneNumber,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/phone/send-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'phone_number': phoneNumber,
            }),
          )
          .timeout(timeout);

      logger.i('Send phone OTP response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      logger.e('Send phone OTP error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Verify phone OTP
  Future<Map<String, dynamic>> verifyPhoneOTP({
    required String phoneNumber,
    required String otp,
    String? name,
    String? googleId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/phone/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'phone_number': phoneNumber,
              'otp': otp,
              if (name != null) 'name': name,
              if (googleId != null) 'google_id': googleId,  // Pass google_id if available
            }),
          )
          .timeout(timeout);

      logger.i('Verify phone OTP response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      logger.e('Verify phone OTP error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Send email OTP
  Future<Map<String, dynamic>> sendEmailOTP({
    required String email,
    String? name,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/email/send-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              if (name != null) 'name': name,
            }),
          )
          .timeout(timeout);

      logger.i('Send email OTP response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      logger.e('Send email OTP error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Verify email OTP
  Future<Map<String, dynamic>> verifyEmailOTP({
    required String email,
    required String otp,
    String? name,
    String? googleId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/email/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'otp': otp,
              if (name != null) 'name': name,
              if (googleId != null) 'google_id': googleId,
            }),
          )
          .timeout(timeout);

      logger.i('Verify email OTP response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      logger.e('Verify email OTP error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Health check
  Future<bool> healthCheck() async {
    try {
      final response = await http
          .get(
            Uri.parse('${baseUrl.replaceAll('/api', '')}/health'),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      logger.e('Health check error: $e');
      return false;
    }
  }

  /// Register a new user with email and password
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    String? googleId,
  }) async {
    try {
      print('DEBUG API: Sending registration request');
      print('DEBUG API: Email: $email');
      print('DEBUG API: Backend URL: $baseUrl/auth/register');
      
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              if (googleId != null) 'google_id': googleId,
            }),
          )
          .timeout(timeout);

      print('DEBUG API: Registration response: ${response.statusCode}');
      logger.i('Registration response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('DEBUG API: Registration error: $e');
      logger.e('Registration error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Upload face image for recognition
  Future<Map<String, dynamic>> uploadFaceImage({
    required String imagePath,
    required String token,
    String faceType = "straight",
  }) async {
    try {
      final file = await _getFileFromPath(imagePath);
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/upload-face').replace(
          queryParameters: {'face_type': faceType},
        ),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imagePath,
          filename: 'face_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      logger.i('Face upload response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      logger.e('Face upload error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Helper to get file from path
  Future<dynamic> _getFileFromPath(String path) async {
    // This is a placeholder - in real implementation, 
    // we'd use File class properly
    return null;
  }
}
