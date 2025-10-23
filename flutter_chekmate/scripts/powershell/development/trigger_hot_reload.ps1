# Trigger Hot Reload by Modifying a File
# This will cause Flutter to auto hot reload

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "🔄 TRIGGERING HOT RELOAD" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📝 Modifying main.dart to trigger hot reload..." -ForegroundColor Yellow

# Read the main.dart file
$mainDartPath = "lib\main.dart"
$content = Get-Content $mainDartPath -Raw

# Add a comment to trigger hot reload
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$newContent = $content -replace "\/\/ Hot reload trigger:.*", "// Hot reload trigger: $timestamp"

# If the comment doesn't exist, add it
if ($newContent -eq $content) {
    $newContent = "// Hot reload trigger: $timestamp`n" + $content
}

# Write back to file
Set-Content $mainDartPath -Value $newContent

Write-Host "✅ File modified - Flutter should hot reload automatically" -ForegroundColor Green
Write-Host ""
Write-Host "⏳ Waiting 5 seconds for hot reload to complete..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host "✅ Hot reload should be complete!" -ForegroundColor Green
Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "🚀 RUNNING VERIFICATION" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# Run the verification
python automated_verification.py

Write-Host ""
Write-Host "DONE!" -ForegroundColor Green
Write-Host ""

