# Quick Setup Reference

## Backend Setup (5 minutes)

```bash
# 1. Navigate to backend directory
cd backend_fastapi

# 2. Copy environment template
cp .env.example .env

# 3. Edit .env (use default values for development)
nano .env

# 4. Install dependencies (if not done)
pip install -r requirements.txt

# 5. Run server
python main.py

# Output should show:
# ✓ Uvicorn running on http://127.0.0.1:5000
# ✓ Database tables created
```

## Frontend Setup (5 minutes)

```bash
# 1. Navigate to frontend directory
cd mobile_flutter

# 2. Copy environment template
cp .env.example .env

# 3. Edit .env with development values
nano .env
# API_BASE_URL=http://10.0.2.2:5000/api

# 4. Get dependencies
flutter pub get

# 5. Run app
flutter run

# Select device when prompted
```

## Docker Setup (10 minutes)

```bash
# Build backend Docker image
docker build -t ailens-backend:latest backend_fastapi/

# Run with environment
docker run \
  -e ENVIRONMENT=development \
  -e DATABASE_URL=sqlite:///./ailens.db \
  -e SECRET_KEY=dev-key \
  -p 5000:5000 \
  ailens-backend:latest
```

## Environment Variables Needed

### Backend (.env)
```env
ENVIRONMENT=development
DATABASE_URL=sqlite:///./ailens.db
SECRET_KEY=your-secret-key-here
API_BASE_URL=http://localhost:5000/api
OTP_EXPIRY_MINUTES=10
UPLOAD_DIR=./uploads
```

### Frontend (.env)
```env
FLUTTER_ENV=development
API_BASE_URL=http://10.0.2.2:5000/api
DEBUG=true
```

## Verify Installation

```bash
# Backend health check
curl http://localhost:5000/health

# Frontend emulator/device
flutter devices

# Test API
curl -X GET http://localhost:5000/api/health
```

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Port 5000 already in use | `lsof -i :5000` then `kill -9 <PID>` |
| Module not found error | `pip install -r requirements.txt` |
| .env not loading | Check file is in correct directory |
| API not reachable | Verify `API_BASE_URL` in Flutter `.env` |
| Secure storage error | Clear app data: `adb shell pm clear app.package` |

## Important .gitignore Entries

Make sure `.env` files are ignored:

```gitignore
# Environment
.env
.env.local
.env.*.local
.env.production

# Other sensitive files
*.secret
credentials.json
~/.aws/credentials
```

## Key Configuration Files

| File | Purpose | Ignore |
|------|---------|--------|
| `backend_fastapi/.env` | Backend secrets | ✅ Yes |
| `backend_fastapi/.env.example` | Template | ❌ No |
| `mobile_flutter/.env` | Frontend config | ✅ Yes |
| `mobile_flutter/.env.example` | Template | ❌ No |

## Storage Usage

### Secure Storage (Mobile)
- **iOS**: Keychain (automatic encryption)
- **Android**: Android Keystore (AES-256 encryption)
- **Storage Service**: `SecureConfig` class in Flutter
- **Type**: Encrypted local storage on device

### File Storage (Backend)
- **Location**: `uploads/` directory
- **Subdirs**: `faces/`, `voices/`, `temp/`
- **Max Size**: 50MB per file (configurable)
- **Auto Cleanup**: Delete files older than 30 days

## Testing Credentials

For development testing:

```
Email: demo@ailens.app
Password: Demo123!
OTP: 123456
```

Database will auto-create test users with these credentials.

## Next Steps

1. ✅ Set up backend with `.env`
2. ✅ Set up frontend with `.env`
3. ✅ Verify API connectivity
4. ✅ Test authentication flow
5. → Read [SECURE_STORAGE_SETUP.md](SECURE_STORAGE_SETUP.md) for details
6. → Read [DEPLOYMENT_CONFIG.md](DEPLOYMENT_CONFIG.md) for production

## Useful Commands

```bash
# View current configuration
cat backend_fastapi/.env

# Generate strong secret key
python -c "import secrets; print(secrets.token_urlsafe(48))"

# Test API endpoint
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@ailens.app","password":"Demo123!"}'

# View Flutter logs
flutter logs

# Clear Flutter cache
flutter clean

# Get API service logs
tail -f backend_fastapi.log
```

## Documentation

- 📖 [SECURE_STORAGE_SETUP.md](SECURE_STORAGE_SETUP.md) - Detailed security guide
- 📖 [DEPLOYMENT_CONFIG.md](DEPLOYMENT_CONFIG.md) - Production deployment
- 📖 [ENVIRONMENT_CONFIGURATION.md](ENVIRONMENT_CONFIGURATION.md) - Configuration details
- 📖 [API_DOCUMENTATION.md](API_DOCUMENTATION.md) - API endpoints

## Support

If something goes wrong:

1. Check the relevant documentation file
2. Verify all environment variables are set
3. Check logs for error messages
4. Clear caches and restart

**Backend Logs:**
```bash
tail -f backend_fastapi.log
```

**Flutter Logs:**
```bash
flutter logs
```
