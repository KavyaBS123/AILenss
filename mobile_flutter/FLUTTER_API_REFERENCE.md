# Flutter API Reference Guide

**Version:** 1.0.0  
**Last Updated:** February 16, 2026  
**Language:** Dart

---

## 📋 Table of Contents

1. [API Service Overview](#api-service-overview)
2. [Authentication Endpoints](#authentication-endpoints)
3. [Response Format](#response-format)
4. [Error Handling](#error-handling)
5. [Code Examples](#code-examples)
6. [Token Management](#token-management)

---

## 🔧 API Service Overview

The `ApiService` in `lib/services/api_service.dart` provides a clean interface to the AILens backend API.

### Configuration
```dart
// Accessed via Provider
final apiService = Provider.of<ApiService>(context, listen: false);
```

### Base URL
```
http://localhost:5000/api
```

---

## 🔐 Authentication Endpoints

### 1. Register

**Function:**
```dart
Future<Map<String, dynamic>> register({
  required String firstName,
  required String lastName,
  required String email,
  required String phone,
  required String password,
  required String passwordConfirm,
})
```

**Request Body:**
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "phone": "9876543210",
  "password": "Password@123",
  "passwordConfirm": "Password@123"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "User registered successfully. OTP sent to email.",
  "otp": "123456",
  "email": "john@example.com",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Email already registered"
}
```

**Usage:**
```dart
try {
  final result = await apiService.register(
    firstName: 'John',
    lastName: 'Doe',
    email: 'john@example.com',
    phone: '9876543210',
    password: 'Password@123',
    passwordConfirm: 'Password@123',
  );

  print('Registered! OTP: ${result['otp']}');
  // Navigate to OTP verification screen
} catch (e) {
  print('Registration failed: $e');
  // Show error to user
}
```

---

### 2. Verify OTP

**Function:**
```dart
Future<Map<String, dynamic>> verifyOTP({
  required String email,
  required String otp,
})
```

**Request Body:**
```json
{
  "email": "john@example.com",
  "otp": "123456"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "OTP verified successfully",
  "email": "john@example.com"
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Invalid or expired OTP"
}
```

**Usage:**
```dart
try {
  final result = await apiService.verifyOTP(
    email: 'john@example.com',
    otp: '123456',
  );
  
  print('OTP verified!');
  // Navigate to login screen
} catch (e) {
  print('OTP verification failed: $e');
}
```

---

### 3. Login

**Function:**
```dart
Future<Map<String, dynamic>> login({
  required String email,
  required String password,
})
```

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "Password@123"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "phone": "9876543210",
    "isEmailVerified": true,
    "isPhoneVerified": false,
    "isBiometricEnrolled": false,
    "profilePhotoUrl": null,
    "bio": ""
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

**Account Locked Response (429):**
```json
{
  "success": false,
  "message": "Account locked. Try again after 2 hours"
}
```

**Usage:**
```dart
try {
  final result = await apiService.login(
    email: 'john@example.com',
    password: 'Password@123',
  );

  final token = result['token'];
  final user = result['user'];

  // Save token securely
  await StorageService.saveToken(token);
  await StorageService.saveUserData(user);

  // Navigate to home screen
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => HomeScreen()),
    (route) => false,
  );
} catch (e) {
  print('Login failed: $e');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Login failed: $e')),
  );
}
```

---

### 4. Login with Google

**Function:**
```dart
Future<Map<String, dynamic>> loginWithGoogle({
  required String token,
})
```

**Request Body:**
```json
{
  "token": "google_id_token_here"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Google login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "507f1f77bcf86cd799439012",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@gmail.com",
    "isEmailVerified": true,
    "isBiometricEnrolled": false
  }
}
```

**Usage:**
```dart
// Note: Google Sign-In integration is a future feature
// This implementation shows the expected API usage

try {
  final result = await apiService.loginWithGoogle(
    token: googleToken,
  );

  final token = result['token'];
  await StorageService.saveToken(token);
  
  // Navigate to home
} catch (e) {
  print('Google login failed: $e');
}
```

---

### 5. Get Current User

**Function:**
```dart
Future<Map<String, dynamic>> getCurrentUser(String token)
```

**Request Header:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Success Response (200):**
```json
{
  "success": true,
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "phone": "9876543210",
    "isEmailVerified": true,
    "isPhoneVerified": false,
    "isBiometricEnrolled": false,
    "profilePhotoUrl": "https://s3.amazonaws.com/ailens-bucket/profiles/507f1f77bcf86cd799439011",
    "bio": "AI Biometric Authentication Enthusiast",
    "createdAt": "2026-02-16T10:30:00.000Z",
    "updatedAt": "2026-02-16T10:30:00.000Z"
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "message": "Token expired or invalid"
}
```

**Usage:**
```dart
try {
  final token = await StorageService.getToken();
  
  if (token != null) {
    final result = await apiService.getCurrentUser(token);
    final user = User.fromJson(result['user']);
    
    setState(() {
      _user = user;
    });
  } else {
    // No token, redirect to login
    Navigator.pushReplacementNamed(context, '/login');
  }
} catch (e) {
  print('Failed to fetch user: $e');
  // Token might be expired, clear and redirect to login
  await StorageService.clearToken();
  Navigator.pushReplacementNamed(context, '/login');
}
```

---

### 6. Logout

**Function:**
```dart
Future<Map<String, dynamic>> logout(String token)
```

**Request Header:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Logout successful"
}
```

**Usage:**
```dart
try {
  final token = await StorageService.getToken();
  
  if (token != null) {
    await apiService.logout(token);
  }

  // Clear all stored data
  await StorageService.clearAll();

  // Navigate to login
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => LoginScreen()),
    (route) => false,
  );
} catch (e) {
  print('Logout error: $e');
  // Still clear data and redirect even if API call fails
  await StorageService.clearAll();
  Navigator.pushReplacementNamed(context, '/login');
}
```

---

## 📋 Response Format

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {}  // Optional additional data
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "code": "ERROR_CODE"  // Optional
}
```

---

## ⚠️ Error Handling

### HTTP Status Codes
| Code | Meaning | Action |
|------|---------|--------|
| 200 | OK | Success |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Check input validation |
| 401 | Unauthorized | Invalid/expired token, redirect to login |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 429 | Too Many Requests | Rate limited or account locked |
| 500 | Server Error | Server-side error |

### Error Handling Pattern
```dart
Future<void> safeLaunchAPI<T>(
  Future<T> Function() apiCall,
  Function(T) onSuccess,
  Function(String) onError,
) async {
  try {
    final response = await apiCall();
    onSuccess(response);
  } on SocketException {
    onError('No internet connection');
  } on TimeoutException {
    onError('Request timed out');
  } on FormatException {
    onError('Invalid response format');
  } catch (e) {
    onError('Error: $e');
  }
}
```

---

## 💻 Code Examples

### Complete Registration Flow
```dart
class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      
      final result = await apiService.register(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        passwordConfirm: _confirmPasswordController.text,
      );

      // Navigate to OTP verification
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPVerificationScreen(
            email: _emailController.text,
            generatedOTP: result['otp'],
            token: result['token'],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Account')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Form fields...
            ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Authentication Validator
```dart
class AuthValidator {
  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email is required';
    }
    if (!value!.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Password is required';
    }
    if (value!.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Phone is required';
    }
    if (value!.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validatePasswordMatch(
    String password,
    String confirm,
  ) {
    if (password != confirm) {
      return 'Passwords do not match';
    }
    return null;
  }
}
```

---

## 🔑 Token Management

### Saving Token
```dart
final result = await apiService.login(email, password);
final token = result['token'];

// Save securely
await StorageService.saveToken(token);

// Also save user data
await StorageService.saveUserData(result['user']);
```

### Retrieving Token
```dart
final token = await StorageService.getToken();

if (token != null) {
  // Use token for authenticated requests
  final user = await apiService.getCurrentUser(token);
} else {
  // No token, redirect to login
  Navigator.pushReplacementNamed(context, '/login');
}
```

### Clearing Token
```dart
// On logout or token expiration
await StorageService.clearToken();

// Or clear all data
await StorageService.clearAll();
```

### Token Expiration
```dart
// Token expires in 7 days (604800 seconds)
// Implement automatic re-login prompts:

Future<void> _checkTokenExpiration() async {
  final token = await StorageService.getToken();
  
  if (token == null) {
    // Navigate to login
    Navigator.pushReplacementNamed(context, '/login');
    return;
  }

  try {
    // Try to fetch user
    await apiService.getCurrentUser(token);
  } on Exception {
    // Token might be expired
    await StorageService.clearToken();
    Navigator.pushReplacementNamed(context, '/login');
  }
}
```

---

## 🔐 Security Best Practices

1. **Never log tokens**
   ```dart
   // ❌ DON'T
   print('Token: $token');

   // ✅ DO
   print('Token saved securely');
   ```

2. **Always use HTTPS in production**
   ```dart
   // .env
   API_BASE_URL=https://api.ailens.com/api
   ```

3. **Validate inputs before sending**
   ```dart
   if (_formKey.currentState!.validate()) {
     // Safe to proceed with API call
   }
   ```

4. **Handle expired tokens gracefully**
   ```dart
   try {
     final result = await apiService.getCurrentUser(token);
   } catch (e) {
     if (e.toString().contains('401')) {
       // Redirect to login
     }
   }
   ```

---

## 📞 Support

For issues or questions:
1. Check the troubleshooting section in [FLUTTER_SETUP.md](FLUTTER_SETUP.md)
2. Review backend API docs: [API_DOCUMENTATION.md](../docs/API_DOCUMENTATION.md)
3. Check implementation examples above

---

**Last Updated:** February 16, 2026  
**Status:** Ready for Development
