# Flutter Quick Reference Guide

**Last Updated:** February 16, 2026

---

## ⚡ Quick Commands

### Setup & Installation
```bash
# Install Flutter dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Get specific package info
flutter pub show <package_name>
```

### Development
```bash
# Run app on emulator/device
flutter run

# Run with verbose output
flutter run -v

# Hot reload (during development)
Press 'r' in terminal

# Hot restart
Press 'R' in terminal

# Stop app
Press 'q' in terminal
```

### Building
```bash
# Build APK for Android
flutter build apk --split-per-abi

# Build iOS release
flutter build ios --release

# Check build info
flutter build apk --analyze-size
```

### Code Quality
```bash
# Format code
dart format lib/

# Analyze code
dart analyze

# Run tests
flutter test

# Generate coverage
flutter test --coverage
```

---

## 📁 File Structure Quick Reference

```
mobile_flutter/
├── lib/
│   ├── main.dart                     # App entry point
│   ├── screens/                      # Full screens
│   │   ├── splash_screen.dart       # Splash/loading
│   │   ├── login_screen.dart        # Login page
│   │   ├── register_screen.dart     # Registration page
│   │   └── home_screen.dart         # Home/dashboard
│   ├── services/
│   │   └── api_service.dart         # API calls
│   ├── models/
│   │   └── user.dart                # User model
│   ├── utils/
│   │   └── storage_service.dart     # Token storage
│   └── widgets/                      # Reusable components
├── pubspec.yaml                      # Dependencies
├── .env                              # Configuration
└── .env.example                      # Config template
```

---

## 🔑 Code Snippets

### API Call Example
```dart
// Get from Provider
final apiService = Provider.of<ApiService>(context, listen: false);

// Login
final result = await apiService.login(
  email: 'user@example.com',
  password: 'password123',
);

// Save token
await StorageService.saveToken(result['token']);

// Show error
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Error: $e')),
);
```

### State Management
```dart
// Watch state changes
Consumer<ApiService>(
  builder: (context, api, _) {
    return Text(api.baseUrl);
  },
)

// Get without rebuild
final api = Provider.of<ApiService>(
  context,
  listen: false,
);
```

### Form Validation
```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: TextFormField(
    validator: (value) {
      if (value?.isEmpty ?? true) return 'Required';
      return null;
    },
  ),
)

// Check validation
if (_formKey.currentState!.validate()) {
  // Valid form
}
```

### Navigation
```dart
// Navigate to screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => NextScreen()),
);

// Replace current screen
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => NextScreen()),
);

// Go back
Navigator.pop(context);
```

---

## 🐛 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| App won't start | Run `flutter clean && flutter pub get && flutter run` |
| Hot reload not working | Press 'R' (uppercase) for hot restart |
| Cannot connect to API | Check API_BASE_URL in .env and backend running |
| Emulator won't start | Check Android SDK installation with `flutter doctor` |
| Build fails | Clear cache: `flutter clean` then rebuild |
| Dependency error | Run `flutter pub get` or `flutter pub upgrade` |
| State not updating | Check `notifyListeners()` is called in Provider |
| Back button not working | Use `Navigator.push` (not `pushReplacement`) |

---

## 📱 UI Components Quick Ref

### Navigation
```dart
// Bottom navigation
BottomNavigationBar(
  currentIndex: _index,
  onTap: (i) => setState(() => _index = i),
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.profile), label: 'Profile'),
  ],
)
```

### Forms
```dart
// Text input
TextFormField(
  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
  obscureText: true,  // For passwords
  keyboardType: TextInputType.email,
)

// Button
ElevatedButton(
  onPressed: _handleSubmit,
  child: Text('Submit'),
)
```

### Layout
```dart
// Scrollable column
SingleChildScrollView(
  child: Column(children: [...]),
)

// Row with space distribution
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [...],
)

// Expanded flex layout
Row(
  children: [
    Expanded(flex: 2, child: Container()),
    Expanded(flex: 1, child: Container()),
  ],
)
```

### Display
```dart
// Card
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Content'),
  ),
)

// Divider
Divider(height: 1)

// Circular loader
CircularProgressIndicator()

// List
ListView.builder(
  itemCount: items.length,
  itemBuilder: (ctx, i) => Text(items[i]),
)
```

---

## 🔐 Security Quick Tips

```dart
// ✅ Store tokens securely
await StorageService.saveToken(token);

// ✅ Validate inputs
if (email.contains('@')) { /* valid */ }

// ✅ Handle errors gracefully
try {
  await apiCall();
} catch (e) {
  showError(e.toString());
}

// ✅ Clear tokens on logout
await StorageService.clearToken();

// ❌ DON'T log sensitive data
print(token);  // BAD
```

---

## 📝 Environment Variables

**Set in mobile_flutter/.env:**

```
API_BASE_URL=http://localhost:5000/api
API_TIMEOUT_SECONDS=30
APP_NAME=AILens
DEBUG=true
GOOGLE_CLIENT_ID=your_id
GOOGLE_CLIENT_SECRET=your_secret
```

### Access in code:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000/api';
```

---

## 🔗 API Endpoints Summary

```
POST   /api/auth/register           - Register
POST   /api/auth/verify-otp         - Verify OTP
POST   /api/auth/login              - Login
POST   /api/auth/google             - Google login
GET    /api/auth/me                 - Get profile
POST   /api/auth/logout             - Logout
```

**Test Credentials:**
- Email: test@example.com
- Password: Test@123
- OTP: 123456

---

## 📚 Key Files

| File | Purpose |
|------|---------|
| [main.dart](lib/main.dart) | App entry point |
| [api_service.dart](lib/services/api_service.dart) | API calls |
| [storage_service.dart](lib/utils/storage_service.dart) | Token storage |
| [user.dart](lib/models/user.dart) | User model |
| [login_screen.dart](lib/screens/login_screen.dart) | Login page |
| [register_screen.dart](lib/screens/register_screen.dart) | Registration |
| [home_screen.dart](lib/screens/home_screen.dart) | Home page |

---

## 🎨 Theme & Colors

**Primary Color:** Deep Purple (RGB: 103, 58, 183)
**Accent Color:** Light Blue

Set in main.dart:
```dart
theme: ThemeData(
  primaryColor: Colors.deepPurple,
  useMaterial3: true,
)
```

---

## 📲 Testing Flows

### Registration
```
1. Tap "Sign Up"
2. Fill: First Name, Last Name, Email, Phone, Password
3. Tap "Register"
4. OTP screen appears (OTP: 123456)
5. Enter OTP
6. Redirects to Login
```

### Login
```
1. Enter registered email
2. Enter password
3. Tap "Login"
4. Navigate to Home screen
5. User data displays
```

### Logout
```
1. On Home screen, tap "Logout"
2. Token cleared
3. Navigate to Login screen
```

---

## 🆘 Getting Help

### Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Material Design](https://material.io)

### Local Documentation
- [FLUTTER_SETUP.md](FLUTTER_SETUP.md) - Installation guide
- [FLUTTER_DEVELOPMENT_GUIDE.md](FLUTTER_DEVELOPMENT_GUIDE.md) - Best practices
- [FLUTTER_API_REFERENCE.md](FLUTTER_API_REFERENCE.md) - API details
- [FLUTTER_TROUBLESHOOTING.md](FLUTTER_TROUBLESHOOTING.md) - Problem solving

### Debug Commands
```bash
# Check device info
flutter devices

# Run with debugger
flutter run

# View problems
flutter doctor -v

# Clear everything
flutter clean
```

---

## 💡 Pro Tips

1. **Use hot reload frequently** - Press 'r' to test changes quickly
2. **Always run `flutter pub get`** - After editing pubspec.yaml
3. **Check .env variables** - Most issues are config-related
4. **Use Provider patterns** - Makes state management clean
5. **Test on real device** - Emulator behavior may differ
6. **Keep UI simple** - Users prefer clean interfaces
7. **Handle errors gracefully** - Show user-friendly messages
8. **Test API calls first** - Use cURL before testing in app

---

## 🚀 Development Workflow

```
1. Make code changes
2. Press 'r' for hot reload
3. Test in emulator/device
4. Check console for errors
5. Fix issues
6. Repeat until satisfied
7. Run: dart format lib/
8. Run: dart analyze
9. Commit code: git add . && git commit -m "message"
```

---

## 📋 Checklist for Common Tasks

### Adding New Dependency
- [ ] Add to pubspec.yaml
- [ ] Run `flutter pub get`
- [ ] Import in code
- [ ] Use in implementation

### Adding New Screen
- [ ] Create file in lib/screens/
- [ ] Extend StatelessWidget or StatefulWidget
- [ ] Import dependencies
- [ ] Add navigation route in main.dart
- [ ] Test navigation

### Adding New API Endpoint
- [ ] Add method to ApiService
- [ ] Add error handling
- [ ] Test with curl first
- [ ] Test in app

### Troubleshooting Issue
- [ ] Read error message carefully
- [ ] Check .env configuration
- [ ] Verify backend is running
- [ ] Clear cache: flutter clean
- [ ] Check Flutter doctor
- [ ] Restart emulator
- [ ] Check documentation
- [ ] Try hot restart

---

**Quick Links:**
- [Backend API Docs](../../docs/API_DOCUMENTATION.md)
- [Setup Guide](FLUTTER_SETUP.md)
- [Development Guide](FLUTTER_DEVELOPMENT_GUIDE.md)
- [Troubleshooting](FLUTTER_TROUBLESHOOTING.md)

---

**Last Updated:** February 16, 2026
