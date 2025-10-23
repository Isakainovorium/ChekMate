# 🔧 Android SDK Installation Guide for ChekMate

**Status:** ⚠️ REQUIRED FOR DEPLOYMENT  
**Priority:** P0-CRITICAL  
**Created:** October 23, 2025  
**Estimated Time:** 60 minutes

---

## 📋 Current Status

**Flutter Doctor Results:**
```
[X] Android toolchain - develop for Android devices
    X Unable to locate Android SDK.
[!] Android Studio (not installed)
```

**Java JDK Status:**
```
❌ Java JDK not installed
❌ javac not found in PATH
```

---

## 🎯 Installation Requirements

To build Android apps with Flutter, you need:

1. ✅ **Flutter SDK** - Already installed (v3.35.5)
2. ❌ **Java JDK 11 or higher** - Not installed
3. ❌ **Android SDK** - Not installed
4. ❌ **Android Studio** (recommended) OR Android Command Line Tools

---

## 📦 Option 1: Install Android Studio (RECOMMENDED)

Android Studio includes everything you need: Java JDK, Android SDK, emulators, and build tools.

### Step 1: Download Android Studio

1. Go to: https://developer.android.com/studio
2. Click **"Download Android Studio"**
3. Accept the terms and download the installer
4. **File size:** ~1.1 GB
5. **Installation size:** ~3-4 GB

### Step 2: Install Android Studio

1. Run the downloaded installer (`android-studio-*.exe`)
2. Click **"Next"** through the setup wizard
3. Choose **"Standard"** installation type
4. Select a theme (Light or Dark)
5. Click **"Finish"** to start downloading components

**Components that will be installed:**
- Android SDK
- Android SDK Platform
- Android Virtual Device (AVD)
- Performance (Intel® HAXM or Android Emulator Hypervisor)

### Step 3: Complete First-Time Setup

1. Android Studio will launch and show "Welcome" screen
2. Click **"More Actions"** → **"SDK Manager"**
3. Verify the following are installed:
   - **SDK Platforms** tab:
     - ✅ Android 13.0 (Tiramisu) - API Level 33
     - ✅ Android 14.0 (UpsideDownCake) - API Level 34
   - **SDK Tools** tab:
     - ✅ Android SDK Build-Tools (latest)
     - ✅ Android SDK Command-line Tools
     - ✅ Android SDK Platform-Tools
     - ✅ Android Emulator
     - ✅ Google Play services

### Step 4: Configure Environment Variables

**Option A: Automatic (via Flutter)**
```powershell
# Flutter will detect Android Studio and configure automatically
flutter doctor --android-licenses
```

**Option B: Manual Configuration**

1. Open **System Properties** → **Environment Variables**
2. Add new **System Variable**:
   - **Variable name:** `ANDROID_HOME`
   - **Variable value:** `C:\Users\IsaKai2296\AppData\Local\Android\Sdk`
3. Edit **Path** variable and add:
   - `%ANDROID_HOME%\platform-tools`
   - `%ANDROID_HOME%\tools`
   - `%ANDROID_HOME%\tools\bin`
4. Click **OK** to save

### Step 5: Accept Android Licenses

```powershell
flutter doctor --android-licenses
# Type 'y' to accept all licenses
```

### Step 6: Verify Installation

```powershell
flutter doctor -v
```

**Expected output:**
```
[√] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
    • Android SDK at C:\Users\IsaKai2296\AppData\Local\Android\Sdk
    • Platform android-34, build-tools 34.0.0
    • Java binary at: C:\Program Files\Android\Android Studio\jbr\bin\java
    • Java version OpenJDK Runtime Environment (build 17.0.x)
    • All Android licenses accepted.
```

---

## 📦 Option 2: Install Command Line Tools Only (Advanced)

If you don't want Android Studio, you can install just the command line tools.

### Step 1: Install Java JDK

1. Download **OpenJDK 17** from: https://adoptium.net/
2. Choose **Windows x64** installer
3. Run installer and select:
   - ✅ Add to PATH
   - ✅ Set JAVA_HOME variable
4. Verify installation:
   ```powershell
   java -version
   # Should show: openjdk version "17.0.x"
   ```

### Step 2: Download Android Command Line Tools

1. Go to: https://developer.android.com/studio#command-line-tools-only
2. Download **Command line tools only** for Windows
3. Extract to: `C:\Android\cmdline-tools\latest\`

### Step 3: Install SDK Components

```powershell
# Set ANDROID_HOME
$env:ANDROID_HOME = "C:\Android"

# Install SDK components
cd C:\Android\cmdline-tools\latest\bin

# Install platform tools
.\sdkmanager "platform-tools"

# Install build tools
.\sdkmanager "build-tools;34.0.0"

# Install platforms
.\sdkmanager "platforms;android-33"
.\sdkmanager "platforms;android-34"

# Accept licenses
.\sdkmanager --licenses
```

### Step 4: Configure Environment Variables

1. Add **System Variable**:
   - `ANDROID_HOME` = `C:\Android`
2. Add to **Path**:
   - `C:\Android\platform-tools`
   - `C:\Android\cmdline-tools\latest\bin`

### Step 5: Configure Flutter

```powershell
flutter config --android-sdk C:\Android
flutter doctor --android-licenses
```

---

## ✅ Verification Checklist

After installation, verify everything is working:

### 1. Check Flutter Doctor
```powershell
flutter doctor -v
```

**Expected:**
- [√] Android toolchain - develop for Android devices
- [√] Android Studio (or command line tools)

### 2. Check Java
```powershell
java -version
javac -version
```

**Expected:**
- Java version 11 or higher

### 3. Check Android SDK
```powershell
# Check SDK location
echo $env:ANDROID_HOME

# List installed packages
sdkmanager --list_installed
```

### 4. Test Android Build
```powershell
cd flutter_chekmate
flutter build apk --debug
```

**Expected:**
- Build completes successfully
- APK created at: `build/app/outputs/flutter-apk/app-debug.apk`

---

## 🚨 Common Issues & Solutions

### Issue 1: "Unable to locate Android SDK"

**Solution:**
```powershell
# Set ANDROID_HOME manually
flutter config --android-sdk "C:\Users\IsaKai2296\AppData\Local\Android\Sdk"
```

### Issue 2: "Android license status unknown"

**Solution:**
```powershell
flutter doctor --android-licenses
# Accept all licenses by typing 'y'
```

### Issue 3: "Java not found"

**Solution:**
- Install Java JDK 17 from https://adoptium.net/
- Restart PowerShell/VS Code after installation

### Issue 4: "Build tools not found"

**Solution:**
```powershell
# Open Android Studio → SDK Manager → SDK Tools
# Install "Android SDK Build-Tools"
```

---

## 📊 Disk Space Requirements

- **Android Studio:** ~4 GB
- **Android SDK:** ~2-3 GB
- **Java JDK:** ~300 MB
- **Total:** ~6-7 GB

---

## 🎯 Next Steps After Installation

Once Android SDK is installed:

1. ✅ Run `flutter doctor` to verify
2. ✅ Proceed to **Task #2: Create Android Keystore**
3. ✅ Continue with **Task #4: Configure SHA-1 Fingerprint**
4. ✅ Build and test release APK

---

## 📞 Need Help?

- **Flutter Android Setup:** https://flutter.dev/to/windows-android-setup
- **Android Studio Guide:** https://developer.android.com/studio/install
- **Flutter Doctor Issues:** https://flutter.dev/docs/get-started/install/windows#android-setup

---

**Last Updated:** October 23, 2025  
**Next Review:** After Android SDK installation

