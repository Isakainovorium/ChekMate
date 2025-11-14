# ChekMate - Enterprise Flutter Monorepo

A comprehensive dating platform built with Flutter, supporting iOS, Android, and Web deployments.

## 🏗️ Project Structure

```
ChekMate/
├── flutter_chekmate/          # Main Flutter application
├── platform/                  # Platform-specific configurations
│   ├── ios/                   # iOS-specific files and configs
│   ├── android/               # Android-specific files and configs
│   └── web/                   # Web-specific files and configs
├── config/                    # Environment and configuration files
├── docs/                      # Documentation
│   ├── architecture/          # Architecture documentation
│   ├── deployment/            # Deployment guides
│   └── api/                   # API documentation
├── scripts/                   # Build and deployment scripts
├── .github/                   # GitHub workflows and templates
├── phase_progression/         # Development phase tracking
└── archive/                   # Archived files and iterations
```

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK
- Xcode (for iOS development)
- Android Studio (for Android development)
- Node.js (for web development)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/Isakainovorium/ChekMate.git
   cd ChekMate
   ```

2. **Install dependencies**
   ```bash
   cd flutter_chekmate
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # iOS
   flutter run --flavor development --target lib/main.dart
   
   # Android
   flutter run --flavor development --target lib/main.dart
   
   # Web
   flutter run -d chrome --target lib/main.dart
   ```

## 🏗️ Build & Deployment

### Platform-Specific Builds

#### iOS (App Store)
```bash
# Development
flutter build ios --flavor development --target lib/main.dart

# Production
flutter build ios --release --flavor production --target lib/main.dart
```

#### Android (Google Play Store)
```bash
# Development
flutter build apk --flavor development --target lib/main.dart

# Production
flutter build appbundle --release --flavor production --target lib/main.dart
```

#### Web (PWA)
```bash
# Development
flutter build web --target lib/main.dart

# Production
flutter build web --release --target lib/main.dart
```

### CI/CD with CodeMagic

This monorepo uses CodeMagic for automated builds and deployments:

- **iOS**: Automatic TestFlight and App Store deployment
- **Android**: Automatic Google Play Store deployment
- **Web**: Automatic hosting deployment

See `.github/workflows/` for GitHub Actions and `codemagic.yaml` for CodeMagic configuration.

## 🔧 Environment Configuration

### Required Environment Variables

Create a `.env` file in the `config/` directory:

```bash
# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key

# Apple App Store Connect
APPLE_ISSUER_ID=your-issuer-id
APPLE_KEY_ID=your-key-id
APPLE_PRIVATE_KEY_PATH=path/to/private-key.p8

# Google Play Console
GOOGLE_PLAY_SERVICE_ACCOUNT=path/to/service-account.json

# API Endpoints
API_BASE_URL=https://api.chekmate.com
WEBSOCKET_URL=wss://ws.chekmate.com
```

### Security Notes

- **Never commit sensitive files** (API keys, certificates, etc.)
- Use environment variables for all sensitive configuration
- All sensitive files are excluded via `.gitignore`
- Use CodeMagic environment variables for CI/CD secrets

## 📱 Platform-Specific Features

### iOS
- Push Notifications (APNS)
- Face ID / Touch ID
- App Store In-App Purchases
- Universal Links

### Android
- Push Notifications (FCM)
- Biometric Authentication
- Google Play In-App Purchases
- Deep Links

### Web
- Progressive Web App (PWA)
- Push Notifications
- Service Worker
- Responsive Design

## 🧪 Testing

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widget/

# Coverage
flutter test --coverage
```

## 📊 Monitoring & Analytics

- **Firebase Analytics**: User behavior tracking
- **Crashlytics**: Crash reporting and analysis
- **Performance Monitoring**: App performance metrics
- **Remote Config**: Feature flags and A/B testing

## 🏗️ Architecture

The app follows clean architecture principles:

- **Presentation Layer**: Flutter widgets and UI components
- **Business Logic Layer**: Riverpod state management
- **Data Layer**: Repositories and data sources
- **Domain Layer**: Business entities and use cases

See `docs/architecture/` for detailed documentation.

## 🚀 Deployment Pipeline

### Development Flow
1. **Feature Branch**: Create feature branch from `main`
2. **Development**: Implement feature with tests
3. **PR Review**: Code review and testing
4. **Merge**: Merge to `main` after approval
5. **Staging**: Automatic deployment to staging environment
6. **Production**: Manual promotion to production

### Release Process
1. **Version Bump**: Update version in `pubspec.yaml`
2. **Changelog**: Update `CHANGELOG.md`
3. **Tag Release**: Create Git tag for version
4. **Build**: Automatic builds for all platforms
5. **Deploy**: Automatic deployment to stores

## 📚 Documentation

- [Architecture Guide](docs/architecture/README.md)
- [iOS Deployment Guide](docs/deployment/ios.md)
- [Android Deployment Guide](docs/deployment/android.md)
- [Web Deployment Guide](docs/deployment/web.md)
- [API Documentation](docs/api/README.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new features
5. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in GitHub
- Check the [FAQ](docs/FAQ.md)
- Review [troubleshooting guides](docs/troubleshooting/)

## 📞 Contact

- **Project Maintainer**: [Your Name](mailto:your.email@example.com)
- **GitHub Issues**: [Create Issue](https://github.com/Isakainovorium/ChekMate/issues)
- **Discord**: [Join our Discord](https://discord.gg/chekmate) 

