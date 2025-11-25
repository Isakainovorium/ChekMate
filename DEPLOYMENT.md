# ChekMate Deployment Guide

This document outlines the best practices and steps for deploying ChekMate using Codemagic CI/CD and GitHub.

## Overview

ChekMate uses Codemagic for automated builds and deployments to:
- iOS App Store (via TestFlight and App Store Connect)
- Google Play Store (via internal testing and production)

## Prerequisites

### 1. Codemagic Account Setup
- Create an account at [codemagic.io](https://codemagic.io)
- Connect your GitHub repository
- Configure team and billing settings

### 2. Environment Variables and Secrets

All sensitive information must be stored as encrypted environment variables in Codemagic, organized into groups:

#### A. Firebase Credentials Group (`firebase_credentials`)
```yaml
- GOOGLE_SERVICE_INFO_PLIST (base64-encoded iOS Firebase config)
- GOOGLE_SERVICES_JSON (base64-encoded Android Firebase config)
```

**How to encode:**
```bash
# iOS
base64 -i ios/Runner/GoogleService-Info.plist | pbcopy

# Android  
base64 -i android/app/google-services.json | pbcopy
```

#### B. App Store Credentials Group (`app_store_credentials`)
```yaml
- APP_STORE_CONNECT_KEY_IDENTIFIER
- APP_STORE_CONNECT_ISSUER_ID
- APP_STORE_CONNECT_PRIVATE_KEY (base64-encoded)
- CERTIFICATE_PRIVATE_KEY
```

#### C. Keystore Credentials Group (`keystore_credentials`)
```yaml
- KEYSTORE_PASSWORD
- KEY_ALIAS
- KEY_PASSWORD
- KEYSTORE (base64-encoded .jks file)
```

### 3. Code Signing Setup

#### iOS Code Signing
1. In Codemagic, navigate to your app settings
2. Go to "Code signing identities" > "iOS"
3. Upload:
   - Distribution certificate (.p12)
   - Provisioning profiles (Development, Ad Hoc, App Store)
4. Or use automatic code signing with App Store Connect API

#### Android Code Signing
1. Upload your keystore file (.jks or .keystore)
2. Add keystore credentials to environment variables
3. Ensure `key.properties` is properly configured

## Workflow Architecture

### Available Workflows

1. **ios-release**: iOS-only builds for App Store
2. **android-release**: Android-only builds for Google Play
3. **ios-and-android**: Combined iOS and Android builds

### Workflow Structure

Each workflow follows these phases:

```
1. Prepare Build Machine (30-45s)
   - Provision macOS/Linux instance
   - Set up environment variables

2. Fetch App Sources (5-10s)
   - Clone repository
   - Checkout specified branch/commit

3. Install SDKs (1-4min)
   - Download and extract Flutter SDK
   - Install Xcode (iOS) or Android SDK

4. Install Dependencies (15-30s)
   - Run flutter pub get
   - Download project dependencies

5. Generate Code (20-40s)
   - Run build_runner for code generation
   - Generate mocks and Riverpod providers

6. Setup Firebase Config (< 1s)
   - Decode base64 environment variables
   - Place config files in correct locations

7. Run Tests (optional, 30s-2min)
   - Execute flutter test
   - Generate coverage reports

8. Platform-Specific Build
   iOS:
   - Install CocoaPods dependencies (1-2min)
   - Build IPA file (5-10min)
   
   Android:
   - Build APK/AAB file (3-5min)

9. Publishing
   - Upload artifacts
   - Submit to app stores
   - Send notifications

10. Cleanup
    - Remove temporary files
    - Archive logs
```

## Best Practices Implementation

### 1. Secure Configuration Management
- NEVER commit sensitive files to repository
- Use base64 encoding for binary/config files
- Mark all sensitive variables as "Secret" in Codemagic
- Use environment variable groups for organization

### 2. Build Environment Best Practices
- Always use `CM_BUILD_DIR` for file paths
- Add `#!/usr/bin/env sh` and `set -e` to scripts
- Use proper error handling with `||` operators
- Clean builds between major changes

### 3. Version Management
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Leverage `cm_get_build_number()` for build numbers
- Tag releases in Git matching app versions

### 4. Testing Strategy
- Run tests in parallel where possible
- Make tests non-blocking for development builds
- Use strict testing for production releases
- Generate and archive coverage reports

### 5. Deployment Strategy
- Test in staging before production
- Use TestFlight for iOS beta testing
- Use Internal Testing for Android
- Implement gradual rollouts

### 6. Monitoring and Rollbacks
- Monitor build logs in Codemagic
- Set up email notifications for failures
- Use Firebase Crashlytics for crash reporting
- Keep previous IPAs/AABs for quick rollbacks

## Triggering Builds

### Automatic Triggers
Builds trigger automatically on:
- Push to `master` branch
- Pull request to `master`
- Manual trigger via Codemagic UI

### Manual Triggers
1. Go to Codemagic dashboard
2. Select your app
3. Click "Start new build"
4. Choose:
   - Branch/commit
   - Workflow
   - Optional SSH/VNC access

## Deployment Commands

The workflow handles everything automatically, but for reference:

### iOS Deployment
```bash
# Build IPA
flutter build ipa --release

# Upload to TestFlight (automated via Codemagic)
xcrun altool --upload-app --file build/ios/ipa/*.ipa
```

### Android Deployment
```bash
# Build App Bundle
flutter build appbundle --release

# Build APK
flutter build apk --release

# Upload to Play Console (automated via Codemagic)
```

## Troubleshooting

### Common Issues

#### 1. Firebase Config Not Found
**Symptom:** Build fails with "GoogleService-Info.plist not found"

**Solution:**
- Verify base64-encoded config is in environment variables
- Ensure variable group is included in workflow
- Check script uses `CM_BUILD_DIR` for paths

#### 2. Code Signing Failures (iOS)
**Symptom:** "No matching provisioning profiles found"

**Solution:**
- Update provisioning profiles in Codemagic
- Verify bundle ID matches
- Check certificate expiration dates

#### 3. Build Timeout
**Symptom:** Build exceeds max duration

**Solution:**
- Increase `max_build_duration` in workflow
- Optimize dependency installation
- Use caching for CocoaPods

#### 4. Test Failures Blocking Build
**Symptom:** Build fails due to widget test issues

**Solution:**
- Make tests non-blocking: `flutter test || echo "Tests completed"`
- Fix tests before production deployment
- Use separate test workflow

### Debug Mode
Enable SSH/VNC access in Codemagic for interactive debugging:
1. Start build with SSH enabled
2. Connect via provided SSH command
3. Investigate build environment
4. Test commands manually

## Monitoring Deployments

### Build Status
- Check Codemagic dashboard for real-time status
- Review build logs for errors
- Monitor email notifications

### App Store Status
- **iOS:** Check App Store Connect for review status
- **Android:** Monitor Play Console for rollout status

### User Analytics
- Firebase Analytics for user engagement
- Crashlytics for crash reports
- Performance Monitoring for app performance

## Rollback Procedure

### If Deployment Fails:
1. Check Codemagic build logs
2. Fix the issue in code
3. Commit and push fix
4. New build triggers automatically

### If Production Issues Occur:
1. **iOS:**
   - Go to App Store Connect
   - Remove from sale OR
   - Submit previous version

2. **Android:**
   - Go to Play Console
   - Halt rollout OR
   - Roll back to previous version

## Maintenance

### Regular Tasks
- [ ] Review and rotate secrets quarterly
- [ ] Update provisioning profiles before expiration
- [ ] Update code signing certificates annually
- [ ] Review and optimize workflow performance monthly
- [ ] Update Flutter SDK to stable releases

### After Each Release
- [ ] Tag release in Git
- [ ] Update CHANGELOG.md
- [ ] Monitor crash reports for 24-48 hours
- [ ] Gather user feedback
- [ ] Plan next release cycle

## Resources

- [Codemagic Documentation](https://docs.codemagic.io/)
- [Flutter CI/CD Best Practices](https://flutter.dev/docs/deployment/cd)
- [Firebase Configuration](https://firebase.google.com/docs)
- [App Store Connect Help](https://developer.apple.com/app-store-connect/)
- [Google Play Console Help](https://support.google.com/googleplay/)

## Support

For deployment issues:
1. Check this documentation
2. Review Codemagic documentation
3. Check build logs
4. Contact team lead or DevOps

---

Last Updated: 2024
Version: 1.0.0


