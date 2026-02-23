import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/storage_service.dart';
import '../utils/app_theme.dart';
import 'face_registration_screen1.dart';
import 'home_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String? name;
  final String? googleId;
  final bool userExists;

  const EmailVerificationScreen({
    Key? key,
    required this.email,
    this.name,
    this.googleId,
    this.userExists = false,
  }) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoadingVerifyOTP = false;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  void _verifyOTP() async {
    if (_otpCode.isEmpty || _otpCode.length != 6) {
      _showMessage('Please enter the complete 6-digit code');
      return;
    }

    setState(() => _isLoadingVerifyOTP = true);

    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.verifyEmailOTP(
        email: widget.email,
        otp: _otpCode,
        name: widget.name,
        googleId: widget.googleId,
      );

      if (response['success']) {
        final token = response['token']?['access_token'];
        if (token != null) {
          await StorageService.saveToken(token);
        }
        if (mounted) {
          _showMessage('Email verified successfully!');
          
          // Navigate based on whether user is new or existing
          Widget nextScreen;
          if (widget.userExists) {
            // Existing user - go directly to home
            nextScreen = const HomeScreen();
          } else {
            // New user - go to face registration
            nextScreen = const FaceRegistrationScreen1();
          }
          
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => nextScreen),
          );
        }
      } else {
        _showMessage(response['message'] ?? 'Verification failed');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Verification failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingVerifyOTP = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _resendOTP() async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.sendEmailOTP(
        email: widget.email,
        name: widget.name,
      );
      
      if (mounted) {
        if (response['success']) {
          _showMessage('OTP resent to your email');
        } else {
          _showMessage(response['message'] ?? 'Failed to resend OTP');
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Failed to resend OTP: ${e.toString()}');
      }
    }
  }

  void _changeEmail() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryTeal,
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'AILens',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Enter verification code',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a 6-digit code to your email',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                widget.email,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryTeal,
                ),
              ),
              const SizedBox(height: 40),
              // OTP Input Fields with Backspace Handling
              RawKeyboardListener(
                focusNode: FocusNode(),
                onKey: (RawKeyEvent event) {
                  if (event is RawKeyDownEvent && 
                      event.logicalKey == LogicalKeyboardKey.backspace) {
                    // Find current focused field
                    for (int i = 0; i < 6; i++) {
                      if (_focusNodes[i].hasFocus) {
                        if (_otpControllers[i].text.isEmpty && i > 0) {
                          // Current field empty, move to previous and clear it
                          _otpControllers[i - 1].clear();
                          _focusNodes[i - 1].requestFocus();
                        }
                        break;
                      }
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 50,
                      height: 56,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primaryTeal,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          }
                          // Auto-verify when all digits entered
                          if (index == 5 && value.isNotEmpty) {
                            _verifyOTP();
                          }
                        },
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 32),
              // Verify Button
              ElevatedButton(
                onPressed: _isLoadingVerifyOTP ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoadingVerifyOTP
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Verify & Continue',
                            style: AppTextStyles.button,
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
              // Change Email Button
              TextButton(
                onPressed: _changeEmail,
                child: Text(
                  'Change email',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Resend OTP Button
              TextButton(
                onPressed: _resendOTP,
                child: Text(
                  'Resend OTP',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w600,
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
