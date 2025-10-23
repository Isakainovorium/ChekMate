# ChekMate Android Deployment Automation Guide

## 🎯 Overview

This guide documents the fully automated Android deployment process for ChekMate, including all scripts, steps, and verification procedures.

---

## 📋 Automation Scripts

### 1. **automate_android_deployment.ps1**
**Location:** `scripts/automate_android_deployment.ps1`

**Purpose:** Complete end-to-end automation of Android deployment

**Features:**
- Silent Android Studio installation
- Android SDK configuration
- Environment variable setup
- Keystore creation
- SHA-1 fingerprint extraction
- Release APK/AAB builds

**Usage:**
```powershell
cd flutter_chekmate
powershell -ExecutionPolicy Bypass -File ".\scripts\automate_android_deployment.ps1"
```

**Parameters:**
- `-SkipAndroidStudioInstall` - Skip Android Studio installation if already installed
- `-SkipKeystoreCreation` - Skip keystore creation if already exists
- `-SkipBuild` - Skip building APK/AAB
- `-KeystorePassword` - Custom keystore password (default: "chekmate2024")
- `-KeyAlias` - Custom key alias (default: "chekmate-key")

---

### 2. **complete_android_setup.ps1**
**Location:** `scripts/complete_android_setup.ps1`

**Purpose:** Complete Android setup after Android Studio installation

**Features:**
- Configure Flutter with Android SDK
- Accept Android licenses
- Create keystore
- Extract SHA-1 fingerprint
- Build release APK and AAB

**Usage:**
```powershell
cd flutter_chekmate
powershell -ExecutionPolicy Bypass -File ".\scripts\complete_android_setup.ps1"
```

**Prerequisites:**
- Android Studio installed
- Android SDK downloaded (via Android Studio setup wizard)

---

## 🚀 Complete Automation Workflow

### Step 1: Download Android Studio
```powershell
$url = "https://redirector.gvt1.com/edgedl/android/studio/install/2024.2.1.11/android-studio-2024.2.1.11-windows.exe"
$output = "$env:USERPROFILE\Downloads\android-studio-2024.2.1.11-windows.exe"
Invoke-WebRequest -Uri $url -OutFile $output
```

### Step 2: Run Full Automation
```powershell
cd c:\Users\IsaKai2296\Downloads\ChekMate_app\flutter_chekmate
powershell -ExecutionPolicy Bypass -File ".\scripts\automate_android_deployment.ps1"
```

**This will:**
1. ✅ Install Android Studio silently (~10 minutes)
2. ✅ Configure Android SDK environment variables
3. ✅ Set up PATH variables
4. ✅ Create Android keystore
5. ✅ Generate key.properties file
6. ✅ Extract SHA-1 fingerprint
7. ✅ Build release APK
8. ✅ Build release AAB

**Total Time:** ~30-40 minutes

---

### Step 3: Manual Steps (Required)

After automation completes, you need to:

#### 3.1 Launch Android Studio First Time
```powershell
Start-Process "C:\Program Files\Android\Android Studio\bin\studio64.exe"
```

**In the setup wizard:**
1. Choose "Standard" installation
2. Accept all licenses
3. Let it download SDK components (~10 minutes)
4. Wait for "Finish" button

#### 3.2 Complete Setup with Second Script
```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\complete_android_setup.ps1"
```

**This will:**
1. ✅ Configure Flutter with Android SDK path
2. ✅ Accept Android licenses via Flutter
3. ✅ Verify Flutter doctor
4. ✅ Create keystore (if not exists)
5. ✅ Extract SHA-1 fingerprint
6. ✅ Build release APK
7. ✅ Build release AAB

---

## 📊 Verification Steps

### 1. Verify Android Studio Installation
```powershell
Test-Path "C:\Program Files\Android\Android Studio\bin\studio64.exe"
# Should return: True
```

### 2. Verify Android SDK
```powershell
Test-Path "$env:LOCALAPPDATA\Android\Sdk"
# Should return: True
```

### 3. Verify Environment Variables
```powershell
$env:ANDROID_HOME
# Should return: C:\Users\<username>\AppData\Local\Android\Sdk

$env:ANDROID_SDK_ROOT
# Should return: C:\Users\<username>\AppData\Local\Android\Sdk
```

### 4. Verify Flutter Doctor
```powershell
flutter doctor -v
```

**Expected output:**
```
[√] Flutter (Channel stable, 3.35.5, ...)
[√] Windows Version (...)
[√] Android toolchain - develop for Android devices
    • Android SDK at C:\Users\...\AppData\Local\Android\Sdk
    • Platform android-34, build-tools 34.0.0
    • Java binary at: C:\Program Files\Android\Android Studio\jbr\bin\java
    • Java version OpenJDK Runtime Environment (build ...)
[√] Chrome - develop for the web
[√] Visual Studio - develop Windows apps
[√] Android Studio (version 2024.2)
[√] VS Code (version ...)
[√] Connected device (3 available)
[√] Network resources
```

### 5. Verify Keystore
```powershell
Test-Path "android\app\upload-keystore.jks"
# Should return: True

Test-Path "android\key.properties"
# Should return: True
```

### 6. Verify SHA-1 Fingerprint
```powershell
Get-Content "android\SHA1_FINGERPRINT.txt"
# Should display: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

### 7. Verify Build Outputs
```powershell
Test-Path "build\app\outputs\flutter-apk\app-release.apk"
# Should return: True

Test-Path "build\app\outputs\bundle\release\app-release.aab"
# Should return: True
```

---

## 🔧 Troubleshooting

### Issue 1: Android Studio Not Found
**Error:** `Android Studio not found`

**Solution:**
```powershell
# Verify installation path
Test-Path "C:\Program Files\Android\Android Studio"

# If not found, reinstall:
powershell -ExecutionPolicy Bypass -File ".\scripts\automate_android_deployment.ps1"
```

### Issue 2: Android SDK Not Found
**Error:** `Unable to locate Android SDK`

**Solution:**
1. Launch Android Studio manually
2. Complete setup wizard
3. Let it download SDK components
4. Run: `flutter config --android-sdk "$env:LOCALAPPDATA\Android\Sdk"`

### Issue 3: License Not Accepted
**Error:** `Android license status unknown`

**Solution:**
```powershell
flutter doctor --android-licenses
# Press 'y' for all prompts
```

### Issue 4: Keystore Creation Failed
**Error:** `keytool: command not found`

**Solution:**
```powershell
# Verify Java is installed
java -version

# If not found, Android Studio includes Java:
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:Path += ";$env:JAVA_HOME\bin"
```

### Issue 5: Build Failed
**Error:** `Gradle build failed`

**Solution:**
```powershell
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release
```

---

## 📁 Generated Files

After successful automation, these files will be created:

```
flutter_chekmate/
├── android/
│   ├── app/
│   │   └── upload-keystore.jks          # Android keystore
│   ├── key.properties                    # Keystore configuration
│   └── SHA1_FINGERPRINT.txt              # SHA-1 fingerprint
├── build/
│   └── app/
│       └── outputs/
│           ├── flutter-apk/
│           │   └── app-release.apk       # Release APK
│           └── bundle/
│               └── release/
│                   └── app-release.aab   # Release App Bundle
└── scripts/
    ├── automate_android_deployment.ps1   # Full automation script
    └── complete_android_setup.ps1        # Post-install script
```

---

## 🎯 Next Steps After Automation

### 1. Add SHA-1 to Firebase Console
1. Open: https://console.firebase.google.com/project/chekmate-a0423/settings/general
2. Scroll to "Your apps" → Android app
3. Click "Add fingerprint"
4. Paste SHA-1 from `android/SHA1_FINGERPRINT.txt`
5. Click "Save"

### 2. Download Updated google-services.json
1. In Firebase Console, click "Download google-services.json"
2. Replace `android/app/google-services.json` with the new file

### 3. Test Release APK
```powershell
# Install on connected Android device
flutter install --release

# Or manually install APK:
adb install build\app\outputs\flutter-apk\app-release.apk
```

### 4. Upload to Google Play Console
1. Go to: https://play.google.com/console
2. Create new app or select existing
3. Upload `build\app\outputs\bundle\release\app-release.aab`
4. Complete store listing
5. Submit for review

---

## ⏱️ Time Estimates

| Task | Time | Automated? |
|------|------|------------|
| Download Android Studio | 5-10 min | ✅ Yes |
| Install Android Studio | 10-15 min | ✅ Yes |
| Download SDK components | 10-15 min | ⚠️ Manual (first launch) |
| Configure environment | 1 min | ✅ Yes |
| Create keystore | 1 min | ✅ Yes |
| Extract SHA-1 | 1 min | ✅ Yes |
| Build APK | 3-5 min | ✅ Yes |
| Build AAB | 3-5 min | ✅ Yes |
| Add SHA-1 to Firebase | 2 min | ❌ Manual |
| Test on device | 5-10 min | ❌ Manual |
| **Total** | **40-60 min** | **80% automated** |

---

## 🔐 Security Notes

### Keystore Security
- **Password:** `chekmate2024` (default, change for production)
- **Location:** `android/app/upload-keystore.jks`
- **Backup:** Store securely - losing this means you can't update your app!

### key.properties Security
- **Never commit to Git!** Already in `.gitignore`
- Contains sensitive passwords
- Required for release builds

### SHA-1 Fingerprint
- **Public information** - safe to share
- Required for Firebase Authentication
- Different for debug and release builds

---

## ✅ Success Criteria

Automation is successful when:

1. ✅ `flutter doctor` shows no Android errors
2. ✅ `upload-keystore.jks` exists
3. ✅ `key.properties` exists
4. ✅ `SHA1_FINGERPRINT.txt` contains valid SHA-1
5. ✅ `app-release.apk` builds successfully
6. ✅ `app-release.aab` builds successfully
7. ✅ APK installs and runs on Android device

---

## 📞 Support

If automation fails:
1. Check `flutter doctor -v` output
2. Review error messages in PowerShell
3. Verify all prerequisites are met
4. Try manual steps from `docs/ANDROID_SDK_INSTALLATION_GUIDE.md`

---

**Last Updated:** 2025-10-23
**ChekMate Version:** Phase 7 - Production Deployment

