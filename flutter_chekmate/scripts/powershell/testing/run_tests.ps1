# ChekMate Flutter Testing Suite
# Fast, reliable testing using only Flutter native commands

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "🧪 CHEKMATE FLUTTER TESTING SUITE" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 Testing Strategy: Flutter Native Tests Only" -ForegroundColor Yellow
Write-Host "   - Unit Tests: flutter test" -ForegroundColor Gray
Write-Host "   - Integration Tests: flutter test integration_test" -ForegroundColor Gray
Write-Host "   - Fast, reliable, no external dependencies" -ForegroundColor Gray
Write-Host ""

$startTime = Get-Date

try {
    Write-Host "🔍 Step 1: Running Unit and Widget Tests..." -ForegroundColor Green
    Write-Host "----------------------------------------------------------------------" -ForegroundColor Gray
    
    $result1 = flutter test
    if ($LASTEXITCODE -ne 0) {
        throw "Unit tests failed"
    }
    Write-Host "✅ Unit and widget tests passed!" -ForegroundColor Green
    Write-Host ""

    Write-Host "🔍 Step 2: Running Integration Tests..." -ForegroundColor Green
    Write-Host "----------------------------------------------------------------------" -ForegroundColor Gray
    
    $result2 = flutter test integration_test
    if ($LASTEXITCODE -ne 0) {
        throw "Integration tests failed"
    }
    Write-Host "✅ Integration tests passed!" -ForegroundColor Green
    Write-Host ""

    Write-Host "📊 Step 3: Generating Test Coverage..." -ForegroundColor Green
    Write-Host "----------------------------------------------------------------------" -ForegroundColor Gray
    
    $result3 = flutter test --coverage
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  Coverage generation failed, but tests passed" -ForegroundColor Yellow
    } else {
        Write-Host "✅ Coverage report generated in coverage/lcov.info" -ForegroundColor Green
    }
    Write-Host ""

    $endTime = Get-Date
    $duration = $endTime - $startTime

    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "🎉 ALL TESTS PASSED!" -ForegroundColor Green
    Write-Host "⏱️  Duration: $($duration.TotalSeconds.ToString('F1')) seconds" -ForegroundColor Cyan
    Write-Host "📁 Coverage: coverage/lcov.info" -ForegroundColor Cyan
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "💡 Quick Commands:" -ForegroundColor Yellow
    Write-Host "   flutter test                    - Run unit/widget tests only" -ForegroundColor Gray
    Write-Host "   flutter test integration_test   - Run integration tests only" -ForegroundColor Gray
    Write-Host "   flutter test --coverage         - Run with coverage" -ForegroundColor Gray
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Red
    Write-Host "❌ TESTS FAILED" -ForegroundColor Red
    Write-Host "======================================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   1. Check test output above for specific failures" -ForegroundColor Gray
    Write-Host "   2. Run individual test files: flutter test test/specific_test.dart" -ForegroundColor Gray
    Write-Host "   3. Run with verbose output: flutter test --verbose" -ForegroundColor Gray
    Write-Host ""
    exit 1
}
