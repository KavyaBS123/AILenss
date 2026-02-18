# AILens FastAPI Backend - API Reference

## Base URL
```
http://localhost:5000
```

## API Endpoints Documentation

---

## 🔐 Authentication Endpoints

### 1. Register User
**POST** `/api/auth/register`

Register a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "phone": "+1234567890",
  "password": "SecurePassword123!",
  "password_confirm": "SecurePassword123!"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "User registered successfully. OTP sent to email.",
  "otp": "123456",
  "email": "user@example.com"
}
```

**Error Responses:**
- `400` - Passwords don't match
- `400` - Email already registered
- `400` - Password too short (min 8 characters)

---

### 2. Login User
**POST** `/api/auth/login`

Authenticate user and receive OTP.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Login successful. OTP sent to email.",
  "otp": "123456",
  "email": "user@example.com"
}
```

**Error Responses:**
- `401` - Invalid email or password
- `401` - User account inactive
- `404` - User not found

---

### 3. Verify OTP
**POST** `/api/auth/verify-otp`

Verify OTP and receive JWT access token.

**Request Body:**
```json
{
  "email": "user@example.com",
  "otp": "123456"
}
```

**Success Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNjc2NDA=",
  "token_type": "bearer",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "phone": "+1234567890",
    "is_active": true,
    "is_verified": true
  }
}
```

**Error Responses:**
- `401` - Invalid OTP
- `401` - OTP expired (valid for 5 minutes)
- `404` - User not found

---

### 4. Get Current User
**GET** `/api/auth/me`

Get the profile of the currently authenticated user.

**Headers:**
```
Authorization: Bearer {access_token}
```

**Success Response (200):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "phone": "+1234567890",
  "is_active": true,
  "is_verified": true
}
```

**Error Responses:**
- `401` - Invalid or missing token
- `404` - User not found

---

### 5. Logout
**POST** `/api/auth/logout`

Logout the current user (token-based, no server-side logout needed).

**Headers:**
```
Authorization: Bearer {access_token}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## 🏥 System Endpoints

### Health Check
**GET** `/health`

Check if the backend server is running.

**Success Response (200):**
```json
{
  "status": "ok",
  "message": "AILens Backend is running",
  "environment": "development"
}
```

---

### API Info
**GET** `/`

Get information about the API.

**Success Response (200):**
```json
{
  "message": "Welcome to AILens API",
  "version": "1.0.0",
  "docs": "/docs"
}
```

---

## 📚 User Model

### User Schema
```json
{
  "id": 1,
  "email": "user@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "phone": "+1234567890",
  "is_active": true,
  "is_verified": false,
  "created_at": "2024-02-16T12:00:00",
  "updated_at": "2024-02-16T12:00:00"
}
```

### Database Fields
- `id` - Primary key, auto-increment
- `email` - Unique email address
- `first_name` - User's first name
- `last_name` - User's last name
- `phone` - Phone number
- `hashed_password` - Bcrypt hashed password
- `is_active` - Account status
- `is_verified` - Email/OTP verification status
- `otp` - One-time password (for verification)
- `otp_created_at` - Timestamp of OTP creation
- `created_at` - Account creation timestamp
- `updated_at` - Last update timestamp

---

## 🔑 Authentication

### JWT Token
The backend uses JWT (JSON Web Tokens) for authentication.

**Token Format:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Token Payload:**
```json
{
  "sub": "1",           // User ID
  "exp": 1676400000    // Expiration time (30 minutes from creation)
}
```

### Token Usage
Include the token in the `Authorization` header for protected endpoints:

```bash
curl -X GET http://localhost:5000/api/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## Error Handling

### Error Response Format
All errors follow this format:

```json
{
  "success": false,
  "message": "Error description",
  "detail": "Additional error details"
}
```

### Common HTTP Status Codes
- `200` - OK, request successful
- `201` - Created, resource created successfully
- `400` - Bad request, validation error
- `401` - Unauthorized, authentication failed
- `404` - Not found, resource doesn't exist
- `500` - Internal server error

---

## 🚀 Usage Examples

### Complete Authentication Flow

#### 1. Register
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@ailens.app",
    "first_name": "Jane",
    "last_name": "Smith",
    "phone": "+1987654321",
    "password": "SecurePass123!",
    "password_confirm": "SecurePass123!"
  }'
```

#### 2. Login
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@ailens.app",
    "password": "SecurePass123!"
  }'
```

Note the OTP in the response!

#### 3. Verify OTP
```bash
curl -X POST http://localhost:5000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@ailens.app",
    "otp": "123456"
  }'
```

Save the `access_token`!

#### 4. Get Current User
```bash
curl -X GET http://localhost:5000/api/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## 📱 Flutter Integration

### API Service Configuration
The Flutter app automatically manages these calls. Configuration:

```dart
// App initializes with:
ApiService apiService = ApiService();

// All requests include these headers:
{
  'Content-Type': 'application/json',
  'Authorization': 'Bearer {token}' // For authenticated requests
}
```

### Example: Login Flow in Flutter
```dart
// 1. Login
final loginResponse = await apiService.login(
  email: 'user@ailens.app',
  password: 'SecurePass123!',
);
// Returns: OTP and token

// 2. Verify OTP
final verifyResponse = await apiService.verifyOTP(
  email: 'user@ailens.app',
  otp: '123456',
);
// Returns: JWT token and user info

// 3. Get User Data
final userResponse = await apiService.getCurrentUser(token);
// Returns: User profile
```

---

## 🔒 Security Features

### Password Security
- Passwords are hashed using **bcrypt**
- Never stored in plain text
- Minimum 8 characters required
- Never returned in responses

### JWT Security
- Uses **HS256** algorithm
- 30-minute expiration time
- Secret key stored in `.env`
- Should be transmitted over HTTPS in production

### OTP Security
- 6-digit random code
- 5-minute expiration
- Regenerated on each login
- Never stored in logs

---

## 🛠️ Development Notes

### Database
- Using **SQLite** for development
- Automatic table creation on startup
- Located at `ailens.db`

### Environment Variables
```
SECRET_KEY=your-secret-key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
DATABASE_URL=sqlite:///./ailens.db
CORS_ORIGINS=["*"]
```

### Testing with Swagger UI
Visit: http://localhost:5000/docs

- Try all endpoints interactively
- See request/response schemas
- Generate code samples

---

## 📞 Support & Documentation

- **FastAPI Official Docs:** https://fastapi.tiangolo.com/
- **SQLModel Docs:** https://sqlmodel.tiangolo.com/
- **Pydantic Docs:** https://docs.pydantic.dev/

---

**Backend Version:** 1.0.0  
**Last Updated:** February 2024
