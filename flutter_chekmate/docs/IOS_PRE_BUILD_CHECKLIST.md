# iOS Pre-Build Checklist

This checklist ensures your iOS app is ready for building and App Store submission **before** you get your Apple Developer account.

## ✅ Pre-Apple Developer Account Checklist

### 1. **Code Configuration**

#### iOS Permissions (Info.plist)
- [x] ✅ **Camera Permission** (`NSCameraUsageDescription`)
  - Required for: Stories, video posts, profile photos
  - Status: ✅ Configured
  
- [x] ✅ **Microphone Permission** (`NSMicrophoneUsageDescription`)
  - Required for: Voice messages, video with audio
  - Status: ✅ Configured
  
- [x] ✅ **Photo Library Permission** (`NSPhotoLibraryUsageDescription`)
  - Required for: Selecting photos/videos to upload
  - Status: ✅ Configured
  
- [x] ✅ **Location Permission** (`NSLocationWhenInUseUsageDescription`)
  - Required for: Location-based features
  - Status: ✅ Configured
  
- [x] ✅ **Notifications Permission** (`UserNotificationsUsageDescription`)
  - Required for: Push notifications
  - Status: ✅ Configured

#### App Configuration
- [x] ✅ **Bundle ID**: `com.chekmate.app`
- [x] ✅ **App Display Name**: ChekMate
- [x] ✅ **Info.plist**: Created with all required permissions
- [x] ✅ **Firebase Config**: `GoogleService-Info.plist` exists

### 2. **Codemagic Configuration**

#### Workflow Setup
- [x] ✅ **Workflow File**: `codemagic.yaml` on `ios` branch
- [x] ✅ **Branch**: Set to `ios` in Codemagic settings
- [x] ✅ **Configuration Detected**: Codemagic recognizes the YAML file
- [x] ✅ **Build Scripts**: All steps configured
- [x] ✅ **Verification Script**: Added to check iOS config before build

#### Email Notifications
- [ ] ⚠️ **Update Email**: Replace `your-email@example.com` in `codemagic.yaml`
  - Location: `vars.NOTIFICATION_EMAIL` or `publishing.email.recipients`
  - Action: Update before first build

### 3. **App Assets**

#### App Icons
- [ ] ⚠️ **App Icon Source**: `assets/icons/app_icon.png` (1024x1024px)
  - Status: Check if file exists
  - Action: Create if missing, then run `flutter pub run flutter_launcher_icons`
  
- [ ] ⚠️ **Splash Icon**: `assets/icons/splash_icon.png` (512x512px or larger)
  - Status: Check if file exists
  - Action: Create if missing, then run `flutter pub run flutter_native_splash:create`

#### Icon Generation
- [ ] ⚠️ **Generate iOS Icons**: Run icon generation command
  ```bash
  cd flutter_chekmate
  flutter pub run flutter_launcher_icons
  ```
  - This creates all required iOS icon sizes automatically
  - Verifies: `ios/Runner/Assets.xcassets/AppIcon.appiconset/` contains icons

### 4. **Version Management**

#### Version Numbers
- [ ] ⚠️ **Check Version**: Verify `pubspec.yaml` has correct version
  - Current: Check `version: X.Y.Z+BUILD` format
  - Example: `version: 1.0.0+1`
  - Codemagic will auto-increment build number

### 5. **Firebase Configuration**

#### Firebase Setup
- [x] ✅ **GoogleService-Info.plist**: File exists in `ios/Runner/`
- [ ] ⚠️ **Environment Variable**: Set `GOOGLE_SERVICE_INFO_PLIST` in Codemagic
  - Location: Codemagic → Environment Variables → `firebase_credentials` group
  - Action: Upload `GoogleService-Info.plist` as environment variable
  - Note: This allows Codemagic to place the file during build

### 6. **Apple Developer Account Preparation**

#### Before Getting Account
- [x] ✅ **App Name**: "ChekMate" (decided)
- [x] ✅ **Bundle ID**: `com.chekmate.app` (configured)
- [ ] ⚠️ **App Store Listing**: Prepare marketing materials
  - App description (up to 4000 characters)
  - Keywords (up to 100 characters)
  - Screenshots (required sizes):
    - iPhone 6.7" (1290 x 2796)
    - iPhone 6.5" (1242 x 2688)
    - iPhone 5.5" (1242 x 2208)
  - App preview videos (optional)
  - Privacy policy URL (required)

#### After Getting Account
- [ ] ⚠️ **App Store Connect API Key**: Generate and configure
  - Location: App Store Connect → Users and Access → Keys
  - Action: Create API key, download `.p8` file
  - Configure in Codemagic: Settings → Code signing identities → App Store Connect

- [ ] ⚠️ **TestFlight Setup**: Configure beta testing
  - Add beta testers
  - Configure TestFlight groups
  - Set up external testing (if needed)

## 🚀 Ready to Build Checklist

Once you have your Apple Developer account, verify:

### Immediate Actions
1. [ ] Update email in `codemagic.yaml`
2. [ ] Generate app icons (if not done)
3. [ ] Configure App Store Connect API key in Codemagic
4. [ ] Set Firebase credentials in Codemagic environment variables
5. [ ] Trigger first build in Codemagic

### First Build Verification
- [ ] Build completes successfully
- [ ] IPA file is generated
- [ ] Email notification received
- [ ] Download IPA and verify it's signed correctly

### App Store Submission
- [ ] Upload IPA to App Store Connect
- [ ] Complete App Store listing information
- [ ] Submit for review
- [ ] Monitor review status

## 📝 Notes

### Current Status
- ✅ **Info.plist**: Fully configured with all permissions
- ✅ **Codemagic Workflow**: Optimized with verification steps
- ✅ **Build Scripts**: All steps configured and tested
- ⚠️ **Email**: Needs to be updated
- ⚠️ **Icons**: May need generation
- ⚠️ **Apple Developer Account**: Pending

### Next Steps
1. Update email address in `codemagic.yaml`
2. Verify/generate app icons
3. Get Apple Developer account ($99/year)
4. Configure App Store Connect API key
5. Trigger first build!

## 🔗 Related Documentation

- [Codemagic iOS Setup Guide](./CI_SETUP.md)
- [iOS Deployment Guide](./IOS_DEPLOYMENT_GUIDE.md)
- [Icon Setup Instructions](../assets/icons/ICON_SETUP_INSTRUCTIONS.md)

---

**Last Updated**: Pre-Apple Developer Account Setup
**Status**: Ready for optimization, pending Apple Developer account

