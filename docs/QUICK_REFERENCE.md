# AILens Quick Reference Guide

**Last Updated:** February 16, 2026

---

## 🚀 Quick Start Commands

### Backend
```bash
# Install dependencies
cd backend && npm install

# Start development server
npm run dev

# Start production server
npm start
```

### Mobile
```bash
# Install dependencies
cd mobile && npm install

# Start Expo
npm start

# Run on Android
npm run android

# Run on iOS
npm run ios

# Run on Web
npm run web
```

---

## 🔗 API Endpoints Quick Reference

**Base URL:** `http://localhost:5000/api`

### Authentication Endpoints

| Method | Endpoint | Auth | Body |
|--------|----------|------|------|
| POST | `/auth/register` | No | firstName, lastName, email, phone, password, passwordConfirm |
| POST | `/auth/verify-otp` | No | email, otp |
| POST | `/auth/login` | No | email, password |
| POST | `/auth/google` | No | token |
| GET | `/auth/me` | Yes | - |
| POST | `/auth/logout` | Yes | - |

---

## 📝 API Request Examples

### Register User
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "phone": "9876543210",
    "password": "SecurePass123",
    "passwordConfirm": "SecurePass123"
  }'
```

### Verify OTP
```bash
curl -X POST http://localhost:5000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "otp": "123456"
  }'
```

### Login
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "SecurePass123"
  }'
```

### Get User Profile
```bash
curl -X GET http://localhost:5000/api/auth/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Health Check
```bash
curl http://localhost:5000/health
```

---

## 🔐 Environment Variables

### Backend (.env)
```
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/ailens
JWT_SECRET=your_secret_here
JWT_EXPIRATION=7d
GOOGLE_CLIENT_ID=your_client_id
GOOGLE_CLIENT_SECRET=your_secret
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_S3_BUCKET=ailens-storage
OTP_SECRET=123456
CORS_ORIGIN=http://localhost:3000,http://localhost:8081
```

### Mobile (.env)
```
EXPO_PUBLIC_API_BASE_URL=http://localhost:5000/api
EXPO_PUBLIC_GOOGLE_CLIENT_ID=your_client_id
EXPO_PUBLIC_APP_NAME=AILens
EXPO_PUBLIC_VERSION=1.0.0
EXPO_PUBLIC_DEBUG=true
```

---

## 🗂️ Project Structure at a Glance

```
AILens/
├── backend/          Express.js API server
├── mobile/           React Native/Expo app
├── docs/             Comprehensive documentation
└── README.md         Main project overview
```

---

## 🧑‍💻 Common Development Tasks

### Update Environment Variables
```bash
# Backend
cd backend
cp .env.example .env
# Edit .env with your credentials

# Mobile
cd mobile
cp .env.example .env
# Edit .env with your credentials
```

### Test Database Connection
```bash
# MongoDB local
mongo mongodb://localhost:27017/ailens

# MongoDB Atlas
mongo "mongodb+srv://user:pass@cluster.mongodb.net/ailens"
```

### View Server Logs
```bash
# Backend logs appear in terminal running: npm run dev
# Check for error messages related to:
# - Database connection
# - Port already in use
# - Environment variables
```

### Reset Database
```bash
# Warning: This deletes all data
# Connect to MongoDB and run:
db.users.deleteMany({})
db.users.drop()
```

---

## 🔑 Important Credentials (Development Only)

### Test User
```
Email: test@example.com
Phone: 9876543210
Password: Test@123
OTP: 123456
```

### Hardcoded Values
```
OTP_SECRET=123456
JWT_EXPIRATION=7d
Account Lockout=5 attempts × 2 hours
OTP Expiration=10 minutes
```

---

## 🐛 Troubleshooting

### "Port already in use"
```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# Mac/Linux
lsof -i :5000
kill -9 <PID>
```

### "Cannot find module"
```bash
# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

### "MongoDB connection error"
```bash
# Check if MongoDB is running
# Local: mongod should be running
# Atlas: Check connection string in .env
```

### "CORS error"
```bash
# Update CORS_ORIGIN in backend .env
CORS_ORIGIN=http://your-frontend-url:port
```

---

## 📊 Response Codes Reference

| Code | Meaning | Typical Example |
|------|---------|-----------------|
| 200 | OK | Login successful |
| 201 | Created | User registered |
| 400 | Bad Request | Missing fields |
| 401 | Unauthorized | Invalid credentials |
| 403 | Forbidden | Account locked |
| 404 | Not Found | User not found |
| 500 | Server Error | Database error |

---

## 🔐 JWT Token Information

```javascript
// Payload structure
{
  "id": "507f1f77bcf86cd799439011",
  "iat": 1676234400,
  "exp": 1677012000
}

// Expiration: 7 days
// Format: Bearer <token>
// Usage: Authorization header
```

---

## 📚 Documentation Links

- **[Setup Guide](./SETUP.md)** - Complete installation
- **[API Documentation](./API_DOCUMENTATION.md)** - Full endpoint reference
- **[Database Schema](./DATABASE_SCHEMA.md)** - MongoDB structure
- **[Google OAuth Setup](./GOOGLE_AUTH_SETUP.md)** - Sign-in with Google
- **[Day 1 Summary](./DAY1_SUMMARY.md)** - What was completed

---

## 🎯 Daily Checklist

### Morning
- [ ] Backend running (`npm run dev`)
- [ ] Database connected
- [ ] Check .env files updated

### Development
- [ ] Test API endpoints
- [ ] Check error logs
- [ ] Commit changes regularly

### End of Day
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Code committed to git

---

## 🤝 Git Commands

```bash
# Clone project
git clone <repo-url>

# Create branch
git checkout -b feature/feature-name

# Check status
git status

# Add files
git add .

# Commit
git commit -m "descriptive message"

# Push
git push origin feature/feature-name

# View logs
git log --oneline
```

---

## 📱 Mobile Testing

### iOS Simulator
```bash
cd mobile
npm run ios
```

### Android Emulator
```bash
cd mobile
npm run android
```

### Web Browser
```bash
cd mobile
npm run web
```

### Physical Device
1. Install Expo Go app
2. Run: `npm start`
3. Scan QR code with camera/Expo Go

---

## 🔧 Useful Tools

| Tool | Purpose | URL |
|------|---------|-----|
| Postman | API testing | postman.com |
| MongoDB Compass | Database GUI | mongodb.com/products/compass |
| VS Code | Code editor | code.visualstudio.com |
| Expo | React Native | expo.dev |
| Google Cloud Console | OAuth setup | console.cloud.google.com |

---

## 📞 Quick Help

| Issue | Look in... |
|-------|-----------|
| API not responding | [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) |
| Database errors | [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md) |
| Setup problems | [SETUP.md](./SETUP.md) |
| Google Sign-In issues | [GOOGLE_AUTH_SETUP.md](./GOOGLE_AUTH_SETUP.md) |
| General questions | [README.md](../README.md) |

---

## 🎓 Learning Paths

### For Backend Developers
1. Read [SETUP.md](./SETUP.md) - Installation
2. Read [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md) - Data structure
3. Read [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) - Endpoints
4. Test endpoints with curl/Postman
5. Review code in `backend/`

### For Mobile Developers
1. Read [SETUP.md](./SETUP.md) - Installation
2. Read [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) - Endpoints
3. Review mobile code in `mobile/src/`
4. Test API integration
5. Build UI components

### For DevOps/Infrastructure
1. Read [README.md](../README.md) - Overview
2. Review .env configurations
3. Plan AWS S3 setup
4. Plan MongoDB deployment
5. Plan GitHub Actions/CI-CD

---

## 💾 Key Files Quick Lookup

| File | Purpose | Priority |
|------|---------|----------|
| backend/index.js | Server entry point | ⭐⭐⭐ |
| backend/models/User.js | Database schema | ⭐⭐⭐ |
| backend/routes/auth.js | API routes | ⭐⭐⭐ |
| backend/.env | Configuration | ⭐⭐⭐ |
| mobile/src/services/api.js | API client | ⭐⭐⭐ |
| docs/API_DOCUMENTATION.md | API reference | ⭐⭐ |
| docs/GOOGLE_AUTH_SETUP.md | OAuth config | ⭐⭐ |

---

## ✨ Pro Tips

1. **Always backup .env file** - Don't commit it to git
2. **Use Postman** - Test APIs before implementing frontend
3. **Check logs first** - Error messages are usually clear
4. **Start simple** - Test basic endpoints first
5. **Document changes** - Keep docs updated
6. **Use git branches** - Keep main branch clean
7. **Test locally first** - Before deploying
8. **Version APIs** - Plan for v2.0 later

---

**Happy Coding! 🚀**

---

**Last Updated:** February 16, 2026
**Version:** 1.0
**Status:** Day 1 Complete
