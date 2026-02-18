import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure configuration storage for sensitive application data
class SecureConfig {
  static const String _apiBaseUrlKey = 'api_base_url';
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _faceDataKey = 'face_data';
  static const String _voiceDataKey = 'voice_data';

  static const _secureStorage = FlutterSecureStorage();

  /// Save API base URL
  static Future<void> saveApiBaseUrl(String url) async {
    await _secureStorage.write(key: _apiBaseUrlKey, value: url);
  }

  /// Get API base URL
  static Future<String?> getApiBaseUrl() async {
    return await _secureStorage.read(key: _apiBaseUrlKey);
  }

  /// Save authentication token
  static Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: _authTokenKey, value: token);
  }

  /// Get authentication token
  static Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _authTokenKey);
  }

  /// Save refresh token
  static Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// Save user ID
  static Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  /// Get user ID
  static Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  /// Save user email
  static Future<void> saveUserEmail(String email) async {
    await _secureStorage.write(key: _userEmailKey, value: email);
  }

  /// Get user email
  static Future<String?> getUserEmail() async {
    return await _secureStorage.read(key: _userEmailKey);
  }

  /// Save face biometric reference (encrypted)
  /// Only store reference ID, not actual biometric data
  static Future<void> saveFaceReference(String faceRefId) async {
    await _secureStorage.write(key: _faceDataKey, value: faceRefId);
  }

  /// Get face biometric reference
  static Future<String?> getFaceReference() async {
    return await _secureStorage.read(key: _faceDataKey);
  }

  /// Save voice biometric reference (encrypted)
  /// Only store reference ID, not actual biometric data
  static Future<void> saveVoiceReference(String voiceRefId) async {
    await _secureStorage.write(key: _voiceDataKey, value: voiceRefId);
  }

  /// Get voice biometric reference
  static Future<String?> getVoiceReference() async {
    return await _secureStorage.read(key: _voiceDataKey);
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all sensitive data
  static Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }

  /// Clear specific keys
  static Future<void> clearKeys(List<String> keys) async {
    for (final key in keys) {
      await _secureStorage.delete(key: key);
    }
  }

  /// Verify data integrity (check if all expected keys exist)
  static Future<Map<String, bool>> verifyIntegrity() async {
    return {
      'token': (await getAuthToken()) != null,
      'userId': (await getUserId()) != null,
      'email': (await getUserEmail()) != null,
    };
  }
}
