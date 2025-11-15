# CI/CD Setup Guide - Codemagic

This guide explains how to set up and use Codemagic CI/CD for automated builds of ChekMate.

## Overview

Codemagic provides cloud-based CI/CD specifically designed for Flutter apps. It allows you to:
- Build iOS apps without a Mac
- Automate Android and iOS builds
- Run tests automatically
- Deploy to App Store and Google Play
- Generate code (mocks, Riverpod providers) before builds

## Prerequisites

- [ ] GitHub account
- [ ] Codemagic account (free at https://codemagic.io/)
- [ ] Apple Developer Account ($99/year) - for iOS builds
- [ ] Google Play Developer Account ($25 one-time) - for Android releases

## Project Configuration

The project includes a `codemagic.yaml` file at the root with three pre-configured workflows.

**Important:** The workflow automatically runs `build_runner` to generate required files:
- Mockito mock classes (`.mocks.dart` files) for tests
- Riverpod provider code

These generated files are **not** committed to the repository and are created during each build.

### 1. iOS Release Workflow (`ios-release`)

Builds iOS IPA for App Store distribution.

**Features:**
- Generates code (mocks, Riverpod providers)
- Runs tests
- Installs CocoaPods dependencies
- Builds release IPA
- Can upload to TestFlight automatically

**Instance:** Mac Mini M1 (required for iOS builds)

### 2. Android Release Workflow (`android-release`)

Builds Android APK and App Bundle for Google Play.

**Features:**
- Generates code (mocks, Riverpod providers)
- Runs tests
- Builds release APK
- Builds release AAB (App Bundle)
- Can upload to Google Play automatically

**Instance:** Linux x2 (faster and cheaper)

### 3. Combined Workflow (`ios-and-android`)

Builds both iOS and Android in a single workflow.

**Use when:** You want to build both platforms together (takes longer, costs more)

## Setup Steps

### Step 1: Connect Repository to Codemagic

1. Go to https://codemagic.io/
2. Sign up or log in with GitHub
3. Click **Add application**
4. Select **ChekMate** repository
5. Click **Finish**

### Step 2: Configure App Store Connect API Key (iOS)

**Required for iOS builds and App Store uploads.**

1. Go to https://appstoreconnect.apple.com/access/api
2. Click **Keys** tab
3. Click **Generate API Key** (+ button)
4. Enter name: "Codemagic CI"
5. Select role: **App Manager**
6. Click **Generate**
7. **Download the `.p8` file** (you can only download once!)
8. Note the **Key ID** and **Issuer ID**

9. In Codemagic:
   - Go to **Settings** → **Code signing identities**
   - Click **Add credentials** → **App Store Connect API key**
   - Upload the `.p8` file
   - Enter **Key ID**
   - Enter **Issuer ID**
   - Save as credential group: `app_store_credentials`

### Step 3: Configure Android Keystore (Android)

**Required for Android release builds.**

If you already have a keystore:

1. In Codemagic:
   - Go to **Settings** → **Code signing identities**
   - Click **Add credentials** → **Android keystore**
   - Upload your `.jks` file
   - Enter keystore password
   - Enter key alias
   - Enter key password
   - Save as credential group: `keystore_credentials`

If you need to create a keystore:

```bash
keytool -genkey -v -keystore chekmate-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias chekmate
```

### Step 4: Configure Firebase (Optional)

If you want to include Firebase configuration in builds:

1. Download `GoogleService-Info.plist` from Firebase Console
2. In Codemagic:
   - Go to **Settings** → **Environment variables**
   - Create group: `firebase_credentials`
   - Add file variable: `GOOGLE_SERVICE_INFO_PLIST`
   - Upload your `GoogleService-Info.plist` file

**Note:** The workflow will automatically place this file in `ios/Runner/` during build.

### Step 5: Update Email Notifications

Edit `codemagic.yaml` and replace `your-email@example.com` with your actual email:

```yaml
publishing:
  email:
    recipients:
      - your-actual-email@example.com
```

### Step 6: Configure Automatic Code Signing (iOS)

1. In Codemagic dashboard, select ChekMate project
2. Go to **Settings** → **Build settings**
3. Enable **Automatic code signing**
4. Select your **Team** (Apple Developer account)
5. Verify **Bundle ID**: `com.chekmate.app`

## Running Builds

### Automatic Builds (Recommended)

Codemagic automatically detects the `codemagic.yaml` file and will:
- Build on every push to `main` or `master` branch
- Build on pull requests (if configured)
- Build on tags (for releases)

### Manual Builds

1. Go to Codemagic dashboard
2. Select ChekMate project
3. Click **Start new build**
4. Select workflow: `ios-release`, `android-release`, or `ios-and-android`
5. Select branch
6. Click **Start build**

### Build Triggers

You can configure build triggers in Codemagic dashboard:
- **On push**: Build when code is pushed
- **On PR**: Build when pull request is opened/updated
- **On tag**: Build when a git tag is created
- **Scheduled**: Build on a schedule (cron)

## Build Process

Each workflow follows these steps:

1. **Install dependencies**: `flutter pub get`
2. **Generate code**: `flutter pub run build_runner build --delete-conflicting-outputs`
   - Generates Mockito mocks for tests
   - Generates Riverpod providers
3. **Run tests**: `flutter test`
4. **Platform-specific setup**:
   - iOS: Install CocoaPods dependencies
   - Android: Configure signing
5. **Build**: Create release artifacts
6. **Publish**: Upload to stores (if configured)

## Build Artifacts

After a successful build, you can download:

### iOS
- **IPA file**: `build/ios/ipa/*.ipa` - Ready for App Store upload
- **Archive**: `build/ios/archive/*.xcarchive` - Xcode archive

### Android
- **APK**: `build/app/outputs/flutter-apk/*.apk` - For direct installation
- **AAB**: `build/app/outputs/bundle/release/*.aab` - For Google Play

## Publishing to Stores

### App Store Connect

To automatically upload to TestFlight/App Store:

1. Ensure App Store Connect API key is configured (Step 2)
2. The workflow already includes `app_store_connect` publishing configuration
3. Set `submit_to_testflight: true` if you want automatic TestFlight upload
4. Add beta groups if needed

### Google Play

To automatically upload to Google Play:

1. Ensure keystore is configured (Step 3)
2. Create a Google Play service account
3. Add service account credentials to Codemagic
4. The workflow already includes `google_play` publishing configuration

## Troubleshooting

### Build Fails: "Missing mocks"

**Solution:** The workflow runs `build_runner` automatically. If it still fails:
- Check that `@GenerateMocks` annotations are correct
- Verify `mockito` is in `dev_dependencies`

### Build Fails: "Code signing error"

**Solution:**
- Verify App Store Connect API key is configured correctly
- Check that Bundle ID matches: `com.chekmate.app`
- Ensure Apple Developer account is active

### Build Fails: "CocoaPods error"

**Solution:**
- The workflow installs CocoaPods automatically
- If it fails, check `ios/Podfile` for syntax errors
- Try updating CocoaPods version in workflow

### Build Takes Too Long

**Optimization tips:**
- Use `android-release` workflow for Android-only builds (faster Linux instance)
- Use `ios-release` workflow for iOS-only builds
- Only use `ios-and-android` when you need both

## Cost Considerations

### Codemagic Free Tier
- **500 build minutes/month**
- **1 concurrent build**
- Perfect for small projects and testing

### Codemagic Pro ($49/month)
- **2,000 build minutes/month**
- **2 concurrent builds**
- Priority support
- Good for regular releases

### Build Time Estimates
- iOS build: ~15-20 minutes
- Android build: ~10-15 minutes
- Combined: ~25-35 minutes

**Free tier allows:** ~25-30 iOS builds per month

## Best Practices

1. **Use separate workflows** for iOS and Android when possible (faster, cheaper)
2. **Run tests locally** before pushing to avoid wasting build minutes
3. **Tag releases** to trigger builds automatically
4. **Monitor build logs** to catch issues early
5. **Keep credentials secure** - never commit keys to repository
6. **Update email** in `codemagic.yaml` to receive build notifications

## Next Steps

1. ✅ Set up Codemagic account
2. ✅ Configure credentials
3. ✅ Update email in `codemagic.yaml`
4. ✅ Push code to trigger first build
5. ✅ Download and test artifacts
6. ✅ Configure automatic publishing (optional)

## Additional Resources

- [Codemagic Documentation](https://docs.codemagic.io/)
- [iOS Deployment Guide](IOS_DEPLOYMENT_GUIDE.md)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)

