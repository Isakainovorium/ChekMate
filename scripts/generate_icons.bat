@echo off
REM Generate iOS App Icons
REM This script generates all required iOS icon sizes from app_icon.png

echo Generating iOS app icons...
cd flutter_chekmate

REM Check if app_icon.png exists
if not exist "assets\icons\app_icon.png" (
    echo ERROR: app_icon.png not found in assets\icons\
    echo Please add app_icon.png (1024x1024px) to assets\icons\ directory
    exit /b 1
)

echo SUCCESS: app_icon.png found
echo Running flutter_launcher_icons...

flutter pub get
flutter pub run flutter_launcher_icons

if %ERRORLEVEL% EQU 0 (
    echo SUCCESS: iOS app icons generated successfully
    echo Icons are now in: ios\Runner\Assets.xcassets\AppIcon.appiconset\
) else (
    echo ERROR: Icon generation failed
    exit /b 1
)

