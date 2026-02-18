# AILens Backend API Documentation

## Base URL
```
http://localhost:5000/api
```

## Authentication
All protected endpoints require a JWT token in the `Authorization` header:
```
Authorization: Bearer <your_jwt_token>
```

## Response Format

All API responses follow this format:

### Success Response
```json
{
  "success": true,
  "message": "Operation description",
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error information"
}
```

## Auth Endpoints

### 1. Register User
Creates a new user account with email and password.

**Endpoint:**
```
POST /auth/register
```

**Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "phone": "9876543210",
  "password": "SecurePassword123",
  "passwordConfirm": "SecurePassword123"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "User registered successfully. Please verify your OTP.",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "otp": "123456",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "phone": "9876543210"
  }
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Email already in use",
  "error": "Email already in use"
}
```

**Validation Rules:**
- firstName: Required, string
- lastName: Required, string
- email: Required, valid email format, unique
- phone: Required, unique, minimum 10 digits
- password: Required, minimum 6 characters
- passwordConfirm: Must match password

**Status Codes:**
- `201` - User created successfully
- `400` - Validation error or user already exists
- `500` - Server error

---

### 2. Verify OTP
Verifies the one-time password for phone number verification.

**Endpoint:**
```
POST /auth/verify-otp
```

**Request Body:**
```json
{
  "email": "john@example.com",
  "otp": "123456"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Phone verified successfully",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "phone": "9876543210",
    "isPhoneVerified": true
  }
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Invalid OTP"
}
```

**Status Codes:**
- `200` - OTP verified successfully
- `400` - Invalid or expired OTP
- `404` - User not found
- `500` - Server error

**Notes:**
- OTP expires after 10 minutes of registration
- Hardcoded OTP for testing: `123456`

---

### 3. Login
Authenticates a user with email and password.

**Endpoint:**
```
POST /auth/login
```

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "SecurePassword123"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "User logged in successfully",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "phone": "9876543210",
    "isPhoneVerified": true,
    "isBiometricEnrolled": false
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

**Error Response (403) - Account Locked:**
```json
{
  "success": false,
  "message": "Account is locked due to multiple failed login attempts. Please try again later."
}
```

**Status Codes:**
- `200` - Login successful
- `400` - Missing email or password
- `401` - Invalid credentials
- `403` - Account locked
- `500` - Server error

**Security Features:**
- Password comparison using bcryptjs
- Account lockout after 5 failed attempts
- 2-hour lockout period
- Login attempt tracking
- Last login timestamp recorded

---

### 4. Google Login
Authenticates a user using Google OAuth token.

**Endpoint:**
```
POST /auth/google
```

**Request Body:**
```json
{
  "token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjE5ZjdlMDgyNWFhMDYxOWM3NzgyMjA3YzQwYTkxZjRlODI1N2FkODcifQ..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "User logged in with Google successfully",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "phone": "google_118287493728374928",
    "isEmailVerified": true,
    "isBiometricEnrolled": false
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "message": "Invalid Google token"
}
```

**Status Codes:**
- `200` - Login successful
- `400` - Missing Google token
- `401` - Invalid token
- `500` - Server error

**Flow:**
1. User logs in via Google on client
2. Client receives Google ID token
3. Client sends ID token to this endpoint
4. Backend verifies token with Google
5. Backend creates or retrieves user
6. Backend returns AILens JWT token

**Notes:**
- If user doesn't exist, a new account is created
- Email is verified automatically for Google users
- For development, token verification is basic. Implement full verification in production.

---

### 5. Get Current User
Retrieves the profile information of the currently authenticated user.

**Endpoint:**
```
GET /auth/me
```

**Headers:**
```
Authorization: Bearer <your_jwt_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "user": {
    "_id": "507f1f77bcf86cd799439011",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "phone": "9876543210",
    "googleId": null,
    "isActive": true,
    "isEmailVerified": false,
    "isPhoneVerified": true,
    "isBiometricEnrolled": false,
    "profilePhoto": null,
    "bio": null,
    "lastLogin": "2026-02-16T10:30:00Z",
    "preferences": {
      "enableNotifications": true,
      "enableBiometricAuth": false,
      "language": "en"
    },
    "biometricData": {
      "videoRecording": null,
      "faceData": {
        "threedMapping": null,
        "landmarks": null,
        "embedding": null
      },
      "voiceData": {
        "recordings": [],
        "voicePrint": null
      }
    },
    "createdAt": "2026-02-16T10:00:00Z",
    "updatedAt": "2026-02-16T10:30:00Z"
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "message": "Not authorized to access this route"
}
```

**Status Codes:**
- `200` - User retrieved successfully
- `401` - Invalid or missing token
- `404` - User not found
- `500` - Server error

---

### 6. Logout
Logs out the current user (token-based, so mainly for client-side cleanup).

**Endpoint:**
```
POST /auth/logout
```

**Headers:**
```
Authorization: Bearer <your_jwt_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "User logged out successfully"
}
```

**Status Codes:**
- `200` - Logout successful
- `401` - Invalid or missing token
- `500` - Server error

**Notes:**
- Token-based systems don't require server-side logout
- Client should delete the token from local storage
- Optional: Implement token blacklist for security

---

## Error Codes & Messages

| Status | Code | Message | Solution |
|--------|------|---------|----------|
| 400 | VALIDATION_ERROR | Missing required fields | Provide all required fields |
| 400 | EMAIL_IN_USE | Email already in use | Use different email |
| 400 | PHONE_IN_USE | Phone number already in use | Use different phone |
| 400 | PASSWORD_MISMATCH | Passwords do not match | Ensure passwords match |
| 400 | INVALID_OTP | Invalid OTP | Enter correct OTP |
| 400 | OTP_EXPIRED | OTP has expired | Request new OTP |
| 401 | INVALID_CREDENTIALS | Invalid email or password | Check credentials |
| 401 | INVALID_TOKEN | Not authorized to access this route | Use valid token |
| 403 | ACCOUNT_LOCKED | Account is locked | Try after 2 hours |
| 404 | NOT_FOUND | User not found | Check email/phone |
| 500 | SERVER_ERROR | Internal server error | Contact support |

---

## JWT Token Details

**Token Format:**
```
Header.Payload.Signature
```

**Payload:**
```json
{
  "id": "507f1f77bcf86cd799439011",
  "iat": 1676234400,
  "exp": 1677012000
}
```

**Token Expiration:** 7 days (configurable via JWT_EXPIRATION in .env)

**Token Usage:**
```javascript
const token = localStorage.getItem('token');
const headers = {
  'Authorization': `Bearer ${token}`
};
const response = await fetch('/api/auth/me', { headers });
```

---

## Rate Limiting (Future Implementation)

Currently not implemented. Plan to add:
- 5 requests per minute per IP for login
- 3 requests per minute for registration
- 10 requests per minute for general API calls

---

## CORS Configuration

**Allowed Origins:**
```
http://localhost:3000
http://localhost:8081
http://localhost:5000
```

Update `CORS_ORIGIN` in `.env` to add/remove origins.

---

## Example Requests

### cURL Examples

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

**Verify OTP:**
```bash
curl -X POST http://localhost:5000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "otp": "123456"
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

**Get User:**
```bash
curl -X GET http://localhost:5000/api/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Logout:**
```bash
curl -X POST http://localhost:5000/api/auth/logout \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### JavaScript/Fetch Examples

**Login:**
```javascript
async function login(email, password) {
  const response = await fetch('http://localhost:5000/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password })
  });
  const data = await response.json();
  
  if (data.success) {
    localStorage.setItem('token', data.token);
    console.log('Login successful');
  } else {
    console.error('Login failed:', data.message);
  }
}
```

**Get User with Token:**
```javascript
async function getUser() {
  const token = localStorage.getItem('token');
  const response = await fetch('http://localhost:5000/api/auth/me', {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  const data = await response.json();
  return data.user;
}
```

---

## Health Check Endpoint

**Endpoint:**
```
GET /health
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2026-02-16T10:30:00.000Z"
}
```

Use this endpoint to verify the backend is running.

---

## Local Testing URLs

- **Health Check:** http://localhost:5000/health
- **Register:** http://localhost:5000/api/auth/register
- **Login:** http://localhost:5000/api/auth/login
- **Verify OTP:** http://localhost:5000/api/auth/verify-otp
- **Google Login:** http://localhost:5000/api/auth/google
- **Get User:** http://localhost:5000/api/auth/me
- **Logout:** http://localhost:5000/api/auth/logout

---

## Upcoming Endpoints (Day 2+)

- POST `/biometric/enroll` - Enroll user biometric data
- POST `/biometric/authenticate` - Authenticate using biometric data
- GET `/biometric/status` - Get biometric enrollment status
- POST `/files/upload` - Upload video/audio files
- GET `/users/:id` - Get user profile
- PUT `/users/:id` - Update user profile

---

**Last Updated:** February 16, 2026
**API Version:** 1.0.0
**Status:** Authentication endpoints complete
