# AILens Database Schema

## Overview
AILens uses MongoDB as the primary database for storing user data, biometric information, and authentication details.

## Collections

### Users Collection

#### Schema Structure

```javascript
{
  _id: ObjectId,
  
  // Basic Information
  firstName: String (required),
  lastName: String (required),
  email: String (required, unique),
  phone: String (required, unique),
  
  // Authentication
  password: String (hashed, select: false),
  otp: {
    code: String,
    expiresAt: Date,
    verified: Boolean
  },
  
  // Google OAuth
  googleId: String (unique, sparse),
  googleProfile: Object,
  
  // Biometric Data (3D Mapping & Video)
  biometricData: {
    videoRecording: {
      url: String,           // S3 URL
      uploadedAt: Date,
      processedAt: Date
    },
    faceData: {
      threedMapping: Object, // 3D coordinates/mesh data
      landmarks: Object,     // Facial landmarks
      embedding: [Number]    // Face recognition vector
    },
    voiceData: {
      recordings: [{
        url: String,         // S3 URL
        uploadedAt: Date,
        processedAt: Date
      }],
      voicePrint: Object     // Voice recognition vector
    }
  },
  
  // Account Status
  isActive: Boolean (default: true),
  isEmailVerified: Boolean (default: false),
  isPhoneVerified: Boolean (default: false),
  isBiometricEnrolled: Boolean (default: false),
  
  // Profile
  profilePhoto: String,      // S3 URL
  bio: String,
  
  // Security
  lastLogin: Date,
  loginAttempts: Number (default: 0),
  lockUntil: Date,           // Account locked until this date
  
  // Preferences
  preferences: {
    enableNotifications: Boolean (default: true),
    enableBiometricAuth: Boolean (default: false),
    language: String (default: 'en')
  },
  
  // Timestamps
  createdAt: Date (default: now),
  updatedAt: Date (default: now)
}
```

## Indexes

### Recommended Indexes for Performance

```javascript
// Email lookup
db.users.createIndex({ email: 1 }, { unique: true })

// Phone lookup
db.users.createIndex({ phone: 1 }, { unique: true })

// Google ID lookup
db.users.createIndex({ googleId: 1 }, { unique: true, sparse: true })

// Activity tracking
db.users.createIndex({ lastLogin: -1 })

// Account status queries
db.users.createIndex({ isActive: 1, isPhoneVerified: 1 })

// TTL Index for OTP cleanup (auto-delete expired OTPs)
db.users.createIndex({ "otp.expiresAt": 1 }, { expireAfterSeconds: 0 })
```

## Data Relationships

### User Relationships (Future)
- Users → Sessions (one user has many sessions)
- Users → Logs (one user has many activity logs)
- Users → Notifications (one user has many notifications)
- Users → BiometricComparisons (one user has many comparisons)

## Security Considerations

1. **Password Storage:**
   - All passwords are hashed using bcryptjs (10 salt rounds)
   - Passwords are excluded from queries by default (select: false)

2. **Unique Constraints:**
   - Email and phone are unique
   - Google ID is unique but sparse (allows null values)

3. **Data Privacy:**
   - Biometric data stored securely
   - Video/audio files stored in S3 with private ACL
   - OTP auto-expires after set time

4. **Account Lockout:**
   - Automatic lockout after 5 failed login attempts
   - 2-hour lockout period

## Data Privacy

### Sensitive Fields
- `password` - Never returned in API responses (select: false)
- `otp.code` - Only used for verification, not stored after verification
- `googleProfile` - Contains profile information

### GDPR Considerations
- Implement right to be forgotten
- Allow data export functionality
- Clear consent for biometric data storage
- Define retention policies for biometric data

## Backup & Recovery

### Backup Strategy
```bash
# Monthly full backup
mongodump --uri="mongodb+srv://<user>:<pass>@cluster.mongodb.net/ailens" \
  --out=/backups/ailens-$(date +%Y%m%d)

# Daily incremental backup (using oplog)
```

### Retention Policy
- Full backups: Keep 3 months
- Incremental backups: Keep 1 month
- OTP records: Auto-delete after expiration

## Migration Notes

### Version 1.0 Schema Changes
- Initial schema setup (Feb 16, 2026)
- OTP field structure with expiration
- Biometric data schema for 3D mapping and voice
- Security fields for account lockout

### Future Schema Updates
- Will be documented in migration notes
- Use MongoDB schema versioning best practices

## Example Queries

### Find user by email
```javascript
db.users.findOne({ email: "user@example.com" })
```

### Find verified users
```javascript
db.users.find({ isPhoneVerified: true, isBiometricEnrolled: true })
```

### Find locked accounts
```javascript
db.users.find({ lockUntil: { $gt: new Date() } })
```

### Find users with biometric data
```javascript
db.users.find({ "biometricData.faceData.embedding": { $exists: true } })
```

### Find users created in last 7 days
```javascript
db.users.find({ 
  createdAt: { 
    $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) 
  } 
})
```

## Performance Optimization

1. **Connection Pooling:** Use MongoDB connection pooling (default: 50-100 connections)
2. **Query Optimization:** Use indexes on frequently queried fields
3. **Caching:** Implement Redis for session/token caching
4. **Pagination:** Use limit and skip for list queries
5. **Aggregation:** Use MongoDB aggregation pipeline for complex queries

---

**Last Updated:** February 16, 2026
**Schema Version:** 1.0
