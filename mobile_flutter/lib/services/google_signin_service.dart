import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import '../utils/app_config.dart';

/// Google Sign-In service wrapper for handling authentication
class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  final logger = Logger();

  late GoogleSignIn _googleSignIn;
  GoogleSignInAccount? _currentUser;

  GoogleSignInService._internal();

  factory GoogleSignInService() {
    return _instance;
  }

  /// Initialize Google Sign-In
  /// Scopes: email and profile information
  void initialize() {
    try {
      // Android: clientId is ignored, reads from google-services.json instead
      // iOS: clientId must be provided or reads from GoogleService-Info.plist
      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
        clientId: _getClientId(),
      );
      logger.i('✅ GoogleSignIn initialized successfully');
    } catch (e) {
      logger.e('❌ GoogleSignIn initialization error: $e');
    }

    // Listen for sign-in/out changes
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _currentUser = account;
      logger.i('User changed: ${account?.displayName ?? "null"}');
    });
  }

  /// Get platform-specific client ID from AppConfig
  /// For Android: returns empty string (reads from google-services.json)
  /// For iOS: uses GoogleService-Info.plist
  String _getClientId() {
    // Android: client ID is in google-services.json, no need to pass here
    // Returning empty string tells GoogleSignIn to use platform defaults
    logger.i('GoogleSignIn will use platform-specific configuration');
    return '';
  }

  /// Sign in with Google
  /// Returns user account on success, null on failure or cancellation
  /// Note: Android emulator may require Google Play Services installed
  Future<GoogleSignInAccount?> signIn() async {
    try {
      logger.i('Starting Google Sign-In...');

      // Check if already signed in
      final isSignedIn = await _googleSignIn.isSignedIn();
      if (isSignedIn) {
        logger.i('Already signed in: ${_currentUser?.email}');
        return _currentUser;
      }

      // Attempt sign-in
      final account = await _googleSignIn.signIn();

      if (account != null) {
        _currentUser = account;
        logger.i('Google Sign-In successful: ${account.email}');
        return account;
      } else {
        logger.w(
            'Google Sign-In cancelled - emulator may lack Google Play Services');
        return null;
      }
    } catch (e) {
      logger.e('Google Sign-In error: $e');
      logger.w(
          'If running on emulator without Play Services, use demo@ailens.app');
      return null;
    }
  }

  /// Get ID token for backend authentication
  /// This token can be sent to your backend for verification
  Future<String?> getIdToken() async {
    try {
      if (_currentUser == null) {
        _currentUser = await _googleSignIn.signInSilently();
      }

      if (_currentUser != null) {
        final authentication = await _currentUser!.authentication;
        return authentication.idToken;
      }
    } catch (e) {
      logger.e('Error getting ID token: $e');
    }
    return null;
  }

  /// Get access token for backend API calls
  Future<String?> getAccessToken() async {
    try {
      if (_currentUser == null) {
        _currentUser = await _googleSignIn.signInSilently();
      }

      if (_currentUser != null) {
        final authentication = await _currentUser!.authentication;
        return authentication.accessToken;
      }
    } catch (e) {
      logger.e('Error getting access token: $e');
    }
    return null;
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      logger.i('Signing out from Google...');
      await _googleSignIn.signOut();
      _currentUser = null;
      logger.i('Google Sign-Out successful');
    } catch (e) {
      logger.e('Google Sign-Out error: $e');
    }
  }

  /// Disconnect Google account (removes app authorization)
  Future<void> disconnect() async {
    try {
      logger.i('Disconnecting Google account...');
      await _googleSignIn.disconnect();
      _currentUser = null;
      logger.i('Google disconnect successful');
    } catch (e) {
      logger.e('Google disconnect error: $e');
    }
  }

  /// Get current user information
  GoogleSignInAccount? get currentUser => _currentUser;

  /// Check if user is currently signed in
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Get user display name
  String? getUserDisplayName() => _currentUser?.displayName;

  /// Get user email
  String? getUserEmail() => _currentUser?.email;

  /// Get user profile picture URL
  String? getUserPhotoUrl() => _currentUser?.photoUrl;

  /// Initialize silent sign-in (check if user was previously signed in)
  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      logger.i('Attempting silent Google Sign-In...');
      final account = await _googleSignIn.signInSilently();

      if (account != null) {
        _currentUser = account;
        logger.i('Silent sign-in successful: ${account.email}');
      }

      return account;
    } catch (e) {
      logger.e('Silent sign-in error: $e');
      return null;
    }
  }
}
