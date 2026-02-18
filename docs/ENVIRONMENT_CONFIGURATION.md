# Environment Configuration Guide

## Overview
This guide explains how to configure environment variables and secure storage for the AILens application. All sensitive information (passwords, API keys, database connections) should be stored securely using environment variables.

## Backend Configuration (FastAPI)

### Quick Start

1. **Copy the example configuration:**
   ```bash
   cd backend_fastapi
   cp .env.example .env
   ```

2. **Edit `.env` with your actual values:**
   ```bash
   # For development
   ENVIRONMENT=development
   SECRET_KEY=lKA4KzGkKGaJHHJ0rvJPoUVl5cCTsYOj13GDVCEGgNU
   DATABASE_URL=sqlite:///./ailens.db
   ```

3. **Start the backend:**
   ```bash
   python main.py
   ```

### Configuration Variables

#### Database Configuration
- **DATABASE_URL**: Database connection string
  - SQLite: `sqlite:///./ailens.db`
  - PostgreSQL: `postgresql://user:password@host:port/database`

#### Security Settings
- **SECRET_KEY**: JWT signing key (generate with `python -c "import secrets; print(secrets.token_urlsafe(32))"`)
- **ALGORITHM**: JWT algorithm (default: HS256)
- **ACCESS_TOKEN_EXPIRE_MINUTES**: Token validity duration (default: 30 minutes)

#### OTP Settings
- **OTP_EXPIRY_MINUTES**: OTP validity duration (default: 10 minutes)
- **OTP_LENGTH**: OTP code length (default: 6 digits)

#### File Storage
- **UPLOAD_DIR**: Directory for uploaded biometric files (default: `./uploads`)
- **MAX_UPLOAD_SIZE_MB**: Maximum file upload size (default: 50 MB)

#### Biometric Quality Thresholds
- **FACE_MIN_QUALITY_SCORE**: Minimum face recognition quality (0.0-1.0, default: 0.8)
- **VOICE_MIN_QUALITY_SCORE**: Minimum voice recognition quality (0.0-1.0, default: 0.75)

### Production Setup

For production deployment:

1. **Generate a strong SECRET_KEY:**
   ```python
   import secrets
   print(secrets.token_urlsafe(32))
   ```

2. **Set environment to production:**
   ```env
   ENVIRONMENT=production
   DEBUG=false
   ```

3. **Use a production database:**
   ```env
   DATABASE_URL=postgresql://user:secure_password@prod-server:5432/ailens_prod
   ```

4. **Restrict CORS origins:**
   Update CORS_ORIGINS in config.py to only allow your frontend domain

5. **Enable HTTPS:**
   Set up SSL/TLS certificates and configure the FastAPI server

## Flutter Configuration (Mobile App)

### Secure Storage Setup

The Flutter app uses **flutter_secure_storage** to securely store sensitive information:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// All sensitive data is stored in:
// iOS: Keychain
// Android: Keystore
// Windows: Credentials Manager
// Linux: Secret Service
```

### Secure Storage Service

The `StorageService` class handles all secure storage:

```dart
// Save sensitive data
await StorageService.saveToken(authToken);
await StorageService.saveUserData(userData);

// Retrieve data
String? token = await StorageService.getToken();
String? userData = await StorageService.getUserData();

// Clear data on logout
await StorageService.clearAll();
```

### Storage Locations

**By Platform:**
- **iOS**: Keychain (encrypted by default)
- **Android**: Android Keystore with AES-256 encryption
- **Windows**: Windows Credentials Manager
- **macOS**: Keychain

### What to Store

#### STORE SECURELY:
- ✅ JWT Authentication Tokens
- ✅ User Credentials (if required)
- ✅ API Keys
- ✅ Refresh Tokens
- ✅ Sensitive User Data

#### DON'T STORE:
- ❌ Passwords in plain text
- ❌ Biometric data locally (process and discard)
- ❌ Session cookies
- ❌ Logs with sensitive info

### Flutter Environment Configuration

1. **Create `.env` file in flutter root:**
   ```env
   FLUTTER_ENV=development
   API_BASE_URL=http://10.0.2.2:5000/api
   LOG_LEVEL=debug
   ```

2. **Load environment variables:**
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';
   
   void main() async {
     await dotenv.load();
     runApp(const MyApp());
   }
   
   // Access variables
   String apiUrl = dotenv.env['API_BASE_URL'] ?? '';
   ```

3. **Update pubspec.yaml:**
   ```yaml
   flutter_dotenv:
     files:
       - .env
   ```

## Security Best Practices

### Password Management
```
✅ DO:
- Use strong, random passwords (16+ characters)
- Use password managers to generate and store passwords
- Change passwords regularly
- Never share credentials in code/logs

❌ DON'T:
- Hard-code passwords in source code
- Use simple/obvious passwords
- Store passwords in git repositories
- Share credentials via email/chat
```

### API Keys & Secrets
```
✅ DO:
- Rotate keys regularly
- Store only in environment variables
- Use different keys for different environments
- Monitor key access and usage
- Revoke compromised keys immediately

❌ DON'T:
- Commit secrets to version control
- Log or print secrets for debugging
- Use production keys in development
- Share keys across teams
```

### Database Connections
```
✅ DO:
- Use environment variables for connection strings
- Use database user accounts with minimal privileges
- Enable database encryption at rest
- Use connection pooling
- Monitor database access logs

❌ DON'T:
- Hard-code database credentials
- Use root/admin accounts for application connections
- Store connection strings in source code
- Use unencrypted connections in production
```

## Environment-Specific Configuration

### Development
```env
ENVIRONMENT=development
DEBUG=true
DATABASE_URL=sqlite:///./ailens.db
SECRET_KEY=dev-key-not-secure
```

### Staging
```env
ENVIRONMENT=staging
DEBUG=false
DATABASE_URL=postgresql://user:pwd@staging-db:5432/ailens_staging
SECRET_KEY=strong-staging-key
```

### Production
```env
ENVIRONMENT=production
DEBUG=false
DATABASE_URL=postgresql://user:strong_pwd@prod-db:5432/ailens_prod
SECRET_KEY=very-strong-production-key
```

## Troubleshooting

### Issue: "No module named 'dotenv'"
**Solution**: Install python-dotenv
```bash
pip install python-dotenv
```

### Issue: ".env file not loaded"
**Solution**: Ensure .env is in the correct directory (backend_fastapi root)
```bash
# From backend_fastapi directory
ls -la .env
```

### Issue: "Secure storage not working"
**Solution**: Clear app data and reinitialize
```bash
# On Android emulator
adb shell pm clear com.example.ailens
```

## File Structure

```
AILens/
├── backend_fastapi/
│   ├── .env              ← Actual configuration (gitignored)
│   ├── .env.example      ← Template (commit this)
│   ├── .gitignore        ← Must include .env, .env.local
│   ├── app/
│   │   └── core/
│   │       └── config.py ← Loads from .env
│   └── main.py
│
├── mobile_flutter/
│   ├── .env              ← Flutter configuration
│   ├── .gitignore
│   ├── lib/
│   │   └── utils/
│   │       └── storage_service.dart ← Secure storage
│   └── pubspec.yaml
```

## Verification Checklist

- [ ] `.env` file created from `.env.example`
- [ ] `.env` added to `.gitignore`
- [ ] All sensitive values configured in `.env`
- [ ] `config.py` loads variables from `.env`
- [ ] `flutter_secure_storage` installed
- [ ] `StorageService` used for sensitive data
- [ ] No hardcoded secrets in source code
- [ ] Backend starts without errors
- [ ] Backend API accessible from frontend
- [ ] Authentication tokens stored securely

## Additional Resources

- [OWASP: Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [12-Factor App: Config](https://12factor.net/config)
- [Flutter Security Best Practices](https://flutter.dev/docs/testing/build-modes)
- [FastAPI Security](https://fastapi.tiangolo.com/tutorial/security/)
