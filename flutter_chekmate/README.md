# ChekMate Flutter App

A complete Flutter conversion of the ChekMate social media/dating app with Firebase integration.

## Prerequisites

### Install Flutter
1. Download Flutter SDK from https://flutter.dev/docs/get-started/install
2. Extract to a location like `C:\flutter` (Windows) or `/usr/local/flutter` (macOS/Linux)
3. Add Flutter to your PATH:
   - Windows: Add `C:\flutter\bin` to your PATH environment variable
   - macOS/Linux: Add `export PATH="$PATH:/usr/local/flutter/bin"` to your shell profile

### Verify Installation
```bash
flutter doctor
```

### Install Dependencies
```bash
flutter pub get
```

## Project Structure

```
flutter_chekmate/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── app.dart                  # Main app widget
│   ├── core/                     # Core functionality
│   │   ├── constants/            # App constants
│   │   ├── theme/               # App theming
│   │   ├── utils/               # Utility functions
│   │   └── services/            # Core services
│   ├── features/                # Feature modules
│   │   ├── auth/                # Authentication
│   │   ├── posts/               # Posts and feed
│   │   ├── stories/             # Stories feature
│   │   ├── messages/            # Messaging
│   │   ├── profile/             # User profiles
│   │   ├── rate_date/           # Rate your date
│   │   ├── live/                # Live streaming
│   │   └── subscription/        # Subscription system
│   ├── shared/                  # Shared components
│   │   ├── widgets/             # Reusable widgets
│   │   ├── models/              # Data models
│   │   └── providers/           # State providers
│   └── firebase_options.dart    # Firebase configuration
├── assets/                      # Static assets
│   ├── images/
│   ├── icons/
│   └── fonts/
├── web/                         # Web-specific files
├── android/                     # Android-specific files
├── ios/                         # iOS-specific files
├── pubspec.yaml                 # Dependencies
└── firebase.json                # Firebase configuration
```

## Features

### Core Features
- [x] Social media feed with posts
- [x] Stories with image/video support
- [x] Real-time messaging
- [x] User profiles and authentication
- [x] Rate Your Date system
- [x] Live streaming
- [x] Subscription management
- [x] Push notifications

### Technical Features
- [x] Firebase integration (Auth, Firestore, Storage, FCM)
- [x] State management with Riverpod
- [x] Responsive design
- [x] Dark/light theme support
- [x] Offline support
- [x] Image caching and optimization
- [x] Real-time updates
- [x] Push notifications

## Development

### Run the app
```bash
# Debug mode
flutter run

# Web
flutter run -d chrome

# Release mode
flutter run --release
```

### Build for production
```bash
# Android APK
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

## Firebase Setup

1. Create a new Firebase project at https://console.firebase.google.com
2. Enable Authentication, Firestore, Storage, and Cloud Messaging
3. Download configuration files:
   - `google-services.json` for Android (place in `android/app/`)
   - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
4. Run `flutterfire configure` to generate `firebase_options.dart`

## Visual UI Editor

This project supports visual editing through:

1. **Flutter Inspector**: Built into VS Code and Android Studio
2. **Hot Reload**: Real-time code changes
3. **Widgetbook**: Component library and visual testing
4. **Flutter Web**: Browser-based development and testing

### Using Widgetbook
```bash
flutter packages pub run build_runner build
flutter run -t lib/widgetbook.dart
```

## Architecture

### State Management
- **Riverpod**: Global state management
- **StateNotifier**: Complex state logic
- **Provider**: Local widget state

### Navigation
- **GoRouter**: Declarative routing
- **Bottom Navigation**: Persistent navigation state
- **Modal Navigation**: Overlays and dialogs

### Data Layer
- **Firebase Firestore**: Real-time database
- **Firebase Storage**: Media storage
- **Local Storage**: Offline caching

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License.
