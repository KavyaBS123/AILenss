import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/google_auth_service.dart';
import '../utils/storage_service.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import 'phone_verification_screen.dart';
import 'email_verification_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  int _selectedTab = 0; // 0: Phone, 1: Email
  bool _showNameInputForPhone = false; // Show name input for new phone users
  String _phoneNumberForNewUser = ''; // Store phone for account creation flow
  final _googleAuthService = GoogleAuthService();

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handlePhoneLogin() async {
    // If showing name input, validate name first
    if (_showNameInputForPhone) {
      if (_nameController.text.trim().isEmpty) {
        _showMessage('Please enter your name');
        return;
      }
      
      setState(() => _isLoading = true);
      
      try {
        final apiService = context.read<ApiService>();
        // Send OTP again for new user (after collecting name)
        final response = await apiService.sendPhoneOTP(phoneNumber: _phoneNumberForNewUser);
        
        if (mounted) {
          if (response['success']) {
            // Navigate to OTP verification with name
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => PhoneVerificationScreen(
                  phoneNumber: _phoneNumberForNewUser,
                  name: _nameController.text.trim(),
                  userExists: false,
                ),
              ),
            );
          } else {
            _showMessage(response['message'] ?? 'Failed to send OTP');
          }
        }
      } catch (e) {
        if (mounted) {
          _showMessage('Failed to send OTP: ${e.toString()}');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
      return;
    }
    
    // Initial phone login check
    if (_phoneController.text.isEmpty) {
      _showMessage('Please enter phone number');
      return;
    }

    final phone = _phoneController.text.trim();
    
    // Validate phone number format (should be 10 digits)
    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      _showMessage('Please enter a valid 10-digit phone number');
      return;
    }
    
    // Allow both formats: with or without +91 prefix since we add it via prefixText
    final fullPhone = phone.startsWith('+91') ? phone : '+91$phone';

    setState(() => _isLoading = true);

    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.sendPhoneOTP(phoneNumber: fullPhone);

      if (mounted) {
        if (response['success']) {
          // Check if user already exists
          final userExists = response['user_exists'] ?? false;
          
          if (userExists) {
            // Existing user - go directly to OTP verification
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => PhoneVerificationScreen(
                  phoneNumber: fullPhone,
                  userExists: userExists,
                ),
              ),
            );
          } else {
            // New user - show name input on same page
            _showMessage('Please enter your name to create account');
            setState(() {
              _showNameInputForPhone = true;
              _phoneNumberForNewUser = fullPhone;
            });
          }
        } else {
          _showMessage(response['message'] ?? 'Failed to send OTP');
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Failed to send OTP: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Handle Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Step 1: Get Google ID Token
      print('DEBUG: Starting Google Sign-In');
      _showMessage('Starting Google sign-in...');
      
      String? googleIdToken;
      try {
        googleIdToken = await _googleAuthService.signInAndGetIdToken()
            .timeout(const Duration(seconds: 45), onTimeout: () {
          print('DEBUG: Google Sign-In timed out after 45s');
          throw Exception('Google sign-in timed out after 45 seconds');
        });
        print('DEBUG: Got ID token result: ${googleIdToken != null}');
      } catch (e) {
        print('DEBUG: Error during Google Sign-In: $e');
        throw Exception('Google Sign-In failed: ${e.toString()}');
      }
      
      if (googleIdToken == null) {
        if (mounted) {
          _showMessage('Sign-in cancelled');
          setState(() => _isLoading = false);
        }
        return;
      }

      // Step 2: Verify with backend and check user existence
      if (mounted) {
        _showMessage('Verifying with Google... (this may take a moment)');
      }

      print('DEBUG: Calling backend with ID token');
      final apiService = context.read<ApiService>();
      
      Map<String, dynamic> response;
      try {
        response = await apiService.loginWithGoogle(idToken: googleIdToken)
            .timeout(const Duration(seconds: 60), onTimeout: () {
          print('DEBUG: Backend call timed out after 60s');
          return {'success': false, 'message': 'Google verification is taking too long. Check your internet and try again.'};
        });
        print('DEBUG: Backend response: $response');
      } catch (e) {
        print('DEBUG: Backend call error: $e');
        throw Exception('Backend error: ${e.toString()}');
      }
      
      if (!mounted) return;
      
      if (response['success']) {
        // Check if user already exists
        final userExists = response['user_exists'] ?? false;
        
        if (userExists) {
          // User exists - auto sign-in
          print('DEBUG: User exists, signing in...');
          final token = response['token'];
          if (token != null && token is String) {
            // Token is already a string for direct GoogleSignInResponse
            await StorageService.saveToken(token);
            _showMessage('✓ Sign in successful!');
            
            await Future.delayed(const Duration(milliseconds: 500));

            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
          } else {
            _showMessage('Error: No token received from server');
          }
        } else {
          // New user - show registration form
          print('DEBUG: New user, showing registration form...');
          final googleInfo = response['google_info'];
          
          if (mounted) {
            _showMessage('Complete your profile to finish signup');
            
            await Future.delayed(const Duration(milliseconds: 500));
            
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => RegistrationScreen(
                    googleId: googleInfo?['google_id'],
                    prefillEmail: googleInfo?['email'],
                    prefillName: googleInfo?['name'],
                  ),
                ),
              );
            }
          }
        }
      } else {
        _showMessage('${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('DEBUG: Final catch block - Error: $e');
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('Exception:')) {
          errorMessage = errorMessage.replaceAll('Exception:', '').trim();
        }
        if (errorMessage.contains('Google Sign-In failed:')) {
          // This is a Google Sign-In issue, not backend
          errorMessage = errorMessage.replaceAll('Google Sign-In failed:', '').trim();
        }
        _showMessage(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleEmailLogin() async {
    if (_emailController.text.trim().isEmpty) {
      _showMessage('Please enter email address');
      return;
    }

    final email = _emailController.text.trim();
    
    // Validate email format - only Gmail allowed
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(email)) {
      _showMessage('Please enter a valid Gmail address (e.g., user@gmail.com)');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.sendEmailOTP(email: email);

      if (!mounted) return;

      if (response['success']) {
        // Check if user already exists
        final userExists = response['user_exists'] ?? false;
        
        _showMessage(userExists 
            ? 'OTP sent! Please check your email' 
            : 'OTP sent! Verify to create account');
        
        // Navigate to OTP verification screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(
              email: email,
              userExists: userExists,
            ),
          ),
        );
      } else {
        final message = response['message'] ?? 'Failed to send OTP';
        _showMessage(message);
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Failed to send OTP: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleCreateAccount() {
    // Navigate to registration screen without Google pre-fill
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RegistrationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // AILens Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryTeal,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'AILens',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              // Welcome back text
              Text(
                'Welcome back',
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 12),
              Text(
                'Sign in to continue protecting your identity',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Tab switching
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: _selectedTab == 0
                                ? AppColors.white
                                : Colors.transparent,
                            boxShadow: _selectedTab == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                color: _selectedTab == 0
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Phone',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: _selectedTab == 0
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                  fontWeight: _selectedTab == 0
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: _selectedTab == 1
                                ? AppColors.white
                                : Colors.transparent,
                            boxShadow: _selectedTab == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.email_outlined,
                                color: _selectedTab == 1
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Email',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: _selectedTab == 1
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                  fontWeight: _selectedTab == 1
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Phone input
              if (_selectedTab == 0) ...
                [
                  if (!_showNameInputForPhone)
                    TextField(
                      controller: _phoneController,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      keyboardType: TextInputType.phone,
                      enabled: !_showNameInputForPhone,
                      decoration: InputDecoration(
                        prefixText: '+91  ',
                        prefixStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        hintText: 'Enter phone number',
                        suffixIcon: Icon(
                          Icons.phone_outlined,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    )
                  else
                    // Show read-only phone display for new user
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.surface,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _phoneNumberForNewUser,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_showNameInputForPhone) ...
                    [
                      const SizedBox(height: 16),
                      // Name input for new user
                      TextField(
                        controller: _nameController,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your name',
                          prefixIcon: Icon(
                            Icons.person_outlined,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                ],
              // Email input
              if (_selectedTab == 1) ...
                [
                  TextField(
                    controller: _emailController,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter email address',
                      suffixIcon: Icon(
                        Icons.email_outlined,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              const SizedBox(height: 24),
              // Sign in with Google button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    side: BorderSide(
                      color: AppColors.border,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.primaryTeal,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://www.google.com/favicon.ico',
                              width: 20,
                              height: 20,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.g_mobiledata,
                                  size: 28,
                                  color: AppColors.textPrimary,
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Sign in with Google',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Sign In button (Phone/Email) or Continue button for account creation
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_selectedTab == 0
                          ? _handlePhoneLogin
                          : _handleEmailLogin),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _showNameInputForPhone ? 'Create Account & Send OTP' : 'Sign In',
                              style: AppTextStyles.button,
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),
              // Back button for name input, or New to AILens link
              if (_showNameInputForPhone)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => setState(() {
                              _showNameInputForPhone = false;
                              _nameController.clear();
                              _phoneNumberForNewUser = '';
                            }),
                    child: Text(
                      'Back to Sign In',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                // New to AILens
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New to AILens? ',
                      style: AppTextStyles.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : _handleCreateAccount,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Create an account',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 60),
              // Terms
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text.rich(
                  TextSpan(
                    text: 'By continuing, you agree to our ',
                    style: AppTextStyles.bodySmall,
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
