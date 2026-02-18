# AILens - AI-Powered Biometric Authentication System

**Version:** 1.0.0  
**Status:** ✅ Features Complete, Backend Ready  
**Last Updated:** February 16, 2026  
**Framework:** FastAPI (Python Backend), Flutter (Mobile App)

---

## 🚀 Quick Start

> **New here?** Start with **[QUICK_START.md](QUICK_START.md)** ⭐

### Flutter App Status: ✅ Running
```bash
# App is already running on Android emulator
# Demo credentials:
Email: demo@ailens.app
Password: Password123!
OTP: 123456
```

### FastAPI Backend Status: 🚀 Ready to Run
```bash
cd backend_fastapi
python main.py
# Server runs on http://localhost:5000
```

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **[QUICK_START.md](QUICK_START.md)** | 📍 Start here! Get running in 5 minutes |
| **[SETUP_GUIDE.md](SETUP_GUIDE.md)** | 📖 Complete setup instructions |
| **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** | 📊 Full project overview |
| **[backend_fastapi/README.md](backend_fastapi/README.md)** | 🔧 Backend documentation |
| **[backend_fastapi/API_REFERENCE.md](backend_fastapi/API_REFERENCE.md)** | 📡 API endpoint reference |

---

## 🎯 Project Overview

AILens is an advanced biometric authentication system that combines AI and machine learning to provide secure, multi-modal user identification.

✅ **Security**
- End-to-end encrypted secure storage
- Server-side file storage (AWS S3)
- JWT token expiration (7 days)
- Account lockout mechanism

✅ **Cross-Platform**
- Backend: Node.js + Express.js
- Mobile: Flutter (iOS & Android)
- Database: MongoDB

---

## 📊 Project Structure

```
AILens/
├── backend/                      # Node.js Express Server
│   ├── config/                   # Configuration files
│   │   ├── database.js          # MongoDB setup
│   │   └── storage.js           # AWS S3 configuration
│   ├── models/                   # Database schemas
│   │   └── User.js              # User model with biometric fields
│   ├── controllers/              # Business logic
│   │   └── authController.js    # Authentication logic
│   ├── routes/                   # API endpoints
│   │   └── auth.js              # Auth routes
│   ├── middleware/               # Express middleware
│   │   └── auth.js              # JWT verification
│   ├── index.js                 # Server entry point
│   ├── package.json             # Dependencies
│   ├── .env                     # Environment variables
│   └── .gitignore               # Git exclusions
│
├── mobile_flutter/              # Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart            # App entry point
│   │   ├── screens/             # UI Screens
│   │   │   ├── splash_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── home_screen.dart
│   │   ├── services/            # Business logic
│   │   │   └── api_service.dart # API client
│   │   ├── models/              # Data models
│   │   │   └── user.dart
│   │   ├── utils/               # Utilities
│   │   │   └── storage_service.dart
│   │   └── widgets/             # Reusable components
│   ├── pubspec.yaml             # Flutter dependencies
│   ├── .env                     # Environment variables
│   └── android/, ios/           # Platform-specific code
│
└── docs/                        # Documentation
    ├── README.md                # Project overview
    ├── SETUP.md                 # Installation guide
    ├── API_DOCUMENTATION.md     # API reference
    ├── DATABASE_SCHEMA.md       # Database structure
    ├── GOOGLE_AUTH_SETUP.md     # OAuth configuration
    ├── DAY1_SUMMARY.md          # Day 1 completion report
    └── QUICK_REFERENCE.md       # Quick command reference
```

---

## 🚀 Quick Start

### Prerequisites

**Backend:**
- Node.js 16+ / npm 8+
- MongoDB (local or Atlas)
- AWS S3 credentials (optional for development)
- Google OAuth credentials (optional)

**Mobile:**
- Flutter SDK 3.0+
- Android SDK 21+ or iOS 12.0+
- Xcode (macOS) or Android Studio

### Installation

#### Backend Setup (5 minutes)
```bash
# Navigate to backend
cd backend

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with your credentials

# Start development server
npm run dev
# Server runs at http://localhost:5000
```

#### Mobile Setup (10 minutes)
```bash
# Navigate to Flutter app
cd mobile_flutter

# Install Flutter dependencies
flutter pub get

# Configure environment
cp .env.example .env
# Edit .env with API_BASE_URL and other settings

# Run on emulator/device
flutter run
```

---

## � Documentation

### For Backend Developers

| Document | Purpose |
|----------|---------|
| [docs/SETUP.md](docs/SETUP.md) | Complete installation guide |
| [docs/API_DOCUMENTATION.md](docs/API_DOCUMENTATION.md) | API endpoints and examples |
| [docs/DATABASE_SCHEMA.md](docs/DATABASE_SCHEMA.md) | MongoDB structure and queries |
| [docs/GOOGLE_AUTH_SETUP.md](docs/GOOGLE_AUTH_SETUP.md) | OAuth configuration |
| [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md) | Common commands and troubleshooting |

### For Mobile Developers (Flutter)

| Document | Purpose |
|----------|---------|
| [mobile_flutter/FLUTTER_SETUP.md](mobile_flutter/FLUTTER_SETUP.md) | Flutter installation and configuration |
| [mobile_flutter/FLUTTER_API_REFERENCE.md](mobile_flutter/FLUTTER_API_REFERENCE.md) | API integration guide with code examples |
| [mobile_flutter/FLUTTER_DEVELOPMENT_GUIDE.md](mobile_flutter/FLUTTER_DEVELOPMENT_GUIDE.md) | Development best practices and patterns |
| [mobile_flutter/FLUTTER_TROUBLESHOOTING.md](mobile_flutter/FLUTTER_TROUBLESHOOTING.md) | Common issues and solutions |

---

## 🔐 API Endpoints

### Authentication

```
POST   /api/auth/register              - Register new user
POST   /api/auth/verify-otp            - Verify OTP
POST   /api/auth/login                 - Login with credentials
POST   /api/auth/google                - Login with Google token
GET    /api/auth/me                    - Get current user (protected)
POST   /api/auth/logout                - Logout (protected)
```

### Example Requests

**Register:**
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "phone": "9876543210",
    "password": "Password@123",
    "passwordConfirm": "Password@123"
  }'
```

**Login:**
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "Password@123"
  }'
```

See [API_DOCUMENTATION.md](docs/API_DOCUMENTATION.md) for complete reference.

---

## 🛠️ Development Commands

### Backend

```bash
cd backend

# Install dependencies
npm install

# Start development server (with hot reload)
npm run dev

# Start production server
npm start

# Run tests (future)
npm test

# Check code quality
npm run lint
```

### Mobile (Flutter)

```bash
cd mobile_flutter

# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Run in release mode
flutter run --release

# Build APK (Android)
flutter build apk --split-per-abi

# Build iOS app
flutter build ios --release

# Run tests
flutter test

# Format code
dart format lib/
```

---

## 🔑 Environment Variables

### Backend (.env)
```
# Server
PORT=5000
NODE_ENV=development

# Database
MONGODB_URI=mongodb://localhost:27017/ailens

# JWT
JWT_SECRET=your_secret_key_here
JWT_EXPIRE=7d

# AWS S3
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_S3_BUCKET=ailens-bucket

# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_secret

# CORS
CORS_ORIGIN=http://localhost:3000

# OTP (Development Only)
OTP_SECRET=123456
```

### Mobile (.env)
```
# API Configuration
API_BASE_URL=http://localhost:5000/api
API_TIMEOUT_SECONDS=30

# App Configuration
APP_NAME=AILens
APP_VERSION=1.0.0
DEBUG=true

# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
```

---

## ✅ Completed Features (Day 1)

### Backend
- ✅ Express.js server with MongoDB
- ✅ User registration with email verification
- ✅ OTP-based email verification (hardcoded "123456")
- ✅ Secure password hashing (bcryptjs)
- ✅ JWT authentication (7-day expiration)
- ✅ Account lockout protection
- ✅ Google OAuth setup guide
- ✅ AWS S3 file storage configuration
- ✅ 6 authenticated API endpoints
- ✅ Comprehensive error handling

### Mobile (Flutter)
- ✅ Flutter project structure
- ✅ API service with all endpoints
- ✅ User model and serialization
- ✅ Splash screen with health check
- ✅ Login screen with validation
- ✅ Registration screen with OTP verification
- ✅ Home screen with user dashboard
- ✅ Secure token storage
- ✅ Material Design UI with deepPurple theme
- ✅ Navigation flows

### Documentation
- ✅ Setup guides (Backend + Flutter)
- ✅ API documentation with examples
- ✅ Database schema documentation
- ✅ Google OAuth setup guide
- ✅ Flutter development guide
- ✅ Flutter API reference
- ✅ Flutter troubleshooting guide
- ✅ Day 1 completion summary

---

## 🔄 In Progress / Next Steps

### Day 2: Biometric Implementation
- [ ] Camera integration for video recording
- [ ] Audio recording for voice biometrics
- [ ] 3D face mapping algorithms
- [ ] Voice print generation
- [ ] Biometric comparison engine
- [ ] Liveness detection
- [ ] Biometric enrollment UI

### Planned Features
- [ ] Firebase Cloud Messaging for notifications
- [ ] SMS OTP implementation
- [ ] User profile management
- [ ] Biometric history and comparison results
- [ ] Settings and preferences
- [ ] Admin dashboard
- [ ] Analytics and reporting

---

## 🧪 Testing

### Manual Testing Checklist

**Registration Flow:**
```
1. ✓ Click "Sign Up"
2. ✓ Fill registration form
3. ✓ Verify OTP Screen appears with OTP "123456"
4. ✓ Enter OTP and verify
5. ✓ Redirect to Login screen
```

**Login Flow:**
```
1. ✓ Enter registered email
2. ✓ Enter password
3. ✓ Click Login
4. ✓ Arrive at Home screen
5. ✓ User data displayed correctly
```

**API Testing:**
```bash
# Health check
curl http://localhost:5000/health

# Test registration
curl -X POST http://localhost:5000/api/auth/register \
  -d '{"firstName":"Test",...}'

# Test login
curl -X POST http://localhost:5000/api/auth/login \
  -d '{"email":"test@test.com","password":"Test@123"}'
```

---

## 🐛 Troubleshooting

### Backend Issues
- **"Cannot connect to MongoDB":** Check MONGODB_URI in .env
- **"Port 5000 already in use":** Kill process on port 5000 or change PORT
- **"Module not found":** Run `npm install` again

### Mobile Issues
- **"Cannot connect to API":** Check API_BASE_URL in .env
- **"Flutter command not found":** Add Flutter to PATH
- **"Emulator won't start":** Check Android SDK installation

See detailed guides:
- [Backend Troubleshooting](docs/QUICK_REFERENCE.md)
- [Flutter Troubleshooting](mobile_flutter/FLUTTER_TROUBLESHOOTING.md)

---

## 🔒 Security

### Current Implementation
- ✅ Password hashing with bcryptjs
- ✅ JWT token-based authentication
- ✅ Secure storage for tokens (flutter_secure_storage)
- ✅ Device-level encryption for biometric data
- ✅ CORS configuration
- ✅ Account lockout protection

### Future Improvements
- [ ] SSL/TLS for production
- [ ] Rate limiting on API endpoints
- [ ] SMS OTP for phone verification
- [ ] Refresh token implementation
- [ ] Biometric encryption at rest
- [ ] Audit logging

---

## 📊 Development Timeline

### ✅ Phase 1: Foundation (Day 1 - COMPLETED)
- Backend infrastructure
- Authentication system
- Database design
- API implementation
- Flutter mobile structure

### 🔄 Phase 2: Biometrics (Day 2 - IN PROGRESS)
- Camera integration
- Video recording
- Audio recording
- Biometric algorithms
- Processing pipeline

### ⏳ Phase 3: Advanced Features (Day 3+)
- Admin dashboard
- Analytics
- Notifications
- User management
- Performance optimization

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Create a feature branch (`git checkout -b feature/feature-name`)
2. Commit changes (`git commit -m 'Add feature'`)
3. Push to branch (`git push origin feature/feature-name`)
4. Open a Pull Request

---

## 📝 Notes

### OTP Configuration
- Currently hardcoded to `123456` for testing
- Expires after 10 minutes
- Will be replaced with real SMS OTP in production

### Google OAuth
- Setup guide: See [GOOGLE_AUTH_SETUP.md](./docs/GOOGLE_AUTH_SETUP.md)
- Awaiting credentials from @Raghav

---

## 📞 Support

**Project Lead:** Team AILens  
**Issues:** Report in GitHub Issues  
**Documentation:** See `/docs` and `/mobile_flutter` folders

---

**Last Updated:** February 16, 2026  
**Status:** Ready for Development ✅  
**Next:** Day 2 - Biometric Implementation

---

## 🚀 Get Started Now

**For Backend Developers:**
```bash
cd backend && npm install && npm run dev
```

**For Mobile Developers:**
```bash
cd mobile_flutter && flutter pub get && flutter run
```

**For Quick Reference:**
- [API Docs](docs/API_DOCUMENTATION.md)
- [Setup Guide](docs/SETUP.md)
- [Flutter Guide](mobile_flutter/FLUTTER_SETUP.md)

---

**Ready to build the future of biometric authentication? Let's go! 🚀**
- Assigned to: @Raghav
- Status: Configuration guide completed, awaiting credentials

### Video Recording
- Made mandatory (not optional) for enhanced 3D mapping
- Better accuracy for face detection with video vs. selfies
- Supports front, left, and right profiles through video

---

## 📞 Support

For questions or issues:
- 📧 Email: support@ailens.com
- 📱 Phone: +1 (XXX) XXX-XXXX
- 🌐 Website: https://ailens.com

---

## 📄 License

This project is proprietary and confidential. Unauthorized copying or distribution is prohibited.

---

## 👥 Team

- **Backend Lead:** [Your Name]
- **Mobile Lead:** [Your Name]
- **AI/ML Lead:** [Your Name]
- **DevOps:** [Your Name]
- **Google OAuth:** @Raghav

---

**Last Updated:** February 16, 2026
**Current Phase:** Foundation Complete (Day 1)
**Next Milestone:** Biometric Enrollment (Day 2)

---

### Quick Links
- [Setup Instructions](./docs/SETUP.md)
- [API Docs](./docs/API_DOCUMENTATION.md)
- [Database Schema](./docs/DATABASE_SCHEMA.md)
- [Google Auth Guide](./docs/GOOGLE_AUTH_SETUP.md)
