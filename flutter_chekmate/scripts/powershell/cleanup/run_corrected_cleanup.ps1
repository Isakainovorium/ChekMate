# Corrected Feed Directory Cleanup Script
# Based on Enterprise Analysis - Keeps Production Files, Deletes Stubs

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   CORRECTED FEED CLEANUP SCRIPT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "ERROR: Not in Flutter project root directory!" -ForegroundColor Red
    Write-Host "Please navigate to flutter_chekmate directory first." -ForegroundColor Yellow
    exit 1
}

# Create backup
Write-Host "[1/6] Creating backup..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupPath = "backups\feed_backup_corrected_$timestamp"

if (-not (Test-Path "backups")) {
    New-Item -ItemType Directory -Path "backups" | Out-Null
}

Copy-Item -Path "lib\features\feed" -Destination $backupPath -Recurse
Write-Host "      Backup created at: $backupPath" -ForegroundColor Green
Write-Host ""

# Show what will be deleted
Write-Host "[2/6] Analysis Summary:" -ForegroundColor Yellow
Write-Host "      Stub directories to delete: 6" -ForegroundColor Gray
Write-Host "      Duplicate files to delete: 2" -ForegroundColor Gray
Write-Host "      Features to relocate: 2 (Auth, Messaging)" -ForegroundColor Gray
Write-Host "      Space to reclaim: ~50 KB" -ForegroundColor Gray
Write-Host ""

$confirmation = Read-Host "Do you want to proceed with cleanup? (yes/no)"

if ($confirmation -ne "yes") {
    Write-Host "Cleanup cancelled." -ForegroundColor Red
    exit 0
}

Write-Host ""
Write-Host "[3/6] Deleting stub directories..." -ForegroundColor Yellow

# Phase 1: Delete all stub/presentation directories
$stubDirs = @(
    "lib\features\feed\pages\auth\presentation",
    "lib\features\feed\pages\home\presentation",
    "lib\features\feed\pages\live\presentation",
    "lib\features\feed\pages\profile\presentation",
    "lib\features\feed\pages\messaging\pages\notifications\presentation",
    "lib\features\feed\pages\messaging\pages\rate_date\presentation"
)

foreach ($dir in $stubDirs) {
    if (Test-Path $dir) {
        Remove-Item $dir -Recurse -Force
        Write-Host "      Deleted: $dir" -ForegroundColor Green
    } else {
        Write-Host "      Not found: $dir" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "[4/6] Deleting duplicate files..." -ForegroundColor Yellow

# Phase 2: Delete individual duplicates
$duplicateFiles = @(
    "lib\features\feed\pages\following_page.dart",
    "lib\features\feed\pages\messaging\pages\pages\messages_page.dart"
)

foreach ($file in $duplicateFiles) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "      Deleted: $file" -ForegroundColor Green
    } else {
        Write-Host "      Not found: $file" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "[5/6] Relocating features..." -ForegroundColor Yellow

# Phase 3: Move Auth to separate feature
if (Test-Path "lib\features\feed\pages\auth") {
    if (Test-Path "lib\features\auth") {
        Write-Host "      Auth feature already exists, merging..." -ForegroundColor Yellow
        # Copy files instead of move
        Copy-Item "lib\features\feed\pages\auth\*" "lib\features\auth\" -Recurse -Force
        Remove-Item "lib\features\feed\pages\auth" -Recurse -Force
    } else {
        New-Item -ItemType Directory -Path "lib\features\auth" -Force | Out-Null
        Move-Item "lib\features\feed\pages\auth\pages" "lib\features\auth\pages" -Force
        Move-Item "lib\features\feed\pages\auth\widgets" "lib\features\auth\widgets" -Force
        Move-Item "lib\features\feed\pages\auth\providers" "lib\features\auth\providers" -Force
        
        if (Test-Path "lib\features\feed\pages\auth\data\services") {
            New-Item -ItemType Directory -Path "lib\features\auth\services" -Force | Out-Null
            Move-Item "lib\features\feed\pages\auth\data\services\*" "lib\features\auth\services\" -Force
        }
        
        Remove-Item "lib\features\feed\pages\auth" -Recurse -Force
    }
    Write-Host "      Moved Auth to lib\features\auth\" -ForegroundColor Green
}

# Phase 3b: Move Messaging to separate feature
if (Test-Path "lib\features\feed\pages\messaging") {
    if (Test-Path "lib\features\messaging") {
        Write-Host "      Messaging feature already exists, merging..." -ForegroundColor Yellow
        # Merge with existing messaging
        $messagingItems = Get-ChildItem "lib\features\feed\pages\messaging" -Recurse
        foreach ($item in $messagingItems) {
            $relativePath = $item.FullName.Replace((Get-Item "lib\features\feed\pages\messaging").FullName, "")
            $destPath = "lib\features\messaging" + $relativePath
            
            if ($item.PSIsContainer) {
                if (-not (Test-Path $destPath)) {
                    New-Item -ItemType Directory -Path $destPath -Force | Out-Null
                }
            } else {
                Copy-Item $item.FullName $destPath -Force
            }
        }
        Remove-Item "lib\features\feed\pages\messaging" -Recurse -Force
    } else {
        New-Item -ItemType Directory -Path "lib\features\messaging" -Force | Out-Null
        Move-Item "lib\features\feed\pages\messaging\*" "lib\features\messaging\" -Recurse -Force
        Remove-Item "lib\features\feed\pages\messaging" -Recurse -Force
    }
    Write-Host "      Moved Messaging to lib\features\messaging\" -ForegroundColor Green
}

Write-Host ""
Write-Host "[6/6] Reorganizing feed structure..." -ForegroundColor Yellow

# Phase 4: Reorganize feed structure
# Move home_page to pages root
if (Test-Path "lib\features\feed\pages\home\pages\home_page.dart") {
    Move-Item "lib\features\feed\pages\home\pages\home_page.dart" "lib\features\feed\pages\home_page.dart" -Force
    Remove-Item "lib\features\feed\pages\home" -Recurse -Force
    Write-Host "      Moved home_page.dart to pages root" -ForegroundColor Green
}

# Move profile to subfeatures
if (Test-Path "lib\features\feed\pages\profile") {
    New-Item -ItemType Directory -Path "lib\features\feed\subfeatures\profile" -Force | Out-Null
    
    if (Test-Path "lib\features\feed\pages\profile\pages") {
        Move-Item "lib\features\feed\pages\profile\pages" "lib\features\feed\subfeatures\profile\pages" -Force
    }
    if (Test-Path "lib\features\feed\pages\profile\widgets") {
        Move-Item "lib\features\feed\pages\profile\widgets" "lib\features\feed\subfeatures\profile\widgets" -Force
    }
    
    Remove-Item "lib\features\feed\pages\profile" -Recurse -Force
    Write-Host "      Moved profile to subfeatures" -ForegroundColor Green
}

# Move live to subfeatures
if (Test-Path "lib\features\feed\pages\live") {
    New-Item -ItemType Directory -Path "lib\features\feed\subfeatures\live\pages" -Force | Out-Null
    
    if (Test-Path "lib\features\feed\pages\live\pages") {
        Move-Item "lib\features\feed\pages\live\pages\*" "lib\features\feed\subfeatures\live\pages\" -Force
    }
    
    Remove-Item "lib\features\feed\pages\live" -Recurse -Force
    Write-Host "      Moved live to subfeatures" -ForegroundColor Green
}

# Move posts to subfeatures if exists
if (Test-Path "lib\features\feed\pages\posts") {
    New-Item -ItemType Directory -Path "lib\features\feed\subfeatures\posts" -Force | Out-Null
    Move-Item "lib\features\feed\pages\posts\*" "lib\features\feed\subfeatures\posts\" -Recurse -Force
    Remove-Item "lib\features\feed\pages\posts" -Recurse -Force
    Write-Host "      Moved posts to subfeatures" -ForegroundColor Green
}

# Rename following_page_riverpod to feed_page
if (Test-Path "lib\features\feed\pages\following_page_riverpod.dart") {
    $content = Get-Content "lib\features\feed\pages\following_page_riverpod.dart" -Raw
    $content = $content -replace "FollowingPageRiverpod", "FeedPage"
    $content = $content -replace "following_page_riverpod", "feed_page"
    Set-Content "lib\features\feed\pages\feed_page.dart" $content
    Remove-Item "lib\features\feed\pages\following_page_riverpod.dart" -Force
    Write-Host "      Renamed following_page_riverpod.dart to feed_page.dart" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "         CLEANUP COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  [OK] Deleted 6 stub directories" -ForegroundColor Green
Write-Host "  [OK] Deleted 2 duplicate files" -ForegroundColor Green
Write-Host "  [OK] Relocated Auth feature" -ForegroundColor Green
Write-Host "  [OK] Relocated Messaging feature" -ForegroundColor Green
Write-Host "  [OK] Reorganized feed structure" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Update import statements in your code" -ForegroundColor White
Write-Host "  2. Update router configuration (app_router.dart)" -ForegroundColor White
Write-Host "  3. Run: flutter pub get" -ForegroundColor White
Write-Host "  4. Run: flutter analyze" -ForegroundColor White
Write-Host "  5. Test the application thoroughly" -ForegroundColor White
Write-Host ""
Write-Host "Backup Location:" -ForegroundColor Yellow
Write-Host "  $backupPath" -ForegroundColor Gray
Write-Host ""
Write-Host "To restore from backup if needed:" -ForegroundColor Yellow
Write-Host "  Remove-Item lib\features\feed -Recurse -Force" -ForegroundColor Gray
Write-Host "  Copy-Item $backupPath lib\features\feed -Recurse" -ForegroundColor Gray
Write-Host ""
