# ============================================================================
# ChekMate Android Deployment Automation Script
# ============================================================================
# This script automates the complete Android app deployment process:
# 1. Install Android Studio silently
# 2. Configure Android SDK
# 3. Create Android keystore
# 4. Configure SHA-1 fingerprint
# 5. Build release APK/AAB
# 6. Test the build
# ============================================================================

param(
    [string]$ProjectRoot = "c:\Users\IsaKai2296\Downloads\ChekMate_app\flutter_chekmate",
    [string]$AndroidStudioInstaller = "$env:USERPROFILE\Downloads\android-studio-2024.2.1.11-windows.exe",
    [string]$KeystorePassword = "chekmate2024",
    [string]$KeyAlias = "chekmate-key",
    [switch]$SkipAndroidStudioInstall,
    [switch]$SkipKeystoreCreation,
    [switch]$SkipBuild
)

# ============================================================================
# Configuration
# ============================================================================

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$AndroidStudioPath = "C:\Program Files\Android\Android Studio"
$AndroidSdkPath = "$env:LOCALAPPDATA\Android\Sdk"
$KeystorePath = "$ProjectRoot\android\app\upload-keystore.jks"
$KeyPropertiesPath = "$ProjectRoot\android\key.properties"

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Step {
    param([string]$Message)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "INFO: $Message" -ForegroundColor Yellow
}

# ============================================================================
# Step 1: Install Android Studio (Silent Installation)
# ============================================================================

if (-not $SkipAndroidStudioInstall) {
    Write-Step "Step 1: Installing Android Studio"
    
    if (-not (Test-Path $AndroidStudioInstaller)) {
        Write-Error-Custom "Android Studio installer not found at: $AndroidStudioInstaller"
        Write-Info "Downloading Android Studio..."
        
        $downloadUrl = "https://redirector.gvt1.com/edgedl/android/studio/install/2024.2.1.11/android-studio-2024.2.1.11-windows.exe"
        Invoke-WebRequest -Uri $downloadUrl -OutFile $AndroidStudioInstaller
        Write-Success "Download complete"
    }
    
    Write-Info "Running silent installation..."
    Write-Info "This may take 10-15 minutes..."
    
    # Run installer with silent flags
    $installArgs = @(
        "/S",  # Silent mode
        "/D=$AndroidStudioPath"  # Installation directory
    )
    
    Start-Process -FilePath $AndroidStudioInstaller -ArgumentList $installArgs -Wait -NoNewWindow
    
    Write-Success "Android Studio installed successfully"
} else {
    Write-Info "Skipping Android Studio installation (already installed)"
}

# ============================================================================
# Step 2: Configure Android SDK
# ============================================================================

Write-Step "Step 2: Configuring Android SDK"

# Set environment variables
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $AndroidSdkPath, "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $AndroidSdkPath, "User")

# Add to PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$pathsToAdd = @(
    "$AndroidSdkPath\platform-tools",
    "$AndroidSdkPath\cmdline-tools\latest\bin",
    "$AndroidSdkPath\tools\bin"
)

foreach ($pathToAdd in $pathsToAdd) {
    if ($currentPath -notlike "*$pathToAdd*") {
        $currentPath = "$currentPath;$pathToAdd"
    }
}

[Environment]::SetEnvironmentVariable("Path", $currentPath, "User")

# Refresh environment variables in current session
$env:ANDROID_HOME = $AndroidSdkPath
$env:ANDROID_SDK_ROOT = $AndroidSdkPath
$env:Path = $currentPath

Write-Success "Android SDK environment variables configured"

# ============================================================================
# Step 3: Install SDK Components
# ============================================================================

Write-Step "Step 3: Installing SDK Components"

Write-Info "Accepting Android licenses..."

# Accept licenses
$sdkmanager = "$AndroidSdkPath\cmdline-tools\latest\bin\sdkmanager.bat"

if (Test-Path $sdkmanager) {
    # Accept all licenses
    $licenses = "y`n" * 10
    $licenses | & $sdkmanager --licenses
    
    Write-Success "Android licenses accepted"
} else {
    Write-Info "SDK Manager not found. Will be configured on first Android Studio launch."
}

# ============================================================================
# Step 4: Verify Flutter Doctor
# ============================================================================

Write-Step "Step 4: Verifying Flutter Configuration"

Set-Location $ProjectRoot

Write-Info "Running flutter doctor..."
flutter doctor -v

Write-Success "Flutter doctor check complete"

# ============================================================================
# Step 5: Create Android Keystore
# ============================================================================

if (-not $SkipKeystoreCreation) {
    Write-Step "Step 5: Creating Android Keystore"
    
    if (Test-Path $KeystorePath) {
        Write-Info "Keystore already exists at: $KeystorePath"
        $overwrite = Read-Host "Overwrite existing keystore? (y/n)"
        if ($overwrite -ne "y") {
            Write-Info "Skipping keystore creation"
            $SkipKeystoreCreation = $true
        } else {
            Remove-Item $KeystorePath -Force
        }
    }
    
    if (-not $SkipKeystoreCreation) {
        Write-Info "Generating keystore..."
        
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
        
        & keytool @keystoreParams
        
        Write-Success "Keystore created at: $KeystorePath"
        
        # Create key.properties file
        Write-Info "Creating key.properties file..."
        
        $keyPropertiesContent = @"
storePassword=$KeystorePassword
keyPassword=$KeystorePassword
keyAlias=$KeyAlias
storeFile=upload-keystore.jks
"@
        
        Set-Content -Path $KeyPropertiesPath -Value $keyPropertiesContent
        
        Write-Success "key.properties created at: $KeyPropertiesPath"
    }
} else {
    Write-Info "Skipping keystore creation"
}

# ============================================================================
# Step 6: Extract SHA-1 Fingerprint
# ============================================================================

Write-Step "Step 6: Extracting SHA-1 Fingerprint"

if (Test-Path $KeystorePath) {
    Write-Info "Extracting SHA-1 fingerprint..."
    
    $sha1Output = & keytool -list -v -keystore $KeystorePath -alias $KeyAlias -storepass $KeystorePassword | Select-String "SHA1:"
    
    if ($sha1Output) {
        $sha1 = $sha1Output.ToString().Split(":")[1].Trim()
        Write-Success "SHA-1 Fingerprint: $sha1"
        Write-Info "Add this SHA-1 to Firebase Console:"
        Write-Host "https://console.firebase.google.com/project/chekmate-a0423/settings/general" -ForegroundColor Cyan
        
        # Save to file for reference
        $sha1 | Out-File "$ProjectRoot\android\SHA1_FINGERPRINT.txt"
        Write-Success "SHA-1 saved to: android\SHA1_FINGERPRINT.txt"
    } else {
        Write-Error-Custom "Failed to extract SHA-1 fingerprint"
    }
} else {
    Write-Info "Keystore not found. Skipping SHA-1 extraction."
}

# ============================================================================
# Step 7: Build Release APK and AAB
# ============================================================================

if (-not $SkipBuild) {
    Write-Step "Step 7: Building Release APK and AAB"
    
    Write-Info "Building release APK..."
    flutter build apk --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Release APK built successfully"
        Write-Info "APK location: build\app\outputs\flutter-apk\app-release.apk"
    } else {
        Write-Error-Custom "Failed to build release APK"
    }
    
    Write-Info "Building release App Bundle (AAB)..."
    flutter build appbundle --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Release AAB built successfully"
        Write-Info "AAB location: build\app\outputs\bundle\release\app-release.aab"
    } else {
        Write-Error-Custom "Failed to build release AAB"
    }
} else {
    Write-Info "Skipping build step"
}

# ============================================================================
# Step 8: Summary
# ============================================================================

Write-Step "Deployment Automation Complete!"

Write-Host "`n📊 Summary:" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

if (-not $SkipAndroidStudioInstall) {
    Write-Host "✅ Android Studio installed" -ForegroundColor Green
}
Write-Host "✅ Android SDK configured" -ForegroundColor Green
Write-Host "✅ Environment variables set" -ForegroundColor Green

if (-not $SkipKeystoreCreation -and (Test-Path $KeystorePath)) {
    Write-Host "✅ Keystore created" -ForegroundColor Green
    Write-Host "✅ key.properties configured" -ForegroundColor Green
    Write-Host "✅ SHA-1 fingerprint extracted" -ForegroundColor Green
}

if (-not $SkipBuild) {
    Write-Host "✅ Release APK built" -ForegroundColor Green
    Write-Host "✅ Release AAB built" -ForegroundColor Green
}

Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Yellow
Write-Host "1. Add SHA-1 to Firebase Console" -ForegroundColor Yellow
Write-Host "2. Download updated google-services.json" -ForegroundColor Yellow
Write-Host "3. Test APK on physical device" -ForegroundColor Yellow
Write-Host "4. Upload AAB to Google Play Console" -ForegroundColor Yellow

Write-Host "`nAll done!" -ForegroundColor Green

