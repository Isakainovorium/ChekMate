# ChekMate - Android Production Setup Script
# This script helps you set up Android SDK and create keystore for production builds
# Date: October 22, 2025

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ChekMate Android Production Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = "C:\Users\IsaKai2296\Downloads\ChekMate_app\flutter_chekmate"
Set-Location $projectRoot

# Step 1: Check Android SDK
Write-Host "Step 1: Checking Android SDK..." -ForegroundColor Yellow
Write-Host ""

$androidHome = $env:ANDROID_HOME
if (-not $androidHome) {
    $androidHome = $env:ANDROID_SDK_ROOT
}

if (-not $androidHome -or -not (Test-Path $androidHome)) {
    Write-Host "❌ Android SDK not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "OPTION 1: Install Android Studio (Recommended)" -ForegroundColor Cyan
    Write-Host "  1. Download from: https://developer.android.com/studio" -ForegroundColor White
    Write-Host "  2. Run the installer" -ForegroundColor White
    Write-Host "  3. Follow the setup wizard (install SDK components)" -ForegroundColor White
    Write-Host "  4. Restart this script after installation" -ForegroundColor White
    Write-Host ""
    Write-Host "OPTION 2: Install Command Line Tools Only (Faster)" -ForegroundColor Cyan
    Write-Host "  1. Download from: https://developer.android.com/studio#command-line-tools-only" -ForegroundColor White
    Write-Host "  2. Extract to: C:\Android\cmdline-tools" -ForegroundColor White
    Write-Host "  3. Run: flutter config --android-sdk C:\Android" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Do you want to open the download page now? (y/n)"
    if ($choice -eq "y" -or $choice -eq "Y") {
        Start-Process "https://developer.android.com/studio"
    }
    
    Write-Host ""
    Write-Host "⏸️  Pausing here. Please install Android SDK and run this script again." -ForegroundColor Yellow
    exit
} else {
    Write-Host "✅ Android SDK found at: $androidHome" -ForegroundColor Green
}

# Step 2: Create Keystore
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 2: Creating Production Keystore" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$keystoreDir = "android\app\keystore"
$keystorePath = "$keystoreDir\chekmate-release.jks"

if (Test-Path $keystorePath) {
    Write-Host "⚠️  Keystore already exists at: $keystorePath" -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to create a new one? This will overwrite the existing keystore! (y/n)"
    if ($overwrite -ne "y" -and $overwrite -ne "Y") {
        Write-Host "✅ Using existing keystore" -ForegroundColor Green
        $useExisting = $true
    } else {
        Remove-Item $keystorePath -Force
        $useExisting = $false
    }
} else {
    $useExisting = $false
}

if (-not $useExisting) {
    # Create keystore directory
    if (-not (Test-Path $keystoreDir)) {
        New-Item -ItemType Directory -Force -Path $keystoreDir | Out-Null
        Write-Host "✅ Created keystore directory" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "You will be asked for the following information:" -ForegroundColor Cyan
    Write-Host "  1. Keystore password (choose a strong password!)" -ForegroundColor White
    Write-Host "  2. Key password (can be same as keystore password)" -ForegroundColor White
    Write-Host "  3. Your name or company name" -ForegroundColor White
    Write-Host "  4. Organizational unit (e.g., Development)" -ForegroundColor White
    Write-Host "  5. Organization name (e.g., ChekMate)" -ForegroundColor White
    Write-Host "  6. City" -ForegroundColor White
    Write-Host "  7. State/Province" -ForegroundColor White
    Write-Host "  8. Country code (e.g., US)" -ForegroundColor White
    Write-Host ""
    Write-Host "⚠️  IMPORTANT: Save your passwords securely! You'll need them for every release." -ForegroundColor Yellow
    Write-Host ""

    $proceed = Read-Host "Ready to create keystore? (y/n)"
    if ($proceed -ne "y" -and $proceed -ne "Y") {
        Write-Host "❌ Keystore creation cancelled" -ForegroundColor Red
        exit
    }

    # Generate keystore
    Write-Host ""
    Write-Host "Creating keystore..." -ForegroundColor Yellow
    
    $keytoolCmd = "keytool -genkey -v -keystore `"$keystorePath`" -keyalg RSA -keysize 2048 -validity 10000 -alias chekmate-release"
    
    try {
        Invoke-Expression $keytoolCmd
        Write-Host ""
        Write-Host "✅ Keystore created successfully!" -ForegroundColor Green
    } catch {
        Write-Host ""
        Write-Host "❌ Failed to create keystore. Make sure Java JDK is installed." -ForegroundColor Red
        Write-Host "Download Java JDK from: https://www.oracle.com/java/technologies/downloads/" -ForegroundColor Yellow
        exit
    }
}

# Step 3: Create key.properties
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 3: Creating key.properties" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$keyPropertiesPath = "android\key.properties"

if (Test-Path $keyPropertiesPath) {
    Write-Host "⚠️  key.properties already exists" -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to update it? (y/n)"
    if ($overwrite -ne "y" -and $overwrite -ne "Y") {
        Write-Host "✅ Using existing key.properties" -ForegroundColor Green
        $skipKeyProperties = $true
    } else {
        $skipKeyProperties = $false
    }
} else {
    $skipKeyProperties = $false
}

if (-not $skipKeyProperties) {
    Write-Host ""
    Write-Host "Please enter your keystore credentials:" -ForegroundColor Cyan
    $storePassword = Read-Host "Keystore password" -AsSecureString
    $keyPassword = Read-Host "Key password" -AsSecureString
    
    # Convert SecureString to plain text for file
    $storePasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePassword))
    $keyPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPassword))
    
    $keyPropertiesContent = @"
storePassword=$storePasswordPlain
keyPassword=$keyPasswordPlain
keyAlias=chekmate-release
storeFile=keystore/chekmate-release.jks
"@
    
    Set-Content -Path $keyPropertiesPath -Value $keyPropertiesContent
    Write-Host "✅ key.properties created successfully!" -ForegroundColor Green
    Write-Host "⚠️  This file is gitignored and contains sensitive information" -ForegroundColor Yellow
}

# Step 4: Verify Setup
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 4: Verifying Setup" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$checks = @()

# Check keystore exists
if (Test-Path $keystorePath) {
    Write-Host "✅ Keystore exists: $keystorePath" -ForegroundColor Green
    $checks += $true
} else {
    Write-Host "❌ Keystore not found: $keystorePath" -ForegroundColor Red
    $checks += $false
}

# Check key.properties exists
if (Test-Path $keyPropertiesPath) {
    Write-Host "✅ key.properties exists" -ForegroundColor Green
    $checks += $true
} else {
    Write-Host "❌ key.properties not found" -ForegroundColor Red
    $checks += $false
}

# Check build.gradle.kts is configured
$buildGradle = Get-Content "android\app\build.gradle.kts" -Raw
if ($buildGradle -match 'com\.chekmate\.app') {
    Write-Host "✅ Application ID is set to production value" -ForegroundColor Green
    $checks += $true
} else {
    Write-Host "❌ Application ID still using example value" -ForegroundColor Red
    $checks += $false
}

# Check if signing config is present
if ($buildGradle -match 'signingConfigs') {
    Write-Host "✅ Signing configuration is present" -ForegroundColor Green
    $checks += $true
} else {
    Write-Host "❌ Signing configuration not found" -ForegroundColor Red
    $checks += $false
}

Write-Host ""
if ($checks -notcontains $false) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✅ ALL CHECKS PASSED!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "You're ready to build a release!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Build release APK: flutter build apk --release" -ForegroundColor White
    Write-Host "  2. Build App Bundle: flutter build appbundle --release" -ForegroundColor White
    Write-Host "  3. Test on device: flutter install --release" -ForegroundColor White
    Write-Host ""
    
    $buildNow = Read-Host "Do you want to build the release App Bundle now? (y/n)"
    if ($buildNow -eq "y" -or $buildNow -eq "Y") {
        Write-Host ""
        Write-Host "Building release App Bundle..." -ForegroundColor Yellow
        Write-Host "This may take several minutes..." -ForegroundColor Gray
        Write-Host ""
        flutter build appbundle --release
    }
} else {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "⚠️  SOME CHECKS FAILED" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please fix the issues above and run this script again." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Cyan

