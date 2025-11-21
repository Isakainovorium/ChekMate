# ChekMate Deployment Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Firebase Configuration](#firebase-configuration)
4. [iOS Deployment](#ios-deployment)
5. [Android Deployment](#android-deployment)
6. [Web Deployment](#web-deployment)
7. [Post-Deployment](#post-deployment)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Tools
- Flutter SDK (3.0.0 or higher)
- Dart SDK (included with Flutter)
- Xcode (for iOS, macOS only)
- Android Studio (for Android)
- Firebase CLI
- Git
- Node.js and npm (for E2E tests and Firebase)

### Verify Installation
```bash
flutter doctor
firebase --version
node --version
npm --version
```

---

## Environment Setup

### 1. Clone and Setup Project
```bash
cd ChekMate_app/flutter_chekmate
flutter pub get
flutter pub run build_runner build
```

### 2. Configure Environment Variables
```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your actual values
# NEVER commit .env to version control!
```

### 3. Update Version
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Format: version+buildNumber
```

---

## Firebase Configuration

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Enter project name: "ChekMate"
4. Enable Google Analytics (recommended)
5. Create project

### 2. Add Apps to Firebase Project

#### iOS App
1. In Firebase Console, click "Add app" > iOS
2. Enter iOS bundle ID: `com.yourcompany.chekmate`
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/`
5. Add to Xcode project

#### Android App
1. In Firebase Console, click "Add app" > Android
2. Enter Android package name: `com.yourcompany.chekmate`
3. Download `google-services.json`
4. Place in `android/app/`

#### Web App
1. In Firebase Console, click "Add app" > Web
2. Register app with nickname "ChekMate Web"
3. Copy Firebase config
4. Update `web/index.html` with config

### 3. Enable Firebase Services

#### Authentication
```bash
# In Firebase Console > Authentication
1. Click "Get Started"
2. Enable Email/Password
3. Enable Google Sign-In
4. Enable Apple Sign-In (for iOS)
```

#### Cloud Firestore
```bash
# In Firebase Console > Firestore Database
1. Click "Create database"
2. Start in production mode
3. Choose location (closest to users)

# Deploy security rules
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

#### Storage
```bash
# In Firebase Console > Storage
1. Click "Get Started"
2. Start in production mode

# Deploy security rules
firebase deploy --only storage
```

#### Cloud Messaging (FCM)
```bash
# In Firebase Console > Cloud Messaging
1. Note Server Key for backend (if needed)
2. Configure APNs for iOS (upload .p8 key)
```

#### Analytics & Crashlytics
```bash
# In Firebase Console
1. Enable Google Analytics
2. Enable Crashlytics
3. Enable Performance Monitoring
```

### 4. Deploy Firebase Configuration
```bash
# Login to Firebase
firebase login

# Initialize Firebase in project
cd flutter_chekmate
firebase init

# Select:
# - Firestore
# - Storage
# - Hosting

# Deploy all Firebase configuration
firebase deploy
```

---

## iOS Deployment

### 1. Configure Xcode Project
```bash
# Open iOS project
open ios/Runner.xcworkspace
```

#### Update Project Settings
1. Select Runner target
2. General tab:
   - Display Name: ChekMate
   - Bundle Identifier: com.yourcompany.chekmate
   - Version: 1.0.0
   - Build: 1
3. Signing & Capabilities:
   - Select your team
   - Enable Automatic Signing
   - Add capabilities:
     * Push Notifications
     * Sign in with Apple
     * Associated Domains (for deep linking)

#### Configure Info.plist
Add required permissions:
```xml
<key>NSCameraUsageDescription</key>
<string>ChekMate needs camera access to take photos for your profile and posts</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>ChekMate needs photo library access to select images for your profile and posts</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>ChekMate uses your location to show nearby users and posts</string>

<key>NSMicrophoneUsageDescription</key>
<string>ChekMate needs microphone access for voice messages</string>

<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you</string>
```

### 2. Configure Apple Sign-In
1. Go to [Apple Developer](https://developer.apple.com)
2. Certificates, Identifiers & Profiles
3. Create App ID with Sign in with Apple capability
4. Create Service ID for web authentication
5. Configure in Firebase Console

### 3. Build for iOS
```bash
# Clean build
flutter clean
flutter pub get

# Build iOS app
flutter build ios --release

# Or build IPA for App Store
flutter build ipa --release
```

### 4. Submit to App Store

#### Using Xcode
1. Open `ios/Runner.xcworkspace`
2. Product > Archive
3. Distribute App > App Store Connect
4. Upload

#### Using Transporter
1. Locate IPA: `build/ios/ipa/chekmate.ipa`
2. Open Transporter app
3. Drag and drop IPA
4. Deliver

#### App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. My Apps > ChekMate
3. Select build
4. Fill in app information
5. Submit for review

---

## Android Deployment

### 1. Generate Signing Key
```bash
# Generate keystore
keytool -genkey -v -keystore ~/chekmate-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias chekmate-key

# Save keystore password securely!
```

### 2. Configure Signing
Create `android/key.properties`:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=chekmate-key
storeFile=/path/to/chekmate-keystore.jks
```

Verify `android/app/build.gradle` has signing config:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 3. Configure AndroidManifest.xml
Verify permissions in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

### 4. Build for Android
```bash
# Clean build
flutter clean
flutter pub get

# Build App Bundle (recommended)
flutter build appbundle --release

# Or build APK
flutter build apk --release
```

### 5. Submit to Google Play

#### Google Play Console
1. Go to [Google Play Console](https://play.google.com/console)
2. Create app
3. Fill in app details
4. Upload app bundle: `build/app/outputs/bundle/release/app-release.aab`
5. Complete content rating questionnaire
6. Set pricing and distribution
7. Submit for review

---

## Web Deployment

### 1. Build for Web
```bash
# Build web app
flutter build web --release

# Output will be in build/web/
```

### 2. Deploy to Firebase Hosting
```bash
# Deploy to Firebase
firebase deploy --only hosting

# Your app will be live at:
# https://your-project-id.web.app
```

### 3. Custom Domain (Optional)
```bash
# In Firebase Console > Hosting
1. Click "Add custom domain"
2. Enter your domain
3. Follow DNS configuration steps
4. Wait for SSL certificate provisioning
```

### 4. Test PWA Installation
1. Open app in Chrome
2. Click install icon in address bar
3. Verify app installs and works offline

---

## Post-Deployment

### 1. Verify Deployment

#### iOS
```bash
# Check app on TestFlight
1. Go to App Store Connect
2. TestFlight tab
3. Add internal testers
4. Test app before public release
```

#### Android
```bash
# Check app on Internal Testing
1. Go to Google Play Console
2. Internal testing track
3. Add testers
4. Test app before public release
```

### 2. Monitor App Health

#### Firebase Console
- Check Analytics for user activity
- Monitor Crashlytics for crashes
- Review Performance metrics
- Check Cloud Messaging delivery rates

#### App Store / Play Store
- Monitor reviews and ratings
- Respond to user feedback
- Track download numbers
- Monitor crash reports

### 3. Set Up Alerts
```bash
# Firebase Console > Alerts
1. Set up crash rate alerts
2. Set up performance alerts
3. Set up budget alerts
```

---

## Troubleshooting

### Common Issues

#### Build Fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Clear Xcode derived data (iOS)
rm -rf ~/Library/Developer/Xcode/DerivedData

# Clear Gradle cache (Android)
cd android
./gradlew clean
cd ..
```

#### Firebase Connection Issues
```bash
# Verify Firebase configuration
1. Check GoogleService-Info.plist (iOS)
2. Check google-services.json (Android)
3. Verify Firebase project is active
4. Check API keys are correct
```

#### Signing Issues (iOS)
```bash
# In Xcode
1. Select Runner target
2. Signing & Capabilities
3. Revoke and regenerate certificates
4. Download new provisioning profiles
```

#### Signing Issues (Android)
```bash
# Verify keystore
keytool -list -v -keystore ~/chekmate-keystore.jks

# Check key.properties path is correct
# Ensure keystore password is correct
```

#### App Crashes on Launch
```bash
# Check Firebase Crashlytics
1. Go to Firebase Console
2. Crashlytics section
3. Review crash reports
4. Fix issues and redeploy
```

### Getting Help
- Flutter Documentation: https://docs.flutter.dev
- Firebase Documentation: https://firebase.google.com/docs
- Stack Overflow: Tag questions with `flutter` and `firebase`

---

## Deployment Commands Quick Reference

```bash
# Flutter
flutter clean
flutter pub get
flutter test
flutter build ios --release
flutter build ipa --release
flutter build appbundle --release
flutter build apk --release
flutter build web --release

# Firebase
firebase login
firebase init
firebase deploy
firebase deploy --only hosting
firebase deploy --only firestore:rules
firebase deploy --only storage

# iOS
open ios/Runner.xcworkspace
# Product > Archive > Distribute

# Android
cd android
./gradlew assembleRelease
./gradlew bundleRelease
```

---

## Security Checklist

- [ ] All API keys are in environment variables
- [ ] .env file is in .gitignore
- [ ] key.properties is in .gitignore
- [ ] Firestore security rules are deployed
- [ ] Storage security rules are deployed
- [ ] App Check is enabled (optional but recommended)
- [ ] SSL/HTTPS is enabled for all endpoints
- [ ] User data is encrypted at rest
- [ ] Sensitive operations require authentication

---

## Performance Optimization

### Before Deployment
- [ ] Run `flutter analyze` and fix all issues
- [ ] Run `flutter test` and ensure all tests pass
- [ ] Profile app performance with DevTools
- [ ] Optimize images (compress, use WebP)
- [ ] Enable code minification
- [ ] Remove debug code and console logs

### After Deployment
- [ ] Monitor app size
- [ ] Monitor startup time
- [ ] Monitor memory usage
- [ ] Monitor network requests
- [ ] Optimize based on Firebase Performance data

---

## Maintenance Plan

### Weekly
- Check crash reports
- Review user feedback
- Monitor analytics
- Check server costs

### Monthly
- Update dependencies
- Review security
- Analyze user behavior
- Plan feature updates

### Quarterly
- Major version update
- Performance audit
- Security audit
- User survey

---

**Last Updated:** [Current Date]  
**Version:** 1.0.0  
**Maintainer:** [Your Name/Team]

---

## SUCCESS!

Your ChekMate app is now deployed! Monitor the app closely for the first week and be ready to push hotfixes if needed.

Good luck with your launch!


