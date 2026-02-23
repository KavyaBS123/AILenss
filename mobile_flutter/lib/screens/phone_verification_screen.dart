import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/storage_service.dart';
import '../utils/app_theme.dart';
import 'face_registration_screen1.dart';
import 'home_screen.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String? name;
  final String? googleId;
  final bool userExists;

  const PhoneVerificationScreen({
    Key? key,
    required this.phoneNumber,
    this.name,
    this.googleId,
    this.userExists = false,
  }) : super(key: key);

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
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
      final response = await apiService.verifyPhoneOTP(
        phoneNumber: widget.phoneNumber,
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
          _showMessage('Phone verified successfully!');
          
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
              const SizedBox(height: 80),
              // Heading
              Text(
                'Enter verification code',
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a 6-digit code to your phone',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) => _buildOTPBox(index)),
              ),
              const SizedBox(height: 48),
              // Verify button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoadingVerifyOTP ? null : _verifyOTP,
                  child: _isLoadingVerifyOTP
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
                              'Verify & Continue',
                              style: AppTextStyles.button,
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              // Change phone button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Change phone',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
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

  Widget _buildOTPBox(int index) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) {
        // Handle backspace key
        if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
          if (_otpControllers[index].text.isEmpty && index > 0) {
            // If current field is empty and backspace pressed, move to previous field and clear it
            _otpControllers[index - 1].clear();
            _focusNodes[index - 1].requestFocus();
            setState(() {});
          } else if (_otpControllers[index].text.isNotEmpty) {
            // If current field has value, clear it
            _otpControllers[index].clear();
            setState(() {});
          }
        }
      },
      child: Container(
        width: 48,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: _otpControllers[index].text.isNotEmpty
                ? AppColors.primaryTeal
                : AppColors.border,
            width: _otpControllers[index].text.isNotEmpty ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) {
            setState(() {});
            if (value.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            }
            // Auto-verify when all fields are filled
            if (index == 5 && value.isNotEmpty) {
              final otpComplete = _otpControllers.every((c) => c.text.isNotEmpty);
              if (otpComplete) {
                _verifyOTP();
              }
            }
          },
        ),
      ),
    );
  }
}
