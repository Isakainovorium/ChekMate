@echo off
REM Batch script to run the feed directory cleanup

echo ========================================
echo    CHEKMATE FEED DIRECTORY CLEANUP
echo ========================================
echo.

REM Check if we're in the right directory
if not exist "pubspec.yaml" (
    echo ERROR: Not in Flutter project root directory!
    echo Please navigate to flutter_chekmate directory first.
    pause
    exit /b 1
)

REM Create backup
echo Creating backup of feed directory...
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~0,4%-%dt:~4,2%-%dt:~6,2%_%dt:~8,2%-%dt:~10,2%-%dt:~12,2%"
set "backupPath=backups\feed_backup_%timestamp%"

if not exist "backups" mkdir "backups"
xcopy /E /I /Q "lib\features\feed" "%backupPath%"
echo Backup created at: %backupPath%
echo.

echo Current Structure Analysis:
echo ================================
echo.
echo Checking for duplicate files...
dir /B "lib\features\feed\pages\auth\pages\*.dart" 2>nul
dir /B "lib\features\feed\pages\auth\presentation\pages\*.dart" 2>nul
dir /B "lib\features\feed\pages\home\pages\*.dart" 2>nul
dir /B "lib\features\feed\pages\home\presentation\pages\*.dart" 2>nul
echo.

echo WARNING: This will restructure your feed directory!
echo A backup has been created at: %backupPath%
echo.

set /p confirmation=Do you want to proceed with cleanup? (yes/no): 

if /i not "%confirmation%"=="yes" (
    echo Cleanup cancelled.
    pause
    exit /b 0
)

echo.
echo Running cleanup script...
dart run lib\features\feed\cleanup_script.dart

if %errorlevel% equ 0 (
    echo.
    echo Cleanup completed successfully!
    echo.
    echo Running flutter pub get...
    flutter pub get
    
    echo.
    echo ========================================
    echo          CLEANUP COMPLETE!
    echo ========================================
    echo.
    echo Next steps:
    echo   1. Review the changes in your IDE
    echo   2. Fix any remaining import errors
    echo   3. Run: flutter analyze
    echo   4. Test your application
    echo.
    echo If you need to restore, use:
    echo   xcopy /E /I /Y "%backupPath%\*" "lib\features\feed"
) else (
    echo.
    echo Cleanup failed!
    echo Check the error messages above.
    echo.
    echo To restore from backup:
    echo   xcopy /E /I /Y "%backupPath%\*" "lib\features\feed"
)

pause
