@echo off
echo Generating mock files for tests...
flutter pub run build_runner build --delete-conflicting-outputs
echo Mock files generated successfully!
pause

