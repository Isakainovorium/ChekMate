# FlutterFire CLI Setup Instructions

## Current Status

Your `firebase_options.dart` file has been manually configured with the correct iOS settings. However, to ensure full compatibility and automatic platform registration, you should run the official FlutterFire CLI.

## Prerequisites

1. **Flutter SDK** must be installed and in your PATH
2. **Firebase CLI** (optional but recommended)
3. **Firebase project access** - You must be logged into Firebase

## Installation Steps

### Step 1: Install FlutterFire CLI

Open a terminal/command prompt and run:

```bash
dart pub global activate flutterfire_cli
```

Or if `dart` is not in your PATH, use:

```bash
flutter pub global activate flutterfire_cli
```

### Step 2: Navigate to Your Flutter Project

```bash
cd flutter_chekmate
```

### Step 3: Run FlutterFire Configure

```bash
flutterfire configure --project=chekmate-a0423
```

This command will:
- Automatically detect your Firebase project
- Register your iOS and Android apps (if configured in Firebase console)
- Generate/update `lib/firebase_options.dart` with all platform configurations
- Ensure all app IDs and bundle IDs match Firebase console

## What the CLI Will Do

1. **Authenticate** - You'll be prompted to log in to Firebase (if not already)
2. **Select Platforms** - Choose which platforms to configure (iOS, Android, Web, etc.)
3. **Auto-detect Apps** - The CLI will find your registered apps in Firebase
4. **Generate Config** - Creates/updates `firebase_options.dart` with all correct values

## Alternative: Manual Configuration

If you cannot run the CLI (Flutter not in PATH), the current `firebase_options.dart` file is already correctly configured for iOS with:

- ✅ Correct API Key
- ✅ Correct App ID: `1:209000668199:ios:c6c7680afe597e441ac202`
- ✅ Correct Bundle ID: `com.chekmate.app`
- ✅ Correct Project ID: `chekmate-a0423`
- ✅ Correct iOS Client ID

## Android Configuration

If you plan to build for Android, you'll need to:

1. **Add Android app in Firebase Console** (if not already done)
2. **Download `google-services.json`** from Firebase console
3. **Place it in** `android/app/google-services.json`
4. **Run FlutterFire CLI** to update `firebase_options.dart` with Android App ID

Or manually update the Android section in `firebase_options.dart` with the Android App ID from Firebase console.

## Verification

After running the CLI (or using the manual config), verify:

1. **iOS Configuration** matches Firebase console:
   - App ID: `1:209000668199:ios:c6c7680afe597e441ac202`
   - Bundle ID: `com.chekmate.app`

2. **File Location**: `flutter_chekmate/lib/firebase_options.dart` exists

3. **Test Initialization**: Your `main.dart` should initialize Firebase without errors

## Next Steps

1. Run the FlutterFire CLI when you have Flutter in your PATH
2. Or continue with the current manual configuration (iOS is already correct)
3. Initialize Firebase in your `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // ... rest of your app
}
```

## Troubleshooting

### Flutter Not in PATH
- Add Flutter to your system PATH
- Or use the full path to Flutter executable
- Or run from an IDE that has Flutter configured (VS Code, Android Studio)

### Authentication Issues
- Make sure you're logged into Firebase
- Use `firebase login` if needed
- Check Firebase project permissions

### App Not Found
- Verify the app is registered in Firebase console
- Check Bundle ID/Package name matches exactly
- Re-register the app if needed

## Current Configuration

Your current `firebase_options.dart` is ready for iOS development. The FlutterFire CLI will enhance it by:
- Adding Android configuration (if Android app exists)
- Ensuring all fields are complete
- Validating against Firebase console

But for iOS-only development, the current configuration is sufficient.

