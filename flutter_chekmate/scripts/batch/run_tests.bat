@echo off
echo.
echo ======================================================================
echo 🧪 CHEKMATE FLUTTER TESTING SUITE
echo ======================================================================
echo.

echo 📋 Testing Strategy: Flutter Native Tests Only
echo    - Unit Tests: flutter test
echo    - Integration Tests: flutter test integration_test
echo    - Fast, reliable, no external dependencies
echo.

set "start_time=%time%"

echo 🔍 Step 1: Running Unit and Widget Tests...
echo ----------------------------------------------------------------------
flutter test
if %errorlevel% neq 0 (
    echo ❌ Unit tests failed!
    goto :error
)
echo ✅ Unit and widget tests passed!
echo.

echo 🔍 Step 2: Running Integration Tests...
echo ----------------------------------------------------------------------
flutter test integration_test
if %errorlevel% neq 0 (
    echo ❌ Integration tests failed!
    goto :error
)
echo ✅ Integration tests passed!
echo.

echo 📊 Step 3: Generating Test Coverage...
echo ----------------------------------------------------------------------
flutter test --coverage
if %errorlevel% neq 0 (
    echo ⚠️  Coverage generation failed, but tests passed
) else (
    echo ✅ Coverage report generated in coverage/lcov.info
)
echo.

set "end_time=%time%"
echo ======================================================================
echo 🎉 ALL TESTS PASSED!
echo ⏱️  Started: %start_time%
echo ⏱️  Finished: %end_time%
echo 📁 Coverage: coverage/lcov.info
echo ======================================================================
echo.
echo 💡 Quick Commands:
echo    flutter test                    - Run unit/widget tests only
echo    flutter test integration_test   - Run integration tests only
echo    flutter test --coverage         - Run with coverage
echo.
goto :end

:error
echo.
echo ======================================================================
echo ❌ TESTS FAILED
echo ======================================================================
echo.
echo 🔧 Troubleshooting:
echo    1. Check test output above for specific failures
echo    2. Run individual test files: flutter test test/specific_test.dart
echo    3. Run with verbose output: flutter test --verbose
echo.
exit /b 1

:end
pause
