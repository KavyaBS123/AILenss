# Secure Storage & Environment Configuration Guide

## Table of Contents
1. [Overview](#overview)
2. [Backend Setup](#backend-setup)
3. [Frontend Setup](#frontend-setup)
4. [Security Best Practices](#security-best-practices)
5. [Troubleshooting](#troubleshooting)

## Overview

AILens uses a multi-layered security approach:

- **Backend**: Environment variables (`.env` file) for all sensitive configuration
- **Frontend**: Flutter Secure Storage for encrypted local storage of tokens and user data
- **Database**: SQLite with proper connection string management
- **API**: JWT tokens with secure storage

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                     AILens Application                   │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌────────────────┐              ┌─────────────────┐   │
│  │  Flutter App   │              │  FastAPI Server │   │
│  │  (Mobile)      │◄────HTTP────►│  (Backend)      │   │
│  └────────────────┘              └─────────────────┘   │
│        ▲                                 ▲              │
│        │                                 │              │
│        ├─ SecureConfig                   ├─ .env file  │
│        │  (Keychain/Keystore)            │  (OS level) │
│        │                                 │              │
│        └─ Secure Storage                 └─ Database   │
│           (Flutter Secure Storage)         Connection   │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

## Backend Setup

### Step 1: Create Environment File

```bash
cd backend_fastapi
cp .env.example .env
```

### Step 2: Configure Sensitive Values

Edit `.env` with your actual configuration:

```bash
# Security - Use a strong random key
SECRET_KEY=lKA4KzGkKGaJHHJ0rvJPoUVl5cCTsYOj13GDVCEGgNU

# Database URL
DATABASE_URL=sqlite:///./ailens.db

# OTP Settings
OTP_EXPIRY_MINUTES=10
OTP_LENGTH=6

# File Storage
UPLOAD_DIR=./uploads
MAX_UPLOAD_SIZE_MB=50

# Biometric Quality Thresholds
FACE_MIN_QUALITY_SCORE=0.8
VOICE_MIN_QUALITY_SCORE=0.75
```

### Step 3: Verify Configuration

```python
from app.core.config import settings

print(f"API Base: {settings.API_STR}")
print(f"Database: {settings.DATABASE_URL}")
print(f"Debug Mode: {settings.DEBUG}")
print(f"Upload Directory: {settings.UPLOAD_DIR}")
```

### Step 4: Initialize Storage

```bash
python -c "from app.core.file_storage import FileStorageManager; FileStorageManager.initialize()"
```

## Frontend Setup

### Step 1: Create Flutter Environment File

```bash
cd mobile_flutter
cp .env.example .env
```

### Step 2: Configure API Endpoints

Edit `.env`:

```env
# Development
FLUTTER_ENV=development
API_BASE_URL=http://10.0.2.2:5000/api

# For physical devices
# API_BASE_URL=http://192.168.x.x:5000/api

# Production
# API_BASE_URL=https://api.ailens.com/api
```

### Step 3: Initialize Configuration in Code

In `main.dart`, configuration is automatically initialized:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file
  await dotenv.load(fileName: '.env');
  
  // Initialize AppConfig from environment variables
  await AppConfig.initialize();
  AppConfig.instance.logConfiguration();
  
  runApp(const AILensApp());
}
```

### Step 4: Use Secure Storage in Your Code

```dart
import 'utils/secure_config.dart';

// Save token after authentication
await SecureConfig.saveAuthToken(token);
await SecureConfig.saveUserId(userId);

// Retrieve token when needed
String? token = await SecureConfig.getAuthToken();

// Check authentication status
bool isAuth = await SecureConfig.isAuthenticated();

// Logout - clear all data
await SecureConfig.clearAll();
```

## Security Best Practices

### ✅ DO THIS

#### Backend
```python
# Load from environment variables
from app.core.config import settings

database_url = settings.DATABASE_URL
secret_key = settings.SECRET_KEY
api_timeout = settings.ACCESS_TOKEN_EXPIRE_MINUTES

# Never hard-code secrets
# Never log sensitive data
logger.info(f"Database connected")  # Good
# logger.info(f"Connected to {database_url}")  # BAD!
```

#### Frontend
```dart
// Use SecureConfig for sensitive data
await SecureConfig.saveAuthToken(token);

// Use AppConfig for non-sensitive settings
String apiUrl = AppConfig.instance.apiUrl;

// Check authentication before API calls
bool isAuth = await SecureConfig.isAuthenticated();
if (isAuth) {
  String? token = await SecureConfig.getAuthToken();
  // Use token in API request
}
```

### ❌ DON'T DO THIS

**Backend:**
```python
# ❌ Hard-coded secrets
DATABASE_URL = "sqlite:///./ailens.db"
SECRET_KEY = "my-secret-key"

# ❌ Logging sensitive data
print(f"Database URL: {database_url}")
logger.debug(f"Token: {auth_token}")

# ❌ Storing passwords
user_password = "password123"
```

**Frontend:**
```dart
// ❌ Hard-coded API endpoints
const String API_URL = "http://localhost:5000/api";

// ❌ Storing tokens in SharedPreferences (unencrypted)
await prefs.setString('token', token);

// ❌ Logging sensitive data
print('Token: $token');

// ❌ Storing passwords
await storage.write(key: 'password', value: userPassword);
```

## Credential Management

### Adding New Secrets

When adding a new sensitive configuration:

1. **Add to `.env.example`**:
   ```env
   NEW_SECRET_KEY=example_value
   ```

2. **Add to `config.py`**:
   ```python
   NEW_SECRET_KEY: str = os.getenv("NEW_SECRET_KEY", "default")
   ```

3. **Update actual `.env`** (don't commit):
   ```env
   NEW_SECRET_KEY=actual_secure_value
   ```

4. **Use in code**:
   ```python
   from app.core.config import settings
   my_secret = settings.NEW_SECRET_KEY
   ```

### Rotating Secrets

**In Development:**
```bash
# 1. Generate new secret
python -c "import secrets; print(secrets.token_urlsafe(32))"

# 2. Update .env
SECRET_KEY=new_secret_value

# 3. Restart server
```

**In Production:**
```bash
# 1. Update SECRET_KEY in .env on production server
# 2. Restart application
# 3. Old tokens become invalid (users re-login)
# 4. Set REFRESH_TOKEN_EXPIRE_DAYS=0 during transition
```

## File Storage

### Uploading Files Securely

```python
from app.core.file_storage import FileStorageManager

# Save face biometric
success, result = await FileStorageManager.save_face_biometric(
    user_id="user123",
    file_content=bytes_data,
    original_filename="photo.jpg"
)

if success:
    file_path = result  # "faces/user123_face_20240116_120000.jpg"
else:
    error = result  # Error message
```

### File Storage Structure

```
uploads/
├── faces/
│   ├── user123_face_20240116_120000.jpg
│   ├── user123_face_20240116_130000.jpg
│   └── user456_face_20240116_120030.jpg
│
├── voices/
│   ├── user123_voice_20240116_120000.wav
│   ├── user123_voice_20240116_130000.wav
│   └── user456_voice_20240116_120030.wav
│
└── temp/
    └── [temporary processing files]
```

### File Retention Policy

```python
# Delete files older than 30 days
deleted_count = FileStorageManager.cleanup_old_files(days=30)
print(f"Deleted {deleted_count} old files")

# Delete all files for a user
FileStorageManager.delete_user_files(user_id="user123")

# Get storage statistics
stats = FileStorageManager.get_storage_stats()
print(f"Total storage: {stats['total_size_mb']} MB")
print(f"Face files: {stats['face_files']}")
print(f"Voice files: {stats['voice_files']}")
```

## Troubleshooting

### Issue: "KeyError: 'SECRET_KEY'"
**Cause**: `.env` file not loaded
**Solution**:
```bash
# Check .env file exists
ls backend_fastapi/.env

# Ensure it has content
cat backend_fastapi/.env

# Restart server
python main.py
```

### Issue: Secure Storage Not Working on Android
**Cause**: Android Keystore not available
**Solution**:
```dart
// Add to AndroidManifest.xml
<uses-permission android:name="android.permission.USE_CREDENTIALS" />

// Clear app data
adb shell pm clear com.example.ailens
```

### Issue: API URL Not Loading from .env
**Cause**: `.env` file not mapped in Flutter
**Solution**:
```yaml
# Update pubspec.yaml
flutter_dotenv:
  files:
    - .env
```

### Issue: "Database connection refused"
**Cause**: Wrong DATABASE_URL in .env
**Solution**:
```bash
# Check URL format
DATABASE_URL=sqlite:///./ailens.db  # Correct for SQLite

# Set absolute path if needed
DATABASE_URL=/home/user/ailens/ailens.db
```

## Environment Variables Reference

### Backend Environment Variables

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| ENVIRONMENT | string | No | development | Environment: development, staging, production |
| PROJECT_NAME | string | No | AILens | Project name |
| DATABASE_URL | string | Yes | sqlite:///./ailens.db | Database connection string |
| SECRET_KEY | string | Yes | - | JWT signing key |
| ALGORITHM | string | No | HS256 | JWT algorithm |
| ACCESS_TOKEN_EXPIRE_MINUTES | int | No | 30 | Token expiry in minutes |
| OTP_EXPIRY_MINUTES | int | No | 10 | OTP validity in minutes |
| OTP_LENGTH | int | No | 6 | OTP code length |
| UPLOAD_DIR | string | No | ./uploads | File upload directory |
| MAX_UPLOAD_SIZE_MB | int | No | 50 | Max upload size |
| FACE_MIN_QUALITY_SCORE | float | No | 0.8 | Min face quality (0-1) |
| VOICE_MIN_QUALITY_SCORE | float | No | 0.75 | Min voice quality (0-1) |
| AWS_REGION | string | No | us-east-1 | AWS region for S3 |
| S3_BUCKET | string | No | ailens-biometrics | S3 bucket name |

### Flutter Environment Variables

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| FLUTTER_ENV | string | No | development | Environment: development, staging, production |
| API_BASE_URL | string | Yes | http://10.0.2.2:5000/api | Backend API URL |
| LOG_LEVEL | string | No | debug | Logging level |
| ENABLE_GOOGLE_SIGNIN | bool | No | false | Enable Google Sign-In |
| ENABLE_FACE_RECOGNITION | bool | No | true | Enable face recognition |
| ENABLE_VOICE_RECOGNITION | bool | No | true | Enable voice recognition |
| GOOGLE_CLIENT_ID | string | No | - | Google OAuth client ID |
| GOOGLE_CLIENT_SECRET | string | No | - | Google OAuth secret |

## Additional Resources

- [OWASP: Secure Coding Practices](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/)
- [12-Factor App: Config](https://12factor.net/config)
- [Flutter Security](https://flutter.dev/docs/testing/build-modes)
- [FastAPI Security](https://fastapi.tiangolo.com/tutorial/security/)
- [Python Secrets Module](https://docs.python.org/3/library/secrets.html)

## Checklist for Secure Deployment

- [ ] Generate strong SECRET_KEY using `secrets` module
- [ ] Update all environment-specific variables in `.env`
- [ ] Ensure `.env` is in `.gitignore` and not committed
- [ ] Test all API endpoints with correct credentials
- [ ] Verify file upload directory has correct permissions
- [ ] Test authentication flow on all platforms (Android, iOS, Web)
- [ ] Review logs for any exposed sensitive information
- [ ] Set up monitoring and alerting for security events
- [ ] Perform security audit before production release
- [ ] Document all secrets and their rotation schedule
