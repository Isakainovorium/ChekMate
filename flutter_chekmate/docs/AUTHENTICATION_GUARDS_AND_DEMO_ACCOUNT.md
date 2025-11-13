# Authentication Guards & Demo Account Setup

## 📋 Overview

This document describes the authentication guards implementation and demo account setup for the ChekMate Flutter web application.

---

## 🔒 Authentication Guards

### Implementation Details

**Location:** `flutter_chekmate/lib/core/router/app_router_enhanced.dart`

### Features

1. **Automatic Redirect to Login**
   - Unauthenticated users are automatically redirected to `/login` when accessing protected routes
   - The intended destination is preserved in a `returnTo` query parameter
   - After successful login, users are redirected to their intended destination

2. **Public Routes**
   - `/login` - Login page
   - `/signup` - Signup page
   - `/auth/two-factor-verification` - Two-factor verification page

3. **Protected Routes**
   - All other routes require authentication
   - Includes: home, profile, messages, notifications, explore, live, etc.

4. **Post-Login Redirect**
   - If user logs in with a `returnTo` parameter, they're redirected to that page
   - Otherwise, they're redirected to the home page (`/`)

### How It Works

```dart
// Authentication redirect logic in GoRouter
redirect: (context, state) {
  final authState = ref.read(authStateProvider);
  final isAuthenticated = authState.value != null;
  
  // Define public routes
  final publicRoutes = [
    RoutePaths.login,
    RoutePaths.signup,
    RoutePaths.twoFactorVerification,
  ];
  
  final isPublicRoute = publicRoutes.contains(state.matchedLocation);
  
  // Redirect unauthenticated users to login
  if (!isAuthenticated && !isPublicRoute) {
    final returnTo = state.matchedLocation;
    return '${RoutePaths.login}?${QueryParams.returnTo}=$returnTo';
  }
  
  // Redirect authenticated users away from login/signup
  if (isAuthenticated && (state.matchedLocation == RoutePaths.login || 
                          state.matchedLocation == RoutePaths.signup)) {
    final returnTo = state.uri.queryParameters[QueryParams.returnTo];
    if (returnTo != null && returnTo.isNotEmpty) {
      return returnTo;
    }
    return RoutePaths.home;
  }
  
  return null; // No redirect needed
},
```

### Router Refresh on Auth Changes

The router automatically refreshes when authentication state changes using `GoRouterRefreshStream`:

```dart
refreshListenable: GoRouterRefreshStream(
  ref.read(authRepositoryProvider).authStateChanges,
),
```

---

## 🎭 Demo Account

### Credentials

**Email:** `demo@chekmate.app`  
**Password:** `ChekMate2024!`

### Features

The demo account includes:

1. **User Profile**
   - Display name: Demo User
   - Username: demo_user
   - Bio: "👋 Hi! I'm a demo account for testing ChekMate. Feel free to explore all features!"
   - Profile picture (auto-generated avatar)
   - Cover photo
   - Verified badge
   - Location: San Francisco, CA
   - Age: 28
   - Interests: Technology, Travel, Photography, Music, Food

2. **Sample Posts** (3-5 posts)
   - Dating experience posts with ratings
   - Photos and captions
   - Likes, comments, and shares

3. **Sample Messages/Conversations**
   - Pre-populated conversations with other demo users

4. **Sample Notifications**
   - Various notification types (likes, comments, follows, etc.)

### Demo Account Button

**Location:** `flutter_chekmate/lib/pages/auth/login_page.dart`

A "Try Demo Account" button has been added to the login page that:
- Auto-fills the demo credentials
- Automatically triggers the login process
- Provides instant access to the app for testing

---

## 🚀 Setup Instructions

### Step 1: Download Firebase Service Account Key

1. Go to Firebase Console: https://console.firebase.google.com/project/chekmate-a0423/settings/serviceaccounts/adminsdk
2. Click **"Generate new private key"**
3. Click **"Generate key"** in the confirmation dialog
4. Save the downloaded JSON file as `serviceAccountKey.json`
5. Move it to `flutter_chekmate/scripts/` directory

⚠️ **IMPORTANT:** Never commit `serviceAccountKey.json` to Git! It's already in `.gitignore`.

### Step 2: Install Dependencies

```bash
cd flutter_chekmate/scripts
npm install
```

### Step 3: Run Demo Account Creation Script

```bash
cd flutter_chekmate/scripts
npm run create-demo
```

Or directly:

```bash
cd flutter_chekmate/scripts
node create_demo_account.js
```

### Step 4: Verify Demo Account

1. Open the app: https://chekmate-a0423.web.app
2. Click "Try Demo Account" button on the login page
3. Verify that you're logged in and can see sample data

---

## 🧪 Testing

### Test Authentication Guards

1. **Test Unauthenticated Access**
   - Open https://chekmate-a0423.web.app/#/profile (or any protected route)
   - Verify you're redirected to `/login?returnTo=/profile`

2. **Test Login Redirect**
   - Log in with demo account
   - Verify you're redirected to the intended page (`/profile`)

3. **Test Authenticated Access to Login**
   - While logged in, try to access `/login`
   - Verify you're redirected to home page

4. **Test Logout**
   - Log out
   - Try to access any protected route
   - Verify you're redirected to login

### Test Demo Account

1. **Test Demo Button**
   - Click "Try Demo Account" on login page
   - Verify credentials are auto-filled
   - Verify login is successful

2. **Test Sample Data**
   - Verify profile has demo user information
   - Verify posts are visible in feed
   - Verify messages/conversations exist
   - Verify notifications are present

---

## 📝 Demo Account Data Structure

### User Document (`users/{uid}`)

```json
{
  "uid": "auto-generated",
  "email": "demo@chekmate.app",
  "username": "demo_user",
  "displayName": "Demo User",
  "bio": "👋 Hi! I'm a demo account for testing ChekMate...",
  "avatar": "https://ui-avatars.com/api/?name=Demo+User&size=512&background=F5A623&color=fff",
  "coverPhoto": "https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=1200",
  "followers": 42,
  "following": 38,
  "posts": 12,
  "isVerified": true,
  "isPremium": false,
  "location": "San Francisco, CA",
  "age": 28,
  "gender": "Other",
  "interests": ["Technology", "Travel", "Photography", "Music", "Food"],
  "locationEnabled": true,
  "searchRadiusKm": 50.0,
  "coordinates": { "_latitude": 37.7749, "_longitude": -122.4194 },
  "geohash": "9q8yy",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "onboardingCompleted": true
}
```

---

## 🔐 Security Notes

1. **Service Account Key**
   - Keep `serviceAccountKey.json` secure
   - Never commit to version control
   - Only use for server-side operations

2. **Demo Account Password**
   - Use a strong password even for demo accounts
   - Consider rotating the password periodically
   - Monitor for unauthorized access

3. **Firestore Security Rules**
   - Ensure demo account data is read-only for other users
   - Prevent demo account from modifying critical data

---

## 📚 Related Documentation

- [Firebase Console Setup](./FIREBASE_CONSOLE_SETUP.md)
- [Demo Account Setup](../scripts/DEMO_ACCOUNT_SETUP.md)
- [Phase Tracker](./PHASE_TRACKER.md)

---

## ✅ Deployment Checklist

- [x] Authentication guards implemented in router
- [x] Demo account button added to login page
- [x] Demo account credentials configured
- [x] Demo account creation script updated
- [ ] Service account key downloaded
- [ ] Demo account created in Firebase
- [ ] Demo account tested on live deployment
- [ ] Client notified of demo credentials

---

**Last Updated:** October 27, 2025  
**Status:** Ready for Demo Account Creation

