# Test OpenAI Vision - Quick Test Script

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "🧪 TESTING OPENAI VISION" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# Read API key from file
$apiKeyFile = ".openai_key"

if (Test-Path $apiKeyFile) {
    $apiKey = Get-Content $apiKeyFile | Select-Object -First 1
    $apiKey = $apiKey.Trim()
    
    # Set environment variable
    $env:OPENAI_API_KEY = $apiKey
    
    Write-Host "✅ API key loaded" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "❌ API key file not found: $apiKeyFile" -ForegroundColor Red
    exit 1
}

# Check if we have a screenshot to analyze
$screenshot = Get-ChildItem "live_screenshot_*.png" | Select-Object -First 1

if ($screenshot) {
    Write-Host "📸 Found screenshot: $($screenshot.Name)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🤖 Analyzing with GPT-4 Vision..." -ForegroundColor Yellow
    Write-Host ""
    
    python visual_analyzer_mcp.py $screenshot.Name --provider openai
} else {
    Write-Host "⚠️  No screenshot found. Capturing one now..." -ForegroundColor Yellow
    Write-Host ""
    
    # Start screen share server in background if not running
    $serverRunning = Get-Process python -ErrorAction SilentlyContinue | Where-Object {$_.CommandLine -like "*screen_share_server*"}
    
    if (-not $serverRunning) {
        Write-Host "🚀 Starting screen share server..." -ForegroundColor Yellow
        Start-Process python -ArgumentList "screen_share_server.py --port 8888" -WindowStyle Hidden
        Start-Sleep -Seconds 3
    }
    
    # Capture screenshot
    Write-Host "📸 Capturing screenshot..." -ForegroundColor Yellow
    python analyze_live_screen.py
    
    # Find the new screenshot
    $screenshot = Get-ChildItem "live_screenshot_*.png" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    
    if ($screenshot) {
        Write-Host ""
        Write-Host "🤖 Analyzing with GPT-4 Vision..." -ForegroundColor Yellow
        Write-Host ""
        
        python visual_analyzer_mcp.py $screenshot.Name --provider openai
    } else {
        Write-Host "❌ Failed to capture screenshot" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "✅ TEST COMPLETE" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

