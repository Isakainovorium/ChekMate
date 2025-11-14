#!/bin/bash
# Generate iOS App Icons
# This script generates all required iOS icon sizes from app_icon.png

echo "Generating iOS app icons..."
cd flutter_chekmate

# Check if app_icon.png exists
if [ ! -f "assets/icons/app_icon.png" ]; then
    echo "ERROR: app_icon.png not found in assets/icons/"
    echo "Please add app_icon.png (1024x1024px) to assets/icons/ directory"
    exit 1
fi

echo "SUCCESS: app_icon.png found"
echo "Running flutter_launcher_icons..."

flutter pub get
flutter pub run flutter_launcher_icons

if [ $? -eq 0 ]; then
    echo "SUCCESS: iOS app icons generated successfully"
    echo "Icons are now in: ios/Runner/Assets.xcassets/AppIcon.appiconset/"
else
    echo "ERROR: Icon generation failed"
    exit 1
fi

