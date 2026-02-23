import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'secure_config.dart';

/// Environment-based API configuration for the Flutter app
class AppConfig {
  static final AppConfig _instance = AppConfig._internal();

  late String _apiBaseUrl;
  late String _environment;
  late bool _debugMode;
  late Map<String, String> _allEnvVars;

  AppConfig._internal();

  static AppConfig get instance => _instance;

  /// Initialize configuration from .env file
  static Future<void> initialize() async {
    try {
      await dotenv.load();
      _instance._loadFromEnv();
    } catch (e) {
      print('Error loading environment variables: $e');
      // Fallback to defaults
      _instance._loadDefaults();
    }
  }

  void _loadFromEnv() {
    _allEnvVars = dotenv.env;

    _apiBaseUrl = dotenv.env['API_BASE_URL'] ?? _getDefaultApiUrl();
    _environment = dotenv.env['FLUTTER_ENV'] ?? 'development';
    _debugMode = (dotenv.env['DEBUG'] ?? 'true').toLowerCase() == 'true';
  }

  void _loadDefaults() {
    _allEnvVars = {};
    _apiBaseUrl = _getDefaultApiUrl();
    _environment = 'development';
    _debugMode = true;
  }

  String _getDefaultApiUrl() {
    // ADB port forwarding: localhost:5000 on phone tunnels to computer's port 5000
    // Backend listens on 0.0.0.0:5000 so localhost:5000 will work via tunnel
    return 'http://localhost:5000/api';
  }

  // Getters
  String get apiBaseUrl => _apiBaseUrl;
  String get environment => _environment;
  bool get debugMode => _debugMode;
  bool get isProduction => _environment == 'production';
  bool get isDevelopment => _environment == 'development';
  bool get isStaging => _environment == 'staging';

  // Feature flags
  bool get enableGoogleSignIn =>
      (dotenv.env['ENABLE_GOOGLE_SIGNIN'] ?? 'false').toLowerCase() == 'true';

  bool get enableFaceRecognition =>
      (dotenv.env['ENABLE_FACE_RECOGNITION'] ?? 'true').toLowerCase() == 'true';

  bool get enableVoiceRecognition =>
      (dotenv.env['ENABLE_VOICE_RECOGNITION'] ?? 'true').toLowerCase() ==
      'true';

  // API configuration
  String get apiUrl => apiBaseUrl;
  bool get enableNetworkLogs =>
      (dotenv.env['ENABLE_NETWORK_LOGS'] ?? 'false').toLowerCase() == 'true';

  Duration get apiTimeout =>
      Duration(seconds: int.parse(dotenv.env['API_TIMEOUT_SECONDS'] ?? '15'));

  // Biometric configuration
  String get cameraQuality => dotenv.env['CAMERA_QUALITY'] ?? 'High';
  int get voiceSampleRate =>
      int.parse(dotenv.env['VOICE_SAMPLE_RATE'] ?? '44100');
  int get voiceBitRate => int.parse(dotenv.env['VOICE_BIT_RATE'] ?? '128000');

  // Google OAuth
  String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
  String get googleClientSecret => dotenv.env['GOOGLE_CLIENT_SECRET'] ?? '';

  /// Update API base URL at runtime (for testing or switching servers)
  Future<void> setApiBaseUrl(String url) async {
    _apiBaseUrl = url;
    await SecureConfig.saveApiBaseUrl(url);
  }

  /// Load API base URL from secure storage if available
  Future<void> loadApiBaseUrlFromStorage() async {
    final savedUrl = await SecureConfig.getApiBaseUrl();
    if (savedUrl != null) {
      _apiBaseUrl = savedUrl;
    }
  }

  /// Get all environment variables (for debugging)
  Map<String, String> getAllEnvVars() => Map.from(_allEnvVars);

  /// Verify configuration validity
  bool isConfigValid() {
    return _apiBaseUrl.isNotEmpty &&
        (_apiBaseUrl.startsWith('http://') ||
            _apiBaseUrl.startsWith('https://'));
  }

  /// Log configuration info (sanitized for debugging)
  void logConfiguration() {
    print('=== AILens Configuration ===');
    print('Environment: $_environment');
    print('API Base URL: $_apiBaseUrl');
    print('Debug Mode: $_debugMode');
    print(
        'Face Recognition: ${enableFaceRecognition ? 'Enabled' : 'Disabled'}');
    print(
        'Voice Recognition: ${enableVoiceRecognition ? 'Enabled' : 'Disabled'}');
    print('Google Sign-In: ${enableGoogleSignIn ? 'Enabled' : 'Disabled'}');
    print('============================');
  }
}
