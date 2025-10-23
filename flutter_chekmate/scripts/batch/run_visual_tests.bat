@echo off
echo ========================================
echo ChekMate Visual Selenium Tests
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed!
    echo Please install Python from https://www.python.org/
    pause
    exit /b 1
)

echo [1/4] Installing Python dependencies...
pip install -r requirements.txt

echo.
echo [2/4] Checking if Flutter app is running...
echo Make sure your Flutter app is running on http://localhost:60366
echo If not, run: flutter run -d chrome
echo.
pause

echo.
echo [3/4] Running Selenium visual tests...
python ..\python\test_selenium.py

echo.
echo [4/4] Tests complete!
echo Check the test_screenshots folder for visual confirmation
echo.
pause

