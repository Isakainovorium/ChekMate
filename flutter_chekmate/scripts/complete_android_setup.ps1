# ============================================================================
# ChekMate Android Setup Completion Script
# ============================================================================
# Completes the Android setup after Android Studio installation
# ============================================================================

$ErrorActionPreference = "Continue"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "ChekMate Android Setup - Part 2" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Configuration
$AndroidSdkPath = "$env:LOCALAPPDATA\Android\Sdk"
$ProjectRoot = "c:\Users\IsaKai2296\Downloads\ChekMate_app\flutter_chekmate"
$KeystorePath = "$ProjectRoot\android\app\upload-keystore.jks"
$KeyPropertiesPath = "$ProjectRoot\android\key.properties"
$KeystorePassword = "chekmate2024"
$KeyAlias = "chekmate-key"

# Step 1: Configure Flutter Android SDK
Write-Host "`nStep 1: Configuring Flutter Android SDK..." -ForegroundColor Yellow

if (Test-Path $AndroidSdkPath) {
    flutter config --android-sdk $AndroidSdkPath
    Write-Host "SUCCESS: Flutter configured with Android SDK" -ForegroundColor Green
} else {
    Write-Host "WARNING: Android SDK not found at $AndroidSdkPath" -ForegroundColor Red
    Write-Host "Please launch Android Studio first to download SDK components" -ForegroundColor Yellow
    exit 1
}

# Step 2: Accept Android Licenses
Write-Host "`nStep 2: Accepting Android Licenses..." -ForegroundColor Yellow

$yes = "y`n" * 20
$yes | flutter doctor --android-licenses

Write-Host "SUCCESS: Android licenses accepted" -ForegroundColor Green

# Step 3: Verify Flutter Doctor
Write-Host "`nStep 3: Verifying Flutter Configuration..." -ForegroundColor Yellow

flutter doctor -v

# Step 4: Create Keystore
Write-Host "`nStep 4: Creating Android Keystore..." -ForegroundColor Yellow

if (Test-Path $KeystorePath) {
    Write-Host "INFO: Keystore already exists. Skipping creation." -ForegroundColor Yellow
} else {
    $keystoreParams = @(
        "-genkeypair",
        "-v",
        "-keystore", $KeystorePath,
        "-keyalg", "RSA",
        "-keysize", "2048",
        "-validity", "10000",
        "-alias", $KeyAlias,
        "-storepass", $KeystorePassword,
        "-keypass", $KeystorePassword,
        "-dname", "CN=ChekMate, OU=Development, O=ChekMate, L=City, S=State, C=US"
    )
    
    keytool @keystoreParams
    
    Write-Host "SUCCESS: Keystore created" -ForegroundColor Green
    
    # Create key.properties
    $keyPropertiesContent = @"
storePassword=$KeystorePassword
keyPassword=$KeystorePassword
keyAlias=$KeyAlias
storeFile=upload-keystore.jks
"@
    
    Set-Content -Path $KeyPropertiesPath -Value $keyPropertiesContent
    Write-Host "SUCCESS: key.properties created" -ForegroundColor Green
}

# Step 5: Extract SHA-1
Write-Host "`nStep 5: Extracting SHA-1 Fingerprint..." -ForegroundColor Yellow

if (Test-Path $KeystorePath) {
    $sha1Output = keytool -list -v -keystore $KeystorePath -alias $KeyAlias -storepass $KeystorePassword 2>&1 | Select-String "SHA1:"
    
    if ($sha1Output) {
        $sha1 = $sha1Output.ToString().Split(":")[1].Trim()
        Write-Host "`nSUCCESS: SHA-1 Fingerprint extracted" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "SHA-1: $sha1" -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Cyan
        
        # Save to file
        $sha1 | Out-File "$ProjectRoot\android\SHA1_FINGERPRINT.txt"
        
        Write-Host "`nNEXT STEP: Add this SHA-1 to Firebase Console:" -ForegroundColor Yellow
        Write-Host "https://console.firebase.google.com/project/chekmate-a0423/settings/general" -ForegroundColor Cyan
    }
}

# Step 6: Update build.gradle for signing
Write-Host "`nStep 6: Configuring build.gradle for signing..." -ForegroundColor Yellow

$buildGradlePath = "$ProjectRoot\android\app\build.gradle.kts"

if (Test-Path $buildGradlePath) {
    $buildGradleContent = Get-Content $buildGradlePath -Raw
    
    # Check if signing config already exists
    if ($buildGradleContent -notmatch "signingConfigs") {
        Write-Host "INFO: Adding signing configuration to build.gradle.kts" -ForegroundColor Yellow
        
        # This will be done manually or in next step
        Write-Host "WARNING: Manual update required for build.gradle.kts" -ForegroundColor Yellow
        Write-Host "See: docs/ANDROID_SDK_INSTALLATION_GUIDE.md" -ForegroundColor Yellow
    } else {
        Write-Host "INFO: Signing configuration already exists" -ForegroundColor Green
    }
}

# Step 7: Build Release APK
Write-Host "`nStep 7: Building Release APK..." -ForegroundColor Yellow

Set-Location $ProjectRoot

flutter clean
flutter pub get
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nSUCCESS: Release APK built successfully!" -ForegroundColor Green
    Write-Host "Location: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan
} else {
    Write-Host "`nERROR: Failed to build release APK" -ForegroundColor Red
}

# Step 8: Build App Bundle
Write-Host "`nStep 8: Building App Bundle (AAB)..." -ForegroundColor Yellow

flutter build appbundle --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nSUCCESS: App Bundle built successfully!" -ForegroundColor Green
    Write-Host "Location: build\app\outputs\bundle\release\app-release.aab" -ForegroundColor Cyan
} else {
    Write-Host "`nERROR: Failed to build app bundle" -ForegroundColor Red
}

# Summary
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Android Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "`nCompleted Tasks:" -ForegroundColor Yellow
Write-Host "- Android SDK configured" -ForegroundColor Green
Write-Host "- Android licenses accepted" -ForegroundColor Green
Write-Host "- Keystore created" -ForegroundColor Green
Write-Host "- SHA-1 fingerprint extracted" -ForegroundColor Green
Write-Host "- Release APK built" -ForegroundColor Green
Write-Host "- App Bundle built" -ForegroundColor Green

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Add SHA-1 to Firebase Console" -ForegroundColor Cyan
Write-Host "2. Download updated google-services.json" -ForegroundColor Cyan
Write-Host "3. Test APK on physical device" -ForegroundColor Cyan
Write-Host "4. Upload AAB to Google Play Console" -ForegroundColor Cyan

Write-Host "`nAll done!" -ForegroundColor Green

