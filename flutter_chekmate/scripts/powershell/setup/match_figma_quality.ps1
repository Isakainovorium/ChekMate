# Match Figma Quality - Automated Workflow
# This script uses OpenAI GPT-4 Vision to analyze and fix your Flutter app to match Figma

param(
    [string]$FigmaScreenshot = "",
    [string]$FlutterUrl = "http://localhost:8080"
)

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "🎨 MATCH FIGMA QUALITY - AI-Powered Design Matching" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if Figma screenshot exists
if ($FigmaScreenshot -eq "") {
    Write-Host "📸 STEP 1: Figma Screenshot" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please provide a screenshot of your Figma design." -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  1. Take a screenshot of your Figma design" -ForegroundColor White
    Write-Host "  2. Save it to this folder" -ForegroundColor White
    Write-Host "  3. Run: .\match_figma_quality.ps1 -FigmaScreenshot 'figma.png'" -ForegroundColor White
    Write-Host ""
    Write-Host "OR export from Figma:" -ForegroundColor Cyan
    Write-Host "  1. Open: https://www.figma.com/make/DctaXwzyY5MceogG5WYSSB/ChekMate" -ForegroundColor White
    Write-Host "  2. Select the home screen frame" -ForegroundColor White
    Write-Host "  3. Right-click → Export → PNG" -ForegroundColor White
    Write-Host "  4. Save as 'figma_home.png' in this folder" -ForegroundColor White
    Write-Host ""
    exit 0
}

if (-not (Test-Path $FigmaScreenshot)) {
    Write-Host "❌ ERROR: Figma screenshot not found: $FigmaScreenshot" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Figma screenshot found: $FigmaScreenshot" -ForegroundColor Green
Write-Host ""

# Step 2: Capture Flutter app screenshot
Write-Host "📸 STEP 2: Capturing Flutter App Screenshot" -ForegroundColor Yellow
Write-Host ""

# Check if screen share server is running
$serverRunning = Get-Process python -ErrorAction SilentlyContinue | Where-Object {$_.CommandLine -like "*screen_share_server*"}

if (-not $serverRunning) {
    Write-Host "🚀 Starting screen share server..." -ForegroundColor Yellow
    Start-Process python -ArgumentList "screen_share_server.py --port 8888" -WindowStyle Hidden
    Start-Sleep -Seconds 3
}

# Capture screenshot
Write-Host "📸 Capturing current screen..." -ForegroundColor Yellow
python analyze_live_screen.py

# Find the latest screenshot
$flutterScreenshot = Get-ChildItem "live_screenshot_*.png" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $flutterScreenshot) {
    Write-Host "❌ ERROR: Failed to capture Flutter screenshot" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Flutter screenshot captured: $($flutterScreenshot.Name)" -ForegroundColor Green
Write-Host ""

# Step 3: Analyze with AI
Write-Host "🤖 STEP 3: AI Analysis (GPT-4 Vision)" -ForegroundColor Yellow
Write-Host ""
Write-Host "This will:" -ForegroundColor White
Write-Host "  1. Analyze your Figma design (gpt-4o-mini - cost efficient)" -ForegroundColor Gray
Write-Host "  2. Analyze your Flutter app (gpt-4o-mini - cost efficient)" -ForegroundColor Gray
Write-Host "  3. Compare them side-by-side (gpt-4o - high accuracy)" -ForegroundColor Gray
Write-Host "  4. Generate specific fix recommendations" -ForegroundColor Gray
Write-Host ""
Write-Host "Estimated cost: ~$0.05 per analysis" -ForegroundColor Cyan
Write-Host ""

python figma_to_flutter_analyzer.py --figma $FigmaScreenshot --flutter $flutterScreenshot.Name --mode compare

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "📋 NEXT STEPS:" -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Review the analysis report: FIGMA_FLUTTER_COMPARISON_REPORT.md" -ForegroundColor White
Write-Host "2. I'll read the report and implement the fixes" -ForegroundColor White
Write-Host "3. We'll re-run this script to verify the fixes" -ForegroundColor White
Write-Host "4. Repeat until Figma quality is achieved!" -ForegroundColor White
Write-Host ""
Write-Host "✅ Analysis complete!" -ForegroundColor Green
Write-Host ""

