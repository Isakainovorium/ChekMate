# PowerShell script to run duplicate analysis

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ENTERPRISE DUPLICATE ANALYSIS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Find Flutter/Dart in PATH or common locations
$dartCmd = $null
$flutterCmd = $null

# Check if dart is in PATH
if (Get-Command dart -ErrorAction SilentlyContinue) {
    $dartCmd = "dart"
} elseif (Get-Command flutter -ErrorAction SilentlyContinue) {
    $flutterCmd = "flutter"
}

# Try common Flutter installation paths
if (-not $dartCmd -and -not $flutterCmd) {
    $commonPaths = @(
        "$env:LOCALAPPDATA\flutter\bin\dart.exe",
        "$env:USERPROFILE\flutter\bin\dart.exe",
        "C:\flutter\bin\dart.exe",
        "$env:LOCALAPPDATA\flutter\bin\flutter.exe",
        "$env:USERPROFILE\flutter\bin\flutter.exe",
        "C:\flutter\bin\flutter.exe"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            if ($path -like "*dart.exe") {
                $dartCmd = $path
                break
            } elseif ($path -like "*flutter.exe") {
                $flutterCmd = $path
                break
            }
        }
    }
}

if ($dartCmd) {
    Write-Host "Using Dart: $dartCmd" -ForegroundColor Green
    & $dartCmd run lib\features\feed\analyze_duplicates.dart
} elseif ($flutterCmd) {
    Write-Host "Using Flutter: $flutterCmd" -ForegroundColor Green
    & $flutterCmd pub run lib\features\feed\analyze_duplicates.dart
} else {
    Write-Host "ERROR: Dart/Flutter not found!" -ForegroundColor Red
    Write-Host "Running manual analysis instead..." -ForegroundColor Yellow
    Write-Host ""
    
    # Manual analysis as fallback
    . "$PSScriptRoot\manual_duplicate_analysis.ps1"
}
