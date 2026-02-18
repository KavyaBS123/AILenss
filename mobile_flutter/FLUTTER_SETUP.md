# AILens Flutter Mobile App - Setup Guide

**Updated:** February 16, 2026  
**Framework:** Flutter  
**Target:** iOS & Android  
**Dart Version:** 3.0+

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Project Structure](#project-structure)
4. [Configuration](#configuration)
5. [Running the App](#running-the-app)
6. [API Integration](#api-integration)
7. [Screens Overview](#screens-overview)
8. [Testing](#testing)
9. [Building for Production](#building-for-production)
10. [Troubleshooting](#troubleshooting)

---

## 📋 Prerequisites

### System Requirements
- **Flutter SDK:** 3.0.0 or higher
- **Dart:** 3.0.0 or higher
- **Android:** SDK 21+ (minSdkVersion)
- **iOS:** iOS 12.0+
- **IDE:** Android Studio, VS Code, or Xcode

### Installation

#### Windows
```bash
# Download Flutter SDK
https://flutter.dev/docs/get-started/install/windows

# Add Flutter to PATH
# Run flutter doctor to verify installation
flutter doctor
```

#### macOS
```bash
# Using Homebrew
brew install flutter

# Or download from
https://flutter.dev/docs/get-started/install/macos

# Run flutter doctor
flutter doctor
```

#### Linux
```bash
# Download and extract
cd ~/development
tar xf ~/Downloads/flutter_linux_v3.0.0-stable.tar.xz

# Add to PATH
export PATH="$PATH:$HOME/development/flutter/bin"

# Run flutter doctor
flutter doctor
```

### Install Dependencies
```bash
# Resolve any missing dependencies
flutter doctor --android-licenses

# Install platform tools
flutter pub global activate devtools
```

---

## 🚀 Installation

### 1. Clone/Navigate to Project
```bash
cd mobile_flutter
```

### 2. Install Flutter Dependencies
```bash
# Get all pub dependencies
flutter pub get

# Or use upgrade to get latest compatible versions
flutter pub upgrade
```

### 3. Get Required Native Packages
```bash
# This fetches native dependencies for iOS/Android
flutter pub get
```

### 4. Configure Environment Variables
```bash
# Copy the template
cp .env.example .env

# Edit .env with your configuration
# Set API_BASE_URL, GOOGLE_CLIENT_ID, etc.
```

---

## 📁 Project Structure

```
mobile_flutter/
├── lib/                              # Main Flutter source code
│   ├── main.dart                     # App entry point
│   ├── screens/                      # UI Screens
│   │   ├── splash_screen.dart        # Splash/loading screen
│   │   ├── login_screen.dart         # Login screen
│   │   ├── register_screen.dart      # Registration & OTP verification
│   │   └── home_screen.dart          # Home/dashboard screen
│   ├── services/                     # Business logic & API
│   │   └── api_service.dart          # HTTP API client
│   ├── models/                       # Data models
│   │   └── user.dart                 # User model
│   ├── widgets/                      # Reusable widgets (coming soon)
│   ├── utils/                        # Utilities
│   │   └── storage_service.dart      # Secure storage
│   └── constants/                    # Constants (coming soon)
│
├── android/                          # Android native code
│   ├── app/
│   │   ├── src/debug/AndroidManifest.xml
│   │   ├── src/main/AndroidManifest.xml
│   │   └── build.gradle
│   └── build.gradle
│
├── ios/                              # iOS native code
│   ├── Podfile
│   ├── Runner.xcodeproj/
│   └── Runner/
│       └── Info.plist
│
├── pubspec.yaml                      # Flutter dependencies
├── pubspec.lock                      # Locked dependency versions
├── .env                              # Environment variables
├── .env.example                      # Environment template
└── .gitignore                        # Git exclusions
```

---

## ⚙️ Configuration

### Environment Variables (.env)

```bash
# Backend API
API_BASE_URL=http://localhost:5000/api

# For physical device on same network:
# API_BASE_URL=http://192.168.1.100:5000/api

# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id_here
GOOGLE_CLIENT_SECRET=your_google_client_secret_here

# App Settings
APP_NAME=AILens
APP_VERSION=1.0.0
DEBUG=true

# API Configuration
API_TIMEOUT_SECONDS=30
```

### Platform-Specific Configuration

#### Android (android/app/src/main/AndroidManifest.xml)
```xml
<!-- Add internet permission -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

#### iOS (ios/Runner/Info.plist)
```xml
<!-- Add camera description -->
<key>NSCameraUsageDescription</key>
<string>AILens uses your camera for biometric authentication</string>

<!-- Add microphone description -->
<key>NSMicrophoneUsageDescription</key>
<string>AILens uses your microphone for voice authentication</string>
```

---

## 🏃 Running the App

### Run on Emulator/Simulator

#### Android Emulator
```bash
# Start Android emulator first, then:
flutter run

# Or specify device
flutter run -d emulator-5554

# Run in release mode
flutter run --release
```

#### iOS Simulator
```bash
# Open iOS simulator
open -a Simulator

# Run the app
flutter run

# Or specify device
flutter run -d iPhone\ Pro\ \(6th\ generation\)

# Run in release mode
flutter run --release
```

### Run on Physical Device

#### Android Device
```bash
# Enable USB Debugging on device
# Connect via USB

# List connected devices
flutter devices

# Run app
flutter run

# Run in release mode
flutter run --release
```

#### iOS Device
```bash
# Connect device via USB/WiFi
# Trust the computer on device

# List devices
flutter devices

# Run app (requires provisioning profile)
flutter run

# Or use Xcode
open ios/Runner.xcworkspace
# Press Play button in Xcode
```

### Hot Reload During Development
```bash
# While app is running, press 'r' in terminal for hot reload
# Press 'R' for hot restart
# Press 'q' to quit
```

---

## 🔌 API Integration

### API Service

The `lib/services/api_service.dart` provides:

#### Authentication Endpoints
```dart
// Register
final result = await apiService.register(
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@example.com',
  phone: '9876543210',
  password: 'password123',
  passwordConfirm: 'password123',
);

// Verify OTP
final result = await apiService.verifyOTP(
  email: 'john@example.com',
  otp: '123456',
);

// Login
final result = await apiService.login(
  email: 'john@example.com',
  password: 'password123',
);

// Get Current User
final result = await apiService.getCurrentUser(token);

// Logout
final result = await apiService.logout(token);
```

### Response Format
```dart
{
  'success': true,
  'message': 'Operation successful',
  'token': 'jwt_token_here',
  'user': {
    'id': 'user_id',
    'firstName': 'John',
    'lastName': 'Doe',
    'email': 'john@example.com',
    // ... other fields
  }
}
```

---

## 📱 Screens Overview

### 1. Splash Screen
- App logo and welcome message
- Checks backend connectivity
- Auto-navigates to Login or Home based on session

### 2. Login Screen
- Email and password input
- Google Sign-In button
- Link to registration screen
- Error handling and loading state

### 3. Register Screen
- Form with: firstName, lastName, email, phone, password
- Password confirmation
- Validation before submission
- Auto-navigates to OTP verification

### 4. OTP Verification Screen
- Shows OTP sent message
- Test OTP display (development only)
- OTP input field
- Auto-navigates to Login on success

### 5. Home Screen
- Displays user welcome message
- Shows account status (email, phone, biometric)
- Enroll Biometrics button
- Settings button
- Logout button

---

## 🧪 Testing

### Manual Testing Checklist

#### Registration Flow
```
1. Tap "Sign up" on login screen
2. Fill registration form:
   - First Name: John
   - Last Name: Doe
   - Email: john@test.com
   - Phone: 9876543210
   - Password: Test@123
   - Confirm: Test@123
3. Tap "Register"
4. Should show OTP verification screen
5. Enter OTP: 123456 (hardcoded for dev)
6. Should navigate to Login screen
7. Success message appears
```

#### Login Flow
```
1. Enter email: john@test.com
2. Enter password: Test@123
3. Tap "Login"
4. Should navigate to Home screen
5. User profile should display
```

#### API Testing with cURL
```bash
# Register
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstName":"John",
    "lastName":"Doe",
    "email":"john@test.com",
    "phone":"9876543210",
    "password":"Test@123",
    "passwordConfirm":"Test@123"
  }'

# Response includes OTP: 123456
```

### Widget Testing (Future)
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/api_service_test.dart

# Run with coverage
flutter test --coverage
```

---

## 📦 Building for Production

### Android Build

#### Create Release Keystore
```bash
# Generate keystore
keytool -genkey -v -keystore ~/key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Create signing properties
# Create android/key.properties:
storePassword=<your_password>
keyPassword=<your_password>
keyAlias=upload
storeFile=/Users/<username>/key.jks
```

#### Build APK
```bash
flutter build apk --split-per-abi

# Output: build/app/outputs/flutter-apk/app-*.apk
```

#### Build App Bundle (for Google Play)
```bash
flutter build appbundle

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS Build

#### Prepare for App Store
```bash
# Build for iOS
flutter build ios --release

# Export to App Store
# Use Xcode or upload via Transporter
```

#### Build IPA for TestFlight
```bash
flutter build ios --release

# Open Xcode and archive
open ios/Runner.xcworkspace
# Product > Archive
```

---

## 🐛 Troubleshooting

### Common Issues

#### "flutter: command not found"
```bash
# Add Flutter to PATH
export PATH="$PATH:$HOME/development/flutter/bin"

# Verify
flutter doctor
```

#### "Cannot connect to API"
```bash
# Check if backend is running
curl http://localhost:5000/health

# For physical device, use your machine's IP:
# API_BASE_URL=http://192.168.1.100:5000/api
```

#### "Android SDK not found"
```bash
# Install Android SDK
flutter doctor --android-licenses

# Or set manually
export ANDROID_HOME=$HOME/Library/Android/sdk
```

#### "CocoaPods error" (iOS)
```bash
cd ios
rm Podfile.lock
cd ..
flutter pub get
flutter run
```

#### "Certificate not found" (iOS)
```bash
# In Xcode:
# 1. Open ios/Runner.xcworkspace
# 2. Select Runner project
# 3. Go to Signing & Capabilities
# 4. Select Team and signing certificate
```

#### "Hot reload not working"
```bash
# Try hot restart
# Press 'R' in terminal (uppercase R)

# Or fully restart
flutter run --restart
```

#### "Build cache issues"
```bash
# Clear build cache
flutter clean
flutter pub get
flutter run
```

---

## 📚 Dependencies

### Main Packages

| Package | Version | Purpose |
|---------|---------|---------|
| provider | 6.0.0 | State management |
| http | 1.1.0 | HTTP requests |
| dio | 5.0.0 | Advanced HTTP (alternative) |
| shared_preferences | 2.0.0 | Local storage |
| flutter_secure_storage | 9.0.0 | Secure storage |
| google_sign_in | 6.1.0 | Google OAuth |
| camera | 0.10.0 | Camera access |
| image_picker | 1.0.0 | Image selection |
| record | 4.2.0 | Audio recording |

---

## 🔐 Security Best Practices

1. **Never commit .env files**
   ```bash
   # Add to .gitignore
   .env
   ```

2. **Use secure storage for tokens**
   ```dart
   await StorageService.saveToken(token);
   final token = await StorageService.getToken();
   ```

3. **Validate all inputs**
   ```dart
   if (email.isEmpty || !email.contains('@')) {
     // Show error
   }
   ```

4. **Handle errors gracefully**
   ```dart
   try {
     await apiService.login(email, password);
   } catch (e) {
     // Show user-friendly error
   }
   ```

5. **Use HTTPS in production**
   ```bash
   # Update .env for production
   API_BASE_URL=https://api.ailens.com/api
   ```

---

## 📝 Next Steps (Day 2)

- [ ] Implement biometric camera screen
- [ ] Implement video recording functionality
- [ ] Create video upload and processing
- [ ] Implement 3D mapping visualization
- [ ] Add voice recording screen
- [ ] Implement biometric comparison
- [ ] Complete Google Sign-In integration
- [ ] Add offline support with local caching

---

## 🔗 Useful Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Flutter Packages](https://pub.dev)
- [Material Design](https://material.io)
- [Dart Documentation](https://dart.dev/guides)
- [Firebase Integration](https://firebase.flutter.dev)

---

## 📞 Support

For help with:
- **Flutter Setup:** See Flutter docs
- **Backend API:** Check [API_DOCUMENTATION.md](../docs/API_DOCUMENTATION.md)
- **Issues:** Check troubleshooting section above

---

**Last Updated:** February 16, 2026
**Status:** Ready for Development
**Next:** Day 2 - Biometric Implementation
