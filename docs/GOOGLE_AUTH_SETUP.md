# AILens Google OAuth Setup Guide

## Overview
This guide covers setting up Google Sign-In authentication for AILens across web, mobile (React Native), and backend APIs.

## Prerequisites
- Google Account
- Google Cloud Project
- Familiarity with Google Cloud Console

## Step 1: Create Google Cloud Project

### 1.1 Create New Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click on the project dropdown at the top
3. Click "NEW PROJECT"
4. **Project name:** AILens
5. **Organization:** Your organization (optional)
6. **Location:** Default
7. Click "CREATE"

Wait for the project to be created (usually 1-2 minutes).

### 1.2 Select Your Project
- Once created, select the AILens project from the dropdown

## Step 2: Enable Required APIs

### 2.1 Enable Google+ API
1. In the search bar at the top, type "Google+ API"
2. Click on "Google+ API" from results
3. Click "ENABLE"

### 2.2 Enable Identity Toolkit API (Optional but Recommended)
1. Search for "Identity Toolkit API"
2. Click on the result
3. Click "ENABLE"

### 2.3 Enable Sign-In with Google
1. Search for "Login with Google" in the marketplace
2. Select "Google Sign-In"
3. Click or follow any additional setup instructions

## Step 3: Create OAuth 2.0 Credentials

### 3.1 Create OAuth Consent Screen

1. Go to **APIs & Services** > **OAuth consent screen**
2. Select **External** (if internal, skip directly to step 3.2)
3. Click "CREATE"

**Form Details:**

**OAuth Consent Screen:**
- **App name:** AILens
- **User support email:** your-email@gmail.com
- **Developer contact information:** your-email@gmail.com

**Scopes:**
- Click "ADD OR REMOVE SCOPES"
- Search for and add these scopes:
  - `userinfo.email`
  - `userinfo.profile`
  - `openid`
- Click "UPDATE" and "SAVE AND CONTINUE"

**Test users (for development):**
- Click "ADD USERS"
- Add your email and any test email addresses
- Click "SAVE AND CONTINUE"

**Summary:**
- Review and click "BACK TO DASHBOARD"

### 3.2 Create OAuth 2.0 Client ID

1. Go to **APIs & Services** > **Credentials**
2. Click "CREATE CREDENTIALS" > **OAuth client ID**
3. Select **Web application** (we'll create separate ones for mobile later)

**Web Application Configuration:**

**Name:** AILens Web Client

**Authorized JavaScript origins:**
- `http://localhost:3000`
- `http://localhost:8080`
- (Add production URLs later)

**Authorized redirect URIs:**
- `http://localhost:3000/auth/callback`
- `http://localhost:5000/auth/google/callback`
- (Add production URLs later)

4. Click "CREATE"
5. A dialog will appear with your credentials:
   - **Client ID:** Copy this
   - **Client Secret:** Copy this

6. Click "OK"

### 3.3 Create OAuth 2.0 Client ID for Android

1. Click "CREATE CREDENTIALS" > **OAuth client ID**
2. Select **Android**
3. **Name:** AILens Android
4. **Package name:** com.ailens.app (use your actual package name)
5. Get your app's **SHA-1 certificate fingerprint:**

```bash
# Generate SHA-1 (if you have a keystore)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey

# For development, you can use the debug SHA-1:
# (It will be shown in gradlew output or Android Studio)
```

6. Paste the SHA-1 fingerprint
7. Click "CREATE"
8. Note your **Client ID**

### 3.4 Create OAuth 2.0 Client ID for iOS

1. Click "CREATE CREDENTIALS" > **OAuth client ID**
2. Select **iOS**
3. **Name:** AILens iOS
4. **Bundle ID:** com.ailens.app (use your actual bundle ID)
5. Get your app's **iOS URL scheme(s):**
   - Usually: `com.googleusercontent.apps.<CLIENT_ID>`
   - Can also be custom: `ailens://oauth`
6. Click "CREATE"
7. Note your **Client ID**

## Step 4: Update Environment Variables

### 4.1 Backend (.env)

```
GOOGLE_CLIENT_ID=your_web_client_id_here
GOOGLE_CLIENT_SECRET=your_web_client_secret_here
GOOGLE_CALLBACK_URL=http://localhost:5000/auth/google/callback
```

### 4.2 Mobile (.env)

```
EXPO_PUBLIC_GOOGLE_CLIENT_ID=your_android_or_ios_client_id
EXPO_PUBLIC_GOOGLE_CLIENT_SECRET=your_google_client_secret_here
```

### 4.3 Frontend Web (.env if applicable)

```
REACT_APP_GOOGLE_CLIENT_ID=your_web_client_id_here
```

## Step 5: Backend Implementation

### 5.1 Install Dependencies

```bash
cd backend
npm install google-auth-library passport-google-oauth20
```

### 5.2 Update Backend Code

The initial `/api/auth/google` endpoint is already set up. For production, we need to verify the token:

```javascript
const { OAuth2Client } = require('google-auth-library');

const client = new OAuth2Client({
  clientID: process.env.GOOGLE_CLIENT_ID,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET,
  redirectUrl: process.env.GOOGLE_CALLBACK_URL,
});

async function verifyToken(token) {
  try {
    const ticket = await client.verifyIdToken({
      idToken: token,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    return ticket.getPayload();
  } catch (error) {
    console.error('Token verification failed:', error);
    throw error;
  }
}
```

### 5.3 Update Auth Controller

The backend auth controller already has a placeholder for Google login. Update it to use real verification.

## Step 6: Mobile Implementation

### 6.1 Install Dependencies

```bash
cd mobile

# For Expo
expo install expo-auth-session expo-web-browser

# Or using npm/yarn
npm install expo-auth-session expo-web-browser google-auth-library
```

### 6.2 Configure Expo

In `app.json`:

```json
{
  "expo": {
    "plugins": [
      [
        "expo-auth-session",
        {
          "googleClient": {
            "androidClientId": "your_android_client_id.apps.googleusercontent.com",
            "iosClientId": "your_ios_client_id.apps.googleusercontent.com"
          }
        }
      ]
    ],
    "scheme": "ailens"
  }
}
```

### 6.3 Create Google Login Component

```javascript
import * as Google from 'expo-auth-session/providers/google';
import * as WebBrowser from 'expo-web-browser';

WebBrowser.maybeCompleteAuthSession();

export function GoogleLoginButton() {
  const [request, response, promptAsync] = Google.useAuthRequest({
    clientId: process.env.EXPO_PUBLIC_GOOGLE_CLIENT_ID,
    iosClientId: process.env.EXPO_PUBLIC_GOOGLE_CLIENT_ID,
    androidClientId: process.env.EXPO_PUBLIC_GOOGLE_CLIENT_ID,
  });

  const handleGoogleLogin = async () => {
    const result = await promptAsync();
    if (result?.type === 'success') {
      const { id_token } = result.params;
      // Send id_token to backend
      const response = await fetch(`${API_BASE_URL}/auth/google`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ token: id_token }),
      });
      // Handle response
    }
  };

  return (
    <TouchableOpacity onPress={handleGoogleLogin}>
      <Text>Sign in with Google</Text>
    </TouchableOpacity>
  );
}
```

## Step 7: Testing

### 7.1 Test Web Application

1. Go to `http://localhost:3000`
2. Click "Sign in with Google"
3. Verify redirection to Google login
4. Check that you're redirected back to `http://localhost:3000/auth/callback`

### 7.2 Test Backend

```bash
curl -X POST http://localhost:5000/api/auth/google \
  -H "Content-Type: application/json" \
  -d '{
    "token": "your_google_id_token_here"
  }'
```

### 7.3 Test Mobile App

1. Run the Expo app
2. Click "Sign in with Google"
3. Complete Google login flow
4. Verify you're logged in

## Troubleshooting

### Error: "Redirect URI mismatch"
- **Solution:** Ensure the redirect URI in Google Console matches exactly with your code
- Check for trailing slashes, http vs https, domain names

### Error: "Invalid client"
- **Solution:** Double-check your Client ID and Secret
- Ensure you're using the correct credentialtype (Web, Android, iOS)

### Error: "Scope not allowed"
- **Solution:** Check that the requested scopes are configured in the OAuth consent screen
- Re-create the OAuth consent screen if needed

### Error: "User cancelled"
- **Solution:** This is expected behavior when user closes the login dialog
- Handle gracefully in your UI

### Test User Not Working
- **Solution:** Only test users added to the OAuth consent screen can test external apps
- Add your test email in the "Test users" section

### Mobile App Not Redirecting
- **Solution:** Verify the scheme and redirect URL configuration
- Check that the app is properly configured in app.json
- For Android, ensure SHA-1 fingerprint matches your keystore

## Production Deployment

### 1. Update Consent Screen to Production
- Go to OAuth consent screen
- Change from "External" to "Internal" or add more test users

### 2. Update Redirect URIs
- Add production domains to Google Cloud Console:
  - Backend: `https://api.yourdomain.com/auth/google/callback`
  - Frontend: `https://yourdomain.com/auth/callback`

### 3. Use HTTPS Everywhere
- Ensure all URLs use https in production

### 4. Store Secrets Securely
- Use environment variables in production
- Never commit .env files to version control
- Use services like AWS Secrets Manager or Google Secret Manager

### 5. Verify Token Signature
- Implement proper token verification in backend
- Don't trust tokens without verification

## Additional Resources

- [Google Sign-In Documentation](https://developers.google.com/identity)
- [OAuth 2.0 Playground](https://developers.google.com/oauthplayground)
- [Google API Client Libraries](https://developers.google.com/identity/protocols/oauth2/)
- [Expo Auth Session Docs](https://docs.expo.dev/guides/authentication/)

---

**Last Updated:** February 16, 2026
**Status:** Setup Guide Complete
**Next Step:** Implement backend token verification
**Assigned to:** @Raghav
