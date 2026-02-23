import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'face_registration_capture.dart';
import 'face_registration_screen2.dart';

class FaceRegistrationScreen1 extends StatefulWidget {
  const FaceRegistrationScreen1({Key? key}) : super(key: key);

  @override
  State<FaceRegistrationScreen1> createState() => _FaceRegistrationScreen1State();
}

class _FaceRegistrationScreen1State extends State<FaceRegistrationScreen1> {
  String? _capturedImagePath;

  @override
  Widget build(BuildContext context) {
    return FaceRegistrationCaptureScreen(
      title: 'Register Your Face',
      stepText: 'Step 1 of 3',
      instructionTitle: 'Look straight',
      instructionSubtitle: 'Position your face in the center',
      accentColor: AppColors.primaryTeal,
      progressColors: [
        AppColors.primaryTeal,
        Colors.grey.shade300,
        Colors.grey.shade300,
      ],
      onImageCaptured: (imagePath) {
        setState(() => _capturedImagePath = imagePath);
      },
      onCaptureSuccess: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FaceRegistrationScreen2(
              faceImages: [_capturedImagePath ?? ''],
            ),
          ),
        );
      },
    );
  }}