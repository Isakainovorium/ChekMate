# ============================================================================
# ChekMate GitHub Repository Setup Script
# ============================================================================
# This script sets up the GitHub repository with the following branch structure:
# - main: Main codebase (lib/, test/, assets/, etc.)
# - docs: Documentation files only
# - android: Android-specific files only
# - ios: iOS-specific files only
# - tools: Sensitive configuration and tools
# ============================================================================

$ErrorActionPreference = "Stop"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "ChekMate GitHub Repository Setup" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Configuration
$repoUrl = "https://github.com/Isakainovorium/ChekMate.git"
$projectRoot = "c:\Users\IsaKai2296\Downloads\ChekMate_app\flutter_chekmate"

Set-Location $projectRoot

# Step 1: Add remote repository
Write-Host "Step 1: Adding GitHub remote..." -ForegroundColor Yellow

$remoteExists = git remote | Select-String "origin"
if ($remoteExists) {
    Write-Host "Remote 'origin' already exists. Removing..." -ForegroundColor Yellow
    git remote remove origin
}

git remote add origin $repoUrl
Write-Host "SUCCESS: Remote added" -ForegroundColor Green

# Step 2: Create and commit main branch
Write-Host "`nStep 2: Setting up main branch..." -ForegroundColor Yellow

# Stage all files except sensitive ones (gitignore will handle this)
git add .
git commit -m "Initial commit: ChekMate Flutter app - Phase 7 Production Deployment

- Complete Flutter app with 70 packages
- Clean architecture (feature-first organization)
- Firebase integration (Auth, Firestore, Storage, FCM, Analytics, Crashlytics)
- 56 enterprise-grade UI components
- 70%+ test coverage (50+ unit tests, 15+ widget tests, 5+ integration tests)
- TikTok/Instagram-style animations
- Voice messages, video playback, multi-photo carousel
- Location-based discovery with interest matching
- Push notifications and analytics
- Production-ready with ProGuard obfuscation

Phase 7 Progress: 38% complete (3/8 tasks)
- Firebase Android/iOS configuration complete
- Firebase security rules deployed
- Android SDK setup in progress
"

Write-Host "SUCCESS: Main branch committed" -ForegroundColor Green

# Step 3: Create docs branch
Write-Host "`nStep 3: Creating docs branch..." -ForegroundColor Yellow

git checkout --orphan docs
git rm -rf .
git checkout main -- docs/
git add docs/
git commit -m "Documentation: ChekMate project documentation

- Architecture documentation
- Phase tracker and progress reports
- Implementation guides
- Testing documentation
- Deployment guides
- CircleCI integration docs
"

Write-Host "SUCCESS: Docs branch created" -ForegroundColor Green

# Step 4: Create android branch
Write-Host "`nStep 4: Creating android branch..." -ForegroundColor Yellow

git checkout --orphan android
git rm -rf .
git checkout main -- android/
git add android/
git commit -m "Android: ChekMate Android platform files

- Gradle build configuration
- Android manifest
- ProGuard rules
- Splash screen assets
- App icons
- Firebase configuration (excluded from main)
"

Write-Host "SUCCESS: Android branch created" -ForegroundColor Green

# Step 5: Create ios branch
Write-Host "`nStep 5: Creating ios branch..." -ForegroundColor Yellow

git checkout --orphan ios
git rm -rf .
git checkout main -- ios/
git add ios/
git commit -m "iOS: ChekMate iOS platform files

- Xcode project configuration
- iOS app icons and launch screens
- Info.plist configuration
- Firebase configuration (excluded from main)
- Bundle identifier: com.chekmate.app
"

Write-Host "SUCCESS: iOS branch created" -ForegroundColor Green

# Step 6: Create tools branch for sensitive files
Write-Host "`nStep 6: Creating tools branch..." -ForegroundColor Yellow

git checkout --orphan tools
git rm -rf .

# Add sensitive files that are gitignored on main
if (Test-Path "$projectRoot\android\app\google-services.json") {
    New-Item -ItemType Directory -Path "android/app" -Force | Out-Null
    Copy-Item "$projectRoot\android\app\google-services.json" "android/app/" -Force
}

if (Test-Path "$projectRoot\ios\Runner\GoogleService-Info.plist") {
    New-Item -ItemType Directory -Path "ios/Runner" -Force | Out-Null
    Copy-Item "$projectRoot\ios\Runner\GoogleService-Info.plist" "ios/Runner/" -Force
}

if (Test-Path "$projectRoot\lib\firebase_options.dart") {
    New-Item -ItemType Directory -Path "lib" -Force | Out-Null
    Copy-Item "$projectRoot\lib\firebase_options.dart" "lib/" -Force
}

if (Test-Path "$projectRoot\.firebaserc") {
    Copy-Item "$projectRoot\.firebaserc" "." -Force
}

if (Test-Path "$projectRoot\firebase.json") {
    Copy-Item "$projectRoot\firebase.json" "." -Force
}

if (Test-Path "$projectRoot\firestore.rules") {
    Copy-Item "$projectRoot\firestore.rules" "." -Force
}

if (Test-Path "$projectRoot\storage.rules") {
    Copy-Item "$projectRoot\storage.rules" "." -Force
}

# Add scripts
if (Test-Path "$projectRoot\scripts") {
    Copy-Item "$projectRoot\scripts" "." -Recurse -Force
}

# Add CircleCI config
if (Test-Path "$projectRoot\.circleci") {
    Copy-Item "$projectRoot\.circleci" "." -Recurse -Force
}

git add .
git commit -m "Tools: Sensitive configuration and automation scripts

IMPORTANT: This branch contains sensitive information!
- Firebase configuration files (API keys, project IDs)
- Firebase security rules
- Automation scripts
- CircleCI configuration

DO NOT make this branch public!
"

Write-Host "SUCCESS: Tools branch created" -ForegroundColor Green

# Step 7: Push all branches to GitHub
Write-Host "`nStep 7: Pushing all branches to GitHub..." -ForegroundColor Yellow

git checkout main
git push -u origin main
git push -u origin docs
git push -u origin android
git push -u origin ios
git push -u origin tools

Write-Host "SUCCESS: All branches pushed to GitHub" -ForegroundColor Green

# Step 8: Set branch protections (manual step)
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "GitHub Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "`nBranches created:" -ForegroundColor Yellow
Write-Host "- main: Main codebase (lib/, test/, assets/, pubspec.yaml, etc.)" -ForegroundColor Cyan
Write-Host "- docs: Documentation only (docs/)" -ForegroundColor Cyan
Write-Host "- android: Android platform files (android/)" -ForegroundColor Cyan
Write-Host "- ios: iOS platform files (ios/)" -ForegroundColor Cyan
Write-Host "- tools: Sensitive config & scripts (Firebase, CircleCI, scripts/)" -ForegroundColor Cyan

Write-Host "`nIMPORTANT: Manual steps required:" -ForegroundColor Red
Write-Host "1. Go to: https://github.com/Isakainovorium/ChekMate/settings/branches" -ForegroundColor Yellow
Write-Host "2. Set 'main' as the default branch" -ForegroundColor Yellow
Write-Host "3. Add branch protection rules for 'main':" -ForegroundColor Yellow
Write-Host "   - Require pull request reviews before merging" -ForegroundColor Yellow
Write-Host "   - Require status checks to pass before merging" -ForegroundColor Yellow
Write-Host "4. Make 'tools' branch PRIVATE or restrict access" -ForegroundColor Yellow
Write-Host "   (contains sensitive Firebase configuration)" -ForegroundColor Yellow

Write-Host "`nRepository URL: https://github.com/Isakainovorium/ChekMate" -ForegroundColor Cyan

Write-Host "`nAll done!" -ForegroundColor Green

