# CodeMagic Setup - Browser-Assisted Steps

This document tracks the browser-assisted setup process for CodeMagic iOS build configuration.

## Current Status

### Completed (Code Changes)
- ✅ Updated `codemagic.yaml` with correct API credentials
- ✅ Removed all emojis from build scripts
- ✅ Updated notification email to: `isakaihbg@gmail.com`
- ✅ API key documentation updated

### Requires Manual Action (Authentication Required)

The following steps require you to log into CodeMagic. I can guide you through the browser, but you'll need to authenticate.

## Step-by-Step Browser Guide

### Step 1: Login to CodeMagic
**Current Page**: https://codemagic.io/login

**Action Required**:
1. Enter your email address in the email field
2. Click "Log in" OR use one of the provider buttons (GitHub/Bitbucket/GitLab)
3. Complete authentication

**After Login**: You'll be redirected to the Applications page

### Step 2: Add Application (if not already added)
**Expected Page**: https://codemagic.io/apps

**Actions**:
1. Click "Add application" button
2. Select your team (if you have multiple teams)
3. Connect your repository:
   - Choose GitHub, GitLab, or Bitbucket
   - Authorize CodeMagic access
   - Select the repository containing ChekMate app
4. Select **Flutter** as project type
5. Click "Finish: Add application"

**Verification**: CodeMagic should detect `codemagic.yaml` automatically

### Step 3: Configure Apple Developer Portal Integration
**Navigation**: User Settings → Integrations

**Actions**:
1. Go to User Settings (click your profile/avatar → Settings)
2. Scroll to "Integrations" section
3. Find "Apple Developer Portal" → Click "Connect"
4. Fill in:
   - **API key name**: `CodeMagic API Key`
   - **Issuer ID**: `92d1170a-d80b-41dd-b616-a30752db2bec`
   - **Key ID**: `7WNHASSNQK`
   - **API key**: Upload `AuthKey_7WNHASSNQK__ASC.p8` file
5. Click "Save"

**File Location**: `C:\Users\IsaKai2296\Downloads\ChekMate_app\AuthKey_7WNHASSNQK__ASC.p8`

### Step 4: Configure Environment Variables
**Navigation**: User Settings → Environment variables

**Actions**:
1. Go to User Settings → Environment variables
2. Verify `app_store_credentials` group exists (auto-created)
3. Create/verify `firebase_credentials` group:
   - Click "Add group" if needed
   - Name: `firebase_credentials`
4. Add variable to `firebase_credentials`:
   - Variable name: `GOOGLE_SERVICE_INFO_PLIST`
   - Upload your `GoogleService-Info.plist` file
   - Mark as Secure: Yes
   - Group: `firebase_credentials`

**Note**: If `GoogleService-Info.plist` is already in your repo, this step is optional.

### Step 5: Enable Automatic Code Signing
**Navigation**: App Page → Workflow Editor

**Actions**:
1. Go to your ChekMate app page
2. Click "Workflow Editor" or "Edit workflow"
3. Find "Distribution" section
4. Under "iOS code signing":
   - Select "Automatic"
   - Ensure "Apple Developer Portal" integration is selected (from Step 3)
5. Save changes

### Step 6: Verify Apple Developer Portal
**Navigation**: https://developer.apple.com/account/

**Verification Checklist**:
- [ ] Bundle ID `com.chekmate.app` exists in Identifiers
- [ ] Required capabilities enabled (Push Notifications, etc.)

**Navigation**: https://appstoreconnect.apple.com/

**Verification Checklist**:
- [ ] App exists with Bundle ID `com.chekmate.app`
- [ ] If not, create it:
  - Click "+" → New App
  - Platform: iOS
  - Bundle ID: `com.chekmate.app`
  - App Name: `ChekMate`
  - Primary Language: (select)
  - SKU: `chekmate-001`

### Step 7: Trigger First Build
**Navigation**: App Page in CodeMagic

**Actions**:
1. Ensure correct branch is selected (branch with `codemagic.yaml`)
2. Click "Start new build"
3. Select workflow: `ios-release`
4. Click "Start build"

**Monitor**:
- Watch build logs in real-time
- Check for errors
- Verify IPA generation

## Quick Reference

### Credentials
- **Issuer ID**: `92d1170a-d80b-41dd-b616-a30752db2bec`
- **Key ID**: `7WNHASSNQK`
- **API Key File**: `AuthKey_7WNHASSNQK__ASC.p8`
- **Bundle ID**: `com.chekmate.app`
- **Email**: `isakaihbg@gmail.com`

### File Locations
- API Key: `C:\Users\IsaKai2296\Downloads\ChekMate_app\AuthKey_7WNHASSNQK__ASC.p8`
- Config: `C:\Users\IsaKai2296\Downloads\ChekMate_app\codemagic.yaml`

## Next Actions

1. **Log into CodeMagic** at https://codemagic.io/login
2. **Follow Steps 2-7** above
3. **Monitor first build** for success

Once you're logged in, I can help navigate through the specific pages and verify configurations.

