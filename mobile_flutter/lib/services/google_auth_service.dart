import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class GoogleAuthService {
  final logger = Logger();
  
  late final GoogleSignIn googleSignIn;

  GoogleAuthService() {
    googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile', 'openid'],
      serverClientId: '218890731930-ffkppto75dbmjrdts3fgf3nmhdsg2f9l.apps.googleusercontent.com',
    );
  }

  Future<String?> signInAndGetIdToken() async {
    try {
      logger.i('=== Starting Google Sign-In ===');
      
      // Step 1: Show account picker and get account
      logger.i('Calling googleSignIn.signIn()...');
      final GoogleSignInAccount? account = await googleSignIn.signIn()
          .timeout(const Duration(seconds: 60), onTimeout: () {
        logger.e('TIMEOUT: Account selection timed out after 60 seconds');
        throw Exception('Account selection timed out');
      });
      
      if (account == null) {
        logger.w('User cancelled sign-in');
        return null;
      }
      
      logger.i('✓ Account selected: ${account.email}');
      
      // Step 2: Get authentication with ID token
      logger.i('Requesting authentication token...');
      final GoogleSignInAuthentication auth = await account.authentication
          .timeout(const Duration(seconds: 30), onTimeout: () {
        logger.e('TIMEOUT: Authentication request timed out after 30 seconds');
        throw Exception('Authentication timed out');
      });
      
      logger.i('✓ Authentication obtained');
      
      // Step 3: Verify ID token exists
      if (auth.idToken == null || auth.idToken!.isEmpty) {
        logger.e('CRITICAL: ID token is null or empty after authentication!');
        logger.e('Access token present: ${auth.accessToken != null}');
        throw Exception('No ID token received from Google');
      }
      
      logger.i('✓ ID token obtained successfully');
      logger.i('ID token length: ${auth.idToken!.length}');
      
      return auth.idToken;
      
    } catch (e) {
      logger.e('Exception in signInAndGetIdToken: $e');
      // Sign out on error to clean up state
      try {
        await googleSignIn.signOut();
      } catch (_) {}
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
      logger.i('✓ Signed out successfully');
    } catch (e) {
      logger.e('Error signing out: $e');
    }
  }

  Future<bool> isSignedIn() async {
    try {
      return await googleSignIn.isSignedIn();
    } catch (e) {
      logger.e('Error checking sign-in status: $e');
      return false;
    }
  }
}
