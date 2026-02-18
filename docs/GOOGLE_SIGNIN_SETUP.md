# Google Sign-In Setup - Complete

## ✅ Configuration Completed

Your AILens app is now configured with Google Sign-In using the credentials:

**Organization**: AILens  
**Project ID**: ailens-487617  
**Client ID**: 533580524636-om06c72ge6doe8va12el3r25ovg4t1r4.apps.googleusercontent.com

---

## 📁 Files Updated

### 1. **mobile_flutter/.env**
```env
GOOGLE_CLIENT_ID=533580524636-om06c72ge6doe8va12el3r25ovg4t1r4.apps.googleusercontent.com
```
✅ Client ID loaded from environment

### 2. **backend_fastapi/.env**
```env
GOOGLE_CLIENT_ID=533580524636-om06c72ge6doe8va12el3r25ovg4t1r4.apps.googleusercontent.com
GOOGLE_PROJECT_ID=ailens-487617
```
✅ Backend configured with Google project

### 3. **mobile_flutter/lib/services/google_signin_service.dart**
- Updated to use `AppConfig` for client ID
- Uses environment variable credentials
- Supports both Android and iOS

### 4. **mobile_flutter/android/app/google-services.json**
- Created with AILens configuration
- Contains OAuth credentials
- Ready for Android build

---

## 🚀 To Use Google Sign-In

### Step 1: Verify AppConfig is Loading

The app automatically loads Google Client ID from `.env`:

```dart
// In AppConfig.instance:
String googleClientId = AppConfig.instance.googleClientId;
// Returns: "533580524636-om06c72ge6doe8va12el3r25ovg4t1r4.apps.googleusercontent.com"
```

### Step 2: Clean and Rebuild App

```bash
cd mobile_flutter
flutter clean
flutter pub get
flutter run
```

### Step 3: Test Google Sign-In

1. Run the app on Android emulator or physical device
2. On Login screen, click **"Sign in with Google"** button
3. Select your Google account
4. App will authenticate and navigate to Home screen

---

## 🔐 Security Notes

### What's Configured

✅ **Client ID** - Public (safe to share)  
❌ **Client Secret** - Only needed for backend OAuth flow (not in mobile app)  
✅ **android/app/google-services.json** - Firebase/Google configuration  
✅ **Environment variables** - Loaded at runtime  

### How It Works

1. **App starts** → Loads `.env` file
2. **AppConfig initialized** → Client ID loaded from env
3. **GoogleSignInService.initialize()** → Sets up Google Sign-In with client ID
4. **User clicks "Sign in with Google"** → Opens Google login
5. **Google authenticates** → Returns ID token to app
6. **App stores token** → Securely in Keystore/Keychain

---

## ✅ Verification Checklist

- [x] Client ID added to `.env`
- [x] GoogleSignInService updated to use AppConfig
- [x] google-services.json created
- [x] Backend .env configured
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Run `flutter run`
- [ ] Test login with Google account
- [ ] Verify home screen appears after auth

---

## 🧪 Testing Google Sign-In

### On Android Emulator

```bash
# 1. Start emulator
flutter emulators --launch

# 2. Make sure Play Services installed
adb shell pm list packages | grep "google"

# 3. Run app
flutter run

# 4. Click "Sign in with Google"
```

### On iOS Simulator

```bash
# iOS will show popup automatically
flutter run -d ios
```

### On Physical Device

```bash
# Physical device has Play Services
flutter run -d <device_id>
```

---

## 🐛 Troubleshooting

### Issue: "The application does not have permission"

**Cause**: SHA-1 fingerprint mismatch  
**Solution**: Verify SHA-1 matches in Google Console

### Issue: "Google Sign-In error"

**Check**:
1. `google-services.json` in `android/app/`
2. Client ID in `.env`
3. Android package name is `com.example.ailens`

### Issue: "PlatformException: com.google.android.gms.common.api.ApiException"

**Solution**: Update Google Play Services
```bash
flutter pub upgrade
flutter clean
flutter pub get
flutter run
```

---

## 📱 Platform-Specific Setup

### Android

✅ **Configured automatically via:**
- `google-services.json` in `android/app/`
- SHA-1 fingerprint: `CE:20:62:6B:D6:AF:26:06:9B:C9:47:FD:93:D1:5E:36:00:AA:D0:82`
- Package name: `com.example.ailens`

### iOS

⏳ **Still needs GoogleService-Info.plist:**
1. Go to Firebase Console
2. Add iOS app with Bundle ID: `com.example.ailens`
3. Download `GoogleService-Info.plist`
4. Add to Xcode: `Runner` → Add files → `GoogleService-Info.plist`

---

## 🔗 Integration with Backend (Optional Future)

When you want backend to validate Google tokens:

```python
# backend_fastapi/app/api/auth.py
from google.auth.transport import requests
from google.oauth2 import id_token

@app.post("/api/auth/google-login")
async def google_login(token: str):
    # Verify token with Google
    try:
        idinfo = id_token.verify_oauth2_token(
            token, 
            requests.Request(), 
            settings.GOOGLE_CLIENT_ID
        )
        # idinfo['email'], idinfo['name'], etc.
        return {"message": "Authenticated", "user": idinfo['email']}
    except ValueError:
        return {"error": "Invalid token"}
```

---

## 📚 Additional Resources

- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Firebase Console](https://console.firebase.google.com/)

---

## ✨ What's Next?

1. **Test Google Sign-In** ← Do this first!
2. Create user profile screen after Google login
3. Link Google account to biometric data
4. Add backend validation (optional)
5. Migrate from demo mode to real authentication

---

**Status**: ✅ Google Sign-In Ready  
**Configuration Date**: February 16, 2026  
**Client ID**: 533580524636-om06c72ge6doe8va12el3r25ovg4t1r4.apps.googleusercontent.com
