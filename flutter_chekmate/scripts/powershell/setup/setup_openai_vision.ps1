# Setup OpenAI Vision for Screen Analysis
# This script configures the visual analyzer to use your OpenAI API key

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "🔧 OPENAI VISION SETUP" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# Check if openai is installed
Write-Host "📦 Checking dependencies..." -ForegroundColor Yellow
try {
    python -c "import openai" 2>$null
    Write-Host "✅ OpenAI library is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ OpenAI library not installed. Installing..." -ForegroundColor Red
    pip install openai
}

Write-Host ""
Write-Host "🔐 Setting up API key..." -ForegroundColor Yellow

# Read API key from file
$apiKeyFile = ".openai_key"

if (Test-Path $apiKeyFile) {
    $apiKey = Get-Content $apiKeyFile -Raw
    $apiKey = $apiKey.Trim()
    
    # Set environment variable for current session
    $env:OPENAI_API_KEY = $apiKey
    
    Write-Host "✅ API key loaded from file" -ForegroundColor Green
    Write-Host "   File: $apiKeyFile" -ForegroundColor Gray
} else {
    Write-Host "⚠️  API key file not found: $apiKeyFile" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please create the file and add your OpenAI API key:" -ForegroundColor White
    Write-Host "   1. Create file: $apiKeyFile" -ForegroundColor Gray
    Write-Host "   2. Add your API key (one line, no quotes)" -ForegroundColor Gray
    Write-Host "   3. Run this script again" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "   1. Start screen share server:" -ForegroundColor White
Write-Host "      python screen_share_server.py --port 8888" -ForegroundColor Gray
Write-Host ""
Write-Host "   2. Capture a screenshot:" -ForegroundColor White
Write-Host "      python analyze_live_screen.py" -ForegroundColor Gray
Write-Host ""
Write-Host "   3. Analyze with AI vision:" -ForegroundColor White
Write-Host "      python visual_analyzer_mcp.py live_screenshot_*.png --provider openai" -ForegroundColor Gray
Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

