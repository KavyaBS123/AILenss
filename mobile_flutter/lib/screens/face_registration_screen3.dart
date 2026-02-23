import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../utils/storage_service.dart';
import 'face_registration_capture.dart';
import 'home_screen.dart';

class FaceRegistrationScreen3 extends StatefulWidget {
  final List<String> faceImages;

  const FaceRegistrationScreen3({
    Key? key,
    required this.faceImages,
  }) : super(key: key);

  @override
  State<FaceRegistrationScreen3> createState() => _FaceRegistrationScreen3State();
}

class _FaceRegistrationScreen3State extends State<FaceRegistrationScreen3> {
  String? _capturedImagePath;
  bool _isUploading = false;

  Future<void> _uploadFacesAndContinue() async {
    final updatedImages = [...widget.faceImages, _capturedImagePath ?? ''];
    
    setState(() => _isUploading = true);

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        _showMessage('Authentication required');
        return;
      }

      final apiService = context.read<ApiService>();

      // Face types for each step: straight, left, right
      final faceTypes = ['straight', 'left', 'right'];

      // Upload all face images
      for (int i = 0; i < updatedImages.length; i++) {
        final imagePath = updatedImages[i];
        if (imagePath.isNotEmpty) {
          await apiService.uploadFaceImage(
            imagePath: imagePath,
            token: token,
            faceType: faceTypes[i],
          );
        }
      }

      if (mounted) {
        _showMessage('Face registration completed!');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Failed to upload faces: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
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
    return _isUploading
        ? Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    'Uploading face images...',
                    style: AppTextStyles.h2,
                  ),
                ],
              ),
            ),
          )
        : FaceRegistrationCaptureScreen(
            title: 'Register Your Face',
            stepText: 'Step 3 of 3',
            instructionTitle: 'Turn right',
            instructionSubtitle: 'Slowly turn your head to the right',
            accentColor: AppColors.primaryOrange,
            progressColors: [
              AppColors.primaryTeal,
              AppColors.primaryTeal,
              AppColors.primaryOrange,
            ],
            onImageCaptured: (imagePath) {
              setState(() => _capturedImagePath = imagePath);
            },
            onCaptureSuccess: () {
              _uploadFacesAndContinue();
            },
          );
  }}