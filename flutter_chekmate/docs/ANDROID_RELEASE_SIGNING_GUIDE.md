# 🔐 Android Release Signing Configuration Guide

**Purpose:** Configure production signing for Android release builds  
**Status:** REQUIRED FOR PRODUCTION  
**Priority:** 🔴 CRITICAL

---

## 📋 Overview

Android apps must be digitally signed before they can be installed on devices or published to Google Play Store. This guide shows how to create a signing keystore and configure your Flutter app for production releases.

---

## 🔑 Step 1: Create a Keystore

### On Windows (PowerShell):
```powershell
# Navigate to your project directory
cd C:\Users\IsaKai2296\Downloads\ChekMate_app\flutter_chekmate

# Create keystore directory (if it doesn't exist)
New-Item -ItemType Directory -Force -Path android\app\keystore

# Generate keystore
keytool -genkey -v -keystore android\app\keystore\chekmate-release.jks `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias chekmate-release
```

### On macOS/Linux:
```bash
# Navigate to your project directory
cd ~/ChekMate_app/flutter_chekmate

# Create keystore directory
mkdir -p android/app/keystore

# Generate keystore
keytool -genkey -v -keystore android/app/keystore/chekmate-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias chekmate-release
```

### Keystore Information Prompts:
You'll be asked for:
1. **Keystore password:** Choose a strong password (save it securely!)
2. **Key password:** Can be same as keystore password
3. **First and last name:** Your name or company name
4. **Organizational unit:** Your team/department
5. **Organization:** Your company name
6. **City/Locality:** Your city
7. **State/Province:** Your state
8. **Country code:** Two-letter country code (e.g., US, UK, CA)

**⚠️ IMPORTANT:**
- **NEVER** commit the keystore file to git
- **SAVE** the passwords securely (password manager recommended)
- **BACKUP** the keystore file to a secure location
- If you lose the keystore, you cannot update your app on Google Play!

---

## 📝 Step 2: Create key.properties File

Create `android/key.properties` with your keystore information:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=chekmate-release
storeFile=keystore/chekmate-release.jks
```

**Replace:**
- `YOUR_KEYSTORE_PASSWORD` with your actual keystore password
- `YOUR_KEY_PASSWORD` with your actual key password

**⚠️ SECURITY:**
This file contains sensitive information and is already in `.gitignore`

---

## 🔧 Step 3: Update build.gradle.kts

Replace the contents of `android/app/build.gradle.kts`:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = java.util.Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.chekmate.app"  // UPDATE THIS to your actual package name
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.chekmate.app"  // UPDATE THIS to your actual package name
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Signing configuration
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            
            // Enable code shrinking, obfuscation, and optimization
            isMinifyEnabled = true
            isShrinkResources = true
            
            // ProGuard rules
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Add any additional dependencies here
}
```

---

## 🛡️ Step 4: Create ProGuard Rules

Create `android/app/proguard-rules.pro`:

```proguard
# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Riverpod
-keep class * extends com.riverpod.** { *; }

# Keep all model classes (adjust package name)
-keep class com.chekmate.app.** { *; }

# Gson (if used)
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
```

---

## 🔒 Step 5: Update .gitignore

Verify these lines are in `flutter_chekmate/.gitignore`:

```gitignore
# Android signing
android/key.properties
android/app/keystore/
*.jks
*.keystore

# Secrets
*.key
*.secret
config/secrets.yaml
config/api_keys.yaml
```

These are already present in your `.gitignore` ✅

---

## 🏗️ Step 6: Build Release APK/AAB

### Build APK (for testing):
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle (for Google Play):
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

---

## ✅ Step 7: Verify Signing

### Check APK signature:
```bash
# Windows
jarsigner -verify -verbose -certs build\app\outputs\flutter-apk\app-release.apk

# macOS/Linux
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```

Should show: `jar verified.`

### Check App Bundle signature:
```bash
# Windows
jarsigner -verify -verbose -certs build\app\outputs\bundle\release\app-release.aab

# macOS/Linux
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

---

## 📦 Step 8: Test Release Build

### Install on device:
```bash
flutter install --release
```

### Or manually install APK:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Test thoroughly:**
- App launches correctly
- All features work
- No crashes
- Performance is good
- Firebase integration works

---

## 🚀 Step 9: Upload to Google Play

1. Go to [Google Play Console](https://play.google.com/console)
2. Create a new app (if not already created)
3. Navigate to **Production** → **Create new release**
4. Upload `app-release.aab` (App Bundle, not APK)
5. Fill in release notes
6. Review and rollout

---

## 🔐 Security Best Practices

### DO:
- ✅ Use a strong keystore password (16+ characters)
- ✅ Store keystore in a secure location (encrypted backup)
- ✅ Use a password manager for credentials
- ✅ Keep `key.properties` out of version control
- ✅ Use different keystores for debug and release
- ✅ Enable ProGuard for code obfuscation

### DON'T:
- ❌ Commit keystore to git
- ❌ Share keystore password in plain text
- ❌ Use weak passwords
- ❌ Lose your keystore (you can't update your app!)
- ❌ Use the same keystore for multiple apps
- ❌ Email keystore files

---

## 🆘 Troubleshooting

### "keytool: command not found"
**Solution:** Install Java JDK and add to PATH
- Download from: https://www.oracle.com/java/technologies/downloads/
- Add `JAVA_HOME/bin` to PATH

### "Keystore was tampered with, or password was incorrect"
**Solution:** Check your password in `key.properties`

### "Failed to read key from keystore"
**Solution:** Verify `storeFile` path in `key.properties` is correct

### Build fails with ProGuard errors
**Solution:** Add keep rules to `proguard-rules.pro` for affected classes

---

## 📚 Additional Resources

- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Flutter Deployment Guide](https://docs.flutter.dev/deployment/android)
- [Google Play Console](https://play.google.com/console)
- [ProGuard Rules](https://www.guardsquare.com/manual/configuration/usage)

---

**Created:** October 22, 2025  
**Status:** Ready for implementation  
**Priority:** 🔴 CRITICAL - Required for production deployment

