import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'face_registration_capture.dart';
import 'face_registration_screen3.dart';

class FaceRegistrationScreen2 extends StatefulWidget {
  final List<String> faceImages;

  const FaceRegistrationScreen2({
    Key? key,
    required this.faceImages,
  }) : super(key: key);

  @override
  State<FaceRegistrationScreen2> createState() => _FaceRegistrationScreen2State();
}

class _FaceRegistrationScreen2State extends State<FaceRegistrationScreen2> {
  String? _capturedImagePath;

  @override
  Widget build(BuildContext context) {
    return FaceRegistrationCaptureScreen(
      title: 'Register Your Face',
      stepText: 'Step 2 of 3',
      instructionTitle: 'Turn left',
      instructionSubtitle: 'Slowly turn your head to the left',
      accentColor: AppColors.primaryOrange,
      progressColors: [
        AppColors.primaryTeal,
        AppColors.primaryTeal,
        Colors.grey.shade300,
      ],
      onImageCaptured: (imagePath) {
        setState(() => _capturedImagePath = imagePath);
      },
      onCaptureSuccess: () {
        final updatedImages = [...widget.faceImages, _capturedImagePath ?? ''];
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FaceRegistrationScreen3(
              faceImages: updatedImages,
            ),
          ),
        );
      },
    );
  }}