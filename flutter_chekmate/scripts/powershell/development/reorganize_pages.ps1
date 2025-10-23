# PowerShell script to reorganize page files
Write-Host "🚀 Starting page file reorganization..." -ForegroundColor Cyan

# Copy auth pages
Write-Host "`n📁 Copying auth pages..." -ForegroundColor Yellow
Copy-Item "lib\features\auth\pages\login_page.dart" "lib\pages\auth\login_page.dart" -Force
Copy-Item "lib\features\auth\pages\signup_page.dart" "lib\pages\auth\signup_page.dart" -Force
Write-Host "✅ Auth pages copied" -ForegroundColor Green

# Copy and rename HomePage (from home_page_new.dart)
Write-Host "`n📁 Copying HomePage (from home_page_new.dart)..." -ForegroundColor Yellow
Copy-Item "lib\features\feed\pages\home\presentation\pages\home_page_new.dart" "lib\pages\home\home_page.dart" -Force
Write-Host "✅ HomePage copied" -ForegroundColor Green

# Copy messaging pages
Write-Host "`n📁 Copying messaging pages..." -ForegroundColor Yellow
Copy-Item "lib\features\messaging\pages\messages_page.dart" "lib\pages\messages\messages_page.dart" -Force
Copy-Item "lib\features\messaging\pages\chat_page.dart" "lib\pages\messages\chat_page.dart" -Force
Write-Host "✅ Messaging pages copied" -ForegroundColor Green

# Copy profile page
Write-Host "`n📁 Copying profile page..." -ForegroundColor Yellow
Copy-Item "lib\features\feed\subfeatures\profile\pages\my_profile_page.dart" "lib\pages\profile\my_profile_page.dart" -Force
Write-Host "✅ Profile page copied" -ForegroundColor Green

# Copy notifications page
Write-Host "`n📁 Copying notifications page..." -ForegroundColor Yellow
Copy-Item "lib\features\notifications\pages\notifications_page.dart" "lib\pages\notifications\notifications_page.dart" -Force
Write-Host "✅ Notifications page copied" -ForegroundColor Green

# Copy explore page
Write-Host "`n📁 Copying explore page..." -ForegroundColor Yellow
Copy-Item "lib\features\feed\pages\explore\pages\explore_page.dart" "lib\pages\explore\explore_page.dart" -Force
Write-Host "✅ Explore page copied" -ForegroundColor Green

# Copy live page
Write-Host "`n📁 Copying live page..." -ForegroundColor Yellow
Copy-Item "lib\features\feed\pages\live\pages\live_page.dart" "lib\pages\live\live_page.dart" -Force
Write-Host "✅ Live page copied" -ForegroundColor Green

# Copy subscribe page
Write-Host "`n📁 Copying subscribe page..." -ForegroundColor Yellow
Copy-Item "lib\features\subscription\pages\subscribe_page.dart" "lib\pages\subscribe\subscribe_page.dart" -Force
Write-Host "✅ Subscribe page copied" -ForegroundColor Green

Write-Host "`n✨ All existing pages copied successfully!" -ForegroundColor Green
Write-Host "`n⚠️  Note: rate_date_page.dart and create_post_page.dart need to be created" -ForegroundColor Yellow
Write-Host "`n📝 Next steps:" -ForegroundColor Cyan
Write-Host "  1. Update imports in copied files" -ForegroundColor White
Write-Host "  2. Rename HomePageNew to HomePage in home_page.dart" -ForegroundColor White
Write-Host "  3. Create rate_date_page.dart and create_post_page.dart" -ForegroundColor White
Write-Host "  4. Update app_router.dart imports" -ForegroundColor White
Write-Host "  5. Run flutter analyze" -ForegroundColor White

