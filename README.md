<div align="center">

# ChekMate - Dating Experience Platform

### *"Dating can be a Game - Don't Get Played"*

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-blue)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**The world's first social platform dedicated to sharing and rating dating experiences.**

[Features](#-key-features) • [Getting Started](#-quick-start) • [Documentation](#-documentation) • [Contributing](#-contributing)

</div>

---

## 📖 Table of Contents

- [What is ChekMate?](#-what-is-chekmate)
- [Mission & Vision](#-mission--vision)
- [Key Features](#-key-features)
- [How It Works](#-how-it-works)
- [Technical Stack](#-technical-stack)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Quick Start](#-quick-start)
- [Build & Deployment](#-build--deployment)
- [Environment Configuration](#-environment-configuration)
- [Testing](#-testing)
- [Documentation](#-documentation)
- [Contributing](#-contributing)
- [Support](#-support)

---

## 🎯 What is ChekMate?

**ChekMate is NOT a dating app.** We don't connect people for relationships or help you find dates.

Instead, ChekMate is the **first-in-class Dating Experience Sharing Platform** - a social community where people share their dating stories, rate their experiences, and help each other navigate the dating world with transparency and community support.

Think of it as **Yelp meets Instagram, but for dating experiences.**

### What Makes Us Different

| Traditional Dating Apps | ChekMate |
|------------------------|----------|
| ❌ Find dates and matches | ✅ Share dating experiences and stories |
| ❌ Swipe to connect with people | ✅ Discover what others are experiencing |
| ❌ Arrange meetups | ✅ Rate and discuss past dates |
| ❌ Focus on matchmaking | ✅ Focus on community transparency |

---

## 🚀 Mission & Vision

### Our Mission

**Empower people to navigate the dating world through shared experiences, community transparency, and collective wisdom.**

We believe dating shouldn't be a game where people get played. By creating a platform where users can:
- **Share** their dating experiences openly
- **Rate** their dates with our unique WOW/GTFOH/ChekMate system
- **Discover** what others are experiencing in the dating scene
- **Learn** from the community's collective dating wisdom

...we're building accountability and transparency into modern dating culture.

### Our Vision

To become the world's leading community for dating experience sharing, where:
- Every dating story contributes to collective knowledge
- Community transparency helps people make informed decisions
- Shared experiences create a supportive dating ecosystem
- Users help each other avoid bad experiences and celebrate great ones

### Core Values

🎯 **Transparency** - Honest sharing of dating experiences
🤝 **Community** - Supporting each other through dating journeys
🛡️ **Accountability** - Creating responsibility in dating culture
💡 **Wisdom** - Learning from collective experiences
🎉 **Celebration** - Recognizing great dating moments

---

## ✨ Key Features

ChekMate's features are designed around **experience-first dating** - helping users share, discover, and learn from dating experiences rather than creating them.

### 🌟 Rate Your Date (Core Feature)

**What It Does:**
Our signature feature allows users to rate their past dating experiences using three unique ratings:

- **WOW** 🎉 - "That's Amazing; Sweet!" - Exceptional dates worth celebrating
- **GTFOH** 🚫 - "NOT RECOMMENDED" - Warn the community about bad experiences
- **ChekMate** ♟️ - "Smart Play" - When you outsmarted a tricky dating situation

**How It Achieves Our Mission:**
This rating system creates **accountability and transparency** in the dating world. By sharing honest ratings:
- Users help others make informed decisions about potential dates
- The community learns what behaviors to watch for
- Great dating experiences get recognized and celebrated
- Bad actors become visible through community feedback
- Users feel empowered to share both wins and warnings

**Technical Implementation:**
- Real-time rating aggregation using Firebase Firestore
- Privacy-focused: ratings are anonymous but verified
- Anti-spam measures to prevent rating manipulation
- Contextual rating prompts after date experiences

---

### 📱 Dating Experience Sharing

**What It Does:**
Users create rich, multimedia posts sharing their dating stories, advice, and experiences:
- Photo and video posts with captions
- Dating advice and tips
- Funny or cautionary dating tales
- Success stories and lessons learned
- Location-tagged experiences

**How It Achieves Our Mission:**
Experience sharing transforms individual dating moments into **collective wisdom**:
- New daters learn from veterans' experiences
- Common dating red flags become visible
- Positive dating behaviors get amplified
- Users feel less alone in their dating journeys
- Community builds empathy and understanding

**Technical Implementation:**
- Firebase Storage for media uploads (images, videos)
- Image cropping and optimization for performance
- Rich text formatting for detailed storytelling
- Hashtag and mention support for discoverability
- Content moderation and reporting system

---

### 📖 Dating Stories (24-Hour Stories)

**What It Does:**
Ephemeral, authentic glimpses into real-time dating experiences:
- Share quick updates about ongoing dates
- Post reactions to dating app conversations
- Document dating preparation and aftermath
- Create polls asking for dating advice
- Share location-based dating scene updates

**How It Achieves Our Mission:**
Stories provide **real-time community support** during dating experiences:
- Users get instant feedback on dating situations
- Community provides advice during active dates
- Authentic, unfiltered dating moments build trust
- 24-hour format encourages honest, spontaneous sharing
- Creates a sense of "we're in this together"

**Technical Implementation:**
- Auto-expiring content (24-hour lifecycle)
- Real-time story viewing with Firebase
- Interactive elements (polls, questions, reactions)
- Story highlights for permanent archiving
- Privacy controls (close friends, public, private)

---

### 🗺️ Discover Local Dating Stories

**What It Does:**
Location-based discovery of dating experiences in your area:
- See what's happening in your local dating scene
- Discover popular date spots and venues
- Find dating events and meetups
- Read reviews of local dating venues
- Connect with others navigating the same dating landscape

**How It Achieves Our Mission:**
Local discovery creates **geographic community transparency**:
- Users learn about their specific dating environment
- Local dating culture becomes visible and discussable
- Venue recommendations come from real experiences
- Regional dating trends and patterns emerge
- Users feel connected to their local dating community

**Technical Implementation:**
- Geolocator integration for precise location services
- Geocoding for address and place name resolution
- Location-based content filtering and discovery
- Privacy-first: users control location sharing granularity
- Map visualization of dating experiences

---

### 💬 Community Discussions

**What It Does:**
Private and group messaging for discussing dating experiences:
- One-on-one conversations with friends
- Group chats for dating advice
- Share experiences privately before posting publicly
- Get feedback on dating situations
- Build support networks

**How It Achieves Our Mission:**
Discussions enable **peer-to-peer support and advice**:
- Users get personalized guidance from trusted friends
- Sensitive experiences can be shared privately first
- Group wisdom helps solve dating dilemmas
- Community bonds strengthen through shared support
- Users feel safe discussing vulnerable topics

**Technical Implementation:**
- Real-time messaging with Firebase Cloud Messaging
- End-to-end encryption for privacy
- Rich media sharing (photos, videos, voice messages)
- Read receipts and typing indicators
- Push notifications for timely responses

---

### 🎥 Live Dating Discussions

**What It Does:**
Real-time video streaming for dating Q&A and community discussions:
- Host live dating advice sessions
- Share real-time date preparation
- Conduct dating topic discussions
- Answer community questions live
- Create interactive dating workshops

**How It Achieves Our Mission:**
Live streaming creates **synchronous community engagement**:
- Real-time advice during dating emergencies
- Expert guidance becomes accessible to all
- Community learns together in real-time
- Authentic, unscripted dating conversations
- Builds stronger community connections

**Technical Implementation:**
- Video streaming infrastructure (planned)
- Real-time chat during streams
- Stream recording and replay
- Viewer interaction features
- Moderation tools for safe discussions

---

### 🔍 Intelligent Content Discovery

**What It Does:**
Smart algorithm that surfaces relevant dating experiences based on:
- Your interests and dating preferences
- Similar experiences to yours
- Trending dating topics
- Local dating scene activity
- Community engagement patterns

**How It Achieves Our Mission:**
Intelligent discovery ensures users find **relevant, valuable experiences**:
- Personalized learning from similar situations
- Trending topics keep community informed
- Diverse perspectives prevent echo chambers
- Quality content gets amplified
- Users discover helpful experiences they didn't know to search for

**Technical Implementation:**
- Machine learning content recommendation
- User behavior analysis and preference learning
- Engagement-based ranking algorithms
- Content freshness and relevance scoring
- A/B testing for algorithm optimization

---

### 👤 Profile & Community Building

**What It Does:**
Rich user profiles showcasing dating journey and community contributions:
- Share your dating philosophy and goals
- Display your experience ratings and posts
- Build follower/following networks
- Earn community reputation badges
- Showcase dating advice expertise

**How It Achieves Our Mission:**
Profiles create **identity and credibility** in the community:
- Users build trust through consistent contributions
- Expertise becomes visible and valued
- Community leaders emerge naturally
- Accountability through persistent identity
- Users feel ownership of their community presence

**Technical Implementation:**
- Firebase Authentication for secure identity
- Cloud Firestore for profile data
- Profile verification system
- Reputation and badge algorithms
- Privacy controls for profile visibility

---

### 🔔 Smart Notifications

**What It Does:**
Timely alerts for community engagement and important updates:
- New ratings on your shared experiences
- Responses to your dating questions
- Trending topics in your area
- Friend activity and updates
- Safety alerts and community warnings

**How It Achieves Our Mission:**
Notifications keep users **engaged and informed**:
- Timely responses to dating questions
- Community support when needed
- Important safety information reaches users quickly
- Engagement drives more experience sharing
- Users stay connected to their support network

**Technical Implementation:**
- Firebase Cloud Messaging for push notifications
- Intelligent notification batching and timing
- User preference controls
- Priority-based notification system
- Cross-platform notification support

---

## 🎮 How It Works

### For New Users

1. **Join the Community** - Create your profile and set dating interests
2. **Explore Experiences** - Discover what others are sharing about dating
3. **Share Your Story** - Post your first dating experience or advice
4. **Rate Your Dates** - Use WOW/GTFOH/ChekMate to rate past experiences
5. **Build Connections** - Follow users with similar dating journeys
6. **Contribute Wisdom** - Help others through comments and discussions

### For Active Community Members

1. **Daily Discovery** - Check your feed for new dating experiences
2. **Share Regularly** - Post stories, advice, and ratings
3. **Engage Authentically** - Comment, react, and support others
4. **Build Reputation** - Become a trusted voice in the community
5. **Help Others** - Answer questions and provide guidance
6. **Stay Local** - Contribute to your local dating scene transparency

---

## 🏗️ Project Structure

```
ChekMate/
├── flutter_chekmate/          # Main Flutter application
│   ├── lib/
│   │   ├── core/              # Core utilities, constants, theme
│   │   ├── shared/            # Shared UI components and widgets
│   │   ├── pages/             # App screens and features
│   │   └── main.dart          # Application entry point
│   ├── assets/                # Images, icons, animations
│   ├── ios/                   # iOS-specific configuration
│   ├── android/               # Android-specific configuration
│   └── web/                   # Web-specific configuration
├── platform/                  # Platform-specific configurations
│   ├── ios/                   # iOS build configurations
│   ├── android/               # Android build configurations
│   └── web/                   # Web deployment configs
├── config/                    # Environment and configuration files
├── docs/                      # Documentation
│   ├── architecture/          # Architecture documentation
│   ├── deployment/            # Deployment guides
│   ├── firebase/              # Firebase setup guides
│   └── api/                   # API documentation
├── scripts/                   # Build and deployment scripts
├── .github/                   # GitHub workflows and templates
├── phase_progression/         # Development phase tracking
└── archive/                   # Archived files and iterations
```

---

## 💻 Technical Stack

ChekMate is built with modern, enterprise-grade technologies to ensure scalability, performance, and cross-platform compatibility.

### Frontend Framework

- **Flutter 3.0+** - Google's UI toolkit for building natively compiled applications
  - Single codebase for iOS, Android, and Web
  - Material Design 3 (Material You) support
  - Hot reload for rapid development
  - Native performance on all platforms

### Backend & Cloud Services

- **Firebase** - Google's comprehensive app development platform
  - **Firebase Authentication** - Secure user authentication and authorization
  - **Cloud Firestore** - NoSQL database for real-time data synchronization
  - **Firebase Storage** - Scalable cloud storage for media files
  - **Firebase Analytics** - User behavior tracking and insights
  - **Firebase Cloud Messaging** - Cross-platform push notifications
  - **Firebase Crashlytics** - Real-time crash reporting (planned)
  - **Firebase Performance Monitoring** - App performance metrics (planned)

### State Management

- **Riverpod 2.4+** - Robust, compile-safe state management
  - Provider-based architecture
  - Automatic dependency injection
  - Testing-friendly design
  - Code generation support

### Media & Content

- **Image Picker** - Camera and gallery access for photo/video uploads
- **Image Cropper** - Advanced image editing and cropping
- **Cached Network Image** - Efficient image loading and caching
- **Video Player** - Native video playback support
- **Lottie** - High-quality animations

### Location Services

- **Geolocator** - Precise location tracking and geofencing
- **Geocoding** - Address and place name resolution
- Location-based content discovery
- Privacy-first location sharing

### Networking & Storage

- **Dio** - Powerful HTTP client for API communication
- **Connectivity Plus** - Network connectivity monitoring
- **Shared Preferences** - Simple key-value storage
- **Hive** - Fast, lightweight NoSQL database for local storage

### UI & Animations

- **Shimmer** - Loading skeleton animations
- **Material Design 3** - Modern, adaptive UI components
- **Custom animations** - TikTok-style swipe gestures and transitions
- **Responsive design** - Adaptive layouts for all screen sizes

### Development Tools

- **Flutter Lints** - Recommended linting rules
- **Build Runner** - Code generation for Riverpod and other packages
- **Flutter Launcher Icons** - Automated app icon generation
- **DevTools** - Performance profiling and debugging

### CI/CD & Deployment

- **CodeMagic** - Automated builds and deployments
  - iOS TestFlight and App Store deployment
  - Android Google Play Store deployment
  - Web hosting deployment
- **GitHub Actions** - Automated testing and workflows
- **Environment-based builds** - Development, staging, production

---

## 🏛️ Architecture

ChekMate follows **Clean Architecture** principles with a feature-first organization for scalability and maintainability.

### Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                  Presentation Layer                      │
│  (Flutter Widgets, UI Components, Screens)              │
│  - Stateless/Stateful Widgets                           │
│  - Riverpod Providers for UI State                      │
│  - Navigation and Routing                               │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│               Business Logic Layer                       │
│  (Riverpod State Management, Use Cases)                 │
│  - State Providers and Notifiers                        │
│  - Business Rules and Validation                        │
│  - Feature-specific Logic                               │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                    Data Layer                            │
│  (Repositories, Data Sources, Models)                   │
│  - Repository Pattern                                   │
│  - Firebase Integration                                 │
│  - Local Storage (Hive, SharedPreferences)             │
│  - API Communication (Dio)                              │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                  Domain Layer                            │
│  (Entities, Business Models, Interfaces)                │
│  - Core Business Entities                               │
│  - Repository Interfaces                                │
│  - Domain-specific Logic                                │
└─────────────────────────────────────────────────────────┘
```

### Key Architectural Patterns

1. **Repository Pattern** - Abstraction layer for data access
2. **Provider Pattern** - Dependency injection and state management
3. **MVVM** - Model-View-ViewModel for UI separation
4. **Feature-First Organization** - Code organized by feature, not layer
5. **Dependency Inversion** - High-level modules don't depend on low-level modules

### Code Organization

```
lib/
├── core/                      # Core utilities and shared code
│   ├── constants/             # App-wide constants
│   ├── theme/                 # Theme and styling
│   ├── config/                # Configuration files
│   └── utils/                 # Utility functions
├── shared/                    # Shared UI components
│   ├── ui/
│   │   ├── components/        # Reusable UI components
│   │   ├── animations/        # Custom animations
│   │   └── loading/           # Loading states
│   └── widgets/               # Common widgets
├── features/                  # Feature modules (planned)
│   ├── auth/                  # Authentication feature
│   ├── posts/                 # Posts and content sharing
│   ├── ratings/               # Rate Your Date feature
│   ├── stories/               # Dating Stories feature
│   ├── discovery/             # Content discovery
│   └── profile/               # User profiles
└── main.dart                  # Application entry point
```

### Design Principles

- **Single Responsibility** - Each class has one reason to change
- **Open/Closed** - Open for extension, closed for modification
- **Liskov Substitution** - Subtypes must be substitutable for base types
- **Interface Segregation** - Many specific interfaces over one general interface
- **Dependency Inversion** - Depend on abstractions, not concretions

---

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0 or higher) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (included with Flutter)
- **Git** - [Install Git](https://git-scm.com/downloads)
- **IDE** - VS Code or Android Studio with Flutter plugins
- **Xcode** (macOS only, for iOS development) - [Install Xcode](https://developer.apple.com/xcode/)
- **Android Studio** (for Android development) - [Install Android Studio](https://developer.android.com/studio)
- **Node.js** (for web development) - [Install Node.js](https://nodejs.org/)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Isakainovorium/ChekMate.git
   cd ChekMate
   ```

2. **Navigate to the Flutter project**
   ```bash
   cd flutter_chekmate
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Verify Flutter installation**
   ```bash
   flutter doctor
   ```
   Fix any issues reported by Flutter Doctor before proceeding.

5. **Configure Firebase** (if not already configured)
   - Ensure `firebase_options.dart` exists in `lib/`
   - Verify Firebase configuration files:
     - iOS: `ios/Runner/GoogleService-Info.plist`
     - Android: `android/app/google-services.json`
     - Web: Firebase config in `web/index.html`

### Running the App

#### iOS (macOS only)

```bash
# Development build
flutter run --flavor development --target lib/main.dart

# Or simply
flutter run
```

#### Android

```bash
# Development build
flutter run --flavor development --target lib/main.dart

# Or simply
flutter run
```

#### Web

```bash
# Run in Chrome
flutter run -d chrome --target lib/main.dart

# Or simply
flutter run -d chrome
```

### First-Time Setup Checklist

- [ ] Flutter SDK installed and configured
- [ ] IDE with Flutter plugins installed
- [ ] Repository cloned successfully
- [ ] Dependencies installed (`flutter pub get`)
- [ ] `flutter doctor` shows no critical issues
- [ ] Firebase configuration files present
- [ ] App runs successfully on at least one platform

---

## 🏗️ Build & Deployment

ChekMate uses a multi-platform deployment strategy with automated CI/CD pipelines.

### Platform-Specific Builds

#### iOS (App Store)

**Development Build:**
```bash
flutter build ios --flavor development --target lib/main.dart
```

**Production Build:**
```bash
flutter build ios --release --flavor production --target lib/main.dart
```

**Requirements:**
- macOS with Xcode installed
- Apple Developer account ($99/year)
- Valid provisioning profiles and certificates
- App Store Connect API key configured

**Build Output:**
- `.ipa` file for App Store submission
- Located in `build/ios/iphoneos/`

#### Android (Google Play Store)

**Development APK:**
```bash
flutter build apk --flavor development --target lib/main.dart
```

**Production App Bundle (Recommended):**
```bash
flutter build appbundle --release --flavor production --target lib/main.dart
```

**Production APK:**
```bash
flutter build apk --release --flavor production --target lib/main.dart
```

**Requirements:**
- Android SDK and build tools
- Google Play Console account ($25 one-time fee)
- Signing key configured in `android/key.properties`
- Upload key and keystore files

**Build Output:**
- `.aab` (App Bundle) or `.apk` file
- Located in `build/app/outputs/`

#### Web (Progressive Web App)

**Development Build:**
```bash
flutter build web --target lib/main.dart
```

**Production Build:**
```bash
flutter build web --release --target lib/main.dart
```

**Requirements:**
- Web hosting service (Firebase Hosting, Netlify, Vercel, etc.)
- Domain name (optional)
- SSL certificate (usually provided by hosting)

**Build Output:**
- Static web files in `build/web/`
- Ready for deployment to any web server

### CI/CD with CodeMagic

ChekMate uses **CodeMagic** for automated builds, testing, and deployments across all platforms.

#### Automated Workflows

**iOS Workflow:**
- ✅ Automatic code signing with App Store Connect API
- ✅ Build and archive for TestFlight
- ✅ Automatic TestFlight deployment
- ✅ App Store submission (manual approval)
- ✅ Email notifications on build status

**Android Workflow:**
- ✅ Automatic signing with upload key
- ✅ Build App Bundle for Google Play
- ✅ Automatic Google Play Console deployment
- ✅ Internal testing track deployment
- ✅ Email notifications on build status

**Web Workflow:**
- ✅ Build optimized web bundle
- ✅ Deploy to Firebase Hosting
- ✅ Automatic cache invalidation
- ✅ Preview deployments for PRs

#### Configuration Files

- **CodeMagic:** `codemagic.yaml` - Main CI/CD configuration
- **GitHub Actions:** `.github/workflows/` - Additional automation
- **Build Scripts:** `scripts/` - Custom build and deployment scripts

#### Triggering Builds

**Automatic Triggers:**
- Push to `main` branch → Production deployment
- Push to `develop` branch → Staging deployment
- Pull requests → Preview builds
- Git tags → Release builds

**Manual Triggers:**
- CodeMagic dashboard → Start build
- GitHub Actions → Workflow dispatch

#### Environment Variables

Configure these in CodeMagic settings:

```bash
# Firebase
FIREBASE_PROJECT_ID=chekmate-a0423
FIREBASE_API_KEY=<your-api-key>

# Apple App Store Connect
APPLE_ISSUER_ID=<your-issuer-id>
APPLE_KEY_ID=<your-key-id>
APPLE_PRIVATE_KEY=<base64-encoded-p8-file>

# Google Play Console
GOOGLE_PLAY_SERVICE_ACCOUNT=<base64-encoded-json>

# Notification
NOTIFICATION_EMAIL=<your-email@example.com>
```

### Deployment Pipeline

```
┌─────────────┐
│   Commit    │
│   & Push    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   GitHub    │
│  Webhook    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  CodeMagic  │
│   Trigger   │
└──────┬──────┘
       │
       ├──────────────┬──────────────┬──────────────┐
       ▼              ▼              ▼              ▼
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│   iOS    │   │ Android  │   │   Web    │   │  Tests   │
│  Build   │   │  Build   │   │  Build   │   │   Run    │
└────┬─────┘   └────┬─────┘   └────┬─────┘   └────┬─────┘
     │              │              │              │
     ▼              ▼              ▼              ▼
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│TestFlight│   │Google Play│  │ Firebase │   │  Report  │
│  Deploy  │   │  Deploy  │   │ Hosting  │   │  Results │
└──────────┘   └──────────┘   └──────────┘   └──────────┘
```

### Release Process

1. **Version Bump**
   ```bash
   # Update version in pubspec.yaml
   version: 1.1.0+2  # Format: MAJOR.MINOR.PATCH+BUILD
   ```

2. **Update Changelog**
   ```bash
   # Add release notes to CHANGELOG.md
   ## [1.1.0] - 2025-01-15
   ### Added
   - New Rate Your Date feature
   ### Fixed
   - Performance improvements
   ```

3. **Create Git Tag**
   ```bash
   git tag -a v1.1.0 -m "Release version 1.1.0"
   git push origin v1.1.0
   ```

4. **Trigger Build**
   - CodeMagic automatically detects the tag
   - Builds are created for all platforms
   - Deployments proceed based on configuration

5. **Monitor Deployment**
   - Check CodeMagic dashboard for build status
   - Verify TestFlight/Google Play deployment
   - Test deployed builds on real devices

6. **Production Release**
   - iOS: Submit for App Store review from App Store Connect
   - Android: Promote from internal to production track
   - Web: Automatic deployment to production URL

---

## 🔧 Environment Configuration

ChekMate uses environment-based configuration for different deployment stages and sensitive credentials.

### Environment Files

**Development Environment:**
```bash
# config/.env.development
ENVIRONMENT=development
API_BASE_URL=https://dev-api.chekmate.com
ENABLE_LOGGING=true
ENABLE_ANALYTICS=false
```

**Staging Environment:**
```bash
# config/.env.staging
ENVIRONMENT=staging
API_BASE_URL=https://staging-api.chekmate.com
ENABLE_LOGGING=true
ENABLE_ANALYTICS=true
```

**Production Environment:**
```bash
# config/.env.production
ENVIRONMENT=production
API_BASE_URL=https://api.chekmate.com
ENABLE_LOGGING=false
ENABLE_ANALYTICS=true
```

### Firebase Configuration

**Current Firebase Project:**
- **Project ID:** `chekmate-a0423`
- **Storage Bucket:** `chekmate-a0423.firebasestorage.app`
- **Messaging Sender ID:** `209000668199`

**Configuration Files:**
- iOS: `ios/Runner/GoogleService-Info.plist`
- Android: `android/app/google-services.json`
- Web: Firebase config in `web/index.html`
- Flutter: `lib/firebase_options.dart` (auto-generated)

### Required Environment Variables

Configure these in CodeMagic or your local environment:

```bash
# Firebase Configuration
FIREBASE_PROJECT_ID=chekmate-a0423
FIREBASE_API_KEY=<your-firebase-api-key>
FIREBASE_STORAGE_BUCKET=chekmate-a0423.firebasestorage.app

# Apple App Store Connect (iOS Deployment)
APPLE_ISSUER_ID=<your-issuer-id>
APPLE_KEY_ID=<your-key-id>
APPLE_PRIVATE_KEY=<base64-encoded-p8-file>
APPLE_TEAM_ID=<your-team-id>

# Google Play Console (Android Deployment)
GOOGLE_PLAY_SERVICE_ACCOUNT=<base64-encoded-service-account-json>
ANDROID_KEYSTORE_PASSWORD=<your-keystore-password>
ANDROID_KEY_ALIAS=<your-key-alias>
ANDROID_KEY_PASSWORD=<your-key-password>

# Notification Settings
NOTIFICATION_EMAIL=<your-email@example.com>

# API Endpoints (Future)
API_BASE_URL=https://api.chekmate.com
WEBSOCKET_URL=wss://ws.chekmate.com

# Feature Flags (Optional)
ENABLE_LIVE_STREAMING=false
ENABLE_PREMIUM_FEATURES=false
ENABLE_ANALYTICS=true
```

### Security Best Practices

🔒 **Critical Security Rules:**

1. **Never commit sensitive files:**
   - ❌ API keys and secrets
   - ❌ Firebase configuration files with credentials
   - ❌ Signing certificates and keystores
   - ❌ `.env` files with real credentials
   - ✅ Use `.env.example` as template only

2. **Use environment variables:**
   - Store all secrets in CodeMagic environment variables
   - Use different credentials for dev/staging/production
   - Rotate credentials regularly

3. **Git Security:**
   - All sensitive files are in `.gitignore`
   - Use `git-secrets` to prevent accidental commits
   - Review commits before pushing

4. **Access Control:**
   - Limit Firebase project access to team members only
   - Use role-based access control (RBAC)
   - Enable 2FA on all accounts

5. **Monitoring:**
   - Enable Firebase Security Rules
   - Monitor for unauthorized access attempts
   - Set up alerts for suspicious activity

### Platform-Specific Configuration

#### iOS Configuration

**Info.plist Permissions:**
```xml
<!-- Camera Permission -->
<key>NSCameraUsageDescription</key>
<string>ChekMate needs camera access to share dating experiences through photos and videos</string>

<!-- Microphone Permission -->
<key>NSMicrophoneUsageDescription</key>
<string>ChekMate needs microphone access for voice messages and video content</string>

<!-- Photo Library Permission -->
<key>NSPhotoLibraryUsageDescription</key>
<string>ChekMate needs photo library access to share your dating experiences</string>

<!-- Location Permission -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>ChekMate uses your location to show local dating experiences and stories</string>

<!-- Notifications Permission -->
<key>UserNotificationsUsageDescription</key>
<string>ChekMate sends notifications for community updates and responses</string>
```

**Bundle Configuration:**
- **Bundle ID:** `com.chekmate.app`
- **Display Name:** ChekMate
- **Minimum iOS Version:** 12.0
- **Supported Devices:** iPhone, iPad

#### Android Configuration

**AndroidManifest.xml Permissions:**
```xml
<!-- Camera Permission -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- Storage Permission -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!-- Location Permission -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Internet Permission -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

**App Configuration:**
- **Application ID:** `com.chekmate.app`
- **App Name:** ChekMate
- **Minimum SDK:** 21 (Android 5.0)
- **Target SDK:** 34 (Android 14)

#### Web Configuration

**PWA Features:**
- Service Worker for offline support
- Web App Manifest for installability
- Push Notifications (via Firebase)
- Responsive design for all screen sizes

**Browser Support:**
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

---

## 📱 Platform-Specific Features

### iOS Features

✅ **Push Notifications (APNS)**
- Real-time community updates
- Rating notifications
- Message alerts
- Trending topic notifications

✅ **Face ID / Touch ID**
- Secure app access
- Privacy protection for sensitive content
- Quick authentication

✅ **App Store In-App Purchases** (Planned)
- Premium features
- Ad-free experience
- Exclusive content access

✅ **Universal Links**
- Deep linking to specific experiences
- Share links that open in app
- Seamless web-to-app transitions

✅ **iOS-Specific Optimizations**
- Native performance
- Smooth animations (120Hz ProMotion support)
- Haptic feedback
- Dark mode support

### Android Features

✅ **Push Notifications (FCM)**
- Real-time community updates
- Customizable notification channels
- Rich notifications with actions
- Notification grouping

✅ **Biometric Authentication**
- Fingerprint authentication
- Face unlock support
- Secure app access

✅ **Google Play In-App Purchases** (Planned)
- Premium subscriptions
- One-time purchases
- Promotional offers

✅ **Deep Links**
- App Links for verified domains
- Share links that open in app
- Intent filters for content sharing

✅ **Android-Specific Optimizations**
- Material Design 3 (Material You)
- Dynamic color theming
- Adaptive icons
- Edge-to-edge display support

### Web Features

✅ **Progressive Web App (PWA)**
- Install to home screen
- Offline functionality
- App-like experience
- Automatic updates

✅ **Push Notifications**
- Browser-based notifications
- Cross-platform support
- Opt-in notification system

✅ **Service Worker**
- Offline content caching
- Background sync
- Performance optimization

✅ **Responsive Design**
- Mobile-first approach
- Tablet optimization
- Desktop experience
- Adaptive layouts

✅ **Web-Specific Features**
- SEO optimization
- Social media sharing
- URL-based navigation
- Browser history support

---

## 🧪 Testing

ChekMate maintains high code quality through comprehensive testing strategies.

### Test Types

#### Unit Tests
Test individual functions, classes, and business logic in isolation.

```bash
# Run all unit tests
flutter test

# Run specific test file
flutter test test/core/utils/date_utils_test.dart

# Run tests with verbose output
flutter test --verbose
```

**Coverage:**
- Business logic validation
- Utility functions
- Data models and serialization
- State management providers

#### Widget Tests
Test UI components and widget behavior.

```bash
# Run widget tests
flutter test test/widgets/

# Run specific widget test
flutter test test/widgets/app_button_test.dart
```

**Coverage:**
- UI component rendering
- User interactions
- Widget state changes
- Layout and styling

#### Integration Tests
Test complete user flows and feature interactions.

```bash
# Run integration tests
flutter test integration_test/

# Run on specific device
flutter test integration_test/ -d <device-id>
```

**Coverage:**
- End-to-end user flows
- Feature integration
- Navigation flows
- API integration

### Code Coverage

Generate and view code coverage reports:

```bash
# Generate coverage report
flutter test --coverage

# View coverage in browser (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Coverage Goals:**
- Unit tests: 80%+ coverage
- Widget tests: 70%+ coverage
- Integration tests: Key user flows covered

### Testing Best Practices

1. **Write tests first** (TDD approach when possible)
2. **Test behavior, not implementation**
3. **Keep tests isolated and independent**
4. **Use meaningful test descriptions**
5. **Mock external dependencies**
6. **Test edge cases and error scenarios**

### Continuous Testing

Tests run automatically on:
- Every pull request
- Commits to `main` and `develop` branches
- Pre-deployment builds
- Scheduled nightly runs

---

## 📊 Monitoring & Analytics

ChekMate uses comprehensive monitoring to ensure app quality and understand user behavior.

### Firebase Analytics

**User Behavior Tracking:**
- Screen views and navigation patterns
- Feature usage and engagement
- User retention and churn
- Conversion funnels

**Custom Events:**
```dart
// Track dating experience shared
FirebaseAnalytics.instance.logEvent(
  name: 'experience_shared',
  parameters: {
    'rating_type': 'WOW',
    'has_media': true,
    'location_tagged': true,
  },
);

// Track Rate Your Date usage
FirebaseAnalytics.instance.logEvent(
  name: 'date_rated',
  parameters: {
    'rating': 'ChekMate',
    'experience_type': 'first_date',
  },
);
```

**User Properties:**
- User demographics
- Dating preferences
- Engagement level
- Premium status

### Crashlytics (Planned)

**Crash Reporting:**
- Real-time crash alerts
- Stack traces and device info
- Crash-free user percentage
- Crash clustering and prioritization

**Error Tracking:**
```dart
// Log non-fatal errors
FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'Failed to load user profile',
  fatal: false,
);
```

### Performance Monitoring (Planned)

**App Performance Metrics:**
- App startup time
- Screen rendering performance
- Network request latency
- Custom performance traces

**Custom Traces:**
```dart
// Track experience sharing performance
final trace = FirebasePerformance.instance.newTrace('share_experience');
await trace.start();
// ... perform operation
await trace.stop();
```

### Remote Config (Planned)

**Feature Flags:**
- Enable/disable features remotely
- A/B testing for new features
- Gradual feature rollouts
- Emergency kill switches

**Configuration Examples:**
```dart
// Feature flags
final enableLiveStreaming = remoteConfig.getBool('enable_live_streaming');
final maxMediaUploads = remoteConfig.getInt('max_media_uploads');
final ratingThreshold = remoteConfig.getDouble('rating_threshold');
```

### Monitoring Dashboard

**Key Metrics:**
- Daily Active Users (DAU)
- Monthly Active Users (MAU)
- User retention rates
- Experience sharing frequency
- Rating distribution (WOW/GTFOH/ChekMate)
- Crash-free sessions
- App performance scores

---

## 📚 Documentation

Comprehensive documentation is available in the `docs/` directory:

### Architecture Documentation
- [Architecture Overview](docs/architecture/README.md) - System design and patterns
- [Clean Architecture Guide](docs/architecture/clean_architecture.md) - Layer separation
- [State Management](docs/architecture/state_management.md) - Riverpod patterns

### Deployment Guides
- [iOS Deployment Guide](docs/deployment/ios.md) - App Store submission
- [Android Deployment Guide](docs/deployment/android.md) - Google Play deployment
- [Web Deployment Guide](docs/deployment/web.md) - PWA hosting
- [Deployment Status](docs/deployment/DEPLOYMENT_STATUS_SUMMARY.md) - Current status

### Firebase Documentation
- [Firebase Setup](docs/firebase/FIREBASE_SETUP_SUMMARY.md) - Initial configuration
- [Firebase Integration](docs/firebase/FIREBASE_INTEGRATION_CHECKLIST.md) - Feature integration
- [FlutterFire CLI](docs/firebase/FLUTTERFIRE_CLI_SETUP.md) - CLI setup guide

### CodeMagic CI/CD
- [CodeMagic Setup](docs/codemagic/CODEMAGIC_SETUP_GUIDE.md) - CI/CD configuration
- [Browser Setup](docs/codemagic/BROWSER_SETUP_STEPS.md) - Web deployment

### Development Guides
- [iOS Pre-Build Checklist](flutter_chekmate/docs/IOS_PRE_BUILD_CHECKLIST.md) - iOS preparation
- [Component Fix Plan](flutter_chekmate/docs/COMPONENT_FIX_PLAN.md) - UI components
- [Phase Tracker](flutter_chekmate/docs/PHASE_TRACKER.md) - Development phases

### API Documentation
- [API Reference](docs/api/README.md) - API endpoints and usage
- [Firebase API](docs/api/firebase.md) - Firebase integration details

---

## 🤝 Contributing

We welcome contributions from the community! ChekMate is built on the principle of shared experiences, and that extends to our development process.

### How to Contribute

1. **Fork the Repository**
   ```bash
   # Click "Fork" on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/ChekMate.git
   cd ChekMate
   ```

2. **Create a Feature Branch**
   ```bash
   # Create a branch for your feature or fix
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

3. **Make Your Changes**
   - Write clean, documented code
   - Follow existing code style and conventions
   - Add tests for new features
   - Update documentation as needed

4. **Test Your Changes**
   ```bash
   # Run tests
   flutter test

   # Check code formatting
   flutter format .

   # Run static analysis
   flutter analyze
   ```

5. **Commit Your Changes**
   ```bash
   # Use conventional commit messages
   git commit -m "feat: add new rating animation"
   git commit -m "fix: resolve image upload issue"
   git commit -m "docs: update README with new features"
   ```

6. **Push to Your Fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Submit a Pull Request**
   - Go to the original ChekMate repository
   - Click "New Pull Request"
   - Select your fork and branch
   - Provide a clear description of your changes
   - Link any related issues

### Contribution Guidelines

#### Code Style

- **Dart Style Guide**: Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- **Formatting**: Use `flutter format .` before committing
- **Linting**: Fix all issues from `flutter analyze`
- **Naming**: Use descriptive, meaningful names

#### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new feature
fix: bug fix
docs: documentation changes
style: formatting, missing semicolons, etc.
refactor: code restructuring
test: adding tests
chore: maintenance tasks
```

#### Pull Request Guidelines

- **One feature per PR**: Keep PRs focused and manageable
- **Clear description**: Explain what, why, and how
- **Link issues**: Reference related issues with `Fixes #123`
- **Add tests**: Include tests for new features
- **Update docs**: Update relevant documentation
- **Screenshots**: Include UI changes screenshots

#### Code Review Process

1. **Automated Checks**: CI/CD runs tests and linting
2. **Peer Review**: At least one maintainer reviews code
3. **Feedback**: Address review comments
4. **Approval**: Maintainer approves PR
5. **Merge**: PR is merged to `main` branch

### Areas for Contribution

We especially welcome contributions in these areas:

🎨 **UI/UX Improvements**
- New animations and transitions
- Accessibility enhancements
- Dark mode refinements
- Responsive design improvements

🐛 **Bug Fixes**
- Performance optimizations
- Memory leak fixes
- Edge case handling
- Cross-platform compatibility

📚 **Documentation**
- Code documentation
- User guides
- API documentation
- Tutorial content

✨ **New Features**
- Community-requested features
- Platform-specific enhancements
- Integration with new services
- Experimental features

🧪 **Testing**
- Unit test coverage
- Widget tests
- Integration tests
- Performance tests

### Community Guidelines

- **Be respectful**: Treat everyone with respect and kindness
- **Be constructive**: Provide helpful, actionable feedback
- **Be patient**: Maintainers are volunteers with limited time
- **Be collaborative**: Work together to improve ChekMate
- **Follow the Code of Conduct**: See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)

### Getting Help

- **Questions**: Open a [GitHub Discussion](https://github.com/Isakainovorium/ChekMate/discussions)
- **Bugs**: Create a [GitHub Issue](https://github.com/Isakainovorium/ChekMate/issues)
- **Security**: Email security@chekmate.com (do not open public issues)

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

### What This Means

✅ **You can:**
- Use ChekMate for personal or commercial projects
- Modify the source code
- Distribute the software
- Sublicense the software

❌ **You cannot:**
- Hold the authors liable for damages
- Use the ChekMate name or trademarks without permission

📋 **You must:**
- Include the original license and copyright notice
- State significant changes made to the code

---

## 🆘 Support

Need help with ChekMate? We're here to support you!

### For Users

**App Issues:**
- Report bugs via [GitHub Issues](https://github.com/Isakainovorium/ChekMate/issues)
- Check [FAQ](docs/FAQ.md) for common questions
- Review [Troubleshooting Guide](docs/troubleshooting/README.md)

**Feature Requests:**
- Submit ideas via [GitHub Discussions](https://github.com/Isakainovorium/ChekMate/discussions)
- Vote on existing feature requests
- Participate in community polls

**Community Support:**
- Join our [Discord Server](https://discord.gg/chekmate) (coming soon)
- Follow us on social media for updates
- Participate in community events

### For Developers

**Technical Support:**
- [GitHub Issues](https://github.com/Isakainovorium/ChekMate/issues) - Bug reports and technical issues
- [GitHub Discussions](https://github.com/Isakainovorium/ChekMate/discussions) - Questions and discussions
- [Documentation](docs/) - Comprehensive guides and references

**Development Resources:**
- [Architecture Guide](docs/architecture/README.md) - System design
- [Contributing Guide](#-contributing) - How to contribute
- [API Documentation](docs/api/README.md) - API reference

**Common Issues:**

<details>
<summary><b>Build Failures</b></summary>

1. Run `flutter clean`
2. Delete `pubspec.lock`
3. Run `flutter pub get`
4. Rebuild the app

If issues persist, check [Build Troubleshooting](docs/troubleshooting/build_issues.md)
</details>

<details>
<summary><b>Firebase Configuration Issues</b></summary>

1. Verify `firebase_options.dart` exists
2. Check platform-specific config files
3. Ensure Firebase project is properly set up
4. Review [Firebase Setup Guide](docs/firebase/FIREBASE_SETUP_SUMMARY.md)
</details>

<details>
<summary><b>iOS Build Issues</b></summary>

1. Update CocoaPods: `pod repo update`
2. Clean iOS build: `cd ios && pod deintegrate && pod install`
3. Check Xcode version compatibility
4. Review [iOS Deployment Guide](docs/deployment/ios.md)
</details>

<details>
<summary><b>Android Build Issues</b></summary>

1. Clean Gradle cache: `cd android && ./gradlew clean`
2. Invalidate caches in Android Studio
3. Check Android SDK and build tools versions
4. Review [Android Deployment Guide](docs/deployment/android.md)
</details>

---

## 📞 Contact

### Project Team

**Project Maintainer:**
GitHub: [@Isakainovorium](https://github.com/Isakainovorium)

**Repository:**
[https://github.com/Isakainovorium/ChekMate](https://github.com/Isakainovorium/ChekMate)

### Communication Channels

**GitHub:**
- [Issues](https://github.com/Isakainovorium/ChekMate/issues) - Bug reports and feature requests
- [Discussions](https://github.com/Isakainovorium/ChekMate/discussions) - Community discussions
- [Pull Requests](https://github.com/Isakainovorium/ChekMate/pulls) - Code contributions

**Social Media:** (Coming Soon)
- Twitter: [@ChekMateApp](https://twitter.com/ChekMateApp)
- Instagram: [@ChekMateApp](https://instagram.com/ChekMateApp)
- Discord: [Join our Discord](https://discord.gg/chekmate)

**Email:**
- General Inquiries: hello@chekmate.com
- Security Issues: security@chekmate.com
- Press & Media: press@chekmate.com

---

## 🙏 Acknowledgments

ChekMate is built with amazing open-source technologies:

- **Flutter Team** - For the incredible Flutter framework
- **Firebase Team** - For comprehensive backend services
- **Riverpod Community** - For excellent state management
- **Open Source Contributors** - For all the packages we use

Special thanks to everyone who has contributed to making ChekMate a reality!

---

## 🗺️ Roadmap

### Current Phase: Foundation (v1.0)

✅ **Completed:**
- Core app architecture
- Firebase integration
- Basic UI components
- Authentication system
- Multi-platform support

🚧 **In Progress:**
- Rate Your Date feature
- Experience sharing functionality
- User profiles
- Content discovery feed

### Phase 2: Community Features (v1.1)

📋 **Planned:**
- Dating Stories (24-hour stories)
- Community discussions and messaging
- Location-based discovery
- Enhanced user profiles
- Notification system

### Phase 3: Engagement & Growth (v1.2)

📋 **Planned:**
- Live dating discussions
- Advanced content discovery algorithm
- Community moderation tools
- User reputation system
- Premium features

### Phase 4: Scale & Optimize (v2.0)

📋 **Future:**
- Performance optimizations
- Advanced analytics
- Machine learning recommendations
- International expansion
- Platform-specific features

---

<div align="center">

## 💝 Built with Love for the Dating Community

**ChekMate** - *Dating can be a Game - Don't Get Played*

[⭐ Star us on GitHub](https://github.com/Isakainovorium/ChekMate) • [🐛 Report Bug](https://github.com/Isakainovorium/ChekMate/issues) • [💡 Request Feature](https://github.com/Isakainovorium/ChekMate/discussions)

---

© 2025 ChekMate. All rights reserved.

</div>

