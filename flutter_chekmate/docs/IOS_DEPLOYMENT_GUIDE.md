# ChekMate iOS Deployment Guide

**Version:** 1.0  
**Date:** October 23, 2025  
**Current Environment:** Windows 10 (Build 26100)  
**Status:** ⚠️ **CRITICAL LIMITATION IDENTIFIED**  

---

## 🚨 **CRITICAL: macOS Required for iOS Development**

### **Current Situation:**
- **Your OS:** Windows 10 (Win32NT)
- **iOS Requirement:** macOS with Xcode
- **Impact:** **Cannot build iOS apps directly from Windows**

### **Why macOS is Required:**
1. **Xcode** - Apple's IDE, only available on macOS
2. **iOS Simulator** - Only runs on macOS
3. **Code Signing** - Requires Xcode's signing tools
4. **App Store Upload** - Requires Xcode or Transporter (macOS only)
5. **Apple Developer Tools** - macOS-exclusive

---

## 🎯 **Your Options for iOS Deployment**

### **Option 1: Use a Mac (Recommended)**

#### **A. Physical Mac**
- **Best Option:** MacBook, iMac, Mac Mini, or Mac Studio
- **Minimum Requirements:**
  - macOS 12.0 (Monterey) or later
  - Xcode 14.0 or later
  - 8GB RAM minimum (16GB recommended)
  - 50GB free disk space

#### **B. Borrow/Rent a Mac**
- Borrow from friend/colleague
- Rent from Mac rental services
- Use Mac at coworking space/library

#### **C. Cloud Mac Services**
- **MacStadium** - https://www.macstadium.com/
- **MacinCloud** - https://www.macincloud.com/
- **AWS EC2 Mac Instances** - https://aws.amazon.com/ec2/instance-types/mac/
- **Pricing:** ~$20-100/month

---

### **Option 2: CI/CD Services (Recommended for Windows Users)**

Use cloud-based CI/CD that provides macOS build agents:

#### **A. Codemagic (Recommended)**
- **Website:** https://codemagic.io/
- **Free Tier:** 500 build minutes/month
- **Pros:**
  - Flutter-specific
  - Easy setup
  - Handles code signing automatically
  - Direct App Store upload
- **Setup Time:** ~30 minutes

#### **B. GitHub Actions**
- **Free Tier:** 2,000 minutes/month (public repos)
- **macOS Runners:** Available
- **Pros:**
  - Integrated with GitHub
  - Free for public repos
  - Flexible workflows

#### **C. CircleCI**
- **Free Tier:** Available
- **macOS Executors:** Available
- **Pros:**
  - Good Flutter support
  - Parallel builds

#### **D. Bitrise**
- **Website:** https://www.bitrise.io/
- **Free Tier:** Available
- **Pros:**
  - Mobile-focused
  - Good Flutter integration

---

### **Option 3: Virtual Machine (Not Recommended)**

⚠️ **Apple's EULA prohibits running macOS on non-Apple hardware**

While technically possible using:
- VMware Workstation
- VirtualBox
- Hackintosh

**Issues:**
- Violates Apple's license agreement
- Unstable and slow
- May not work with latest macOS
- Cannot use for commercial apps
- Risk of legal issues

**Verdict:** ❌ **Not recommended for production deployment**

---

## 📋 **Recommended Approach: Codemagic CI/CD**

Since you're on Windows, the **fastest and most reliable** path is using **Codemagic**.

### **Why Codemagic?**
1. ✅ No Mac required
2. ✅ Handles iOS code signing automatically
3. ✅ Direct App Store upload
4. ✅ Flutter-specific (built for Flutter)
5. ✅ Free tier available (500 minutes/month)
6. ✅ Can build both Android and iOS

### **Setup Steps:**

#### **1. Prerequisites**
- [ ] Apple Developer Account ($99/year)
- [ ] GitHub repository (already have: Isakainovorium/ChekMate)
- [ ] Codemagic account (free)

#### **2. Sign Up for Codemagic**
1. Go to https://codemagic.io/
2. Sign up with GitHub account
3. Connect your ChekMate repository

#### **3. Configure iOS Build**
1. In Codemagic dashboard, select ChekMate project
2. Go to **Settings** → **iOS code signing**
3. Choose **Automatic code signing** (recommended)
4. Connect Apple Developer account
5. Codemagic will automatically:
   - Create certificates
   - Create provisioning profiles
   - Configure signing

#### **4. Configure Codemagic Workflow**

The project already includes a `codemagic.yaml` configuration file at the root. This file defines three workflows:

- **ios-release**: Builds iOS IPA for App Store
- **android-release**: Builds Android APK and AAB
- **ios-and-android**: Builds both platforms in one workflow

**The workflow is already configured!** You just need to set up the required credentials in Codemagic.

#### **5. Set Up Credentials in Codemagic**

##### **A. App Store Connect API Key (Required for iOS)**

1. Go to https://appstoreconnect.apple.com/access/api
2. Click **Keys** tab → **Generate API Key**
3. Enter key name: "Codemagic CI"
4. Select **App Manager** role
5. Download the `.p8` key file (you can only download once!)
6. Note the **Key ID** and **Issuer ID**

7. In Codemagic dashboard:
   - Go to **Settings** → **Code signing identities**
   - Click **Add credentials** → **App Store Connect API key**
   - Upload the `.p8` file
   - Enter **Key ID** and **Issuer ID**
   - Save as credential group: `app_store_credentials`

##### **B. Firebase Credentials (Optional but Recommended)**

If you want to include Firebase config in builds:

1. Download `GoogleService-Info.plist` from Firebase Console
2. In Codemagic:
   - Go to **Settings** → **Environment variables**
   - Create group: `firebase_credentials`
   - Add file variable: `GOOGLE_SERVICE_INFO_PLIST`
   - Upload your `GoogleService-Info.plist` file

**Note:** The workflow will automatically place this file in `ios/Runner/` during build.

##### **C. Android Keystore (For Android Builds)**

1. If you have a keystore file:
   - Go to **Settings** → **Code signing identities**
   - Click **Add credentials** → **Android keystore**
   - Upload your `.jks` file
   - Enter keystore password, key alias, and key password
   - Save as credential group: `keystore_credentials`

#### **6. Configure Build Settings**

1. In Codemagic dashboard, select your ChekMate project
2. Go to **Settings** → **Build settings**
3. Ensure **Automatic code signing** is enabled for iOS
4. Select your **Team** (Apple Developer account)
5. Verify **Bundle ID**: `com.chekmate.app`

#### **7. Update Email Notifications**

Edit `codemagic.yaml` and replace `your-email@example.com` with your actual email address in the `publishing.email.recipients` section.

#### **8. Trigger Your First Build**

**Option A: Automatic (Recommended)**
- Push code to your `main` or `master` branch
- Codemagic automatically detects the `codemagic.yaml` file
- Build starts automatically

**Option B: Manual**
1. Go to Codemagic dashboard
2. Click **Start new build**
3. Select workflow: **ios-release**
4. Select branch: `main` (or your default branch)
5. Click **Start build**

#### **9. Monitor Build Progress**

1. Watch build logs in real-time
2. Build typically takes 15-30 minutes
3. Once complete, download IPA from **Artifacts** tab
4. Or configure automatic upload to TestFlight/App Store

---

## 📝 **Manual iOS Setup (If You Get Access to Mac)**

### **Step 1: Install Xcode**
1. Open **App Store** on Mac
2. Search for **Xcode**
3. Click **Install** (12+ GB download)
4. Wait for installation (~30-60 minutes)
5. Open Xcode and accept license agreement

### **Step 2: Install Xcode Command Line Tools**
```bash
xcode-select --install
```

### **Step 3: Verify Flutter iOS Setup**
```bash
flutter doctor -v
```

Expected output:
```
[✓] Xcode - develop for iOS and macOS
    • Xcode at /Applications/Xcode.app/Contents/Developer
    • Build 14C18
    • CocoaPods version 1.11.3
```

### **Step 4: Open iOS Project in Xcode**
```bash
cd /path/to/ChekMate_app/flutter_chekmate
open ios/Runner.xcworkspace
```

### **Step 5: Configure Signing**
1. In Xcode, select **Runner** target
2. Go to **Signing & Capabilities** tab
3. Check **Automatically manage signing**
4. Select your **Team** (Apple Developer account)
5. Verify **Bundle Identifier:** `com.chekmate.app`

### **Step 6: Register Bundle ID**
1. Go to https://developer.apple.com/account/
2. Navigate to **Certificates, Identifiers & Profiles**
3. Click **Identifiers** → **+**
4. Select **App IDs** → **Continue**
5. Enter:
   - **Description:** ChekMate
   - **Bundle ID:** `com.chekmate.app`
   - **Capabilities:** Enable required services
6. Click **Register**

### **Step 7: Create App in App Store Connect**
1. Go to https://appstoreconnect.apple.com/
2. Click **Apps** → **+** → **New App**
3. Fill in:
   - **Platform:** iOS
   - **Name:** ChekMate
   - **Primary Language:** English
   - **Bundle ID:** com.chekmate.app
   - **SKU:** chekmate-app-001
4. Click **Create**

### **Step 8: Build iOS App**
```bash
flutter build ios --release
```

Or build IPA for App Store:
```bash
flutter build ipa --release
```

### **Step 9: Archive and Upload**
1. In Xcode, select **Product** → **Archive**
2. Wait for archive to complete
3. Click **Distribute App**
4. Select **App Store Connect**
5. Click **Upload**
6. Wait for upload to complete

---

## 🔐 **Apple Developer Account Requirements**

### **What You Need:**
- [ ] Apple ID
- [ ] Apple Developer Program membership ($99/year)
- [ ] Two-factor authentication enabled

### **Sign Up:**
1. Go to https://developer.apple.com/programs/enroll/
2. Sign in with Apple ID
3. Complete enrollment form
4. Pay $99 annual fee
5. Wait for approval (usually 24-48 hours)

---

## 📱 **iOS Build Artifacts**

Once built, you'll have:

| Artifact | Location | Purpose |
|----------|----------|---------|
| **IPA** | `build/ios/ipa/ChekMate.ipa` | App Store upload |
| **Archive** | `build/ios/archive/Runner.xcarchive` | Xcode archive |
| **App** | `build/ios/iphoneos/Runner.app` | iOS app bundle |

---

## 🧪 **Testing iOS Build**

### **Option 1: TestFlight (Recommended)**
1. Upload IPA to App Store Connect
2. Go to **TestFlight** tab
3. Add internal testers (email addresses)
4. Testers receive email with download link
5. Install via TestFlight app

### **Option 2: Physical Device (Requires Mac)**
1. Connect iPhone/iPad via USB
2. In Xcode, select device from dropdown
3. Click **Run** button
4. App installs and launches on device

---

## 📊 **iOS Deployment Checklist**

### **Pre-Deployment:**
- [ ] Apple Developer Account active
- [ ] Bundle ID registered
- [ ] App created in App Store Connect
- [ ] App icons prepared (1024x1024 PNG)
- [ ] Screenshots prepared (all required sizes)
- [ ] Privacy policy URL ready
- [ ] App description written

### **Build Configuration:**
- [ ] Bundle ID matches App Store Connect
- [ ] Version number updated in pubspec.yaml
- [ ] Build number incremented
- [ ] Code signing configured
- [ ] Provisioning profiles valid

### **App Store Requirements:**
- [ ] App icons (all sizes)
- [ ] Launch screen
- [ ] Screenshots (iPhone, iPad)
- [ ] App description (4000 chars max)
- [ ] Keywords (100 chars max)
- [ ] Privacy policy URL
- [ ] Support URL
- [ ] Marketing URL (optional)
- [ ] Age rating completed
- [ ] Pricing & availability set

---

## 🚀 **Next Steps Based on Your Situation**

### **If You Have Access to Mac:**
1. ✅ Follow "Manual iOS Setup" section above
2. ✅ Build and test locally
3. ✅ Upload to App Store Connect
4. ✅ Submit for review

### **If You Don't Have Mac (Recommended):**
1. ✅ Sign up for Codemagic (free tier)
2. ✅ Connect GitHub repository
3. ✅ Configure automatic iOS signing
4. ✅ Trigger cloud build
5. ✅ Codemagic uploads to App Store automatically

### **If You Want to Acquire Mac:**
1. ✅ Consider Mac Mini (most affordable)
2. ✅ Or use cloud Mac service (MacStadium, MacinCloud)
3. ✅ Or use GitHub Actions (free macOS runners)

---

## 💰 **Cost Breakdown**

| Item | Cost | Required? |
|------|------|-----------|
| **Apple Developer Account** | $99/year | ✅ Yes |
| **Mac Hardware** | $599+ (Mac Mini) | ⚠️ Optional (use CI/CD) |
| **Codemagic Free Tier** | $0 (500 min/month) | ✅ Recommended |
| **Codemagic Pro** | $49/month | ⚠️ If need more builds |
| **Cloud Mac Rental** | $20-100/month | ⚠️ Alternative to hardware |

**Minimum Cost:** $99/year (Apple Developer + Codemagic free tier)

---

## 🎯 **Recommended Action Plan for ChekMate**

### **Phase 1: Immediate (This Week)**
1. ✅ Sign up for Apple Developer Program ($99)
2. ✅ Wait for approval (24-48 hours)
3. ✅ Sign up for Codemagic (free)
4. ✅ Connect ChekMate GitHub repo to Codemagic

### **Phase 2: Configuration (Next Week)**
1. ✅ Register Bundle ID: `com.chekmate.app`
2. ✅ Create app in App Store Connect
3. ✅ Set up App Store Connect API key in Codemagic
4. ✅ Configure Codemagic iOS signing (automatic)
5. ✅ Update email in `codemagic.yaml`
6. ✅ Prepare app icons and screenshots

### **Phase 3: Build & Test (Week 3)**
1. ✅ Push code to trigger automatic Codemagic build (or trigger manually)
2. ✅ Download IPA from Codemagic artifacts
3. ✅ Configure automatic TestFlight upload (optional)
4. ✅ Test on physical iOS devices via TestFlight
5. ✅ Fix any iOS-specific issues

### **Phase 4: Submission (Week 4)**
1. ✅ Complete App Store listing
2. ✅ Submit for review
3. ✅ Address review feedback
4. ✅ Launch to App Store

**Total Timeline:** ~4 weeks  
**Total Cost:** $99 (Apple Developer)

---

## 📞 **Support Resources**

- **Apple Developer Support:** https://developer.apple.com/support/
- **Flutter iOS Docs:** https://docs.flutter.dev/deployment/ios
- **Codemagic Docs:** https://docs.codemagic.io/
- **App Store Review Guidelines:** https://developer.apple.com/app-store/review/guidelines/

---

## ✅ **Summary**

**Current Blocker:** Windows OS (cannot build iOS locally)

**Recommended Solution:** Use Codemagic CI/CD
- ✅ No Mac required
- ✅ Automatic code signing
- ✅ Direct App Store upload
- ✅ Free tier available
- ✅ Flutter-optimized

**Alternative:** Acquire Mac (hardware or cloud rental)

**Next Immediate Action:** Sign up for Apple Developer Program ($99/year)

