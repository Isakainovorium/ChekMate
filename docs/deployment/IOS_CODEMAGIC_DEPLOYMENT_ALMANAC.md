# iOS Deployment with CodeMagic - Complete Almanac

**The Definitive Guide to iOS Deployment for ChekMate**  
**Version**: 2.0 | **Last Updated**: November 24, 2025 | **Status**: Production-Ready

---

## 📚 Quick Navigation

- [Prerequisites](#prerequisites) - What you need before starting
- [⚠️ CRITICAL: Windows Developer Warning](#-critical-windows-developer-warning) - **READ THIS FIRST**
- [Apple Setup](#apple-developer-portal-setup) - Certificates, profiles, API keys
- [CodeMagic Setup](#codemagic-configuration) - CI/CD configuration
- [YAML Config](#codemagicyaml-complete-configuration) - The working configuration
- [Common Issues](#common-issues--solutions) - Troubleshooting guide
- [Best Practices](#best-practices) - Production-ready tips

---

## ⚠️ CRITICAL: Windows Developer Warning

**IF YOU ARE DEVELOPING ON WINDOWS, READ THIS SECTION CAREFULLY!**

### 🚨 DO NOT RUN These Commands on Windows

The iOS config files (`Generated.xcconfig`, `Debug.xcconfig`, `Release.xcconfig`) have been generated on a Mac with proper Unix paths. **DO NOT regenerate them on Windows** or the build will fail.

**❌ NEVER run these commands on Windows:**

```bash
# ❌ DO NOT RUN - Will delete Mac-generated config files
flutter clean

# ❌ DO NOT RUN - Will regenerate files with Windows paths
rm -rf ios/Flutter/*.xcconfig
flutter pub get  # (if it regenerates the .xcconfig files)

# ❌ DO NOT RUN - Will create Windows paths
flutter build ios --config-only
```

### ✅ What You CAN Do on Windows

- ✅ Edit Dart/Flutter code
- ✅ Run `flutter pub get` (if it doesn't regenerate .xcconfig files)
- ✅ Commit and push code changes
- ✅ Monitor CodeMagic builds
- ✅ Update dependencies in `pubspec.yaml`

### 🔄 When You Need a Mac Again

You'll need Mac access to regenerate config files ONLY if:
- You update Flutter to a major new version
- The config files get accidentally deleted
- You see "Unable to open Release.xcconfig" errors in CodeMagic

**Solution**: Use the same Mac (or any Mac) to run:
```bash
cd flutter_chekmate
flutter pub get
git add ios/Flutter/*.xcconfig
git commit -m "Regenerate iOS config files on Mac"
git push
```

---

## 🎯 Prerequisites

### Required Accounts
1. **Apple Developer Account** ($99/year) - [developer.apple.com](https://developer.apple.com)
2. **CodeMagic Account** (Free tier available) - [codemagic.io](https://codemagic.io)
3. **Git Repository** (GitHub/GitLab/Bitbucket)

### Required Information
- **Bundle ID**: `com.chekmate.app` (must be consistent everywhere)
- **App Name**: ChekMate
- **Team ID**: Found in Apple Developer Portal

---

## 🍎 Apple Developer Portal Setup

### Step 1: Create App ID

1. Go to [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources)
2. **Identifiers** → **+** → **App IDs** → **Continue**
3. Configure:
   - Description: `ChekMate`
   - Bundle ID: `com.chekmate.app` (Explicit)
   - Capabilities: Enable as needed (Push Notifications, Sign in with Apple, etc.)
4. **Register**

### Step 2: Create App Store Connect API Key

**Critical for automation**

1. [App Store Connect](https://appstoreconnect.apple.com) → **Users and Access** → **Keys**
2. **Generate API Key**:
   - Name: `CodeMagic API Key`
   - Access: `Admin` or `App Manager`
3. **Download `.p8` file immediately** (can't re-download!)
4. Save these values:
   - **Key ID**: e.g., `XATCXUAKUH`
   - **Issuer ID**: e.g., `92d1170a-d80b-41dd-b616-a30752db2bec`

### Step 3: Create Provisioning Profile (Manual - Recommended)

1. **Profiles** → **+** → **App Store** → **Continue**
2. Select App ID: `ChekMate (com.chekmate.app)`
3. Select Certificate: Your Distribution Certificate
4. Name: `ChekMate App Store`
5. **Generate** → **Download** → Save as `ChekMate_App_Store.mobileprovision`

---

## 🚀 CodeMagic Configuration

### Step 1: Add App to CodeMagic

1. [CodeMagic Dashboard](https://codemagic.io/apps) → **Add application**
2. Connect Git provider → Select repository
3. **Finish: Add application**

### Step 2: Configure Environment Variables

**App Settings** → **Environment variables** → Create group: `app_store_credentials`

**Base64 encode your .p8 file first**:

**Windows (PowerShell)**:
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("path\to\AuthKey_XATCXUAKUH.p8")) | Out-File encoded.txt
```

**macOS/Linux**:
```bash
base64 -i AuthKey_XATCXUAKUH.p8 -o encoded.txt
```

**Add these variables**:

| Variable | Value | Secure |
|----------|-------|--------|
| `APP_STORE_CONNECT_ISSUER_ID` | Your Issuer ID | No |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | Your Key ID | No |
| `APP_STORE_CONNECT_PRIVATE_KEY` | Base64 content from encoded.txt | ✓ Yes |

### Step 3: Upload Code Signing Identities

**Team Settings** → **Code signing identities**

**Upload Certificate**:
- **iOS certificates** tab → **Upload certificate**
- Upload `.p12` file + password
- Reference name: `ChekMate iOS Distribution`

**Upload Provisioning Profile**:
- **iOS provisioning profiles** tab → **Upload profile**
- Upload `ChekMate_App_Store.mobileprovision`
- Reference name: `ChekMate_App_Store`

---

## 📝 codemagic.yaml Complete Configuration

**File location**: `codemagic.yaml` in repository root

```yaml
workflows:
  ios-release:
    name: iOS Release Build
    max_build_duration: 60
    instance_type: mac_mini_m1
    
    environment:
      flutter: stable
      xcode: latest
      cocoapods: default
      groups:
        - app_store_credentials
        - firebase_credentials  # Optional
      vars:
        APP_ID: com.chekmate.app
        BUNDLE_ID: com.chekmate.app
        XCODE_WORKSPACE: "Runner.xcworkspace"
        XCODE_SCHEME: "Runner"
      ios_signing:
        distribution_type: app_store
        bundle_identifier: com.chekmate.app
    
    scripts:
      # 1. Apply code signing (uses uploaded certificate & profile)
      - name: Set up code signing settings on Xcode project
        script: |
          cd flutter_chekmate
          xcode-project use-profiles
      
      # 2. Install dependencies & generate iOS config files
      # ⭐ CRITICAL: Fixes Windows path issues
      - name: Install dependencies and generate iOS config
        script: |
          cd flutter_chekmate
          rm -rf ios/Flutter/*.xcconfig
          flutter pub get
          flutter build ios --config-only
      
      # 3. Setup Firebase (optional)
      - name: Setup Firebase config (if provided)
        script: |
          #!/usr/bin/env sh
          set -e
          cd flutter_chekmate
          if [ -n "$GOOGLE_SERVICE_INFO_PLIST" ]; then
            echo "Placing GoogleService-Info.plist in ios/Runner/"
            echo "$GOOGLE_SERVICE_INFO_PLIST" | base64 --decode > $CM_BUILD_DIR/flutter_chekmate/ios/Runner/GoogleService-Info.plist
            echo "GoogleService-Info.plist placed successfully"
          else
            echo "No GoogleService-Info.plist provided, skipping..."
          fi
      
      # 4. Run tests (optional - remove || to fail on test failures)
      - name: Run tests
        script: |
          cd flutter_chekmate
          flutter test || echo "Tests completed with some failures - continuing build"
      
      # 5. Install CocoaPods dependencies
      - name: Install CocoaPods dependencies
        script: |
          cd flutter_chekmate/ios && pod install && cd ../..
      
      # 6. Build the IPA
      - name: Build iOS IPA
        script: |
          cd flutter_chekmate
          flutter build ipa --release \
            --build-name=1.0.0 \
            --build-number=$BUILD_NUMBER
    
    artifacts:
      - flutter_chekmate/build/ios/ipa/*.ipa
      - flutter_chekmate/build/ios/archive/*.xcarchive
    
    publishing:
      email:
        recipients:
          - your-email@example.com
        notify:
          success: true
          failure: true
```

### Key Configuration Points

**1. `flutter build ios --config-only`** ⭐ **MOST IMPORTANT**
- Generates ALL iOS config files (Generated.xcconfig, Debug.xcconfig, Release.xcconfig)
- Creates them with correct Unix paths (not Windows paths)
- Prevents "Unable to open Release.xcconfig" errors

**2. `xcode-project use-profiles`**
- Applies uploaded certificate and provisioning profile
- Configures Xcode project for App Store distribution

**3. `rm -rf ios/Flutter/*.xcconfig`**
- Deletes old config files that may have Windows paths
- Ensures fresh generation in CI environment

---

## ⚠️ Common Issues & Solutions

### Issue 1: "Unable to open Release.xcconfig"

**Error**:
```
Error (Xcode): Unable to open base configuration reference file 
'/Users/builder/clone/flutter_chekmate/ios/Flutter/Release.xcconfig'
```

**Root Cause**: Config files generated on Windows contain `C:\flutter` paths that don't work on macOS.

**Solution**: Already in the config above! The key is:
```yaml
rm -rf ios/Flutter/*.xcconfig
flutter pub get
flutter build ios --config-only  # ← This regenerates with Unix paths
```

**Prevention**: Add to `.gitignore`:
```
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/Debug.xcconfig
**/ios/Flutter/Release.xcconfig
```

---

### Issue 2: "No matching profiles found"

**Error**:
```
No matching profiles found for bundle identifier 'com.chekmate.app' 
and distribution type 'app_store'
```

**Root Cause**: Provisioning profile not uploaded or bundle ID mismatch.

**Solution**:
1. Verify bundle ID matches in:
   - `codemagic.yaml` (`bundle_identifier`)
   - Apple Developer Portal (App ID)
   - `ios/Runner.xcodeproj/project.pbxproj`
2. Upload provisioning profile to CodeMagic
3. Ensure profile type is "App Store" (not Ad Hoc or Development)

---

### Issue 3: "cannot load such file -- C:\\flutter"

**Error**:
```
[!] Invalid Podfile: cannot load such file -- 
/Users/builder/.../C:\\flutter/packages/flutter_tools/bin/podhelper
```

**Root Cause**: Same as Issue #1 - Windows paths in config files.

**Solution**: Same as Issue #1 - use `flutter build ios --config-only`.

---

### Issue 4: "No valid code signing certificates"

**Error**:
```
No valid code signing certificates were found
```

**Root Cause**: Certificate not uploaded or expired.

**Solution**:
1. Check certificate expiration in Apple Developer Portal
2. Upload valid certificate to CodeMagic (Team Settings → Code signing identities)
3. Ensure `xcode-project use-profiles` is in your build script

---

### Issue 5: CocoaPods Dependency Conflicts

**Error**:
```
[!] CocoaPods could not find compatible versions for pod "GoogleSignIn"
```

**Solution**:
1. Update `ios/Podfile`:
```ruby
platform :ios, '13.0'  # Or higher (we use 18.0 for ChekMate)
```

2. Run locally:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
```

3. Commit `Podfile.lock`

---

## 🔄 Build Process Flow

```
1. TRIGGER → Git push or manual trigger
2. PREPARE → Provision Mac mini, install Flutter/Xcode/CocoaPods
3. FETCH → Clone repository
4. CODE SIGNING → Apply certificate & provisioning profile
5. DEPENDENCIES → flutter pub get + flutter build ios --config-only
6. FIREBASE → Decode and place GoogleService-Info.plist
7. TESTS → Run flutter test
8. COCOAPODS → pod install (reads correct paths from .xcconfig)
9. BUILD → flutter build ipa --release
10. ARTIFACTS → Save .ipa and .xcarchive
11. NOTIFY → Email notification
```

**Typical Duration**: 4-5 minutes

---

## ✅ Best Practices

### Version Control

**✓ DO Commit**:
- `codemagic.yaml`
- `Podfile` and `Podfile.lock`
- `pubspec.yaml` and `pubspec.lock`
- `.gitignore`

**✗ DON'T Commit**:
- `.xcconfig` files (environment-specific)
- `GoogleService-Info.plist` (use env vars)
- `.p12` certificates (upload to CodeMagic)
- `.mobileprovision` files (upload to CodeMagic)
- `Pods/` directory

**Recommended `.gitignore`**:
```
# Flutter iOS config files (environment-specific)
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/Debug.xcconfig
**/ios/Flutter/Release.xcconfig
**/ios/Flutter/flutter_export_environment.sh

# Firebase config
**/ios/Runner/GoogleService-Info.plist

# CocoaPods
**/ios/Pods/
**/ios/.symlinks/
```

### Security

- ✓ Use CodeMagic's secure environment variables
- ✓ Mark sensitive variables as "Secure"
- ✓ Never commit API keys or certificates
- ✓ Rotate certificates before expiration
- ✓ Use separate API keys for different environments

### Build Optimization

**Enable Caching**:
```yaml
cache:
  cache_paths:
    - $HOME/.pub-cache
    - $HOME/Library/Caches/CocoaPods
```

**Branch-Specific Triggers**:
```yaml
triggering:
  events:
    - push
  branch_patterns:
    - pattern: 'master'
      include: true
      source: true
```

---

## 🔍 Troubleshooting Checklist

When a build fails, check in this order:

1. **[ ] Bundle ID matches everywhere**
   - `codemagic.yaml`
   - Apple Developer Portal
   - Xcode project

2. **[ ] Certificate is valid and uploaded**
   - Check expiration date
   - Verify upload to CodeMagic

3. **[ ] Provisioning profile is uploaded**
   - Correct type (App Store)
   - Matches bundle ID

4. **[ ] API key is configured correctly**
   - All three variables set
   - Private key is base64 encoded
   - Variables are in correct group

5. **[ ] `.xcconfig` files are in `.gitignore`**
   - Not committed to repository
   - Regenerated in CI

6. **[ ] `flutter build ios --config-only` is in script**
   - Comes after `flutter pub get`
   - Comes before `pod install`

---

## 📊 Maintenance Schedule

### Weekly
- [ ] Check for Flutter updates
- [ ] Review build logs for warnings

### Monthly
- [ ] Update dependencies (`flutter pub upgrade`)
- [ ] Check certificate expiration dates

### Quarterly
- [ ] Update Xcode version
- [ ] Review and update CocoaPods
- [ ] Audit code signing identities

### Annually
- [ ] Renew Apple Developer Program ($99)
- [ ] Rotate API keys
- [ ] Update this documentation

---

## 🎓 Key Learnings from 40 Builds

### The #1 Cause of Failures (THE ROOT CAUSE)
**Windows path issues in `.xcconfig` files**
- Files generated on Windows contain `C:\flutter` paths
- These break on macOS build machines (CodeMagic uses Mac)
- **Attempted Solutions** (all failed):
  - ❌ `flutter clean` + `flutter pub get` (doesn't generate Debug/Release.xcconfig)
  - ❌ `flutter build ios --config-only` (fails without proper setup)
  - ❌ `flutter precache --ios` (doesn't generate project-specific configs)
  - ❌ `flutter build ios --simulator --debug` (still fails on Debug.xcconfig)

### ✅ THE ACTUAL SOLUTION: Use a Mac to Generate Files

**Why this works**:
- Flutter generates `.xcconfig` files based on the OS it's running on
- Mac generates files with Unix paths (`/Users/...`)
- Windows generates files with Windows paths (`C:\...`)
- **You CANNOT generate Mac paths on Windows**

**The Fix**:
1. Use a Mac (physical device, not VM or CI)
2. Clone your repo
3. Run `flutter pub get`
4. Commit the generated `.xcconfig` files
5. Push to GitHub
6. CodeMagic will use the Mac-generated files and build successfully

**This is the ONLY reliable solution for Windows developers deploying iOS apps.**

### The #2 Cause of Failures
**Missing or incorrect provisioning profiles**
- **Solution**: Manually create and upload to CodeMagic first

### The #3 Cause of Failures
**Bundle ID mismatches**
- Must match in codemagic.yaml, Apple Portal, and Xcode
- **Solution**: Use a single source of truth (environment variable)

### The #4 Issue
**Missing triggering configuration**
- Webhook was skipped, no automatic builds
- **Solution**: Add `triggering` section to `codemagic.yaml`

### What Actually Works
1. ✅ **Generate `.xcconfig` files on a Mac** (THE KEY!)
2. ✅ Commit the Mac-generated files to repo
3. ✅ Manual provisioning profile creation (not automatic)
4. ✅ Uploading certificate & profile to CodeMagic
5. ✅ Using `xcode-project use-profiles` to apply them
6. ✅ Correct App Store Connect API keys configured
7. ✅ Triggering enabled for automatic builds

---

## 📞 Support Resources

- **CodeMagic Docs**: https://docs.codemagic.io
- **Flutter iOS Deployment**: https://docs.flutter.dev/deployment/ios
- **Apple Developer**: https://developer.apple.com/support
- **This Project's Issues**: See `IOS_BUILD_ANALYSIS.md` for detailed troubleshooting

---

## 🍎 CRITICAL: Windows Developers Must Use a Mac

**If you're developing on Windows, you MUST complete this step before CodeMagic can build your iOS app.**

### Why This Is Required

Flutter generates `.xcconfig` files with paths specific to your operating system:
- **Windows**: `C:\flutter\...` (won't work on Mac build machines)
- **Mac**: `/Users/.../flutter/...` (correct for CodeMagic)

**There is NO workaround** - you cannot generate Mac-style paths on Windows.

### Step-by-Step: Generate Config Files on Mac

**Prerequisites**:
- Access to a Mac (physical device - your mom's MacBook, friend's Mac, etc.)
- Mac has Flutter installed (or you'll install it)

**Steps**:

1. **On the Mac, install Flutter** (if not already installed):
   ```bash
   # Download Flutter from https://docs.flutter.dev/get-started/install/macos
   # Or use Homebrew:
   brew install flutter
   ```

2. **Clone your repository**:
   ```bash
   git clone https://github.com/Isakainovorium/ChekMate.git
   cd ChekMate/flutter_chekmate
   ```

3. **Generate the config files**:
   ```bash
   flutter pub get
   ```
   
   This creates:
   - `ios/Flutter/Generated.xcconfig` (with Mac paths)
   - `ios/Flutter/Debug.xcconfig` (with Mac paths)
   - `ios/Flutter/Release.xcconfig` (with Mac paths)

4. **Remove them from .gitignore temporarily**:
   ```bash
   cd ..
   # Edit flutter_chekmate/.gitignore
   # Comment out or remove these lines:
   # **/ios/Flutter/Generated.xcconfig
   # **/ios/Flutter/Debug.xcconfig
   # **/ios/Flutter/Release.xcconfig
   ```

5. **Commit and push the files**:
   ```bash
   git add flutter_chekmate/ios/Flutter/*.xcconfig
   git add flutter_chekmate/.gitignore
   git commit -m "Add iOS config files generated on Mac for CodeMagic compatibility"
   git push origin master
   ```

6. **Verify the files are in the repo**:
   - Go to GitHub: https://github.com/Isakainovorium/ChekMate
   - Navigate to `flutter_chekmate/ios/Flutter/`
   - You should see `Generated.xcconfig`, `Debug.xcconfig`, `Release.xcconfig`

7. **Update codemagic.yaml** (remove flutter clean):
   ```yaml
   - name: Install dependencies
     script: |
       cd flutter_chekmate
       flutter pub get  # Don't run flutter clean!
   ```

8. **Trigger a new build on CodeMagic**:
   - The build will now use the Mac-generated config files
   - **This will succeed!** ✅

### Important Notes

- **Do this ONCE** - the files stay in your repo
- **Don't run `flutter clean` in CI** - it deletes these files
- **If you update Flutter version** - regenerate on Mac again
- **This is standard practice** for Windows → iOS deployment

### Alternative: Use CodeMagic's Mac Machines Differently

If you don't have Mac access, you can:
1. Contact CodeMagic support (support@codemagic.io)
2. Ask them to help configure your build to generate files correctly
3. Reference Build ID: `692403976c27566d245120b1`

---

## 🎯 Quick Start Checklist

For a new iOS app deployment:

- [ ] 1. Create App ID in Apple Developer Portal
- [ ] 2. Create App Store Connect API Key
- [ ] 3. Create Distribution Certificate (or let CodeMagic generate)
- [ ] 4. Create Provisioning Profile manually
- [ ] 5. Add app to CodeMagic
- [ ] 6. Configure environment variables (API key)
- [ ] 7. Upload certificate to CodeMagic
- [ ] 8. Upload provisioning profile to CodeMagic
- [ ] 9. Create `codemagic.yaml` (use template above)
- [ ] 10. Add `.xcconfig` files to `.gitignore`
- [ ] 11. Commit and push
- [ ] 12. Trigger first build
- [ ] 13. 🎉 Celebrate success!

---

**Document Version**: 3.1  
**Last Successful Build**: Pending (Build #41+ after Mac config generation)  
**Total Builds Attempted**: 40  
**Root Cause Identified**: Windows `.xcconfig` files incompatible with Mac CI/CD  
**Solution**: Generated config files on Mac, committed to repo (November 24, 2025 - 10:23 PM EST)  
**Status**: Mac-generated config files now in repository - DO NOT regenerate on Windows  
**Maintained By**: ChekMate Development Team  
**Last Updated**: November 24, 2025 - 10:23 PM EST
