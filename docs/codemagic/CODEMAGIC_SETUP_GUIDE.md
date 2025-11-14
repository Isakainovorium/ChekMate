# CodeMagic iOS Build Setup Guide

This guide provides step-by-step instructions for completing the CodeMagic configuration for building the ChekMate iOS app.

## Prerequisites

- Apple Developer account with active membership
- App Store Connect API credentials:
  - Issuer ID: `92d1170a-d80b-41dd-b616-a30752db2bec`
  - Key ID: `7WNHASSNQK`
  - API Key File: `AuthKey_7WNHASSNQK__ASC.p8`
- Bundle ID registered: `com.chekmate.app`
- CodeMagic account created

## Step 1: Add App to CodeMagic

1. Log in to [CodeMagic](https://codemagic.io/)
2. Click **Add application** on the Applications page
3. If you have multiple teams, select the appropriate team
4. Connect your repository (GitHub/GitLab/Bitbucket)
   - Authorize CodeMagic to access your repository
   - Select the repository containing the ChekMate app
5. Select **Flutter** as the project type
6. Click **Finish: Add application**

CodeMagic should automatically detect the `codemagic.yaml` file in your repository.

## Step 2: Configure Apple Developer Portal Integration

1. In CodeMagic, go to **User Settings** (or **Team Settings** for team projects)
2. Scroll to the **Integrations** section
3. Find **Apple Developer Portal** and click **Connect**
4. Fill in the following information:
   - **App Store Connect API key name**: `CodeMagic API Key` (or any descriptive name)
   - **Issuer ID**: `92d1170a-d80b-41dd-b616-a30752db2bec`
   - **Key ID**: `7WNHASSNQK`
   - **API key**: Click **Upload** and select the file `AuthKey_7WNHASSNQK__ASC.p8`
5. Click **Save** to complete the integration

## Step 3: Configure Environment Variables

1. In CodeMagic, go to **User Settings** → **Environment variables** (or **Team Settings** for team projects)
2. Create/verify the following environment variable groups:

### app_store_credentials Group
- This group is automatically used by CodeMagic when automatic code signing is enabled
- No manual configuration needed if using automatic code signing

### firebase_credentials Group
1. Create a group named `firebase_credentials` (if it doesn't exist)
2. Add the following variable:
   - **Variable name**: `GOOGLE_SERVICE_INFO_PLIST`
   - **Variable value**: Upload your `GoogleService-Info.plist` file
   - **Secure**: Yes (recommended)
   - **Group**: `firebase_credentials`

Note: If you already have `GoogleService-Info.plist` in your repository at `flutter_chekmate/ios/Runner/GoogleService-Info.plist`, this step is optional.

## Step 4: Enable Automatic Code Signing

1. In CodeMagic, go to your app's page
2. Click on **Workflow Editor** (or edit your workflow)
3. Under **Distribution** section, find **iOS code signing**
4. Select **Automatic** code signing
5. Ensure the **Apple Developer Portal** integration you created in Step 2 is selected
6. CodeMagic will automatically:
   - Generate certificates
   - Create provisioning profiles
   - Sign your app during the build process

## Step 5: Update Notification Email

Before your first build, update the email address in `codemagic.yaml`:

1. In your repository, edit `codemagic.yaml`
2. Find line 17: `NOTIFICATION_EMAIL: your-email@example.com`
3. Replace `your-email@example.com` with your actual email address
4. Commit and push the changes

## Step 6: Verify Apple Developer Portal Setup

Before building, verify the following in Apple Developer Portal:

1. **Bundle ID Registration**:
   - Go to [Apple Developer Portal](https://developer.apple.com/account/)
   - Navigate to **Certificates, Identifiers & Profiles** → **Identifiers**
   - Verify `com.chekmate.app` exists
   - Ensure required capabilities are enabled (Push Notifications, etc.)

2. **App Store Connect App**:
   - Go to [App Store Connect](https://appstoreconnect.apple.com/)
   - Navigate to **My Apps**
   - Verify an app exists with Bundle ID `com.chekmate.app`
   - If it doesn't exist, create it:
     - Click **+** to create a new app
     - Select **iOS**
     - Bundle ID: `com.chekmate.app`
     - App Name: `ChekMate`
     - Primary Language: (select your language)
     - SKU: `chekmate-001` (or any unique identifier)

## Step 7: Optional - Enable App Store Publishing

If you want automatic TestFlight submission:

1. Edit `codemagic.yaml` in your repository
2. Uncomment lines 110-114 (the `app_store_connect` section)
3. Configure as needed:
   ```yaml
   app_store_connect:
     auth: integration
     submit_to_testflight: true
     beta_groups:
       - "Internal Testers"
   ```
4. Commit and push the changes

## Step 8: Trigger First Build

1. In CodeMagic, go to your app's page
2. Ensure the correct branch is selected (the branch containing `codemagic.yaml`)
3. Click **Start new build**
4. Select the `ios-release` workflow
5. Click **Start build**

## Monitoring the Build

1. Watch the build logs in real-time
2. Check for any errors or warnings
3. Verify the build completes successfully
4. Download the IPA file from the artifacts section

## Troubleshooting

### Build Fails with Code Signing Error
- Verify the Apple Developer Portal integration is correctly configured
- Check that the Issuer ID and Key ID are correct
- Ensure your Apple Developer account is active

### Build Fails with "No Bundle ID Found"
- Verify the Bundle ID `com.chekmate.app` is registered in Apple Developer Portal
- Check that the Bundle ID matches in both `codemagic.yaml` and Apple Developer Portal

### Firebase Configuration Issues
- Verify `GoogleService-Info.plist` is in the correct location
- Check that the environment variable is set if using it
- Ensure Firebase is properly configured in your Flutter project

### Email Notifications Not Received
- Verify the email address in `codemagic.yaml` is correct
- Check your spam folder
- Ensure email notifications are enabled in the publishing section

## Success Indicators

- Build completes without errors
- IPA file is generated and downloadable
- Email notification is received
- If publishing is enabled, app appears in TestFlight

## Next Steps After Successful Build

1. Download and test the IPA file
2. If publishing is enabled, check TestFlight for the build
3. Submit to App Store Review (if ready)
4. Monitor build performance and optimize as needed

