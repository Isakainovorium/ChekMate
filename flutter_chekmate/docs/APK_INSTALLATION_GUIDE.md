# ChekMate APK Installation Guide

**Version:** 1.0  
**Date:** October 23, 2025  
**APK Size:** 58.76 MB  
**AAB Size:** 51.86 MB  

---

## 📦 **Build Artifacts Locations**

```
ChekMate_app/flutter_chekmate/
├── build/app/outputs/flutter-apk/
│   └── app-release.apk (58.76 MB)
└── build/app/outputs/bundle/release/
    └── app-release.aab (51.86 MB)
```

---

## 🔧 **Installation Methods**

### **Method 1: ADB Install (Recommended for Testing)**

#### Prerequisites:
- Android device with USB debugging enabled
- ADB (Android Debug Bridge) installed on your computer
- USB cable to connect device to computer

#### Steps:

1. **Enable USB Debugging on Android Device:**
   - Go to **Settings** → **About Phone**
   - Tap **Build Number** 7 times to enable Developer Options
   - Go to **Settings** → **Developer Options**
   - Enable **USB Debugging**

2. **Connect Device to Computer:**
   - Connect your Android device via USB cable
   - On device, tap **Allow** when prompted for USB debugging permission

3. **Verify Device Connection:**
   ```powershell
   adb devices
   ```
   You should see your device listed.

4. **Install APK:**
   ```powershell
   cd C:\Users\IsaKai2296\Downloads\ChekMate_app\flutter_chekmate
   adb install build\app\outputs\flutter-apk\app-release.apk
   ```

5. **Launch App:**
   ```powershell
   adb shell am start -n com.chekmate.app/.MainActivity
   ```

6. **View Logs (for debugging):**
   ```powershell
   adb logcat | Select-String "flutter"
   ```

---

### **Method 2: Manual Transfer and Install**

#### Steps:

1. **Transfer APK to Device:**
   - Connect device to computer via USB
   - Copy `app-release.apk` to device's **Downloads** folder
   - Or use cloud storage (Google Drive, Dropbox) to transfer

2. **Enable Installation from Unknown Sources:**
   - Go to **Settings** → **Security**
   - Enable **Install from Unknown Sources**
   - Or on newer Android: **Settings** → **Apps** → **Special Access** → **Install Unknown Apps** → Enable for your file manager

3. **Install APK:**
   - Open **Files** or **Downloads** app on device
   - Tap on `app-release.apk`
   - Tap **Install**
   - Tap **Open** when installation completes

---

### **Method 3: Google Play Console Internal Testing (AAB)**

#### Prerequisites:
- Google Play Console account
- App created in Play Console
- AAB file ready

#### Steps:

1. **Upload AAB to Play Console:**
   - Go to [Google Play Console](https://play.google.com/console)
   - Select your app (or create new app)
   - Go to **Release** → **Testing** → **Internal Testing**
   - Click **Create New Release**
   - Upload `app-release.aab`
   - Add release notes
   - Click **Review Release** → **Start Rollout**

2. **Add Testers:**
   - Go to **Testing** → **Internal Testing** → **Testers**
   - Create email list of testers
   - Share testing link with testers

3. **Testers Install:**
   - Testers receive email with link
   - Click link to opt-in to testing
   - Install app from Play Store

---

## 🔍 **Verification Steps**

### After Installation:

1. **Check App Icon:**
   - App icon should appear on home screen
   - App name should be "ChekMate"

2. **Launch App:**
   - Tap app icon
   - App should launch without crashes
   - Splash screen should display

3. **Check Permissions:**
   - App will request permissions:
     - Camera (for photos/videos)
     - Microphone (for voice messages)
     - Storage (for media)
     - Notifications (for push notifications)
   - Grant permissions as needed

4. **Test Basic Functionality:**
   - Sign up or log in
   - Navigate through app
   - Test core features

---

## 🐛 **Troubleshooting**

### Installation Failed

**Error: "App not installed"**
- Solution: Uninstall any previous version first
  ```powershell
  adb uninstall com.chekmate.app
  ```
  Then reinstall.

**Error: "INSTALL_FAILED_INSUFFICIENT_STORAGE"**
- Solution: Free up at least 200 MB on device
- Delete unused apps or files

**Error: "INSTALL_FAILED_UPDATE_INCOMPATIBLE"**
- Solution: Uninstall existing app first
  ```powershell
  adb uninstall com.chekmate.app
  ```

### App Crashes on Launch

**Check Logs:**
```powershell
adb logcat -s flutter
```

**Common Issues:**
- Missing Google Play Services → Install from Play Store
- Outdated Android version → Requires Android 5.0+
- Corrupted APK → Re-download and reinstall

### Permissions Not Working

**Reset App Permissions:**
- Go to **Settings** → **Apps** → **ChekMate**
- Tap **Permissions**
- Grant all required permissions

---

## 📊 **Testing Checklist**

Use the comprehensive testing checklist:
- **File:** `docs/ANDROID_DEPLOYMENT_TESTING_CHECKLIST.md`
- **Tests:** 200+ test cases covering all features
- **Categories:**
  - Authentication (Email, Google, Apple)
  - Profile (Photo, Video Intro, Voice Prompt)
  - Posts (Photo, Video, Comments, Likes)
  - Stories (Create, View, Interact)
  - Messaging (Text, Media, Voice)
  - Notifications (Push, In-App)
  - Social (Follow, Search, Discover)
  - Settings & Privacy
  - Performance & Security

---

## 🚀 **Next Steps After Testing**

### If Tests Pass:
1. ✅ Mark all test cases as passed
2. ✅ Document any minor issues
3. ✅ Proceed to Google Play Console upload
4. ✅ Submit for review

### If Critical Issues Found:
1. ❌ Document issues with screenshots
2. ❌ Note steps to reproduce
3. ❌ Fix issues in codebase
4. ❌ Rebuild APK/AAB
5. ❌ Retest

### If Minor Issues Found:
1. ⚠️ Document issues
2. ⚠️ Assess impact
3. ⚠️ Decide: Fix now or post-launch
4. ⚠️ Create issue tracker items

---

## 📞 **Support Commands**

### Useful ADB Commands:

**List connected devices:**
```powershell
adb devices
```

**Install APK:**
```powershell
adb install app-release.apk
```

**Uninstall app:**
```powershell
adb uninstall com.chekmate.app
```

**Launch app:**
```powershell
adb shell am start -n com.chekmate.app/.MainActivity
```

**View logs:**
```powershell
adb logcat -s flutter
```

**Clear app data:**
```powershell
adb shell pm clear com.chekmate.app
```

**Take screenshot:**
```powershell
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png
```

**Record screen:**
```powershell
adb shell screenrecord /sdcard/demo.mp4
# Press Ctrl+C to stop
adb pull /sdcard/demo.mp4
```

---

## 🔐 **Security Notes**

- **APK Signing:** App is signed with release keystore
- **ProGuard:** Code obfuscation enabled
- **Firebase:** Connected to production Firebase project
- **SHA-1:** Fingerprint registered in Firebase Console
- **Permissions:** Only requests necessary permissions

---

## 📝 **Build Information**

| Property | Value |
|----------|-------|
| **Package Name** | com.chekmate.app |
| **Version Code** | (Check pubspec.yaml) |
| **Version Name** | (Check pubspec.yaml) |
| **Min SDK** | 21 (Android 5.0) |
| **Target SDK** | 34 (Android 14) |
| **Build Type** | Release |
| **Signing** | Release Keystore |
| **ProGuard** | Enabled |
| **Obfuscation** | Enabled |

---

## ✅ **Installation Complete!**

Once installed and tested, you're ready to:
1. Upload to Google Play Console
2. Submit for review
3. Launch to production!

**Good luck with your ChekMate deployment! 🚀**

