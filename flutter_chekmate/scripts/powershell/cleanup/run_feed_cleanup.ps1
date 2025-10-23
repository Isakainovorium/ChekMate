# PowerShell script to run the feed directory cleanup

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   CHEKMATE FEED DIRECTORY CLEANUP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "ERROR: Not in Flutter project root directory!" -ForegroundColor Red
    Write-Host "Please navigate to flutter_chekmate directory first." -ForegroundColor Yellow
    exit 1
}

# Create backup
Write-Host "📦 Creating backup of feed directory..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupPath = "backups/feed_backup_$timestamp"

if (-not (Test-Path "backups")) {
    New-Item -ItemType Directory -Path "backups" | Out-Null
}

Copy-Item -Path "lib/features/feed" -Destination $backupPath -Recurse
Write-Host "✅ Backup created at: $backupPath" -ForegroundColor Green
Write-Host ""

# Show current structure analysis
Write-Host "📊 Current Structure Analysis:" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

$duplicates = @(
    "lib/features/feed/pages/auth/pages/login_page.dart",
    "lib/features/feed/pages/auth/presentation/pages/login_page.dart",
    "lib/features/feed/pages/auth/pages/signup_page.dart",
    "lib/features/feed/pages/auth/presentation/pages/signup_page.dart",
    "lib/features/feed/pages/home/pages/home_page.dart",
    "lib/features/feed/pages/home/presentation/pages/home_page.dart",
    "lib/features/feed/pages/home/presentation/pages/home_page_new.dart",
    "lib/features/feed/pages/following_page.dart",
    "lib/features/feed/pages/following_page_riverpod.dart"
)

Write-Host "Found duplicate files:" -ForegroundColor Yellow
foreach ($file in $duplicates) {
    if (Test-Path $file) {
        $size = (Get-Item $file).Length / 1KB
        Write-Host "  • $file (${size}KB)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "Misplaced features:" -ForegroundColor Yellow
if (Test-Path "lib/features/feed/pages/messaging") {
    $msgCount = (Get-ChildItem "lib/features/feed/pages/messaging" -Recurse -File).Count
    Write-Host "  • Messaging: $msgCount files in feed directory" -ForegroundColor Gray
}
if (Test-Path "lib/features/feed/pages/auth") {
    $authCount = (Get-ChildItem "lib/features/feed/pages/auth" -Recurse -File).Count
    Write-Host "  • Auth: $authCount files should be separate feature" -ForegroundColor Gray
}

Write-Host ""
Write-Host "⚠️  WARNING: This will restructure your feed directory!" -ForegroundColor Yellow
Write-Host "A backup has been created at: $backupPath" -ForegroundColor Green
Write-Host ""

$confirmation = Read-Host "Do you want to proceed with cleanup? (yes/no)"

if ($confirmation -ne "yes") {
    Write-Host "Cleanup cancelled." -ForegroundColor Red
    exit 0
}

# Run the Dart cleanup script
Write-Host ""
Write-Host "🚀 Running cleanup script..." -ForegroundColor Cyan
dart run lib/features/feed/cleanup_script.dart

# Check if cleanup was successful
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Cleanup completed successfully!" -ForegroundColor Green
    
    # Run flutter pub get to update dependencies
    Write-Host ""
    Write-Host "📦 Running flutter pub get..." -ForegroundColor Yellow
    flutter pub get
    
    # Show summary
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "         CLEANUP COMPLETE!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Review the changes in your IDE" -ForegroundColor White
    Write-Host "  2. Fix any remaining import errors" -ForegroundColor White
    Write-Host "  3. Run: flutter analyze" -ForegroundColor White
    Write-Host "  4. Test your application" -ForegroundColor White
    Write-Host ""
    Write-Host "If you need to restore, use:" -ForegroundColor Yellow
    Write-Host ("  Copy-Item -Path '" + $backupPath + "' -Destination 'lib/features/feed' -Recurse -Force") -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "❌ Cleanup failed!" -ForegroundColor Red
    Write-Host "Check the error messages above." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To restore from backup:" -ForegroundColor Yellow
    Write-Host ("  Copy-Item -Path '" + $backupPath + "' -Destination 'lib/features/feed' -Recurse -Force") -ForegroundColor Gray
}
