# iOS App Icon Generator Script
# Generates all required iOS app icon sizes from source image

$sourceImage = "assets\icons\app_icon.png"
$outputDir = "ios\Runner\Assets.xcassets\AppIcon.appiconset"

# Check if source image exists
if (-not (Test-Path $sourceImage)) {
    Write-Error "Source image not found: $sourceImage"
    exit 1
}

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

Write-Host "Checking for image processing tools..." -ForegroundColor Cyan

# Try to use ImageMagick if available
$magickPath = Get-Command magick -ErrorAction SilentlyContinue

if ($magickPath) {
    Write-Host "Using ImageMagick to generate icons..." -ForegroundColor Green
    
    foreach ($icon in $iconSizes) {
        $outputPath = Join-Path $outputDir $icon.Name
        $size = $icon.Size
        
        $dimensions = "$size" + "x" + "$size"
        Write-Host "Generating $($icon.Name) ($dimensions)..." -ForegroundColor Yellow
        
        & magick convert $sourceImage -resize $dimensions -background none -gravity center -extent $dimensions $outputPath
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Created $($icon.Name)" -ForegroundColor Green
        } else {
            Write-Error "  ✗ Failed to create $($icon.Name)"
        }
    }
    
    Write-Host "`nAll iOS app icons generated successfully!" -ForegroundColor Green
    Write-Host "Location: $outputDir" -ForegroundColor Cyan
    
} else {
    Write-Host "ImageMagick not found. Trying alternative method..." -ForegroundColor Yellow
    
    # Try using .NET System.Drawing
    try {
        Add-Type -AssemblyName System.Drawing
        
        $sourceImg = [System.Drawing.Image]::FromFile((Resolve-Path $sourceImage))
        
        foreach ($icon in $iconSizes) {
            $outputPath = Join-Path $outputDir $icon.Name
            $size = $icon.Size
            
            $dimensions = "$size" + "x" + "$size"
            Write-Host "Generating $($icon.Name) ($dimensions)..." -ForegroundColor Yellow
            
            $newImg = New-Object System.Drawing.Bitmap($size, $size)
            $graphics = [System.Drawing.Graphics]::FromImage($newImg)
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.DrawImage($sourceImg, 0, 0, $size, $size)
            
            $newImg.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
            
            $graphics.Dispose()
            $newImg.Dispose()
            
            Write-Host "  ✓ Created $($icon.Name)" -ForegroundColor Green
        }
        
        $sourceImg.Dispose()
        
        Write-Host "`nAll iOS app icons generated successfully!" -ForegroundColor Green
        Write-Host "Location: $outputDir" -ForegroundColor Cyan
        
    } catch {
        Write-Error "Failed to generate icons using .NET: $_"
        Write-Host "`nPlease install ImageMagick or use one of these alternatives:" -ForegroundColor Yellow
        Write-Host "1. Install ImageMagick: winget install ImageMagick.ImageMagick" -ForegroundColor Cyan
        Write-Host "2. Use online tool: https://appicon.co/" -ForegroundColor Cyan
        Write-Host "3. Run: flutter pub run flutter_launcher_icons" -ForegroundColor Cyan
        exit 1
    }
}

Write-Host "`nVerifying generated icons..." -ForegroundColor Cyan
$generatedCount = (Get-ChildItem $outputDir -Filter "*.png").Count
Write-Host "Generated $generatedCount icon files" -ForegroundColor Green

if ($generatedCount -eq 15) {
    Write-Host "All required iOS app icons are present!" -ForegroundColor Green
} else {
    Write-Warning "Expected 15 icon files, but found $generatedCount"
}
