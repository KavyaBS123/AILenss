import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../utils/app_theme.dart';

class FaceRegistrationCaptureScreen extends StatefulWidget {
  final String title;
  final String stepText;
  final String instructionTitle;
  final String instructionSubtitle;
  final Color accentColor;
  final List<Color> progressColors;
  final VoidCallback onCaptureSuccess;
  final Function(String)? onImageCaptured; // Callback to pass image path

  const FaceRegistrationCaptureScreen({
    Key? key,
    required this.title,
    required this.stepText,
    required this.instructionTitle,
    required this.instructionSubtitle,
    required this.accentColor,
    required this.progressColors,
    required this.onCaptureSuccess,
    this.onImageCaptured,
  }) : super(key: key);

  @override
  State<FaceRegistrationCaptureScreen> createState() =>
      _FaceRegistrationCaptureScreenState();
}

class _FaceRegistrationCaptureScreenState
    extends State<FaceRegistrationCaptureScreen> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isInitializing = true;
  bool _isDetecting = false;
  bool _faceDetected = false;
  bool _isCapturing = false;
  String? _cameraError;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _stopImageStream();
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup:
            Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.yuv420,
      );

      await controller.initialize();
      _cameraController = controller;

      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: false,
          enableLandmarks: false,
          enableClassification: false,
          enableTracking: true,
          minFaceSize: 0.1,
          performanceMode: FaceDetectorMode.fast,
        ),
      );

      await controller.startImageStream(_processCameraImage);

      if (mounted) {
        setState(() => _isInitializing = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _cameraError = e.toString();
        });
      }
    }
  }

  Future<void> _stopImageStream() async {
    final controller = _cameraController;
    if (controller != null && controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting || _faceDetector == null) {
      return;
    }

    _isDetecting = true;

    try {
      final inputImage = _buildInputImage(image, _cameraController);
      if (inputImage == null) {
        _isDetecting = false;
        return;
      }

      final faces = await _faceDetector!.processImage(inputImage);
      if (!mounted) {
        _isDetecting = false;
        return;
      }

      final detected = faces.isNotEmpty;
      if (_faceDetected != detected) {
        setState(() => _faceDetected = detected);
      }
    } catch (_) {
      // Ignore detection failures to keep the preview running.
    } finally {
      _isDetecting = false;
    }
  }

  InputImage? _buildInputImage(
      CameraImage image, CameraController? controller) {
    if (controller == null) {
      return null;
    }

    final rotation = _rotationForCamera(controller.description);
    final format = _imageFormat(image.format.raw);
    if (format == null) {
      return null;
    }

    final bytes = _concatenatePlanes(image.planes);
    final size = Size(image.width.toDouble(), image.height.toDouble());

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: size,
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  InputImageRotation _rotationForCamera(CameraDescription description) {
    var rotation = description.sensorOrientation;

    if (Platform.isAndroid && _cameraController != null) {
      final orientation = _cameraController!.value.deviceOrientation;
      int rotationCompensation;
      switch (orientation) {
        case DeviceOrientation.portraitUp:
          rotationCompensation = 0;
          break;
        case DeviceOrientation.landscapeLeft:
          rotationCompensation = 90;
          break;
        case DeviceOrientation.portraitDown:
          rotationCompensation = 180;
          break;
        case DeviceOrientation.landscapeRight:
          rotationCompensation = 270;
          break;
      }

      if (description.lensDirection == CameraLensDirection.front) {
        rotation = (rotation + rotationCompensation) % 360;
      } else {
        rotation = (rotation - rotationCompensation + 360) % 360;
      }
    }

    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      case 0:
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  InputImageFormat? _imageFormat(int rawFormat) {
    // Android: ImageFormat.YUV_420_888 = 35
    if (rawFormat == 35) {
      return InputImageFormat.yuv420;
    }
    // iOS: kCVPixelFormatType_32BGRA = 1111970369
    if (rawFormat == 1111970369) {
      return InputImageFormat.bgra8888;
    }
    return null;
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final bytes = WriteBuffer();
    for (final plane in planes) {
      bytes.putUint8List(plane.bytes);
    }
    return bytes.done().buffer.asUint8List();
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      await _stopImageStream();
      final image = await _cameraController!.takePicture();
      if (mounted) {
        // Pass the image path to parent via callback
        widget.onImageCaptured?.call(image.path);
        setState(() {
          _capturedImage = image;
          _isCapturing = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _retakePhoto() async {
    if (_cameraController == null) {
      return;
    }

    setState(() => _capturedImage = null);

    if (!_cameraController!.value.isStreamingImages) {
      try {
        await _cameraController!.startImageStream(_processCameraImage);
      } catch (_) {
        // Ignore restart failures and keep the preview running.
      }
    }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                  Text(
                    'Skip',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                widget.title,
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 12),
              Text(
                widget.stepText,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 6,
                child: Row(
                  children: List.generate(
                    widget.progressColors.length * 2 - 1,
                    (index) {
                      if (index.isOdd) {
                        return const SizedBox(width: 8);
                      }
                      final color = widget.progressColors[index ~/ 2];
                      return Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 60),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.accentColor.withOpacity(0.3),
                          width: 3,
                        ),
                        color: Colors.grey[100],
                      ),
                      child: ClipOval(
                        child: _capturedImage == null
                            ? _buildCameraPreview()
                            : Image.file(
                                File(_capturedImage!.path),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      widget.instructionTitle,
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.instructionSubtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
              _capturedImage == null
                  ? SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: !_isCapturing ? _capturePhoto : null,
                        child: _isCapturing
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
                                  const Icon(Icons.camera_alt, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Capture',
                                    style: AppTextStyles.button,
                                  ),
                                ],
                              ),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: _retakePhoto,
                              child: Text(
                                'Retake',
                                style: AppTextStyles.button.copyWith(
                                  color: AppColors.primaryTeal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: widget.onCaptureSuccess,
                              child: Text(
                                'Continue',
                                style: AppTextStyles.button,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _faceDetected
                      ? 'Face detected.'
                      : 'Face not detected. You can still capture.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color:
                        _faceDetected ? AppColors.success : AppColors.textTertiary,
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

  Widget _buildCameraPreview() {
    if (_cameraError != null) {
      return Center(
        child: Text(
          'Camera error',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
        ),
      );
    }
    if (_isInitializing || _cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return CameraPreview(_cameraController!);
  }
}
