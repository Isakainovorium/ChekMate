# FIREBASE INTEGRATION TESTING GUIDE 🧪

**Purpose:** Comprehensive testing guide for Firebase integration  
**Date:** 2025-10-10  
**Status:** Ready for Testing

---

## 🎯 TESTING OVERVIEW

This guide provides step-by-step instructions to test all Firebase features integrated into the ChekMate Flutter app.

---

## 📋 PRE-TESTING CHECKLIST

### Environment Setup
- [ ] Flutter SDK installed and updated
- [ ] Firebase CLI installed
- [ ] Firebase project `chekmate-a0423` accessible
- [ ] Firebase emulators installed (optional but recommended)
- [ ] Chrome browser for web testing

### Code Verification
- [ ] All Firebase dependencies in `pubspec.yaml`
- [ ] Firebase initialized in `main.dart`
- [ ] `firebase_options.dart` configured
- [ ] All service files created (auth, user, post)
- [ ] All provider files created

---

## 🔥 FIREBASE EMULATOR SETUP (RECOMMENDED)

### Install Emulators
```bash
firebase init emulators
# Select: Authentication, Firestore, Storage
```

### Start Emulators
```bash
cd flutter_chekmate
firebase emulators:start
```

### Configure App for Emulators
Add to `main.dart` after Firebase initialization:
```dart
// FOR TESTING ONLY - Use emulators
if (kDebugMode) {
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
}
```

---

## 🧪 TEST SUITE 1: AUTHENTICATION

### Test 1.1: Sign Up with Email
**Steps:**
1. Run the app: `flutter run -d chrome`
2. Navigate to sign-up page
3. Enter test credentials:
   - Email: `test@chekmate.com`
   - Password: `Test123!`
   - Username: `testuser`
   - Display Name: `Test User`
4. Click "Sign Up"

**Expected Results:**
- ✅ User created in Firebase Auth
- ✅ User document created in Firestore `users` collection
- ✅ User redirected to home page
- ✅ No errors in console

**Verification:**
```dart
// Check in Firebase Console
// Auth > Users > Should see test@chekmate.com
// Firestore > users > Should see user document
```

### Test 1.2: Sign In with Email
**Steps:**
1. Sign out if logged in
2. Navigate to login page
3. Enter credentials:
   - Email: `test@chekmate.com`
   - Password: `Test123!`
4. Click "Sign In"

**Expected Results:**
- ✅ User authenticated
- ✅ Redirected to home page
- ✅ User profile loaded
- ✅ No errors

### Test 1.3: Sign Out
**Steps:**
1. While logged in, click "Sign Out"

**Expected Results:**
- ✅ User signed out
- ✅ Redirected to login page
- ✅ Auth state updated
- ✅ No errors

### Test 1.4: Password Reset
**Steps:**
1. On login page, click "Forgot Password"
2. Enter email: `test@chekmate.com`
3. Click "Send Reset Email"

**Expected Results:**
- ✅ Password reset email sent
- ✅ Success message displayed
- ✅ Check email inbox for reset link

### Test 1.5: Email Verification
**Steps:**
1. After sign up, click "Send Verification Email"
2. Check email inbox
3. Click verification link

**Expected Results:**
- ✅ Verification email sent
- ✅ Email verified in Firebase Auth
- ✅ `emailVerified` = true

---

## 🧪 TEST SUITE 2: USER OPERATIONS

### Test 2.1: Get User Profile
**Steps:**
1. Log in as test user
2. Navigate to profile page
3. Verify profile data displays

**Expected Results:**
- ✅ User profile loaded from Firestore
- ✅ Display name shown
- ✅ Username shown
- ✅ Stats shown (followers, following, posts)
- ✅ Avatar placeholder shown

**Code Test:**
```dart
final userService = UserService();
final user = await userService.getUserById('userId');
print('User: ${user?.displayName}');
```

### Test 2.2: Update Profile
**Steps:**
1. Navigate to Edit Profile page
2. Update fields:
   - Display Name: `Updated Name`
   - Bio: `This is my bio`
   - Location: `New York, NY`
3. Click "Save"

**Expected Results:**
- ✅ Profile updated in Firestore
- ✅ Changes reflected immediately
- ✅ Success message shown
- ✅ Profile page shows new data

### Test 2.3: Upload Profile Picture
**Steps:**
1. On Edit Profile page
2. Click "Change Profile Picture"
3. Select an image file
4. Confirm upload

**Expected Results:**
- ✅ Image uploaded to Firebase Storage
- ✅ URL saved to user document
- ✅ Profile picture displayed
- ✅ File in `profile_pictures/{userId}/` folder

### Test 2.4: Follow User
**Steps:**
1. Navigate to another user's profile
2. Click "Follow" button

**Expected Results:**
- ✅ Following count incremented for current user
- ✅ Followers count incremented for target user
- ✅ Document added to `users/{currentUserId}/following/`
- ✅ Document added to `users/{targetUserId}/followers/`
- ✅ Button changes to "Unfollow"

### Test 2.5: Unfollow User
**Steps:**
1. On followed user's profile
2. Click "Unfollow" button

**Expected Results:**
- ✅ Following count decremented
- ✅ Followers count decremented
- ✅ Documents removed from subcollections
- ✅ Button changes to "Follow"

### Test 2.6: Search Users
**Steps:**
1. Navigate to search page
2. Enter search query: `test`
3. View results

**Expected Results:**
- ✅ Users matching query displayed
- ✅ Results update as you type
- ✅ Can click user to view profile

---

## 🧪 TEST SUITE 3: POST OPERATIONS

### Test 3.1: Create Text Post
**Steps:**
1. Click "Create Post" button
2. Enter text: `This is my first post!`
3. Click "Post"

**Expected Results:**
- ✅ Post created in Firestore `posts` collection
- ✅ Post appears in feed
- ✅ User's post count incremented
- ✅ Post has correct timestamp

### Test 3.2: Create Post with Image
**Steps:**
1. Click "Create Post"
2. Enter text: `Check out this image!`
3. Select 1-3 images
4. Click "Post"

**Expected Results:**
- ✅ Images uploaded to Storage
- ✅ Post created with image URLs
- ✅ Images display in feed
- ✅ Files in `posts/{userId}/{postId}/` folder

### Test 3.3: Create Post with Video
**Steps:**
1. Click "Create Post"
2. Enter text: `My video post`
3. Select a video file
4. Click "Post"

**Expected Results:**
- ✅ Video uploaded to Storage
- ✅ Post created with video URL
- ✅ Video player shown in feed
- ✅ File in `posts/{userId}/{postId}/video.mp4`

### Test 3.4: Like Post
**Steps:**
1. View a post in feed
2. Click "Like" button

**Expected Results:**
- ✅ Like count incremented
- ✅ Like button turns red/filled
- ✅ Document added to `posts/{postId}/likes/`
- ✅ Real-time update (no refresh needed)

### Test 3.5: Unlike Post
**Steps:**
1. On a liked post
2. Click "Like" button again

**Expected Results:**
- ✅ Like count decremented
- ✅ Like button returns to outline
- ✅ Document removed from likes subcollection

### Test 3.6: Chek Post
**Steps:**
1. View a post
2. Click "Chek" button

**Expected Results:**
- ✅ Chek count incremented
- ✅ Document added to `posts/{postId}/cheks/`
- ✅ Visual feedback shown

### Test 3.7: Share Post
**Steps:**
1. View a post
2. Click "Share" button

**Expected Results:**
- ✅ Share count incremented
- ✅ Share dialog shown
- ✅ Share options available

### Test 3.8: Delete Post
**Steps:**
1. On your own post
2. Click "More" > "Delete"
3. Confirm deletion

**Expected Results:**
- ✅ Post removed from Firestore
- ✅ Images/videos deleted from Storage
- ✅ Post disappears from feed
- ✅ User's post count decremented

### Test 3.9: View Posts Feed
**Steps:**
1. Navigate to home feed
2. Scroll through posts

**Expected Results:**
- ✅ Posts load in reverse chronological order
- ✅ Real-time updates (new posts appear)
- ✅ Images load correctly
- ✅ Infinite scroll works

### Test 3.10: View User Posts
**Steps:**
1. Navigate to a user's profile
2. View their posts tab

**Expected Results:**
- ✅ Only that user's posts shown
- ✅ Posts in reverse chronological order
- ✅ Post count matches

---

## 🧪 TEST SUITE 4: REAL-TIME UPDATES

### Test 4.1: Real-time Post Updates
**Steps:**
1. Open app in two browser tabs
2. In tab 1, create a post
3. Watch tab 2

**Expected Results:**
- ✅ New post appears in tab 2 automatically
- ✅ No refresh needed
- ✅ Post appears at top of feed

### Test 4.2: Real-time Like Updates
**Steps:**
1. Open same post in two tabs
2. In tab 1, like the post
3. Watch tab 2

**Expected Results:**
- ✅ Like count updates in tab 2
- ✅ Like button state updates
- ✅ No refresh needed

### Test 4.3: Real-time Profile Updates
**Steps:**
1. Open user profile in two tabs
2. In tab 1, update profile
3. Watch tab 2

**Expected Results:**
- ✅ Profile changes appear in tab 2
- ✅ Stats update automatically
- ✅ No refresh needed

---

## 🧪 TEST SUITE 5: ERROR HANDLING

### Test 5.1: Invalid Email
**Steps:**
1. Try to sign up with email: `notanemail`

**Expected Results:**
- ✅ Error message: "Invalid email format"
- ✅ No account created
- ✅ User stays on sign-up page

### Test 5.2: Weak Password
**Steps:**
1. Try to sign up with password: `123`

**Expected Results:**
- ✅ Error message: "Password too weak"
- ✅ No account created

### Test 5.3: Duplicate Email
**Steps:**
1. Try to sign up with existing email

**Expected Results:**
- ✅ Error message: "Email already in use"
- ✅ No duplicate account created

### Test 5.4: Wrong Password
**Steps:**
1. Try to sign in with wrong password

**Expected Results:**
- ✅ Error message: "Invalid credentials"
- ✅ User not logged in

### Test 5.5: Network Error
**Steps:**
1. Disconnect internet
2. Try to create a post

**Expected Results:**
- ✅ Error message: "Network error"
- ✅ Retry option shown
- ✅ App doesn't crash

---

## 📊 TEST RESULTS TEMPLATE

```markdown
## Test Run: [Date]

### Environment
- Flutter Version: 
- Browser: 
- Firebase Emulator: Yes/No

### Test Results

#### Authentication (5 tests)
- [ ] 1.1 Sign Up: PASS/FAIL
- [ ] 1.2 Sign In: PASS/FAIL
- [ ] 1.3 Sign Out: PASS/FAIL
- [ ] 1.4 Password Reset: PASS/FAIL
- [ ] 1.5 Email Verification: PASS/FAIL

#### User Operations (6 tests)
- [ ] 2.1 Get Profile: PASS/FAIL
- [ ] 2.2 Update Profile: PASS/FAIL
- [ ] 2.3 Upload Picture: PASS/FAIL
- [ ] 2.4 Follow User: PASS/FAIL
- [ ] 2.5 Unfollow User: PASS/FAIL
- [ ] 2.6 Search Users: PASS/FAIL

#### Post Operations (10 tests)
- [ ] 3.1 Create Text Post: PASS/FAIL
- [ ] 3.2 Create Image Post: PASS/FAIL
- [ ] 3.3 Create Video Post: PASS/FAIL
- [ ] 3.4 Like Post: PASS/FAIL
- [ ] 3.5 Unlike Post: PASS/FAIL
- [ ] 3.6 Chek Post: PASS/FAIL
- [ ] 3.7 Share Post: PASS/FAIL
- [ ] 3.8 Delete Post: PASS/FAIL
- [ ] 3.9 View Feed: PASS/FAIL
- [ ] 3.10 View User Posts: PASS/FAIL

#### Real-time Updates (3 tests)
- [ ] 4.1 Post Updates: PASS/FAIL
- [ ] 4.2 Like Updates: PASS/FAIL
- [ ] 4.3 Profile Updates: PASS/FAIL

#### Error Handling (5 tests)
- [ ] 5.1 Invalid Email: PASS/FAIL
- [ ] 5.2 Weak Password: PASS/FAIL
- [ ] 5.3 Duplicate Email: PASS/FAIL
- [ ] 5.4 Wrong Password: PASS/FAIL
- [ ] 5.5 Network Error: PASS/FAIL

### Summary
- Total Tests: 29
- Passed: 
- Failed: 
- Pass Rate: %

### Issues Found
1. 
2. 
3. 

### Notes
```

---

## 🚀 AUTOMATED TESTING (FUTURE)

### Unit Tests
```dart
// test/services/auth_service_test.dart
void main() {
  group('AuthService', () {
    test('signUpWithEmail creates user', () async {
      // Test implementation
    });
  });
}
```

### Widget Tests
```dart
// test/widgets/post_card_test.dart
void main() {
  testWidgets('PostCard displays correctly', (tester) async {
    // Test implementation
  });
}
```

### Integration Tests
```dart
// integration_test/app_test.dart
void main() {
  testWidgets('Complete user flow', (tester) async {
    // Test sign up, create post, like, etc.
  });
}
```

---

## ✅ TESTING COMPLETE CHECKLIST

- [ ] All 29 manual tests passed
- [ ] Firebase emulator tests passed
- [ ] Production Firebase tests passed
- [ ] Real-time updates working
- [ ] Error handling working
- [ ] No console errors
- [ ] No memory leaks
- [ ] Performance acceptable
- [ ] Security rules tested
- [ ] Storage rules tested

---

**🧪 READY TO TEST! 🧪**

Follow this guide to thoroughly test all Firebase integration features!

