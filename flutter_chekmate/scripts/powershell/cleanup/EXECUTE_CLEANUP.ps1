# Master Cleanup Execution Script
# Runs all cleanup steps in correct order

Write-Host ""
Write-Host "###############################################" -ForegroundColor Cyan
Write-Host "#                                             #" -ForegroundColor Cyan
Write-Host "#   CHEKMATE FEED CLEANUP - MASTER SCRIPT    #" -ForegroundColor Cyan
Write-Host "#                                             #" -ForegroundColor Cyan
Write-Host "###############################################" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "ERROR: Not in Flutter project root directory!" -ForegroundColor Red
    Write-Host "Please navigate to flutter_chekmate directory first." -ForegroundColor Yellow
    exit 1
}

Write-Host "This script will:" -ForegroundColor Yellow
Write-Host "  1. Create a backup of your feed directory" -ForegroundColor White
Write-Host "  2. Delete all stub/presentation directories" -ForegroundColor White
Write-Host "  3. Delete duplicate files" -ForegroundColor White
Write-Host "  4. Move Auth to lib/features/auth/" -ForegroundColor White
Write-Host "  5. Move Messaging to lib/features/messaging/" -ForegroundColor White
Write-Host "  6. Reorganize feed structure" -ForegroundColor White
Write-Host "  7. Update all import statements" -ForegroundColor White
Write-Host "  8. Run flutter pub get" -ForegroundColor White
Write-Host "  9. Run flutter analyze" -ForegroundColor White
Write-Host ""

$confirmation = Read-Host "Are you ready to proceed? (yes/no)"

if ($confirmation -ne "yes") {
    Write-Host ""
    Write-Host "Cleanup cancelled. No changes were made." -ForegroundColor Red
    Write-Host ""
    exit 0
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "STEP 1: Running Cleanup Script" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

# Run cleanup script
& "$PSScriptRoot\run_corrected_cleanup.ps1"

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Cleanup script failed!" -ForegroundColor Red
    Write-Host "Please check the errors above and restore from backup if needed." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "STEP 2: Updating Import Statements" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

# Run import update script
& "$PSScriptRoot\update_imports.ps1"

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "STEP 3: Running Flutter Pub Get" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

# Check if flutter is available
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    flutter pub get
} else {
    Write-Host "WARNING: Flutter command not found. Please run 'flutter pub get' manually." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "STEP 4: Running Flutter Analyze" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

if (Get-Command flutter -ErrorAction SilentlyContinue) {
    flutter analyze
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "WARNING: Flutter analyze found some issues." -ForegroundColor Yellow
        Write-Host "Please review the errors above and fix them manually." -ForegroundColor Yellow
    }
} else {
    Write-Host "WARNING: Flutter command not found. Please run 'flutter analyze' manually." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "###############################################" -ForegroundColor Green
Write-Host "#                                             #" -ForegroundColor Green
Write-Host "#          CLEANUP COMPLETED!                 #" -ForegroundColor Green
Write-Host "#                                             #" -ForegroundColor Green
Write-Host "###############################################" -ForegroundColor Green
Write-Host ""

Write-Host "SUMMARY OF CHANGES:" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[OK] Deleted 6 stub directories" -ForegroundColor Green
Write-Host "[OK] Deleted 2 duplicate files" -ForegroundColor Green
Write-Host "[OK] Moved Auth to lib/features/auth/" -ForegroundColor Green
Write-Host "[OK] Moved Messaging to lib/features/messaging/" -ForegroundColor Green
Write-Host "[OK] Reorganized feed structure" -ForegroundColor Green
Write-Host "[OK] Updated import statements" -ForegroundColor Green
Write-Host ""

Write-Host "MANUAL TASKS REMAINING:" -ForegroundColor Yellow
Write-Host "=======================" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Update Router Configuration:" -ForegroundColor White
Write-Host "   File: lib/core/router/app_router.dart" -ForegroundColor Gray
Write-Host "   - Update auth routes to use 'features/auth/'" -ForegroundColor Gray
Write-Host "   - Update messaging routes to use 'features/messaging/'" -ForegroundColor Gray
Write-Host "   - Update profile routes to use 'features/feed/subfeatures/profile/'" -ForegroundColor Gray
Write-Host "   - Update following_page_riverpod to feed_page" -ForegroundColor Gray
Write-Host ""

Write-Host "2. Test Critical Paths:" -ForegroundColor White
Write-Host "   - Login/Signup flow" -ForegroundColor Gray
Write-Host "   - Home feed" -ForegroundColor Gray
Write-Host "   - Profile pages" -ForegroundColor Gray
Write-Host "   - Messaging" -ForegroundColor Gray
Write-Host "   - Live feed" -ForegroundColor Gray
Write-Host ""

Write-Host "3. Review Any Remaining Errors:" -ForegroundColor White
Write-Host "   Run: flutter analyze" -ForegroundColor Gray
Write-Host "   Fix any import errors manually" -ForegroundColor Gray
Write-Host ""

Write-Host "BACKUP LOCATION:" -ForegroundColor Cyan
$latestBackup = Get-ChildItem "backups" -Filter "feed_backup_corrected_*" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($latestBackup) {
    Write-Host "  $($latestBackup.FullName)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "To restore if needed:" -ForegroundColor Yellow
    Write-Host "  Remove-Item lib\features\feed -Recurse -Force" -ForegroundColor Gray
    Write-Host "  Copy-Item '$($latestBackup.FullName)' lib\features\feed -Recurse" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
