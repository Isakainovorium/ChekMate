# ChekMate Flutter App - Code Structure

> **"Dating can be a Game - Don't Get Played"**
> 
> The world's first Dating Experience Sharing Platform

---

## 📁 Directory Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Main app widget with MaterialApp
├── firebase_options.dart        # Firebase configuration
│
├── core/                        # Core functionality
│   ├── index.dart               # Barrel export for core
│   ├── config/                  # Environment configuration
│   ├── constants/               # App-wide constants
│   ├── domain/                  # Core domain entities
│   ├── models/                  # Core data models
│   ├── navigation/              # Navigation state & widgets
│   ├── providers/               # Core Riverpod providers
│   ├── router/                  # GoRouter configuration
│   ├── services/                # Core services (auth, FCM, etc.)
│   │   ├── index.dart           # Barrel export for services
│   │   └── cultural/            # Cultural intelligence services
│   ├── theme/                   # App theming (colors, spacing, etc.)
│   └── utils/                   # Utility functions
│
├── features/                    # Feature modules (Clean Architecture)
│   ├── index.dart               # Barrel export for features
│   ├── auth/                    # Authentication feature
│   ├── cultural/                # Cultural identity feature
│   ├── explore/                 # Explore/discover feature
│   ├── feed/                    # Main feed feature
│   ├── intelligence/            # Smart content intelligence
│   ├── messages/                # Messaging feature
│   ├── notifications/           # Notifications feature
│   ├── onboarding/              # Onboarding flow
│   ├── posts/                   # Posts feature
│   ├── profile/                 # User profile feature
│   ├── safety/                  # Safety features
│   ├── search/                  # Search feature
│   ├── stories/                 # Stories feature
│   ├── templates/               # Story templates feature
│   ├── voice_messages/          # Voice messages feature
│   └── wisdom/                  # Wisdom score feature
│
├── pages/                       # Page-level widgets
│   ├── create_post/             # Post creation page
│   ├── explore/                 # Explore page
│   ├── home/                    # Home page with feed
│   ├── live/                    # Live streaming page
│   ├── messages/                # Messages list & chat
│   ├── notifications/           # Notifications page
│   ├── onboarding/              # Onboarding screens
│   ├── profile/                 # Profile pages
│   ├── settings/                # Settings pages
│   └── subscribe/               # Subscription page
│
├── shared/                      # Shared components
│   ├── ui/                      # UI components
│   │   ├── index.dart           # Barrel export for UI
│   │   ├── accessibility/       # Accessibility wrappers
│   │   ├── animations/          # Animation components
│   │   ├── components/          # 70+ reusable components
│   │   ├── layouts/             # Layout components
│   │   ├── loading/             # Loading & shimmer states
│   │   └── premium/             # Premium UI components
│   ├── utils/                   # Shared utilities
│   └── widgets/                 # Shared widgets
│
├── widgetbook/                  # Component library
│   ├── showcases/               # Component showcases
│   └── widgetbook.dart          # Widgetbook entry point
│
└── scripts/                     # Utility scripts
```

---

## 🏗️ Architecture

### Clean Architecture Layers

Each feature follows Clean Architecture:

```
feature/
├── data/                        # Data layer
│   ├── datasources/             # Remote & local data sources
│   ├── models/                  # Data transfer objects
│   └── repositories/            # Repository implementations
├── domain/                      # Domain layer
│   ├── entities/                # Business entities
│   ├── repositories/            # Repository interfaces
│   └── usecases/                # Business logic use cases
└── presentation/                # Presentation layer
    ├── providers/               # Riverpod providers
    ├── pages/                   # Feature pages
    └── widgets/                 # Feature widgets
```

### State Management

- **Riverpod** for global state management
- **StateNotifier** for complex state logic
- **Provider** for dependency injection

### Navigation

- **GoRouter** for declarative routing
- **ShellRoute** for persistent bottom navigation
- **Deep linking** support

---

## 🎨 Brand Identity

### Colors (Matched to Logo)

| Role | Color | Hex |
|------|-------|-----|
| **Primary Gold** | 🟡 | `#F5B041` |
| **Primary Dark** | 🟠 | `#D4941C` |
| **Secondary Navy** | 🔵 | `#1E3A5F` |
| **Headlines** | 🔵 | `#1E3A5F` |

### Typography

- **Font**: Inter (Google Fonts)
- **Headlines**: Navy Blue, Bold
- **Body**: Gray `#374151`

### Chess Theme

- **King (♔)**: Male users - Navy gradient
- **Queen (♕)**: Female/other users - Gold gradient
- **Chek Badge**: Gold checkmark with glow

---

## 🚀 Key Features

### Core Features
1. **Rate Your Date** - WOW 🎉 / GTFOH 🚫 / ChekMate ♟️
2. **Dating Stories** - 24-hour ephemeral content
3. **Local Discovery** - Location-based dating scene
4. **Community Discussions** - Messaging and support
5. **Live Dating Discussions** - Real-time Q&A

### Intelligence Features
- **Hybrid Feed Algorithm** - 60% local + 40% interests
- **Serendipity Mode** - Diverse content discovery
- **Reading Pattern Analysis** - Personalized insights
- **Contextual Follow Suggestions** - Smart recommendations

### Cultural Features
- **Free-form Cultural Profiles** - No predefined dropdowns
- **ML Pattern Discovery** - Emergent cultural clusters
- **Cultural Matching** - Similarity-based connections

---

## 📦 Imports

### Recommended Barrel Imports

```dart
// Core functionality
import 'package:flutter_chekmate/core/index.dart';

// Core services
import 'package:flutter_chekmate/core/services/index.dart';

// Shared UI components
import 'package:flutter_chekmate/shared/ui/index.dart';

// Feature exports
import 'package:flutter_chekmate/features/index.dart';
```

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/path/to/test.dart
```

---

## 📚 Documentation

- **[README.md](../../README.md)** - Project overview
- **[docs/UI_UX_SPRINT_CHECKLIST.md](../../docs/UI_UX_SPRINT_CHECKLIST.md)** - UI/UX tasks
- **[docs/COMPONENTS_GUIDE.md](../../docs/COMPONENTS_GUIDE.md)** - Component reference
- **[phase_progression/README.md](../../phase_progression/README.md)** - Phase roadmap

---

*Last Updated: November 28, 2025*
