import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  /// Register a new user
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'firstName': firstName,
              'lastName': lastName,
              'email': email,
              'phone': phone,
              'password': password,
              'passwordConfirm': passwordConfirm,
            }),
          )
          .timeout(timeout);

      logger.i('Register response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      logger.e('Register error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Verify OTP
  Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'otp': otp,
            }),
          )
          .timeout(timeout);

      logger.i('Verify OTP response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      logger.e('Verify OTP error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(timeout);

      logger.i('Login response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      logger.e('Login error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Login with Google token
  Future<Map<String, dynamic>> loginWithGoogle({
    required String token,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/google'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': token}),
          )
          .timeout(timeout);

      logger.i('Google login response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      logger.e('Google login error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
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

  /// Logout
  Future<Map<String, dynamic>> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(timeout);

      logger.i('Logout response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      logger.e('Logout error: $e');
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
          'message': data['message'] ?? 'An error occurred',
          'error': data['error'],
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
}
