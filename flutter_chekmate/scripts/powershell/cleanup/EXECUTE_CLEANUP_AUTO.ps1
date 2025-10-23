# Master Cleanup Execution Script - AUTO RUN VERSION
# Runs all cleanup steps automatically without prompts

Write-Host ""
Write-Host "###############################################" -ForegroundColor Cyan
Write-Host "#                                             #" -ForegroundColor Cyan
Write-Host "#   CHEKMATE FEED CLEANUP - AUTO MODE        #" -ForegroundColor Cyan
Write-Host "#                                             #" -ForegroundColor Cyan
Write-Host "###############################################" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "ERROR: Not in Flutter project root directory!" -ForegroundColor Red
    Write-Host "Please navigate to flutter_chekmate directory first." -ForegroundColor Yellow
    exit 1
}

Write-Host "AUTO MODE: Running cleanup without prompts..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Actions to be performed:" -ForegroundColor White
Write-Host "  1. Create backup" -ForegroundColor Gray
Write-Host "  2. Delete stub directories (6)" -ForegroundColor Gray
Write-Host "  3. Delete duplicate files (2)" -ForegroundColor Gray
Write-Host "  4. Move Auth to lib/features/auth/" -ForegroundColor Gray
Write-Host "  5. Move Messaging to lib/features/messaging/" -ForegroundColor Gray
Write-Host "  6. Reorganize feed structure" -ForegroundColor Gray
Write-Host "  7. Update all imports" -ForegroundColor Gray
Write-Host "  8. Run flutter pub get" -ForegroundColor Gray
Write-Host "  9. Run flutter analyze" -ForegroundColor Gray
Write-Host ""

Start-Sleep -Seconds 2

Write-Host "===============================================" -ForegroundColor Green
Write-Host "STEP 1: Creating Backup" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupPath = "backups\feed_backup_auto_$timestamp"

if (-not (Test-Path "backups")) {
    New-Item -ItemType Directory -Path "backups" | Out-Null
}

Copy-Item -Path "lib\features\feed" -Destination $backupPath -Recurse
Write-Host "[OK] Backup created at: $backupPath" -ForegroundColor Green
Write-Host ""

Write-Host "===============================================" -ForegroundColor Green
Write-Host "STEP 2: Deleting Stub Directories" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

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
        Write-Host "[DELETED] $dir" -ForegroundColor Green
    } else {
        Write-Host "[SKIP] Not found: $dir" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "STEP 3: Deleting Duplicate Files" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

$duplicateFiles = @(
    "lib\features\feed\pages\following_page.dart",
    "lib\features\feed\pages\messaging\pages\pages\messages_page.dart"
)

foreach ($file in $duplicateFiles) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "[DELETED] $file" -ForegroundColor Green
    } else {
        Write-Host "[SKIP] Not found: $file" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "STEP 4: Relocating Auth Feature" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

if (Test-Path "lib\features\feed\pages\auth") {
    if (Test-Path "lib\features\auth") {
        Write-Host "[MERGE] Auth feature already exists, merging..." -ForegroundColor Yellow
        Copy-Item "lib\features\feed\pages\auth\*" "lib\features\auth\" -Recurse -Force
        Remove-Item "lib\features\feed\pages\auth" -Recurse -Force
    } else {
        New-Item -ItemType Directory -Path "lib\features\auth" -Force | Out-Null
        
        if (Test-Path "lib\features\feed\pages\auth\pages") {
            Move-Item "lib\features\feed\pages\auth\pages" "lib\features\auth\pages" -Force
            Write-Host "[MOVED] Auth pages" -ForegroundColor Green
        }
        if (Test-Path "lib\features\feed\pages\auth\widgets") {
            Move-Item "lib\features\feed\pages\auth\widgets" "lib\features\auth\widgets" -Force
            Write-Host "[MOVED] Auth widgets" -ForegroundColor Green
        }
        if (Test-Path "lib\features\feed\pages\auth\providers") {
            Move-Item "lib\features\feed\pages\auth\providers" "lib\features\auth\providers" -Force
            Write-Host "[MOVED] Auth providers" -ForegroundColor Green
        }
        if (Test-Path "lib\features\feed\pages\auth\data\services") {
            New-Item -ItemType Directory -Path "lib\features\auth\services" -Force | Out-Null
            Move-Item "lib\features\feed\pages\auth\data\services\*" "lib\features\auth\services\" -Force
            Write-Host "[MOVED] Auth services" -ForegroundColor Green
        }
        
        Remove-Item "lib\features\feed\pages\auth" -Recurse -Force
    }
    Write-Host "[OK] Auth relocated to lib\features\auth\" -ForegroundColor Green
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "STEP 5: Relocating Messaging Feature" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

if (Test-Path "lib\features\feed\pages\messaging") {
    if (Test-Path "lib\features\messaging") {
        Write-Host "[MERGE] Messaging feature already exists, merging..." -ForegroundColor Yellow
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
    Write-Host "[OK] Messaging relocated to lib\features\messaging\" -ForegroundColor Green
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "STEP 6: Reorganizing Feed Structure" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

# Move home_page to pages root
if (Test-Path "lib\features\feed\pages\home\pages\home_page.dart") {
    Move-Item "lib\features\feed\pages\home\pages\home_page.dart" "lib\features\feed\pages\home_page.dart" -Force
    Remove-Item "lib\features\feed\pages\home" -Recurse -Force
    Write-Host "[MOVED] home_page.dart to pages root" -ForegroundColor Green
}

# Move profile to subfeatures
if (Test-Path "lib\features\feed\pages\profile") {
    New-Item -ItemType Directory -Path "lib\features\feed\subfeatures\profile" -Force | Out-Null
    
    if (Test-Path "lib\features\feed\pages\profile\pages") {
        Move-Item "lib\features\feed\pages\profile\pages" "lib\features\feed\subfeatures\profile\pages" -Force
        Write-Host "[MOVED] Profile pages to subfeatures" -ForegroundColor Green
    }
    if (Test-Path "lib\features\feed\pages\profile\widgets") {
        Move-Item "lib\features\feed\pages\profile\widgets" "lib\features\feed\subfeatures\profile\widgets" -Force
        Write-Host "[MOVED] Profile widgets to subfeatures" -ForegroundColor Green
    }
    
    Remove-Item "lib\features\feed\pages\profile" -Recurse -Force
}

# Move live to subfeatures
if (Test-Path "lib\features\feed\pages\live") {
    New-Item -ItemType Directory -Path "lib\features\feed\subfeatures\live\pages" -Force | Out-Null
    
    if (Test-Path "lib\features\feed\pages\live\pages") {
        Move-Item "lib\features\feed\pages\live\pages\*" "lib\features\feed\subfeatures\live\pages\" -Force
        Write-Host "[MOVED] Live pages to subfeatures" -ForegroundColor Green
    }
    
    Remove-Item "lib\features\feed\pages\live" -Recurse -Force
}

# Move posts to subfeatures if exists
if (Test-Path "lib\features\feed\pages\posts") {
    New-Item -ItemType Directory -Path "lib\features\feed\subfeatures\posts" -Force | Out-Null
    Move-Item "lib\features\feed\pages\posts\*" "lib\features\feed\subfeatures\posts\" -Recurse -Force
    Remove-Item "lib\features\feed\pages\posts" -Recurse -Force
    Write-Host "[MOVED] Posts to subfeatures" -ForegroundColor Green
}

# Rename following_page_riverpod to feed_page
if (Test-Path "lib\features\feed\pages\following_page_riverpod.dart") {
    $content = Get-Content "lib\features\feed\pages\following_page_riverpod.dart" -Raw
    $content = $content -replace "FollowingPageRiverpod", "FeedPage"
    $content = $content -replace "following_page_riverpod", "feed_page"
    Set-Content "lib\features\feed\pages\feed_page.dart" $content
    Remove-Item "lib\features\feed\pages\following_page_riverpod.dart" -Force
    Write-Host "[RENAMED] following_page_riverpod.dart to feed_page.dart" -ForegroundColor Green
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "STEP 7: Updating Import Statements" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

$libPath = "lib"
$dartFiles = Get-ChildItem -Path $libPath -Filter "*.dart" -Recurse

$importMappings = @{
    'features/feed/pages/auth/pages/' = 'features/auth/pages/'
    'features/feed/pages/auth/widgets/' = 'features/auth/widgets/'
    'features/feed/pages/auth/providers/' = 'features/auth/providers/'
    'features/feed/pages/auth/data/services/' = 'features/auth/services/'
    'features/feed/pages/messaging/' = 'features/messaging/'
    'features/feed/pages/profile/pages/' = 'features/feed/subfeatures/profile/pages/'
    'features/feed/pages/profile/widgets/' = 'features/feed/subfeatures/profile/widgets/'
    'features/feed/pages/home/pages/home_page' = 'features/feed/pages/home_page'
    'features/feed/pages/live/pages/' = 'features/feed/subfeatures/live/pages/'
    'features/feed/pages/posts/' = 'features/feed/subfeatures/posts/'
    'features/feed/pages/following_page_riverpod' = 'features/feed/pages/feed_page'
    'features/feed/pages/following_page' = 'features/feed/pages/feed_page'
    'features/feed/pages/auth/presentation/pages/' = 'features/auth/pages/'
    'features/feed/pages/home/presentation/pages/' = 'features/feed/pages/'
    'features/feed/pages/live/presentation/pages/' = 'features/feed/subfeatures/live/pages/'
    'features/feed/pages/profile/presentation/pages/' = 'features/feed/subfeatures/profile/pages/'
}

$updatedCount = 0

foreach ($file in $dartFiles) {
    try {
        $content = Get-Content $file.FullName -Raw
        $fileModified = $false
        
        foreach ($oldPath in $importMappings.Keys) {
            $newPath = $importMappings[$oldPath]
            
            if ($content -match [regex]::Escape($oldPath)) {
                $content = $content -replace [regex]::Escape($oldPath), $newPath
                $fileModified = $true
            }
        }
        
        if ($fileModified) {
            Set-Content $file.FullName $content -NoNewline
            $updatedCount++
        }
        
    } catch {
        Write-Host "[ERROR] $($file.FullName): $_" -ForegroundColor Red
    }
}

Write-Host "[OK] Updated $updatedCount files" -ForegroundColor Green

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "STEP 8: Running Flutter Pub Get" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

if (Get-Command flutter -ErrorAction SilentlyContinue) {
    flutter pub get
    Write-Host "[OK] Flutter pub get completed" -ForegroundColor Green
} else {
    Write-Host "[SKIP] Flutter command not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "STEP 9: Running Flutter Analyze" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

if (Get-Command flutter -ErrorAction SilentlyContinue) {
    flutter analyze
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[WARN] Flutter analyze found some issues" -ForegroundColor Yellow
    } else {
        Write-Host "[OK] Flutter analyze completed successfully" -ForegroundColor Green
    }
} else {
    Write-Host "[SKIP] Flutter command not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "###############################################" -ForegroundColor Green
Write-Host "#                                             #" -ForegroundColor Green
Write-Host "#          CLEANUP COMPLETED!                 #" -ForegroundColor Green
Write-Host "#                                             #" -ForegroundColor Green
Write-Host "###############################################" -ForegroundColor Green
Write-Host ""

Write-Host "SUMMARY:" -ForegroundColor Cyan
Write-Host "========" -ForegroundColor Cyan
Write-Host ""
Write-Host "[OK] Backup created" -ForegroundColor Green
Write-Host "[OK] Deleted stub directories" -ForegroundColor Green
Write-Host "[OK] Deleted duplicate files" -ForegroundColor Green
Write-Host "[OK] Relocated Auth feature" -ForegroundColor Green
Write-Host "[OK] Relocated Messaging feature" -ForegroundColor Green
Write-Host "[OK] Reorganized feed structure" -ForegroundColor Green
Write-Host "[OK] Updated $updatedCount import statements" -ForegroundColor Green
Write-Host ""

Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "===========" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Update Router Configuration:" -ForegroundColor White
Write-Host "   File: lib\core\router\app_router.dart" -ForegroundColor Gray
Write-Host "   See: ROUTER_UPDATE_GUIDE.md" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Test Your Application:" -ForegroundColor White
Write-Host "   - Login/Signup flow" -ForegroundColor Gray
Write-Host "   - Home feed" -ForegroundColor Gray
Write-Host "   - Profile pages" -ForegroundColor Gray
Write-Host "   - Messaging" -ForegroundColor Gray
Write-Host ""

Write-Host "BACKUP LOCATION:" -ForegroundColor Cyan
Write-Host "  $backupPath" -ForegroundColor Gray
Write-Host ""

Write-Host "Cleanup completed successfully!" -ForegroundColor Green
Write-Host ""
