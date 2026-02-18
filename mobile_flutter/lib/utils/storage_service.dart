import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  static const _secureStorage = FlutterSecureStorage();

  /// Save JWT token securely
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Get JWT token
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear token (logout)
  static Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  /// Save user data
  static Future<void> saveUserData(String userData) async {
    await _secureStorage.write(key: _userKey, value: userData);
  }

  /// Get user data
  static Future<String?> getUserData() async {
    return await _secureStorage.read(key: _userKey);
  }

  /// Clear all data
  static Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
