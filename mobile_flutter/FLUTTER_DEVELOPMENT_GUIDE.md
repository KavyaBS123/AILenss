# Flutter Development Guide

**Version:** 1.0.0  
**Last Updated:** February 16, 2026  
**Target Audience:** Flutter Developers

---

## 📋 Table of Contents

1. [Development Setup](#development-setup)
2. [Project Architecture](#project-architecture)
3. [State Management](#state-management)
4. [Widget Development](#widget-development)
5. [Screen Implementation](#screen-implementation)
6. [API Integration](#api-integration)
7. [Best Practices](#best-practices)
8. [Testing & Debugging](#testing--debugging)
9. [Performance Optimization](#performance-optimization)
10. [Common Patterns](#common-patterns)

---

## 🚀 Development Setup

### IDE Configuration

#### VS Code
```json
// .vscode/settings.json
{
  "dart.sdk": "/path/to/flutter/bin/cache/dart-sdk",
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll": "explicit"
    }
  }
}
```

#### Android Studio
- Install Flutter plugin
- Install Dart plugin
- Set Flutter SDK path: Settings > Languages & Frameworks > Flutter

### Development Workflow
```bash
# Terminal 1: Run Flutter app with hot reload
flutter run

# Terminal 2: Run tests
flutter test --watch

# Check code quality
dart analyze

# Format code
dart format lib/
```

---

## 🏗️ Project Architecture

### Folder Structure
```
lib/
├── main.dart                 # Application entry point
│
├── screens/                  # Full-page UI
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   └── home_screen.dart
│
├── services/                 # Business logic
│   ├── api_service.dart      # API communication
│   └── database_service.dart # (Future)
│
├── models/                   # Data structures
│   ├── user.dart
│   └── models.dart
│
├── widgets/                  # Reusable UI components
│   ├── custom_button.dart
│   ├── custom_input.dart
│   └── status_card.dart
│
├── utils/                    # Utility functions
│   ├── storage_service.dart
│   ├── constants.dart
│   └── validators.dart
│
└── constants/                # Application constants
    ├── colors.dart
    ├── strings.dart
    └── dimensions.dart
```

### Architecture Pattern: MVVM-like
```
UI (Screens) 
    ↓
Provider (State Management)
    ↓
Services (Business Logic)
    ↓
Models (Data)
    ↓
Backend API
```

---

## 🎯 State Management

### Using Provider Package

#### Simple Provider (Value)
```dart
// Define in main.dart
MultiProvider(
  providers: [
    Provider<ApiService>(create: (_) => ApiService()),
  ],
  child: MyApp(),
)

// Use in widget
final apiService = Provider.of<ApiService>(context, listen: false);
```

#### ChangeNotifier (Reactive)
```dart
// Create a notifier
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // API call
      final result = await apiService.login(email, password);
      _user = User.fromJson(result['user']);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}

// Register in main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
  ],
  child: MyApp(),
)

// Use in widget
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Center(
          child: authProvider.isLoading
              ? CircularProgressIndicator()
              : LoginForm(authProvider: authProvider),
        );
      },
    );
  }
}
```

#### Best Practices
```dart
// ✅ DO: Use Consumer for rebuilds
Consumer<ApiService>(
  builder: (context, api, _) {
    return Text('Using ${api.baseUrl}');
  },
)

// ❌ DON'T: Use Provider.of with listen=true in build
// This rebuilds the entire widget on every change
final api = Provider.of<ApiService>(context);

// ✅ DO: Use listen=false for single operations
final api = Provider.of<ApiService>(context, listen: false);
await api.login(email, password);
```

---

## 🧩 Widget Development

### Creating Reusable Widgets

#### Custom Button
```dart
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;

  const CustomButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.deepPurple,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(label),
    );
  }
}

// Usage
CustomButton(
  label: 'Login',
  isLoading: isLoading,
  onPressed: _handleLogin,
)
```

#### Custom Input Field
```dart
class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  const CustomTextField({
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText && !_showPassword,
          decoration: InputDecoration(
            hintText: widget.hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _showPassword = !_showPassword);
                    },
                  )
                : widget.suffixIcon,
          ),
        ),
      ],
    );
  }
}

// Usage
CustomTextField(
  label: 'Email',
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Email required';
    if (!value!.contains('@')) return 'Invalid email';
    return null;
  },
)
```

---

## 📱 Screen Implementation

### Complete Login Screen Example
```dart
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      
      final result = await apiService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Save token
      await StorageService.saveToken(result['token']);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 32),
                // Logo
                Icon(Icons.security, size: 80, color: Colors.deepPurple),
                SizedBox(height: 32),
                // Form
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: Validators.validatePassword,
                ),
                SizedBox(height: 24),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: 'Login',
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),
                ),
                SizedBox(height: 16),
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 🔌 API Integration

### Implementing API Calls

```dart
class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        timeout: Duration(seconds: 30),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw data['message'] ?? 'Unknown error occurred';
      }
    } catch (e) {
      throw 'Failed to parse response: $e';
    }
  }

  dynamic _handleError(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection';
    } else if (error is TimeoutException) {
      return 'Request timed out';
    } else {
      return error.toString();
    }
  }
}
```

---

## ✅ Best Practices

### Code Style
```dart
// ✅ Proper formatting
class MyWidget extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const MyWidget({
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(title),
    );
  }
}

// ✅ Use const constructors
const SizedBox(height: 16)

// ✅ Proper imports
import 'package:flutter/material.dart';
import 'services/api_service.dart';

// ❌ Wildcard imports
import 'services/*';
```

### Error Handling
```dart
// ✅ Comprehensive error handling
try {
  final result = await apiService.login(email, password);
  await StorageService.saveToken(result['token']);
  Navigator.pushReplacementNamed(context, '/home');
} on TimeoutException {
  _showError('Request timed out');
} on SocketException {
  _showError('No internet connection');
} catch (e) {
  _showError('Unexpected error: $e');
}

// ✅ Null safety
String? name;
print(name?.length); // Safe access
```

### Performance
```dart
// ✅ Use const widgets
const Text('Title')

// ✅ Dispose controllers
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// ✅ Use SingleChildScrollView for overflow
SingleChildScrollView(
  child: Column(...),
)
```

---

## 🧪 Testing & Debugging

### Widget Testing
```dart
void main() {
  testWidgets('Login button navigation', (tester) async {
    await tester.pumpWidget(MyApp());

    // Find button
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Tap button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify navigation
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
```

### Debugging Tools
```bash
# Hot reload
r

# Hot restart
R

# Show grid
g

# Show type information
w

# Quit
q
```

### Logging
```dart
import 'package:logger/logger.dart';

final logger = Logger();

logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message', error: e, stackTrace: stackTrace);
```

---

## ⚡ Performance Optimization

### Efficient Rendering
```dart
// ✅ Use ListView.builder for large lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
)

// ❌ DON'T use Column with many children
Column(
  children: List.generate(1000, (i) => Text('Item $i')),
)
```

### Reduce Rebuilds
```dart
// ✅ Use const widgets
const SizedBox(height: 16)

// ✅ Use Consumer selector
Selector<ApiService, String>(
  selector: (_, api) => api.baseUrl,
  builder: (_, baseUrl, __) => Text(baseUrl),
)

// ❌ DON'T rebuild entire widget
Consumer<ApiService>(
  builder: (_, api, __) {
    // This rebuilds when ANY property changes
    return Text(api.baseUrl);
  },
)
```

---

## 🔄 Common Patterns

### Authentication Pattern
```dart
Future<void> checkAuthStatus(BuildContext context) async {
  final token = await StorageService.getToken();
  
  if (token == null) {
    Navigator.pushReplacementNamed(context, '/login');
  } else {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.getCurrentUser(token);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
```

### Form Validation Pattern
```dart
class FormValidator {
  static String? email(String? value) {
    if (value?.isEmpty ?? true) return 'Required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
      return 'Invalid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value?.isEmpty ?? true) return 'Required';
    if (value!.length < 6) return 'Min 6 characters';
    return null;
  }
}
```

### Loading State Pattern
```dart
// Using state
bool _isLoading = false;

// Using provider
class LoadingProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
```

---

## 📚 Resources

- [Official Flutter Docs](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)
- [Material Design](https://material.io/design)

---

**Last Updated:** February 16, 2026  
**Status:** Ready for Development
