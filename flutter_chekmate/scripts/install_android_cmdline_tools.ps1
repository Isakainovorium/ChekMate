# Install Android Command Line Tools and Complete Setup
# This script downloads and installs the Android SDK command-line tools

$ErrorActionPreference = "Stop"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Installing Android Command Line Tools" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Configuration
$AndroidSdkPath = "$env:LOCALAPPDATA\Android\Sdk"
$CmdlineToolsUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$CmdlineToolsZip = "$env:TEMP\commandlinetools.zip"
$CmdlineToolsPath = "$AndroidSdkPath\cmdline-tools"

# Create SDK directory if it doesn't exist
if (-not (Test-Path $AndroidSdkPath)) {
    New-Item -ItemType Directory -Path $AndroidSdkPath -Force | Out-Null
    Write-Host "Created Android SDK directory: $AndroidSdkPath" -ForegroundColor Green
}

# Download command-line tools
Write-Host "Downloading Android Command Line Tools..." -ForegroundColor Yellow
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $CmdlineToolsUrl -OutFile $CmdlineToolsZip
Write-Host "Download complete!" -ForegroundColor Green

# Extract command-line tools
Write-Host "`nExtracting command-line tools..." -ForegroundColor Yellow
Expand-Archive -Path $CmdlineToolsZip -DestinationPath "$AndroidSdkPath\cmdline-tools-temp" -Force

# Move to correct location (SDK manager expects 'latest' folder)
if (Test-Path "$AndroidSdkPath\cmdline-tools-temp\cmdline-tools") {
    if (-not (Test-Path $CmdlineToolsPath)) {
        New-Item -ItemType Directory -Path $CmdlineToolsPath -Force | Out-Null
    }
    
    # Remove old 'latest' if exists
    if (Test-Path "$CmdlineToolsPath\latest") {
        Remove-Item "$CmdlineToolsPath\latest" -Recurse -Force
    }
    
    Move-Item "$AndroidSdkPath\cmdline-tools-temp\cmdline-tools" "$CmdlineToolsPath\latest" -Force
    Remove-Item "$AndroidSdkPath\cmdline-tools-temp" -Recurse -Force
    Write-Host "Command-line tools installed!" -ForegroundColor Green
}

# Clean up
Remove-Item $CmdlineToolsZip -Force

# Set environment variables
Write-Host "`nConfiguring environment variables..." -ForegroundColor Yellow
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $AndroidSdkPath, "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $AndroidSdkPath, "User")

$env:ANDROID_HOME = $AndroidSdkPath
$env:ANDROID_SDK_ROOT = $AndroidSdkPath

# Add to PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$pathsToAdd = @(
    "$AndroidSdkPath\cmdline-tools\latest\bin",
    "$AndroidSdkPath\platform-tools",
    "$AndroidSdkPath\tools\bin"
)

foreach ($pathToAdd in $pathsToAdd) {
    if ($currentPath -notlike "*$pathToAdd*") {
        $currentPath = "$currentPath;$pathToAdd"
    }
}

[Environment]::SetEnvironmentVariable("Path", $currentPath, "User")
$env:Path = $currentPath

Write-Host "Environment variables configured!" -ForegroundColor Green

# Install required SDK packages
Write-Host "`nInstalling required SDK packages..." -ForegroundColor Yellow

$sdkmanager = "$AndroidSdkPath\cmdline-tools\latest\bin\sdkmanager.bat"

# Accept licenses first
Write-Host "Accepting Android licenses..." -ForegroundColor Yellow
$yes = "y`n" * 20
$yes | & $sdkmanager --licenses 2>&1 | Out-Null

# Install required packages
$packages = @(
    "platform-tools",
    "platforms;android-34",
    "build-tools;34.0.0",
    "cmdline-tools;latest"
)

foreach ($package in $packages) {
    Write-Host "Installing $package..." -ForegroundColor Yellow
    & $sdkmanager $package 2>&1 | Out-Null
}

Write-Host "`nAll SDK packages installed!" -ForegroundColor Green

# Verify installation
Write-Host "`nVerifying installation..." -ForegroundColor Yellow
flutter doctor -v

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "`nNext step: Run the complete_android_setup.ps1 script" -ForegroundColor Yellow

