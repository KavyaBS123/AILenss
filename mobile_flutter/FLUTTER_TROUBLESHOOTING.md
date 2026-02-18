# Flutter Troubleshooting Guide

**Version:** 1.0.0  
**Last Updated:** February 16, 2026  
**Platform:** Windows, macOS, Linux

---

## 🆘 Common Issues & Solutions

### 1. Flutter Installation & Setup

#### Issue: "flutter: command not found"
**Symptoms:** Terminal doesn't recognize `flutter` command

**Solutions:**
```bash
# Windows (PowerShell)
# Add Flutter to PATH in Environment Variables
[Environment]::SetEnvironmentVariable(
  "Path",
  "$([Environment]::GetEnvironmentVariable('Path', 'User'));C:\flutter\bin",
  "User"
)

# macOS/Linux
# Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:$HOME/flutter/bin"

# Verify installation
flutter doctor
```

---

#### Issue: "flutter doctor shows errors"
**Symptoms:** `flutter doctor` shows red X marks

**Solutions:**
```bash
# Install Android licenses
flutter doctor --android-licenses

# Install missing components
flutter pub global activate devtools

# Check specific issues
flutter doctor -v  # Verbose output

# Common fixes:
# 1. Android SDK not found
export ANDROID_HOME=$HOME/Library/Android/sdk

# 2. Xcode not found (macOS)
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# 3. Java not found
export JAVA_HOME=$(/usr/libexec/java_home)
```

---

### 2. Project & Dependencies

#### Issue: "Pub get failures"
**Symptoms:** `flutter pub get` fails with network errors

**Solutions:**
```bash
# Clear pub cache
flutter pub cache clean

# Remove pubspec.lock
rm pubspec.lock

# Get dependencies
flutter pub get

# Try with verbose output
flutter pub get -v

# Check internet connection
ping pub.dev

# Use different pub server (China)
PUB_HOSTED_URL=https://pub.flutter-io.cn pubspec.yaml get
```

---

#### Issue: "Version conflicts in dependencies"
**Symptoms:** `version solving failed` error

**Solutions:**
```bash
# Check pubspec.yaml for incompatible versions
# Update to compatible versions:

flutter pub upgrade    # Get latest compatible
flutter pub outdated   # See what needs updating

# Or manually edit pubspec.yaml:
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0        # Use compatible version
  http: ^1.1.0
```

---

#### Issue: "Package depends on unavailable SDK"
**Symptoms:** "doesn't support platform: root"

**Solutions:**
```bash
# Check Flutter/Dart version
flutter --version
dart --version

# Upgrade Flutter
flutter upgrade

# Specific Dart version
flutter channel stable
flutter upgrade

# Remove incompatible packages from pubspec.yaml
# Re-run flutter pub get
```

---

### 3. Building & Running

#### Issue: "App won't start / Black screen"
**Symptoms:** App runs but shows black screen

**Solutions:**
```bash
# Clear build cache
flutter clean

# Full rebuild
flutter clean && flutter pub get && flutter run

# Check main.dart entry point
# Ensure MaterialApp or CupertinoApp is returned

# Check for exceptions in console output
# Use DevTools to inspect UI tree
```

---

#### Issue: "Cannot find emulator"
**Symptoms:** `flutter run` shows "No devices found"

**Solutions:**
```bash
# List available emulators
flutter emulators

# Create emulator (Android)
emulator -list-avds
emulator -avd emulator_name &

# Launch iOS simulator (macOS)
open -a Simulator

# Specify device to run on
flutter run -d emulator-5554

# Or run on physical device
flutter run -d <device-id>
```

---

#### Issue: "Build fails on Android"
**Symptoms:** Gradle build error during `flutter run`

**Solutions:**
```bash
# Update Gradle
cd android
./gradlew wrapper --gradle-version 7.4.2

# Clear Gradle cache
rm -rf ~/.gradle/caches/

# Or in Flutter
flutter clean
flutter pub get

# Build with verbose output
flutter build apk -v

# Check gradle version in android/build.gradle
# Should be: com.android.tools.build:gradle:7.x.x
```

---

### 4. Hot Reload & Debugging

#### Issue: "Hot reload not working"
**Symptoms:** Press 'r' but changes don't appear

**Solutions:**
```bash
# Try hot restart instead (uppercase R)
# This is sometimes necessary

# Check for compilation errors
# Errors prevent hot reload

# Restart the app
flutter run --restart

# If still failing, do full rebuild
flutter clean && flutter run
```

---

#### Issue: "Breakpoints not working"
**Symptoms:** Breakpoints are ignored during debugging

**Solutions:**
```bash
# Run app in debug mode
flutter run

# Make sure app is running in debug mode
# (Not release mode)

# Restart debugger
# In VS Code: Restart (or click Restart button)

# Check pubspec.yaml has debug info
# Run with verbose output:
flutter run -v
```

---

### 5. API & Network Issues

#### Issue: "Cannot connect to backend API"
**Symptoms:** API calls timeout or "Connection refused"

**Solutions:**
```dart
// Check backend is running
// http://localhost:5000/health

// Check API_BASE_URL in .env
API_BASE_URL=http://localhost:5000/api

// For physical device:
// Use machine IP instead of localhost
API_BASE_URL=http://192.168.1.100:5000/api

// Verify your machine IP:
ipconfig getifaddr en0  # macOS
ipconfig                 # Windows
```

```bash
# Test backend from terminal
curl http://localhost:5000/health

# If connection refused:
# 1. Check backend is running
# 2. Check port 5000 is not blocked by firewall
# 3. Restart backend with: npm run dev
```

---

#### Issue: "CORS error when calling API"
**Symptoms:** "Access to XMLHttpRequest blocked by CORS"

**Solutions:**
```bash
# Backend needs CORS configuration
# Check backend/index.js has:

const cors = require('cors');
app.use(cors({
  origin: '*',  // Or specific frontend URL
  credentials: true
}));

# Restart backend after updating
```

---

#### Issue: "SSL Certificate error"
**Symptoms:** "CERTIFICATE_VERIFY_FAILED"

**Solutions:**
```dart
// For development only (NOT production):
final client = HttpClient()
  ..badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;

final response = await client.getUrl(Uri.parse(url));

// For production: Use proper SSL certificates
```

---

### 6. Storage & Permissions

#### Issue: "Cannot save token / SharedPreferences error"
**Symptoms:** Storage operations fail

**Solutions:**
```bash
# Check flutter_secure_storage is properly added
flutter pub add flutter_secure_storage

# For Android, check AndroidManifest.xml has:
<uses-permission android:name="android.permission.INTERNET" />

# For iOS, run pod setup
cd ios && pod install && cd ..
```

---

#### Issue: "App requests permission repeatedly"
**Symptoms:** Camera/microphone permission dialogs show many times

**Solutions:**
```dart
// Implement permission handling
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestCameraPermission() async {
  final status = await Permission.camera.request();
  return status.isGranted;
}

// Only request once on app start
if (!await _alreadyRequested()) {
  await requestCameraPermission();
  await _markRequested();
}
```

---

### 7. UI & Layout Issues

#### Issue: "Overflow/Renderflex error"
**Symptoms:** "RenderFlex overflowed by X pixels"

**Solutions:**
```dart
// Use SingleChildScrollView for scrollable content
SingleChildScrollView(
  child: Column(
    children: [/* widgets */],
  ),
)

// Or use Expanded for flex layout
Row(
  children: [
    Expanded(
      flex: 2,
      child: Container(),
    ),
    Expanded(
      flex: 1,
      child: Container(),
    ),
  ],
)

// Or constrain height
Container(
  height: 100,
  child: ListView(children: [/* items */]),
)
```

---

#### Issue: "Text overflow / Ellipsis not showing"
**Symptoms:** Text runs off screen

**Solutions:**
```dart
// Use Expanded or Flexible
Expanded(
  child: Text(
    longText,
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
  ),
)

// Or use SizedBox
SizedBox(
  width: 200,
  child: Text(
    longText,
    overflow: TextOverflow.ellipsis,
  ),
)
```

---

### 8. State Management Issues

#### Issue: "Widget not rebuilding after state change"
**Symptoms:** notifyListeners() called but UI doesn't update

**Solutions:**
```dart
// Make sure using Consumer or Selector
Consumer<MyProvider>(
  builder: (context, provider, child) {
    return Text(provider.value);
  },
)

// Or use watch method if using Riverpod
final value = ref.watch(myProvider);

// Verify notifyListeners() is called
void updateValue(String newValue) {
  _value = newValue;
  notifyListeners();  // Must call this!
}
```

---

#### Issue: "Multiple rebuilds / infinite loop"
**Symptoms:** Build is called repeatedly

**Solutions:**
```dart
// Don't call notifyListeners() in build()
// Move to setState or separate method

// Don't create new instances in build
// Move to top-level or constructor

// Don't call Provider.of with listen: true in build
final api = Provider.of<ApiService>(context);  // ❌ BAD
final api = Provider.of<ApiService>(context, listen: false);  // ✅ GOOD
```

---

### 9. Navigation Issues

#### Issue: "Navigator not working / App stuck"
**Symptoms:** Navigator.push/pushNamed doesn't navigate

**Solutions:**
```dart
// Make sure context is correct (not stale)
// Use BuildContext from current build

// Check route names are correct
MaterialApp(
  routes: {
    '/login': (context) => LoginScreen(),
    '/home': (context) => HomeScreen(),
  },
  home: SplashScreen(),
)

// Use named routes consistently
Navigator.pushNamed(context, '/login');
```

---

#### Issue: "Back button not working"
**Symptoms:** Back button doesn't navigate back

**Solutions:**
```dart
// Push with replacement doesn't allow back
Navigator.pushReplacement(context, route);  // No back

// Use push for backable navigation
Navigator.push(context, route);  // Has back

// Handle back button
WillPopScope(
  onWillPop: () async {
    // Return true to allow back
    // Return false to prevent back
    return true;
  },
  child: Scaffold(...),
)
```

---

### 10. Performance Issues

#### Issue: "App is slow / Jank/Dropped frames"
**Symptoms:** UI stutters or animation is choppy

**Solutions:**
```bash
# Check performance with DevTools
flutter run -v

# Look for frame times > 16ms

# In code:
// ✅ Use const constructors
const Text('Title')

// ✅ Use ListView.builder for large lists
ListView.builder(itemCount: items.length, ...)

// ✅ Dispose controllers
@override void dispose() {
  _controller.dispose();
  super.dispose();
}

// ❌ DON'T: Create new objects in build
@override Widget build(BuildContext context) {
  final list = items.toList();  // Creates new list on every build
  return ListView(children: list);
}
```

---

### 11. Build Size & Release Issues

#### Issue: "APK/App size too large"
**Symptoms:** Built app is > 50MB

**Solutions:**
```bash
# Build split APKs by architecture
flutter build apk --split-per-abi

# Remove unused code
# In pubspec.yaml:
flutter:
  uses-material-design: true

# Bundle app (Play Store format, smaller)
flutter build appbundle

# Analyze APK size
flutter build apk --analyze-size
```

---

#### Issue: "Release build crashes"
**Symptoms:** Works in debug but fails in release

**Solutions:**
```bash
# Often due to code obfuscation
# Test release mode locally first:
flutter run --release

# Check logs for specific errors
flutter logs -rF  # Filter for release crashes

# Disable obfuscation temporarily to debug:
flutter build apk --no-obfuscate

# Verify all assets are included
flutter build apk --verbose
```

---

## 🔧 Debug Tools

### VS Code Debugging
```bash
# Start with debugger
flutter run

# Then in .vscode/launch.json:
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter App",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "console": "integratedTerminal"
    }
  ]
}
```

### Flutter DevTools
```bash
# Open DevTools in browser
flutter pub global activate devtools
devtools

# Or run with app
flutter run --devtools-server-address=http://localhost:9100
```

### Logs & Debugging
```bash
# View logs
flutter logs

# Clear logs
flutter logs -c

# Specific device
flutter logs -d device-id

# Print debugging info
import 'dart:developer';
log('Debug message', name: 'MyApp');
```

---

## 📞 Getting Help

1. **Check Official Docs:** https://flutter.dev/docs
2. **Search StackOverflow:** `flutter` tag
3. **GitHub Issues:** https://github.com/flutter/flutter/issues
4. **Flutter Community:** https://flutter.dev/community
5. **Local Backend Docs:** [API_DOCUMENTATION.md](../docs/API_DOCUMENTATION.md)

---

**Last Updated:** February 16, 2026  
**Status:** Comprehensive Troubleshooting Guide
