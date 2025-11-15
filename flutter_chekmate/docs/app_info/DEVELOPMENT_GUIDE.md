# ChekMate Flutter Development Guide

## Table of Contents
1. [Getting Started](#getting-started)
2. [Project Structure](#project-structure)
3. [Development Workflow](#development-workflow)
4. [Visual UI Editing](#visual-ui-editing)
5. [Firebase Setup](#firebase-setup)
6. [Testing](#testing)
7. [Deployment](#deployment)

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Firebase CLI
- VS Code or Android Studio
- Git

### Installation

1. **Install Flutter**
   ```bash
   # Download from https://flutter.dev
   # Add to PATH
   flutter doctor
   ```

2. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd flutter_chekmate
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Run Code Generation**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Main app widget
├── widgetbook.dart          # Component showcase
├── core/                    # Core functionality
│   ├── theme/              # App theming
│   ├── router/             # Navigation
│   ├── utils/              # Utilities
│   ├── errors/             # Error handling
│   ├── constants/          # Constants
│   ├── providers/          # Global providers
│   ├── navigation/         # Navigation widgets
│   └── data/               # Data layer
│       ├── models/         # Data models
│       └── services/       # Services
├── features/               # Feature modules
│   ├── auth/              # Authentication
│   ├── home/              # Home feed
│   ├── messages/          # Messaging
│   ├── profile/           # User profile
│   ├── posts/             # Posts
│   ├── notifications/     # Notifications
│   ├── rate_date/         # Rate Your Date
│   ├── live/              # Live streaming
│   └── subscription/      # Subscriptions
└── shared/                # Shared components
    └── widgets/           # Reusable widgets
```

## Development Workflow

### Running the App

**Web (Recommended for Development)**
```bash
flutter run -d chrome
```

**Android**
```bash
flutter run -d android
```

**iOS**
```bash
flutter run -d ios
```

### Hot Reload
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Code Generation
```bash
# Watch mode (auto-generates on file changes)
flutter pub run build_runner watch

# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs
```

## Visual UI Editing

### Method 1: Widgetbook (Recommended)

Widgetbook provides a component library and visual testing environment.

**Run Widgetbook:**
```bash
flutter run -d chrome -t lib/widgetbook.dart
```

**Features:**
- Browse all UI components
- Test different states
- Switch between light/dark themes
- Interactive component playground

### Method 2: Hot Reload

1. Open the app in Chrome
2. Make changes to UI code
3. Press `r` in terminal
4. See changes instantly

### Method 3: Flutter Inspector

**VS Code:**
1. Run app in debug mode
2. Open Flutter DevTools
3. Use Widget Inspector tab
4. Click widgets to inspect properties

**Android Studio:**
1. Run app in debug mode
2. Open Flutter Inspector panel
3. Select widgets visually
4. Edit properties in real-time

### Method 4: DartPad

For quick prototyping:
1. Go to https://dartpad.dev
2. Paste widget code
3. See live preview
4. Copy back to project

## Firebase Setup

### 1. Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Follow setup wizard
4. Enable required services:
   - Authentication (Email, Google, Apple)
   - Cloud Firestore
   - Storage
   - Cloud Messaging
   - Analytics
   - Crashlytics

### 2. Configure Firebase

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

This will:
- Create Firebase apps for all platforms
- Generate `firebase_options.dart`
- Configure platform-specific files

### 3. Enable Authentication Methods

1. Go to Firebase Console > Authentication
2. Click "Sign-in method" tab
3. Enable:
   - Email/Password
   - Google
   - Apple (for iOS)

### 4. Set Up Firestore

1. Go to Firebase Console > Firestore Database
2. Click "Create database"
3. Choose production mode
4. Select region
5. Add security rules (see `firestore.rules`)

### 5. Set Up Storage

1. Go to Firebase Console > Storage
2. Click "Get started"
3. Choose production mode
4. Add security rules (see `storage.rules`)

## Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widgets
```

### Integration Tests
```bash
flutter test integration_test
```

### Test Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Deployment

### Web

**Build:**
```bash
flutter build web --release
```

**Deploy to Firebase Hosting:**
```bash
firebase deploy --only hosting
```

### Android

**Build APK:**
```bash
flutter build apk --release
```

**Build App Bundle:**
```bash
flutter build appbundle --release
```

**Deploy to Play Store:**
1. Upload to Google Play Console
2. Fill in store listing
3. Submit for review

### iOS

**Build:**
```bash
flutter build ios --release
```

**Deploy to App Store:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Archive the app
3. Upload to App Store Connect
4. Submit for review

## Best Practices

### Code Style
- Follow Dart style guide
- Use `flutter analyze` to check code
- Format code with `dart format .`
- Add trailing commas for better formatting

### State Management
- Use Riverpod for global state
- Use StatefulWidget for local state
- Keep state close to where it's used
- Avoid unnecessary rebuilds

### Performance
- Use `const` constructors where possible
- Implement `ListView.builder` for long lists
- Cache network images
- Lazy load data
- Profile with DevTools

### Security
- Never commit API keys
- Use environment variables
- Implement proper Firebase rules
- Validate user input
- Sanitize data

## Troubleshooting

### Common Issues

**Issue: Flutter not found**
```bash
# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"
```

**Issue: Dependencies not resolving**
```bash
flutter clean
flutter pub get
```

**Issue: Build errors**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Issue: Firebase not working**
```bash
flutterfire configure
flutter clean
flutter pub get
```

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Material Design](https://material.io)
- [Widgetbook Documentation](https://docs.widgetbook.io)

## Support

For issues and questions:
- Check existing documentation
- Search GitHub issues
- Create new issue with details
- Contact development team
