# Import Update Script
# Updates all import statements after cleanup

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   IMPORT STATEMENT UPDATER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$libPath = "lib"
$dartFiles = Get-ChildItem -Path $libPath -Filter "*.dart" -Recurse

Write-Host "Found $($dartFiles.Count) Dart files to process..." -ForegroundColor Yellow
Write-Host ""

# Define import mappings
$importMappings = @{
    # Auth relocations
    'features/feed/pages/auth/pages/' = 'features/auth/pages/'
    'features/feed/pages/auth/widgets/' = 'features/auth/widgets/'
    'features/feed/pages/auth/providers/' = 'features/auth/providers/'
    'features/feed/pages/auth/data/services/' = 'features/auth/services/'
    
    # Messaging relocations
    'features/feed/pages/messaging/' = 'features/messaging/'
    
    # Profile reorganization
    'features/feed/pages/profile/pages/' = 'features/feed/subfeatures/profile/pages/'
    'features/feed/pages/profile/widgets/' = 'features/feed/subfeatures/profile/widgets/'
    
    # Home reorganization
    'features/feed/pages/home/pages/home_page' = 'features/feed/pages/home_page'
    
    # Live reorganization
    'features/feed/pages/live/pages/' = 'features/feed/subfeatures/live/pages/'
    
    # Posts reorganization
    'features/feed/pages/posts/' = 'features/feed/subfeatures/posts/'
    
    # Following page rename
    'features/feed/pages/following_page_riverpod' = 'features/feed/pages/feed_page'
    'features/feed/pages/following_page' = 'features/feed/pages/feed_page'
    
    # Remove presentation paths (these should not exist anymore)
    'features/feed/pages/auth/presentation/pages/' = 'features/auth/pages/'
    'features/feed/pages/home/presentation/pages/' = 'features/feed/pages/'
    'features/feed/pages/live/presentation/pages/' = 'features/feed/subfeatures/live/pages/'
    'features/feed/pages/profile/presentation/pages/' = 'features/feed/subfeatures/profile/pages/'
}

$updatedCount = 0
$errorCount = 0

foreach ($file in $dartFiles) {
    try {
        $content = Get-Content $file.FullName -Raw
        $originalContent = $content
        $fileModified = $false
        
        # Update imports
        foreach ($oldPath in $importMappings.Keys) {
            $newPath = $importMappings[$oldPath]
            
            if ($content -match [regex]::Escape($oldPath)) {
                $content = $content -replace [regex]::Escape($oldPath), $newPath
                $fileModified = $true
            }
        }
        
        # Save if modified
        if ($fileModified) {
            Set-Content $file.FullName $content -NoNewline
            $updatedCount++
            Write-Host "[UPDATED] $($file.FullName.Replace($PWD, '.'))" -ForegroundColor Green
        }
        
    } catch {
        $errorCount++
        Write-Host "[ERROR] $($file.FullName): $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "         UPDATE COMPLETE!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  Total files scanned: $($dartFiles.Count)" -ForegroundColor White
Write-Host "  Files updated: $updatedCount" -ForegroundColor Green
Write-Host "  Errors: $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Run: flutter analyze" -ForegroundColor White
Write-Host "  2. Check for any remaining import errors" -ForegroundColor White
Write-Host "  3. Update router configuration manually" -ForegroundColor White
Write-Host "  4. Test the application" -ForegroundColor White
Write-Host ""
