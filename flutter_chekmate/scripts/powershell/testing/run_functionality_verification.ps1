# Run Functionality Verification
# This script runs the Flutter app and uses OpenAI Assistant to verify functionality

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "🎯 FUNCTIONALITY VERIFICATION - Phase 5" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if Flutter is available
Write-Host "📋 STEP 1: Checking Flutter..." -ForegroundColor Yellow
Write-Host ""

$flutterPath = Get-Command flutter -ErrorAction SilentlyContinue

if (-not $flutterPath) {
    Write-Host "❌ ERROR: Flutter not found in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run this command manually in a terminal where Flutter is available:" -ForegroundColor Yellow
    Write-Host "  cd flutter_chekmate" -ForegroundColor White
    Write-Host "  flutter run -d chrome --web-port=8080" -ForegroundColor White
    Write-Host ""
    Write-Host "Then, once the app is running, run:" -ForegroundColor Yellow
    Write-Host "  python use_assistant_functionality.py" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "✅ Flutter found: $($flutterPath.Source)" -ForegroundColor Green
Write-Host ""

# Step 2: Check if Figma screenshot exists
Write-Host "📋 STEP 2: Checking Figma screenshot..." -ForegroundColor Yellow
Write-Host ""

if (-not (Test-Path "figma_home.png")) {
    Write-Host "❌ ERROR: figma_home.png not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please export the Figma design:" -ForegroundColor Yellow
    Write-Host "  1. Open: https://www.figma.com/make/DctaXwzyY5MceogG5WYSSB/ChekMate" -ForegroundColor White
    Write-Host "  2. Select the home screen frame" -ForegroundColor White
    Write-Host "  3. Right-click → Export → PNG" -ForegroundColor White
    Write-Host "  4. Save as 'figma_home.png' in this folder" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "✅ Figma screenshot found" -ForegroundColor Green
Write-Host ""

# Step 3: Check if app is already running
Write-Host "📋 STEP 3: Checking if app is running..." -ForegroundColor Yellow
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 2 -ErrorAction Stop
    Write-Host "✅ App is already running on http://localhost:8080" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "⚠️  App not running. Starting Flutter app..." -ForegroundColor Yellow
    Write-Host ""
    
    # Start Flutter app in background
    Write-Host "🚀 Starting: flutter run -d chrome --web-port=8080" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This will take 1-2 minutes..." -ForegroundColor Gray
    Write-Host ""
    
    Start-Process flutter -ArgumentList "run -d chrome --web-port=8080" -NoNewWindow
    
    # Wait for app to start
    Write-Host "⏳ Waiting for app to load..." -ForegroundColor Yellow
    $maxWait = 120
    $waited = 0
    $appReady = $false
    
    while ($waited -lt $maxWait) {
        Start-Sleep -Seconds 5
        $waited += 5
        
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 2 -ErrorAction Stop
            $appReady = $true
            break
        } catch {
            Write-Host "   Still waiting... ($waited seconds)" -ForegroundColor Gray
        }
    }
    
    if (-not $appReady) {
        Write-Host "❌ ERROR: App failed to start within $maxWait seconds" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please start the app manually:" -ForegroundColor Yellow
        Write-Host "  flutter run -d chrome --web-port=8080" -ForegroundColor White
        Write-Host ""
        exit 1
    }
    
    Write-Host "✅ App is running!" -ForegroundColor Green
    Write-Host ""
    
    # Wait a bit more for full load
    Write-Host "⏳ Waiting for full app load..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    Write-Host "✅ Ready!" -ForegroundColor Green
    Write-Host ""
}

# Step 4: Run functionality verification
Write-Host "📋 STEP 4: Running Functionality Verification..." -ForegroundColor Yellow
Write-Host ""
Write-Host "This will:" -ForegroundColor White
Write-Host "  1. Capture current Flutter app screenshot" -ForegroundColor Gray
Write-Host "  2. Compare with Figma design" -ForegroundColor Gray
Write-Host "  3. Verify FUNCTIONALITY (not colors)" -ForegroundColor Gray
Write-Host "  4. Generate functionality report" -ForegroundColor Gray
Write-Host ""
Write-Host "Focus: Does the app FUNCTION like Figma?" -ForegroundColor Cyan
Write-Host "  ✅ All buttons present?" -ForegroundColor Gray
Write-Host "  ✅ All navigation working?" -ForegroundColor Gray
Write-Host "  ✅ All components positioned correctly?" -ForegroundColor Gray
Write-Host "  ✅ All interactions working?" -ForegroundColor Gray
Write-Host ""
Write-Host "NOT checking: Colors (already solved manually)" -ForegroundColor Yellow
Write-Host ""

# Run the Python script
python use_assistant_functionality.py

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "📋 VERIFICATION COMPLETE!" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Review the functionality report" -ForegroundColor White
Write-Host "  2. I'll implement any fixes needed" -ForegroundColor White
Write-Host "  3. We'll re-run verification" -ForegroundColor White
Write-Host "  4. Then you can test manually" -ForegroundColor White
Write-Host ""

