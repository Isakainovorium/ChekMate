# Phase 1 Completion Guide - CodeMagic Setup

## ✅ Step 1.1: Associated Domains - COMPLETED
**Status**: Fixed in `flutter_chekmate/ios/Runner/Runner.entitlements`
- Commented out placeholder associated domains configuration
- Score: +5 pts → **73/100**

---

## 🔄 Step 1.2: Configure CodeMagic Signing (20 min) → +10 pts

### Prerequisites Checklist
- ✅ Apple Developer account active
- ✅ API Key file location: `C:\Users\IsaKai2296\Downloads\AuthKey_Y25ANC77X6.p8`
- ✅ Bundle ID registered: `com.chekmate.app`
- ✅ CodeMagic account created

### API Credentials
- **Issuer ID**: `92d1170a-d80b-41dd-b616-a30752db2bec`
- **Key ID**: `7WNHASSNQK`
- **API Key File**: `AuthKey_7WNHASSNQK__ASC.p8`

---

## Manual Steps Required (You Must Complete)

### A. Login to CodeMagic
1. Go to: https://codemagic.io/login
2. Sign in with your account

### B. Configure Apple Developer Portal Integration
1. Click your profile → **User Settings** (top right)
2. Scroll to **Integrations** section
3. Find **Apple Developer Portal** → Click **Connect**
4. Fill in the form:
   ```
   App Store Connect API key name: ChekMate iOS Signing
   Issuer ID: 92d1170a-d80b-41dd-b616-a30752db2bec
   Key ID: 7WNHASSNQK
   API key: [Upload AuthKey_7WNHASSNQK__ASC.p8]
   ```
5. Click **Save**

### C. Enable Automatic Code Signing
1. Go to your ChekMate app in CodeMagic
2. Click **Workflow Editor** or edit workflow
3. Under **Distribution** → **iOS code signing**
4. Select **Automatic** code signing
5. Select the Apple Developer Portal integration you just created
6. Save the workflow

### D. Verify Environment Groups
The `codemagic.yaml` already references these groups:
- `app_store_credentials` - Auto-configured by Apple Developer Portal integration
- `firebase_credentials` - Optional for now (can add later)

---

## Step 1.3: Trigger Test Build

### Before Building - Verify:
1. **Bundle ID exists in Apple Developer Portal**:
   - Go to: https://developer.apple.com/account/
   - Navigate to: **Certificates, Identifiers & Profiles** → **Identifiers**
   - Confirm `com.chekmate.app` is listed
   - Check that **Push Notifications** capability is enabled

2. **App exists in App Store Connect** (optional for now):
   - Go to: https://appstoreconnect.apple.com/
   - Navigate to **My Apps**
   - Check if app with Bundle ID `com.chekmate.app` exists

### Trigger Build:
1. In CodeMagic, go to your ChekMate app page
2. Select branch: `main` (or your primary branch)
3. Click **Start new build**
4. Select workflow: `ios-release`
5. Click **Start build**

### Monitor Build:
- Watch logs in real-time
- Build should take 15-30 minutes
- Success indicators:
  - ✅ Build completes without errors
  - ✅ IPA file generated in artifacts
  - ✅ Email notification received at: isakaihbg@gmail.com

---

## Expected Results

### If Successful:
- **Score**: 68 → **83/100** (+15 pts)
- IPA file downloadable from CodeMagic artifacts
- File size should be < 200MB
- Ready to proceed to Phase 2 (Build & Testing)

### If Build Fails:
Common issues and fixes:

1. **Code Signing Error**:
   - Verify API credentials are correct
   - Check Apple Developer account is active
   - Ensure automatic signing is enabled

2. **Bundle ID Not Found**:
   - Register `com.chekmate.app` in Apple Developer Portal
   - Wait 5-10 minutes for propagation
   - Retry build

3. **Build Runner Errors**:
   - These are non-critical (tests may fail)
   - Build should continue and complete
   - Check logs for actual blocking errors

---

## Quick Reference Commands

### Check API Key File:
```powershell
Test-Path "C:\Users\IsaKai2296\Downloads\AuthKey_Y25ANC77X6.p8"
```

### View CodeMagic Config:
```powershell
Get-Content "C:\Users\IsaKai2296\Downloads\ChekMate_app\codemagic.yaml"
```

---

## Next Steps After Phase 1

Once build succeeds:
1. Download IPA from CodeMagic artifacts
2. Proceed to **Phase 2: Build & Testing**
3. Test on physical iOS device
4. Verify core features work

---

## Support Links

- CodeMagic Dashboard: https://codemagic.io/apps
- Apple Developer Portal: https://developer.apple.com/account/
- App Store Connect: https://appstoreconnect.apple.com/
- CodeMagic Docs: https://docs.codemagic.io/

---

## Status Tracking

- [x] Step 1.1: Fix Associated Domains → +5 pts (73/100)
- [ ] Step 1.2: Configure CodeMagic Signing → +10 pts (83/100)
- [ ] Step 1.3: Trigger Test Build

**Current Score**: 73/100  
**Target After Phase 1**: 83/100  
**Remaining**: +10 pts
