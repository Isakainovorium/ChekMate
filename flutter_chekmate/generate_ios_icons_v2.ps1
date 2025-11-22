# iOS App Icon Generator Script - Version 2
# Generates all required iOS app icon sizes from source image

$ErrorActionPreference = "Stop"

$sourceImage = "assets\icons\app_icon.png"
$outputDir = "ios\Runner\Assets.xcassets\AppIcon.appiconset"

Write-Host "=== iOS App Icon Generator ===" -ForegroundColor Cyan
Write-Host ""

# Check if source image exists
Write-Host "Checking source image..." -ForegroundColor Yellow
if (-not (Test-Path $sourceImage)) {
    Write-Error "Source image not found: $sourceImage"
    exit 1
}
Write-Host "Source image found: $sourceImage" -ForegroundColor Green

# Check output directory
Write-Host "Checking output directory..." -ForegroundColor Yellow
if (-not (Test-Path $outputDir)) {
    Write-Error "Output directory not found: $outputDir"
    exit 1
}
Write-Host "Output directory found: $outputDir" -ForegroundColor Green
Write-Host ""

# Icon sizes required by iOS
$iconSizes = @(
    @{Name="Icon-App-20x20@1x.png"; Size=20},
    @{Name="Icon-App-20x20@2x.png"; Size=40},
    @{Name="Icon-App-20x20@3x.png"; Size=60},
    @{Name="Icon-App-29x29@1x.png"; Size=29},
    @{Name="Icon-App-29x29@2x.png"; Size=58},
    @{Name="Icon-App-29x29@3x.png"; Size=87},
    @{Name="Icon-App-40x40@1x.png"; Size=40},
    @{Name="Icon-App-40x40@2x.png"; Size=80},
    @{Name="Icon-App-40x40@3x.png"; Size=120},
    @{Name="Icon-App-60x60@2x.png"; Size=120},
    @{Name="Icon-App-60x60@3x.png"; Size=180},
    @{Name="Icon-App-76x76@1x.png"; Size=76},
    @{Name="Icon-App-76x76@2x.png"; Size=152},
    @{Name="Icon-App-83.5x83.5@2x.png"; Size=167},
    @{Name="Icon-App-1024x1024@1x.png"; Size=1024}
)

Write-Host "Attempting to load System.Drawing..." -ForegroundColor Yellow
try {
    Add-Type -AssemblyName System.Drawing
    Write-Host "System.Drawing loaded successfully!" -ForegroundColor Green
} catch {
    Write-Error "Failed to load System.Drawing: $_"
    Write-Host ""
    Write-Host "Alternative solutions:" -ForegroundColor Yellow
    Write-Host "1. Install ImageMagick: winget install ImageMagick.ImageMagick" -ForegroundColor Cyan
    Write-Host "2. Use online tool: https://appicon.co/" -ForegroundColor Cyan
    Write-Host "3. Install Flutter and run: flutter pub run flutter_launcher_icons" -ForegroundColor Cyan
    exit 1
}

Write-Host ""
Write-Host "Loading source image..." -ForegroundColor Yellow
try {
    $fullPath = Resolve-Path $sourceImage
    Write-Host "Full path: $fullPath" -ForegroundColor Gray
    $sourceImg = [System.Drawing.Image]::FromFile($fullPath)
    Write-Host "Source image loaded: $($sourceImg.Width)x$($sourceImg.Height)" -ForegroundColor Green
} catch {
    Write-Error "Failed to load source image: $_"
    exit 1
}

Write-Host ""
Write-Host "Generating iOS app icons..." -ForegroundColor Cyan
Write-Host ""

$successCount = 0
$failCount = 0

foreach ($icon in $iconSizes) {
    try {
        $outputPath = Join-Path $outputDir $icon.Name
        $size = $icon.Size
        
        Write-Host "[$($successCount + $failCount + 1)/15] Generating $($icon.Name) ($size x $size)..." -ForegroundColor Yellow -NoNewline
        
        $newImg = New-Object System.Drawing.Bitmap($size, $size)
        $graphics = [System.Drawing.Graphics]::FromImage($newImg)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        
        $graphics.DrawImage($sourceImg, 0, 0, $size, $size)
        
        $newImg.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
        
        $graphics.Dispose()
        $newImg.Dispose()
        
        Write-Host " DONE" -ForegroundColor Green
        $successCount++
        
    } catch {
        Write-Host " FAILED" -ForegroundColor Red
        Write-Host "  Error: $_" -ForegroundColor Red
        $failCount++
    }
}

$sourceImg.Dispose()

Write-Host ""
Write-Host "=== Generation Complete ===" -ForegroundColor Cyan
Write-Host "Success: $successCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Gray" })
Write-Host ""

# Verify generated icons
$generatedFiles = Get-ChildItem $outputDir -Filter "*.png"
Write-Host "Verifying generated icons..." -ForegroundColor Yellow
Write-Host "Found $($generatedFiles.Count) PNG files in output directory" -ForegroundColor Cyan

if ($generatedFiles.Count -eq 15) {
    Write-Host ""
    Write-Host "SUCCESS: All 15 required iOS app icons generated!" -ForegroundColor Green
    Write-Host "Location: $outputDir" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Verify icons in Xcode" -ForegroundColor White
    Write-Host "2. Build your iOS app" -ForegroundColor White
    Write-Host "3. Test on a device or simulator" -ForegroundColor White
    exit 0
} else {
    Write-Warning "Expected 15 icon files, but found $($generatedFiles.Count)"
    exit 1
}
