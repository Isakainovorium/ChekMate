# ChekMate Android Deployment Testing Checklist

**Version:** 1.0  
**Date:** October 23, 2025  
**Build:** Release APK & AAB  
**Tester:** _________________  
**Device:** _________________  
**Android Version:** _________________  

---

## 📦 **Build Artifacts**

| Artifact | Location | Size | Status |
|----------|----------|------|--------|
| **APK** | `build/app/outputs/flutter-apk/app-release.apk` | 58.76 MB | ✅ Built |
| **AAB** | `build/app/outputs/bundle/release/app-release.aab` | 51.86 MB | ✅ Built |

---

## 🔧 **Pre-Installation Checks**

- [ ] **Device Requirements Met**
  - [ ] Android 5.0 (API 21) or higher
  - [ ] At least 200 MB free storage
  - [ ] Active internet connection (WiFi or mobile data)
  - [ ] Google Play Services installed

- [ ] **Developer Options Enabled**
  - [ ] USB debugging enabled (for APK installation)
  - [ ] Install from unknown sources allowed (if needed)

- [ ] **Installation Method Selected**
  - [ ] Option A: ADB install: `adb install app-release.apk`
  - [ ] Option B: Transfer APK to device and install manually
  - [ ] Option C: Upload AAB to Google Play Console (Internal Testing)

---

## 📱 **Installation Testing**

### APK Installation
- [ ] APK installs without errors
- [ ] App icon appears on home screen
- [ ] App name displays as "ChekMate"
- [ ] No installation warnings or security alerts

### First Launch
- [ ] App launches successfully
- [ ] Splash screen displays correctly
- [ ] No crash on first launch
- [ ] Permissions requested appropriately

---

## 🔐 **Authentication Testing**

### Sign Up Flow
- [ ] **Email/Password Sign Up**
  - [ ] Email validation works
  - [ ] Password strength validation works
  - [ ] Age verification (18+) enforced
  - [ ] Profile creation successful
  - [ ] Firebase user created

- [ ] **Google Sign-In**
  - [ ] Google sign-in button works
  - [ ] Google account picker appears
  - [ ] Authentication completes successfully
  - [ ] User profile created in Firestore

- [ ] **Apple Sign-In** (if available)
  - [ ] Apple sign-in button works
  - [ ] Apple authentication flow completes
  - [ ] User profile created

### Login Flow
- [ ] Email/password login works
- [ ] Google login works
- [ ] Apple login works (if available)
- [ ] "Remember me" functionality works
- [ ] Password reset flow works

### Logout
- [ ] Logout button works
- [ ] User redirected to login screen
- [ ] Session cleared properly

---

## 👤 **Profile Features**

### Profile Setup
- [ ] **Profile Photo Upload**
  - [ ] Camera capture works
  - [ ] Gallery selection works
  - [ ] Photo uploads to Firebase Storage
  - [ ] Photo displays in profile

- [ ] **Profile Information**
  - [ ] Username can be set/edited
  - [ ] Display name can be set/edited
  - [ ] Bio can be set/edited
  - [ ] Age displays correctly
  - [ ] Location can be set

- [ ] **Video Intro**
  - [ ] Video recording works
  - [ ] Video upload to Firebase Storage works
  - [ ] Video playback works
  - [ ] Video thumbnail generates correctly (using video_thumbnail package)

- [ ] **Voice Prompt**
  - [ ] Voice recording works
  - [ ] Audio upload to Firebase Storage works
  - [ ] Audio playback works

### Profile Viewing
- [ ] Own profile displays correctly
- [ ] Other users' profiles display correctly
- [ ] Profile photos load properly
- [ ] Video intros play correctly
- [ ] Voice prompts play correctly

---

## 📸 **Posts Features**

### Create Post
- [ ] **Photo Post**
  - [ ] Camera capture works
  - [ ] Gallery selection works
  - [ ] Multiple photos can be selected
  - [ ] Photos upload to Firebase Storage
  - [ ] Post caption can be added
  - [ ] Post publishes successfully

- [ ] **Video Post**
  - [ ] Video recording works
  - [ ] Video upload works
  - [ ] Video thumbnail generates (video_thumbnail package)
  - [ ] Video plays in feed

- [ ] **Post Metadata**
  - [ ] Location tagging works
  - [ ] Hashtags work
  - [ ] Mentions work (@username)

### View Posts
- [ ] Feed loads posts correctly
- [ ] Images display properly
- [ ] Videos play properly
- [ ] Video thumbnails display
- [ ] Infinite scroll works
- [ ] Pull-to-refresh works

### Interact with Posts
- [ ] Like button works
- [ ] Unlike works
- [ ] Like count updates
- [ ] Comment button opens comment section
- [ ] Comments can be added
- [ ] Comments display correctly
- [ ] Share button works
- [ ] Save post works

### Post Management
- [ ] Edit own post works
- [ ] Delete own post works
- [ ] Report post works
- [ ] Block user works

---

## 📖 **Stories Features**

### Create Story
- [ ] Photo story creation works
- [ ] Video story creation works
- [ ] Story uploads to Firebase Storage
- [ ] Story publishes successfully
- [ ] Story appears in own profile

### View Stories
- [ ] Stories ring displays on profiles
- [ ] Story viewer opens correctly
- [ ] Stories auto-advance
- [ ] Tap to skip works
- [ ] Swipe to next user works
- [ ] Story progress indicator works

### Story Interactions
- [ ] View count displays
- [ ] Story reactions work
- [ ] Story replies work
- [ ] Delete own story works

---

## 💬 **Messaging Features**

### Chat List
- [ ] Chat list loads correctly
- [ ] Unread message count displays
- [ ] Last message preview shows
- [ ] Timestamp displays correctly

### One-on-One Chat
- [ ] **Text Messages**
  - [ ] Send text message works
  - [ ] Receive text message works
  - [ ] Message timestamps display
  - [ ] Read receipts work

- [ ] **Media Messages**
  - [ ] Send photo works
  - [ ] Send video works
  - [ ] Send voice message works
  - [ ] Media uploads to Firebase Storage
  - [ ] Media displays/plays correctly

- [ ] **Message Features**
  - [ ] Typing indicator works
  - [ ] Online status displays
  - [ ] Message deletion works
  - [ ] Message editing works (if implemented)

### Voice Messages
- [ ] Voice recording works
- [ ] Voice message upload works
- [ ] Voice message playback works
- [ ] Playback controls work (play/pause/seek)

---

## 🔔 **Notifications**

### Push Notifications
- [ ] Firebase Cloud Messaging configured
- [ ] Notification permission requested
- [ ] Notifications received when app is closed
- [ ] Notifications received when app is in background
- [ ] Notification tap opens correct screen

### In-App Notifications
- [ ] Notification bell icon shows count
- [ ] Notification list displays correctly
- [ ] Notification types work:
  - [ ] New follower
  - [ ] Post like
  - [ ] Post comment
  - [ ] Message received
  - [ ] Story view

---

## 👥 **Social Features**

### Follow System
- [ ] Follow user works
- [ ] Unfollow user works
- [ ] Follower count updates
- [ ] Following count updates
- [ ] Followers list displays
- [ ] Following list displays

### Discovery
- [ ] Search users works
- [ ] Search posts works
- [ ] Search hashtags works
- [ ] Explore page loads
- [ ] Suggested users display

---

## ⚙️ **Settings & Preferences**

### Account Settings
- [ ] Edit profile works
- [ ] Change password works
- [ ] Email verification works
- [ ] Phone number verification works (if implemented)

### Privacy Settings
- [ ] Private account toggle works
- [ ] Block list displays
- [ ] Unblock user works
- [ ] Hide story from users works

### Notification Settings
- [ ] Toggle push notifications works
- [ ] Toggle notification types works
- [ ] Notification sound settings work

### App Settings
- [ ] Theme toggle works (light/dark)
- [ ] Language selection works (if implemented)
- [ ] Clear cache works
- [ ] App version displays correctly

---

## 🔒 **Security & Permissions**

### Permissions
- [ ] Camera permission requested when needed
- [ ] Microphone permission requested when needed
- [ ] Storage permission requested when needed
- [ ] Location permission requested when needed
- [ ] Notification permission requested when needed
- [ ] Permissions can be denied and app handles gracefully

### Data Security
- [ ] Firebase security rules enforced
- [ ] User can only edit own data
- [ ] User can only delete own content
- [ ] Private content not accessible to others

---

## 🚀 **Performance Testing**

### App Performance
- [ ] App launches in < 3 seconds
- [ ] Feed scrolling is smooth (60 FPS)
- [ ] Image loading is fast
- [ ] Video playback is smooth
- [ ] No memory leaks during extended use
- [ ] No excessive battery drain

### Network Performance
- [ ] App works on WiFi
- [ ] App works on mobile data
- [ ] Offline mode handles gracefully
- [ ] Network errors display user-friendly messages
- [ ] Retry mechanisms work

---

## 🐛 **Error Handling**

### Common Scenarios
- [ ] No internet connection handled gracefully
- [ ] Firebase connection errors handled
- [ ] Invalid input validation works
- [ ] File upload errors handled
- [ ] Large file size errors handled
- [ ] Session expiration handled

### Crash Testing
- [ ] No crashes during normal use
- [ ] No crashes when switching apps
- [ ] No crashes on low memory
- [ ] No crashes on orientation change
- [ ] Firebase Crashlytics reporting works

---

## 📊 **Analytics & Monitoring**

- [ ] Firebase Analytics events tracked
- [ ] User engagement metrics recorded
- [ ] Error logs captured
- [ ] Performance metrics tracked

---

## ✅ **Final Verification**

### Build Verification
- [ ] App version matches expected version
- [ ] Package name is `com.chekmate.app`
- [ ] App is signed with release keystore
- [ ] ProGuard obfuscation applied
- [ ] No debug code or logs in production

### Firebase Verification
- [ ] Connected to production Firebase project
- [ ] Using production `google-services.json`
- [ ] SHA-1 fingerprint matches Firebase Console
- [ ] All Firebase services working:
  - [ ] Authentication
  - [ ] Firestore
  - [ ] Storage
  - [ ] Cloud Messaging
  - [ ] Crashlytics
  - [ ] Analytics

---

## 📝 **Test Results Summary**

**Total Tests:** ___ / 200+  
**Passed:** ___  
**Failed:** ___  
**Blocked:** ___  

### Critical Issues Found:
1. _______________________________________
2. _______________________________________
3. _______________________________________

### Minor Issues Found:
1. _______________________________________
2. _______________________________________
3. _______________________________________

### Recommendations:
1. _______________________________________
2. _______________________________________
3. _______________________________________

---

## 🎯 **Sign-Off**

- [ ] All critical features tested and working
- [ ] No critical bugs found
- [ ] Performance is acceptable
- [ ] Ready for production deployment

**Tester Signature:** _________________  
**Date:** _________________  
**Approval:** ☐ APPROVED  ☐ REJECTED  ☐ NEEDS REVISION

---

## 📞 **Support Information**

**If issues are found:**
1. Document the issue with screenshots/video
2. Note the exact steps to reproduce
3. Check device logs: `adb logcat`
4. Report to development team

**Next Steps After Testing:**
- If APPROVED → Proceed to Google Play Console upload
- If REJECTED → Fix critical issues and rebuild
- If NEEDS REVISION → Address minor issues and retest

