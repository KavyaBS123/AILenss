import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/storage_service.dart';
import '../utils/app_theme.dart';
import 'face_registration_screen1.dart';
import 'phone_verification_screen.dart';
import 'email_verification_screen.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  final String? googleId;
  final String? prefillEmail;
  final String? prefillName;

  const RegistrationScreen({
    Key? key,
    this.googleId,
    this.prefillEmail,
    this.prefillName,
  }) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _phoneEmailController = TextEditingController();
  
  bool _isLoading = false;
  int _selectedTab = 0; // 0: Phone, 1: Email

  @override
  void initState() {
    super.initState();
    // Pre-fill name if available from Google
    if (widget.prefillName != null) {
      _nameController.text = widget.prefillName!;
    }
    // Pre-fill email if available
    if (widget.prefillEmail != null) {
      _phoneEmailController.text = widget.prefillEmail!;
      _selectedTab = 1; // Switch to Email tab
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneEmailController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      _showMessage('Please enter your name');
      return false;
    }
    
    if (_phoneEmailController.text.trim().isEmpty) {
      _showMessage(_selectedTab == 0 ? 'Please enter phone number' : 'Please enter email address');
      return false;
    }
    
    // Validate phone number format
    if (_selectedTab == 0) {
      final phone = _phoneEmailController.text.trim();
      if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
        _showMessage('Please enter a valid 10-digit phone number');
        return false;
      }
    }
    
    // Validate email format - only Gmail allowed
    if (_selectedTab == 1 && !_isValidEmail(_phoneEmailController.text)) {
      _showMessage('Please enter a valid Gmail address (e.g., user@gmail.com)');
      return false;
    }
    
    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$')
        .hasMatch(email);
  }

  void _handleCreateAccount() async {
    if (!_validateForm()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final contact = _phoneEmailController.text.trim();
      
      if (_selectedTab == 0) {
        // Phone mode - send OTP
        final fullPhone = contact.startsWith('+91') ? contact : '+91$contact';
        
        final apiService = context.read<ApiService>();
        final response = await apiService.sendPhoneOTP(phoneNumber: fullPhone);

        if (!mounted) return;

        if (response['success']) {
          _showMessage('OTP sent to your phone');
          
          // Navigate to phone verification with name and googleId stored
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => PhoneVerificationScreen(
                  phoneNumber: fullPhone,
                  name: name,
                  googleId: widget.googleId,
                ),
              ),
            );
          }
        } else {
          _showMessage(response['message'] ?? 'Failed to send OTP');
        }
      } else {
        // Email mode - send OTP for verification
        final apiService = context.read<ApiService>();

        final response = await apiService.sendEmailOTP(
          email: contact,
          name: name,
        );

        if (!mounted) return;

        if (response['success']) {
          _showMessage('OTP sent to your email');
          
          // Navigate to email verification with name and googleId stored
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => EmailVerificationScreen(
                  email: contact,
                  name: name,
                  googleId: widget.googleId,
                  userExists: false,
                ),
              ),
            );
          }
        } else {
          _showMessage(response['message'] ?? 'Failed to send OTP');
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('✓')
            ? Colors.green
            : AppColors.primaryTeal,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5D9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '✨ ',
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      'New to AILens',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Create your account',
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'Start protecting your digital identity today',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              
              // Name field
              Text(
                'Your name',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                enabled: !_isLoading,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              
              // Tab switching for Phone/Email
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
                        onTap: _isLoading ? null : () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
                        onTap: _isLoading ? null : () => setState(() => _selectedTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
              const SizedBox(height: 20),
              
              // Phone/Email input field
              if (_selectedTab == 0)
                TextField(
                  controller: _phoneEmailController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.phone,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
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
                TextField(
                  controller: _phoneEmailController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter email address',
                    suffixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              
              // Create Account button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleCreateAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Create Account',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Sign in link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTextStyles.bodyMedium,
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Sign in',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// New class to handle phone verification with name
class PhoneVerificationScreenWithName extends StatefulWidget {
  final String phoneNumber;
  final String userName;
  final String? googleId;  // Add googleId parameter

  const PhoneVerificationScreenWithName({
    Key? key,
    required this.phoneNumber,
    required this.userName,
    this.googleId,  // Optional googleId
  }) : super(key: key);

  @override
  State<PhoneVerificationScreenWithName> createState() =>
      _PhoneVerificationScreenWithNameState();
}

class _PhoneVerificationScreenWithNameState
    extends State<PhoneVerificationScreenWithName> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  void _handleVerifyOTP() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.verifyPhoneOTP(
        phoneNumber: widget.phoneNumber,
        otp: _otpController.text,
        name: widget.userName,
        googleId: widget.googleId,  // Pass google_id if available
      );

      if (!mounted) return;

      if (response['success']) {
        final token = response['token']?['access_token'];
        if (token != null) {
          await StorageService.saveToken(token);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✓ Account created successfully!')),
          );

          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const FaceRegistrationScreen1()),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Invalid OTP')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5D9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '✨ ',
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      'New to AILens',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Enter verification code',
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'We sent a 6-digit code to your phone',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              
              // OTP Input
              TextField(
                controller: _otpController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: AppTextStyles.h3,
                decoration: InputDecoration(
                  hintText: 'Enter 6-digit code',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primaryTeal,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primaryTeal,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Verify button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Verify & Continue',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Change phone link
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: Text(
                    'Change phone',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
