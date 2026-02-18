# AILens - Day 1: Foundation Setup

## Project Overview
AILens is an AI-powered biometric authentication system that uses face recognition and voice authentication along with mandatory 3D video mapping for enhanced security.

## Day 1 Completed Tasks

### 1. ✅ Project Structure Setup

```
AILens/
├── backend/
│   ├── config/
│   │   ├── database.js       # MongoDB connection
│   │   └── storage.js        # AWS S3 file storage configuration
│   ├── models/
│   │   └── User.js           # User schema with biometric fields
│   ├── controllers/
│   │   └── authController.js # Authentication logic
│   ├── routes/
│   │   └── auth.js           # Auth API endpoints
│   ├── middleware/
│   │   └── auth.js           # JWT verification
│   ├── utils/
│   ├── .env                  # Environment variables
│   ├── package.json          # Node.js dependencies
│   └── index.js              # Server entry point
│
├── mobile/
│   ├── src/
│   │   ├── screens/          # Screen components
│   │   ├── components/       # Reusable components
│   │   ├── context/          # React context for state management
│   │   ├── services/         # API services
│   │   ├── utils/            # Utility functions
│   │   ├── navigation/       # Navigation configuration
│   │   ├── config.js         # Configuration constants
│   │   └── App.js            # Main app component
│   ├── .env                  # Environment variables
│   ├── app.json              # Expo configuration
│   └── package.json          # React Native dependencies
│
└── docs/
    ├── SETUP.md              # Setup instructions (this file)
    ├── API_DOCUMENTATION.md  # Backend API docs
    ├── DATABASE_SCHEMA.md    # Database structure
    └── GOOGLE_AUTH_SETUP.md  # Google OAuth setup
```

### 2. ✅ Database Setup

**Database Type:** MongoDB
**Models Created:**
- **User Model** with fields for:
  - Basic info (firstName, lastName, email, phone)
  - Authentication (password, OTP with hardcoded value "123456")
  - Google OAuth (googleId, googleProfile)
  - Biometric data (videoRecording, faceData, voiceData)
  - Account status (isActive, isEmailVerified, isPhoneVerified, isBiometricEnrolled)
  - Security (loginAttempts, lockUntil, lastLogin)
  - Preferences (enableNotifications, enableBiometricAuth, language)

**Current Setup:**
- OTP: Hardcoded to "123456" for testing
- OTP Expiry: 10 minutes from registration
- Password: Hashed with bcryptjs (10 salt rounds)
- Account Lock: After 5 failed login attempts for 2 hours

### 3. ✅ File Storage Setup

**Storage Solution:** AWS S3
**Configuration in:** `backend/config/storage.js`

**Features:**
- Secure file upload with multer
- Support for video, image, and audio files
- 100MB file size limit
- Private ACL for security
- Automatic file type validation

**File Organization:**
```
ailens-bucket/
├── videoRecording/{userId}/{timestamp}-{filename}
├── faceData/{userId}/{timestamp}-{filename}
└── voiceData/{userId}/{timestamp}-{filename}
```

### 4. ✅ Backend API Endpoints

**Base URL:** `http://localhost:5000/api`

**Authentication Endpoints:**

| Method | Endpoint | Body | Response | Auth Required |
|--------|----------|------|----------|----------------|
| POST | `/auth/register` | firstName, lastName, email, phone, password, passwordConfirm | token, user, otp: "123456" | No |
| POST | `/auth/verify-otp` | email, otp | user, success message | No |
| POST | `/auth/login` | email, password | token, user | No |
| POST | `/auth/google` | token | token, user | No |
| GET | `/auth/me` | - | user details | Yes |
| POST | `/auth/logout` | - | success message | Yes |

**Request Examples:**

**Register:**
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "phone": "9876543210",
    "password": "SecurePassword123",
    "passwordConfirm": "SecurePassword123"
  }'
```

**Login:**
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "SecurePassword123"
  }'
```

**Google Login:**
```bash
curl -X POST http://localhost:5000/api/auth/google \
  -H "Content-Type: application/json" \
  -d '{
    "token": "google_token_here"
  }'
```

### 5. ✅ Environment Variables

**Backend (.env):**
```
# Server
PORT=5000
NODE_ENV=development

# Database
MONGODB_URI=mongodb://localhost:27017/ailens

# JWT
JWT_SECRET=your_secret_key_here_change_in_production
JWT_EXPIRATION=7d

# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id_here
GOOGLE_CLIENT_SECRET=your_google_client_secret_here
GOOGLE_CALLBACK_URL=http://localhost:5000/auth/google/callback

# AWS S3
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your_aws_access_key_here
AWS_SECRET_ACCESS_KEY=your_aws_secret_key_here
AWS_S3_BUCKET=ailens-storage

# OTP (hardcoded for now)
OTP_SECRET=123456

# CORS
CORS_ORIGIN=http://localhost:3000,http://localhost:8081
```

**Mobile (.env):**
```
EXPO_PUBLIC_API_BASE_URL=http://localhost:5000/api
EXPO_PUBLIC_GOOGLE_CLIENT_ID=your_google_client_id_here
EXPO_PUBLIC_GOOGLE_CLIENT_SECRET=your_google_client_secret_here
EXPO_PUBLIC_APP_NAME=AILens
EXPO_PUBLIC_VERSION=1.0.0
EXPO_PUBLIC_DEBUG=true
```

## Installation Instructions

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Setup MongoDB:**
   - **Local MongoDB:** Install and run MongoDB locally
   - **MongoDB Atlas:** Create a cluster and update MONGODB_URI in .env

4. **Update .env file:**
   ```bash
   cp .env .env.local
   # Edit .env with your actual credentials
   ```

5. **Start the server:**
   ```bash
   npm run dev    # For development with hot reload
   # or
   npm start      # For production
   ```

6. **Verify server is running:**
   ```bash
   curl http://localhost:5000/health
   ```

### Mobile App Setup

1. **Navigate to mobile directory:**
   ```bash
   cd mobile
   ```

2. **Install Expo CLI (if not already installed):**
   ```bash
   npm install -g expo-cli
   ```

3. **Install dependencies:**
   ```bash
   npm install
   ```

4. **Update .env file:**
   ```bash
   # Edit .env with your API URL and Google credentials
   ```

5. **Start the app:**
   ```bash
   npm start         # For Expo client
   npm run android   # For Android emulator
   npm run ios       # For iOS simulator
   npm run web       # For web browser
   ```

## Google OAuth Setup (IMPORTANT - @Raghav)

### Step 1: Create Google OAuth 2.0 Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Go to "APIs & Services" > "Credentials"
4. Click "Create Credentials" > "OAuth 2.0 Client IDs"
5. Select "Web application"
6. Add authorized redirect URIs:
   - Backend: `http://localhost:5000/auth/google/callback`
   - Frontend: `http://localhost:3000/auth/callback`
   - Mobile: `com.ailens.app://oauth/callback` (update bundle ID)

7. Copy Client ID and Secret to .env files

### Step 2: Enable Google Sign-In

1. Go to "APIs & Services" > "Library"
2. Search for "Google+ API" and enable it
3. Search for "Identity Toolkit API" and enable it

### Step 3: Update Mobile App

- For React Native: Use `react-native-google-signin` library
- Update Google Client ID in mobile/.env
- Configure iOS and Android bundle IDs in Google Console

### Step 4: Update Backend

- Implement actual Google token verification
- Create user if it doesn't exist
- Return JWT token to client

## Next Steps (Day 2+)

- [ ] Implement biometric enrollment (face video recording)
- [ ] Implement 3D face mapping processing
- [ ] Implement voice enrollment and comparison
- [ ] Create video upload and processing endpoints
- [ ] Implement biometric authentication
- [ ] Add email verification
- [ ] Add password reset functionality
- [ ] Implement refresh token logic
- [ ] Add rate limiting
- [ ] Implement proper error handling and logging

## Testing

### Quick Test Scripts

**Register User:**
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "User",
    "email": "test@example.com",
    "phone": "9999999999",
    "password": "Test@123",
    "passwordConfirm": "Test@123"
  }'
```

**Verify OTP (use response token):**
```bash
curl -X POST http://localhost:5000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "otp": "123456"
  }'
```

**Login:**
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test@123"
  }'
```

## Important Notes

1. **OTP:** Currently hardcoded to "123456" for testing. Will implement real SMS OTP in later phases.
2. **Security:** All passwords are hashed. Change JWT_SECRET in production.
3. **Google OAuth:** Needs actual Google credentials for production.
4. **File Storage:** Configure AWS S3 credentials before using file upload features.
5. **Database:** Use MongoDB Atlas for cloud deployment.

## Troubleshooting

**Port already in use:**
```bash
# Kill the process using port 5000
# Windows:
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# Mac/Linux:
lsof -i :5000
kill -9 <PID>
```

**MongoDB connection error:**
- Ensure MongoDB is running
- Verify MONGODB_URI in .env
- Check network access for MongoDB Atlas

**CORS errors:**
- Update CORS_ORIGIN in backend .env
- Ensure mobile/frontend URL is in the list

## Contact & Support

For questions about Google OAuth setup: @Raghav
For other queries: AILens Team

---

**Last Updated:** February 16, 2026
**Status:** ✅ Day 1 Complete
