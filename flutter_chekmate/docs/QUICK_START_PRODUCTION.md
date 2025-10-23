# 🚀 Quick Start: Production Setup (3 Tasks)

**Time Required:** ~1.5 hours  
**Date:** October 22, 2025  
**Status:** Ready to execute

---

## 📋 OVERVIEW

You need to complete 3 tasks to get ChekMate production-ready:

1. ⏳ **Create Keystore** (15 min)
2. ⏳ **Install Android SDK** (60 min)
3. ⏳ **Test Release Build** (30 min)

---

## 🎯 AUTOMATED SETUP (RECOMMENDED)

### **Option 1: Run the Setup Script**

```powershell
cd C:\Users\IsaKai2296\Downloads\ChekMate_app\flutter_chekmate
.\scripts\powershell\setup_android_production.ps1
```

**This script will:**
- ✅ Check if Android SDK is installed
- ✅ Guide you through Android SDK installation
- ✅ Create production keystore automatically
- ✅ Create key.properties file
- ✅ Verify all configurations
- ✅ Optionally build release App Bundle

**Just follow the prompts!**

---

## 📝 MANUAL SETUP (If you prefer step-by-step)

### **Task 1: Install Android SDK** (60 min)

#### **Option A: Android Studio (Recommended)**

1. **Download Android Studio:**
   - Go to: https://developer.android.com/studio
   - Download the Windows installer
   - File size: ~1.1 GB

2. **Install Android Studio:**
   ```
   - Run the installer
   - Choose "Standard" installation
   - Accept licenses
   - Wait for SDK components to download (~5-10 GB)
   ```

3. **Verify Installation:**
   ```powershell
   flutter doctor -v
   ```
   
   Should show: `[√] Android toolchain`

#### **Option B: Command Line Tools Only (Faster, ~30 min)**

1. **Download Command Line Tools:**
   - Go to: https://developer.android.com/studio#command-line-tools-only
   - Download: `commandlinetools-win-11076708_latest.zip`

2. **Extract and Setup:**
   ```powershell
   # Create directory
   New-Item -ItemType Directory -Force -Path C:\Android\cmdline-tools
   
   # Extract downloaded zip to C:\Android\cmdline-tools\latest
   # (Use Windows Explorer or 7-Zip)
   
   # Set environment variable
   [System.Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Android', 'User')
   
   # Restart PowerShell
   ```

3. **Install SDK Components:**
   ```powershell
   cd C:\Android\cmdline-tools\latest\bin
   
   # Accept licenses
   .\sdkmanager --licenses
   
   # Install required components
   .\sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
   ```

4. **Configure Flutter:**
   ```powershell
   flutter config --android-sdk C:\Android
   flutter doctor --android-licenses
   flutter doctor -v
   ```

---

### **Task 2: Create Keystore** (15 min)

#### **Step 1: Create Keystore Directory**
```powershell
cd C:\Users\IsaKai2296\Downloads\ChekMate_app\flutter_chekmate
New-Item -ItemType Directory -Force -Path android\app\keystore
```

#### **Step 2: Generate Keystore**
```powershell
keytool -genkey -v -keystore android\app\keystore\chekmate-release.jks `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias chekmate-release
```

**You'll be prompted for:**
- Keystore password: `[Choose a strong password]`
- Key password: `[Can be same as keystore password]`
- First and last name: `ChekMate` (or your name)
- Organizational unit: `Development`
- Organization: `ChekMate`
- City: `[Your city]`
- State: `[Your state]`
- Country code: `US` (or your country)

**⚠️ CRITICAL:** Save these passwords securely! You'll need them for every release.

#### **Step 3: Create key.properties**

Create file: `android\key.properties`

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=chekmate-release
storeFile=keystore/chekmate-release.jks
```

**Replace:**
- `YOUR_KEYSTORE_PASSWORD` with your actual password
- `YOUR_KEY_PASSWORD` with your actual password

**⚠️ This file is gitignored and contains sensitive information**

---

### **Task 3: Test Release Build** (30 min)

#### **Step 1: Build Release App Bundle**
```powershell
cd C:\Users\IsaKai2296\Downloads\ChekMate_app\flutter_chekmate
flutter build appbundle --release
```

**Expected output:**
```
✓ Built build\app\outputs\bundle\release\app-release.aab (XX.X MB)
```

**Build time:** 5-10 minutes (first build)

#### **Step 2: Build Release APK (Optional)**
```powershell
flutter build apk --release
```

**Expected output:**
```
✓ Built build\app\outputs\flutter-apk\app-release.apk (XX.X MB)
```

#### **Step 3: Verify Signing**
```powershell
# Verify App Bundle is signed
jarsigner -verify -verbose -certs build\app\outputs\bundle\release\app-release.aab
```

**Should show:** `jar verified.`

#### **Step 4: Install and Test on Device**

**If you have an Android device:**
```powershell
# Enable USB debugging on your device
# Connect device via USB

# Install release build
flutter install --release
```

**If you have an Android emulator:**
```powershell
# Start emulator from Android Studio
# Or use command line:
emulator -avd Pixel_7_API_34

# Install release build
flutter install --release
```

#### **Step 5: Test All Features**

**Critical Tests:**
- [ ] App launches without crashes
- [ ] Firebase authentication works
- [ ] Can create/view posts
- [ ] Can upload images/videos
- [ ] Push notifications work (if configured)
- [ ] Location services work
- [ ] All navigation works
- [ ] No performance issues

---

## ✅ VERIFICATION CHECKLIST

After completing all tasks, verify:

```powershell
# Run verification script
.\scripts\powershell\production_fixes.ps1
```

**Manual checks:**
- [ ] Android SDK installed: `flutter doctor -v` shows `[√] Android toolchain`
- [ ] Keystore exists: `android\app\keystore\chekmate-release.jks`
- [ ] key.properties exists: `android\key.properties`
- [ ] Release build successful: `build\app\outputs\bundle\release\app-release.aab`
- [ ] App Bundle is signed: `jarsigner -verify` shows `jar verified`
- [ ] App installs and runs on device/emulator
- [ ] All features work in release mode

---

## 🎯 SUCCESS CRITERIA

You're ready for production when:

1. ✅ `flutter doctor -v` shows no Android errors
2. ✅ `flutter build appbundle --release` completes successfully
3. ✅ App Bundle is properly signed
4. ✅ App runs on device without crashes
5. ✅ All critical features work

---

## 🆘 TROUBLESHOOTING

### **"keytool: command not found"**
**Solution:** Install Java JDK
- Download: https://www.oracle.com/java/technologies/downloads/
- Install and add to PATH
- Restart PowerShell

### **"Unable to locate Android SDK"**
**Solution:** Set ANDROID_HOME environment variable
```powershell
[System.Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Users\YourName\AppData\Local\Android\Sdk', 'User')
```
Restart PowerShell and run `flutter doctor`

### **"Keystore was tampered with, or password was incorrect"**
**Solution:** Check password in `android\key.properties`

### **Build fails with "Execution failed for task ':app:lintVitalAnalyzeRelease'"**
**Solution:** Disable lint checks temporarily
Add to `android\app\build.gradle.kts`:
```kotlin
android {
    lintOptions {
        checkReleaseBuilds = false
    }
}
```

### **"INSTALL_FAILED_UPDATE_INCOMPATIBLE"**
**Solution:** Uninstall debug version first
```powershell
adb uninstall com.chekmate.app
flutter install --release
```

---

## 📊 ESTIMATED TIMELINE

| Task | Time | Status |
|------|------|--------|
| Install Android SDK | 60 min | ⏳ Pending |
| Create Keystore | 15 min | ⏳ Pending |
| Test Release Build | 30 min | ⏳ Pending |
| **TOTAL** | **105 min** | **~1.75 hours** |

---

## 🚀 NEXT STEPS AFTER COMPLETION

Once all 3 tasks are complete:

1. **Update Dependencies:**
   ```powershell
   flutter pub upgrade --major-versions
   flutter test --coverage
   ```

2. **Prepare for Google Play:**
   - Create Google Play Console account
   - Prepare app screenshots
   - Write app description
   - Create privacy policy

3. **Submit to Google Play:**
   - Upload `app-release.aab`
   - Fill in store listing
   - Submit for review

---

## 📞 QUICK REFERENCE

**Project Directory:**
```
C:\Users\IsaKai2296\Downloads\ChekMate_app\flutter_chekmate
```

**Key Files:**
- Keystore: `android\app\keystore\chekmate-release.jks`
- Key properties: `android\key.properties`
- Build config: `android\app\build.gradle.kts`
- Release output: `build\app\outputs\bundle\release\app-release.aab`

**Key Commands:**
```powershell
# Check Flutter setup
flutter doctor -v

# Build release
flutter build appbundle --release

# Install release
flutter install --release

# Verify signing
jarsigner -verify build\app\outputs\bundle\release\app-release.aab
```

---

**Created:** October 22, 2025  
**Status:** Ready to execute  
**Estimated Time:** 1.75 hours  
**Next Action:** Run `.\scripts\powershell\setup_android_production.ps1`

