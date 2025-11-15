# ChekMate App Icon Setup Instructions

## Current Status
The ChekMate logo image has been provided, but we need to:
1. Create a proper 1024x1024px app icon from the logo
2. Generate all required icon sizes for Android and iOS
3. Run the flutter_launcher_icons package to apply the icons

## Required Files

### Source Icon (1024x1024px)
- **Location:** `assets/icons/app_icon.png`
- **Requirements:**
  - Size: 1024x1024 pixels
  - Format: PNG with transparency
  - Content: ChekMate logo (golden house shapes)
  - Background: Transparent or solid color

### Splash Screen Icon (512x512px or larger)
- **Location:** `assets/icons/splash_icon.png`
- **Requirements:**
  - Size: At least 512x512 pixels
  - Format: PNG with transparency
  - Content: ChekMate logo
  - Background: Transparent (background color set in pubspec.yaml)

## Steps to Complete Setup

### Step 1: Prepare Icon Files
You need to create two PNG files from the ChekMate logo image:

1. **app_icon.png** (1024x1024px)
   - Extract just the logo part (the golden house shapes)
   - Remove the text "CHEKMATE INTERNATIONAL"
   - Remove the bottom triangle with people
   - Center the logo on a 1024x1024 canvas
   - Save with transparency or solid background

2. **splash_icon.png** (512x512px or larger)
   - Can use the same logo as app_icon.png
   - Or use the full branding with text
   - Save with transparency

### Step 2: Place Files
Save both files to:
```
flutter_chekmate/assets/icons/app_icon.png
flutter_chekmate/assets/icons/splash_icon.png
```

### Step 3: Generate Icons
Run the following command to generate all required icon sizes:

```bash
cd flutter_chekmate
flutter pub run flutter_launcher_icons
```

This will automatically generate:
- **Android:** All mipmap sizes (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- **iOS:** All required icon sizes (20x20 to 1024x1024)

### Step 4: Generate Splash Screens
Run the following command to generate splash screens:

```bash
flutter pub run flutter_native_splash:create
```

This will create splash screens for:
- **Android:** Including Android 12+ adaptive splash
- **iOS:** Launch screen images

### Step 5: Verify
Check that icons were generated in:
- `android/app/src/main/res/mipmap-*/launcher_icon.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-*.png`

## Current Configuration (pubspec.yaml)

```yaml
flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icons/app_icon.png"
  min_sdk_android: 21

flutter_native_splash:
  color: "#FF6B35"  # Orange background
  image: assets/icons/splash_icon.png
  android_12:
    image: assets/icons/splash_icon.png
    color: "#FF6B35"
```

## Design Recommendations

### App Icon (Launcher Icon)
- **Keep it simple:** Just the golden house shapes logo
- **No text:** App name appears below icon automatically
- **High contrast:** Ensure logo is visible on all backgrounds
- **Centered:** Logo should be centered with some padding

### Splash Screen
- **Can include text:** "CHEKMATE" wordmark is fine here
- **Matches brand:** Use the orange color (#FF6B35)
- **Quick to load:** Keep file size reasonable

## Tools for Creating Icons

### Online Tools (Easiest)
1. **Canva** (https://canva.com)
   - Upload the logo image
   - Resize to 1024x1024
   - Remove unwanted elements
   - Export as PNG

2. **Figma** (https://figma.com)
   - Import logo
   - Create 1024x1024 frame
   - Export as PNG

3. **Photopea** (https://photopea.com) - Free Photoshop alternative
   - Open logo image
   - Crop/resize to 1024x1024
   - Remove text layers
   - Export as PNG

### Desktop Tools
- **GIMP** (Free) - https://gimp.org
- **Photoshop** (Paid)
- **Affinity Photo** (Paid, one-time purchase)

## What the Logo Should Look Like

Based on the provided image, the app icon should contain:
- ✅ The two golden/orange house-like shapes (chevrons)
- ✅ Gradient from yellow to orange
- ❌ NO "CHEKMATE" text (appears below icon automatically)
- ❌ NO "INTERNATIONAL" text
- ❌ NO bottom triangle with people illustration

The splash screen can optionally include the full branding.

## After Setup

Once icons are generated and you rebuild the app:
- **Android:** Users will see the ChekMate logo on home screen
- **iOS:** Users will see the ChekMate logo on home screen
- **Splash:** Users will see the logo on orange background when app launches

## Need Help?

If you need assistance creating the icon files:
1. Share the original high-resolution ChekMate logo
2. I can provide exact specifications for a designer
3. Or use one of the online tools above to create them yourself

