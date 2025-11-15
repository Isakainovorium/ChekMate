# Script to generate mock files for tests
# Run this script from the flutter_chekmate directory

Write-Host "Generating mock files for tests..." -ForegroundColor Green

# Run build_runner to generate mocks
flutter pub run build_runner build --delete-conflicting-outputs

Write-Host "Mock files generated successfully!" -ForegroundColor Green

