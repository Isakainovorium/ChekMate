# Quick Start Script for Screen Share MCP
# Run this to start the screen share server

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "👁️  SCREEN SHARE MCP - QUICK START" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# Check if Pillow is installed
Write-Host "📦 Checking dependencies..." -ForegroundColor Yellow
try {
    python -c "import PIL" 2>$null
    Write-Host "✅ Pillow is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Pillow not installed. Installing..." -ForegroundColor Red
    pip install Pillow
}

Write-Host ""
Write-Host "🚀 Starting Screen Share Server..." -ForegroundColor Yellow
Write-Host ""
Write-Host "📋 INSTRUCTIONS:" -ForegroundColor Cyan
Write-Host "   1. The server will start on http://localhost:8888" -ForegroundColor White
Write-Host "   2. Open that URL in your browser to see the live feed" -ForegroundColor White
Write-Host "   3. The AI can now access /api/screenshot to see your screen" -ForegroundColor White
Write-Host "   4. Press Ctrl+C to stop the server" -ForegroundColor White
Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# Start the server
python screen_share_server.py --port 8888

