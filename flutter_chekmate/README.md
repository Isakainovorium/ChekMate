# ChekMate - Dating Experience Platform

**"Dating can be a Game - Don't Get Played"**

ChekMate is the **first-in-class social platform** dedicated to sharing and rating dating experiences. Share your date stories, rate your experiences with WOW/GTFOH/ChekMate, and discover what others are saying about their dating adventures.

**We're NOT a dating app** - we're a community for discussing dating, sharing experiences, and helping each other navigate the dating world. Built with Flutter and Firebase.

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

### Core Features - Dating Experience Sharing
- [x] **Rate Your Date** - Share and rate dating experiences (WOW, GTFOH, ChekMate)
- [x] **Dating Stories** - Share your dating experiences through posts and stories
- [x] **Experience Feed** - Discover dating stories and advice from the community
- [x] **Community Discussions** - Connect with others to discuss dating experiences
- [x] **User Profiles** - Showcase your dating journey and experiences
- [x] **Live Discussions** - Real-time conversations about dating topics
- [x] **Premium Content** - Access exclusive dating advice and experiences
- [x] **Notifications** - Stay updated on community discussions

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

## CI/CD with Codemagic

This project is configured for automated builds using [Codemagic](https://codemagic.io/), allowing you to build iOS apps without a Mac.

### Quick Start

1. **Sign up for Codemagic** (free tier: 500 build minutes/month)
   - Go to https://codemagic.io/
   - Sign up with your GitHub account
   - Connect the ChekMate repository

2. **Configure Credentials**
   - Set up App Store Connect API key (for iOS)
   - Add Android keystore (for Android)
   - See [iOS Deployment Guide](docs/IOS_DEPLOYMENT_GUIDE.md) for detailed steps

3. **Trigger Builds**
   - Push to `main` branch → automatic build
   - Or manually trigger from Codemagic dashboard

### Available Workflows

The `codemagic.yaml` file includes three workflows:

- **ios-release**: Builds iOS IPA for App Store
- **android-release**: Builds Android APK and AAB
- **ios-and-android**: Builds both platforms

### Documentation

- **iOS Deployment**: See [docs/IOS_DEPLOYMENT_GUIDE.md](docs/IOS_DEPLOYMENT_GUIDE.md)
- **CI Setup**: See [docs/CI_SETUP.md](docs/CI_SETUP.md)

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
