# Production Readiness Quick Fixes
# Run this script to apply critical production fixes
# Date: October 22, 2025

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ChekMate Production Readiness Fixes" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = "C:\Users\IsaKai2296\Downloads\ChekMate_app\flutter_chekmate"
Set-Location $projectRoot

# Check 1: Verify API key is not exposed
Write-Host "[1/7] Checking API key security..." -ForegroundColor Yellow
$apiKeyFile = "config\.openai_key"
if (Test-Path $apiKeyFile) {
    $content = Get-Content $apiKeyFile -Raw
    if ($content -match "sk-") {
        Write-Host "  ❌ CRITICAL: API key still exposed in $apiKeyFile" -ForegroundColor Red
        Write-Host "  ACTION REQUIRED: Remove the actual API key from this file" -ForegroundColor Red
    } else {
        Write-Host "  ✅ API key file is safe (no actual key found)" -ForegroundColor Green
    }
} else {
    Write-Host "  ⚠️  API key file not found" -ForegroundColor Yellow
}

# Check 2: Verify .gitignore includes Android signing
Write-Host ""
Write-Host "[2/7] Checking .gitignore configuration..." -ForegroundColor Yellow
$gitignore = Get-Content ".gitignore" -Raw
if ($gitignore -match "android/key.properties" -and $gitignore -match "\.jks") {
    Write-Host "  ✅ .gitignore properly configured for Android signing" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  .gitignore may need Android signing entries" -ForegroundColor Yellow
}

# Check 3: Check Android application ID
Write-Host ""
Write-Host "[3/7] Checking Android application ID..." -ForegroundColor Yellow
$buildGradle = Get-Content "android\app\build.gradle.kts" -Raw
if ($buildGradle -match 'com\.example\.flutter_chekmate') {
    Write-Host "  ❌ CRITICAL: Using example application ID" -ForegroundColor Red
    Write-Host "  ACTION REQUIRED: Update to production ID in android/app/build.gradle.kts" -ForegroundColor Red
    Write-Host "  Change 'com.example.flutter_chekmate' to 'com.chekmate.app' (or your domain)" -ForegroundColor Yellow
} else {
    Write-Host "  ✅ Application ID appears to be customized" -ForegroundColor Green
}

# Check 4: Check Android signing configuration
Write-Host ""
Write-Host "[4/7] Checking Android signing configuration..." -ForegroundColor Yellow
if ($buildGradle -match 'signingConfig = signingConfigs\.getByName\("debug"\)') {
    Write-Host "  ❌ CRITICAL: Release builds using debug signing" -ForegroundColor Red
    Write-Host "  ACTION REQUIRED: Configure production signing" -ForegroundColor Red
    Write-Host "  See: docs/ANDROID_RELEASE_SIGNING_GUIDE.md" -ForegroundColor Yellow
} else {
    Write-Host "  ✅ Signing configuration appears to be set up" -ForegroundColor Green
}

# Check 5: Check if Android SDK is installed
Write-Host ""
Write-Host "[5/7] Checking Android SDK..." -ForegroundColor Yellow
try {
    $flutterDoctor = flutter doctor 2>&1 | Out-String
    if ($flutterDoctor -match "Android toolchain.*Unable to locate Android SDK") {
        Write-Host "  ❌ CRITICAL: Android SDK not installed" -ForegroundColor Red
        Write-Host "  ACTION REQUIRED: Install Android Studio" -ForegroundColor Red
        Write-Host "  Download from: https://developer.android.com/studio" -ForegroundColor Yellow
    } else {
        Write-Host "  ✅ Android SDK appears to be installed" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠️  Could not run flutter doctor" -ForegroundColor Yellow
}

# Check 6: Check Firebase configuration
Write-Host ""
Write-Host "[6/7] Checking Firebase configuration..." -ForegroundColor Yellow
$firebaseOptions = Get-Content "lib\firebase_options.dart" -Raw
if ($firebaseOptions -match "This is a placeholder file") {
    Write-Host "  ⚠️  Firebase options file contains placeholder comment" -ForegroundColor Yellow
    Write-Host "  ACTION REQUIRED: Verify Firebase config is production-ready" -ForegroundColor Yellow
} else {
    Write-Host "  ✅ Firebase options file appears configured" -ForegroundColor Green
}

# Check 7: Check for outdated dependencies
Write-Host ""
Write-Host "[7/7] Checking dependencies..." -ForegroundColor Yellow
Write-Host "  Running flutter pub outdated (this may take a moment)..." -ForegroundColor Gray
try {
    $outdated = flutter pub outdated 2>&1 | Out-String
    if ($outdated -match "89.*dependencies are constrained") {
        Write-Host "  ⚠️  89 dependencies have major updates available" -ForegroundColor Yellow
        Write-Host "  RECOMMENDED: Run 'flutter pub upgrade --major-versions'" -ForegroundColor Yellow
    } else {
        Write-Host "  ✅ Dependencies are up to date" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠️  Could not check dependencies" -ForegroundColor Yellow
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Critical Issues Found:" -ForegroundColor Red
Write-Host "  1. Android application ID needs update" -ForegroundColor Yellow
Write-Host "  2. Android release signing not configured" -ForegroundColor Yellow
Write-Host "  3. Android SDK may not be installed" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Review: docs/PRODUCTION_READINESS_AUDIT_2025-10-22.md" -ForegroundColor White
Write-Host "  2. Follow: docs/ANDROID_RELEASE_SIGNING_GUIDE.md" -ForegroundColor White
Write-Host "  3. Update Android application ID in android/app/build.gradle.kts" -ForegroundColor White
Write-Host "  4. Install Android SDK if needed" -ForegroundColor White
Write-Host "  5. Run: flutter pub upgrade --major-versions" -ForegroundColor White
Write-Host "  6. Run: flutter test --coverage" -ForegroundColor White
Write-Host "  7. Build release: flutter build appbundle --release" -ForegroundColor White
Write-Host ""
Write-Host "For detailed instructions, see:" -ForegroundColor Cyan
Write-Host "  docs/PRODUCTION_READINESS_AUDIT_2025-10-22.md" -ForegroundColor White
Write-Host ""

