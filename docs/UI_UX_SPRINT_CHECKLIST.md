# ChekMate UI/UX Quality Sprint Checklist

> **Assessment Date:** November 28, 2025  
> **Target:** Industry-grade release readiness  
> **Estimated Duration:** 3 Sprints (15 working days)

---

## Quick Navigation

- [Sprint 1: Critical Fixes](#sprint-1-critical-fixes-5-days)
- [Sprint 2: Major Usability](#sprint-2-major-usability-fixes-5-days)
- [Sprint 3: Polish & Performance](#sprint-3-polish--performance-5-days)
- [File Reference](#file-reference)
- [Testing Commands](#testing-commands)

---

## Progress Overview

| Sprint | Status | Progress |
|--------|--------|----------|
| Sprint 1: Critical Fixes | 🟢 Complete | 12/12 |
| Sprint 2: Major Usability | 🟢 Complete | 10/10 |
| Sprint 3: Polish & Performance | 🟢 Complete | 10/10 |

**Overall Progress:** 32/32 tasks complete ✅

---

## Sprint 1: Critical Fixes (5 Days)

### 1.1 Semantic Accessibility Implementation
**Priority:** P0 - Legal/Compliance Blocker  
**Effort:** 3-4 days

#### Create Accessibility Foundation
- [x] **1.1.1** Create `lib/shared/ui/accessibility/semantic_wrappers.dart`
  ```dart
  // SemanticAction - wrapper for interactive elements
  // SemanticLabel - wrapper for informational elements
  // SemanticRegion - wrapper for screen regions
  ```

- [x] **1.1.2** Update `lib/shared/ui/components/app_button.dart`
  - Add `semanticLabel` parameter
  - Add `semanticHint` parameter
  - Wrap button with `Semantics` widget

#### Apply Semantics to Core Components
- [x] **1.1.3** Update `lib/features/feed/widgets/post_widget.dart`
  - [x] Like button: `"Like post"` / `"Unlike post"`
  - [x] Comment button: `"View comments"`
  - [x] Share button: `"Share post"`
  - [x] Chek button: `"Chek this post"` / `"Remove chek"`
  - [x] Bookmark button: `"Save post"` / `"Remove from saved"`
  - [x] Post card: Add `Semantics` container with post summary

- [x] **1.1.4** Update `lib/shared/ui/components/app_avatar.dart`
  - Add semantic label with user name
  - Mark decorative avatars with `excludeSemantics: true`

- [x] **1.1.5** Update `lib/core/navigation/main_navigation.dart`
  - Add tab selection semantics
  - Add navigation region semantics

- [x] **1.1.6** Update `lib/features/feed/pages/feed_page.dart`
  - Add list semantics to post list
  - Add scroll region semantics

#### Verification
- [x] **1.1.7** Test with VoiceOver (iOS) or TalkBack (Android)
- [x] **1.1.8** Verify all interactive elements are announced

---

### 1.2 Notifications Page Implementation
**Priority:** P0 - Core Feature Missing  
**Effort:** 2-3 days

#### Create Domain Layer
- [x] **1.2.1** Create `lib/features/notifications/domain/entities/notification_entity.dart`
  ```dart
  enum NotificationType { like, comment, rating, follow, mention, safety }
  
  class NotificationEntity {
    final String id;
    final NotificationType type;
    final String title;
    final String body;
    final String? actorId;
    final String? actorName;
    final String? actorAvatar;
    final String? targetId;
    final DateTime timestamp;
    final bool isRead;
  }
  ```

#### Create Data Layer
- [x] **1.2.2** Create `lib/features/notifications/data/repositories/notifications_repository.dart`

#### Create Presentation Layer
- [x] **1.2.3** Create `lib/features/notifications/presentation/providers/notifications_providers.dart`
  ```dart
  final notificationsStreamProvider = StreamProvider.family<List<NotificationEntity>, String>
  final unreadCountProvider = Provider<int>
  ```

- [x] **1.2.4** Replace stub in `lib/pages/notifications/notifications_page.dart`
  - AppBar with filter actions
  - Filter tabs (All, Mentions, Ratings, Safety)
  - Notifications list with shimmer loading
  - Empty state handling
  - Pull-to-refresh

- [x] **1.2.5** Create `lib/pages/notifications/widgets/notification_tile.dart`
  - Avatar with HeroAvatar
  - Rich content with @mentions
  - Timestamp formatting
  - Read/unread visual state
  - Safety alerts with distinct styling

#### Verification
- [x] **1.2.6** Test loading states
- [x] **1.2.7** Test empty states
- [x] **1.2.8** Test real-time updates

---

### 1.3 Dark Theme Completion
**Priority:** P0 - Promised Feature Broken  
**Effort:** 1-2 days

- [x] **1.3.1** Update `lib/core/theme/app_theme.dart` - Add to `darkTheme`:
  - [x] `appBarTheme`
  - [x] `cardTheme`
  - [x] `inputDecorationTheme`
  - [x] `elevatedButtonTheme`
  - [x] `textButtonTheme`
  - [x] `outlinedButtonTheme`
  - [x] `iconTheme`
  - [x] `dividerTheme`
  - [x] `bottomNavigationBarTheme`
  - [x] `floatingActionButtonTheme`
  - [x] `snackBarTheme`
  - [x] `dialogTheme`
  - [x] `bottomSheetTheme`
  - [x] `chipTheme`

- [x] **1.3.2** Verify contrast ratios in `lib/core/theme/app_colors.dart`
  - Text on background: minimum 4.5:1
  - Large text on background: minimum 3:1

#### Verification
- [x] **1.3.3** Toggle dark mode and verify all screens
- [x] **1.3.4** Run Widgetbook in dark mode

---

### 1.4 Text Scaling Fix
**Priority:** P1 - Accessibility  
**Effort:** 1 day

- [x] **1.4.1** Update `lib/app.dart`
  ```dart
  // Change from:
  maxScaleFactor: 1.2
  // To:
  maxScaleFactor: 2.0
  ```

- [x] **1.4.2** Audit and fix overflow issues:
  - [x] `lib/features/feed/widgets/post_widget.dart` - username row
  - [x] `lib/shared/ui/components/app_button.dart` - button text
  - [x] `lib/core/navigation/main_navigation.dart` - nav labels
  - [x] `lib/pages/home/home_page.dart` - tab labels

#### Verification
- [x] **1.4.3** Test with 200% text scaling on device
- [x] **1.4.4** Verify no text clipping or overflow

---

## Sprint 2: Major Usability Fixes (5 Days)

### 2.1 Theme-Aware Background Colors
**Priority:** P1 - Dark Mode Broken  
**Effort:** 0.5 days

- [x] **2.1.1** Create theme extension in `lib/core/theme/app_theme.dart`
  ```dart
  extension AppThemeColors on ThemeData {
    Color get surfaceBackground => 
      brightness == Brightness.dark 
        ? AppColors.surfaceDark 
        : const Color(0xFFFAFAFA);
  }
  ```

- [x] **2.1.2** Replace hardcoded colors:
  - [x] `lib/pages/home/home_page.dart` line 187
  - [x] `lib/pages/profile/my_profile_page.dart` line 41
  - [x] `lib/pages/messages/messages_page.dart` line 29
  - [x] `lib/features/feed/pages/feed_page.dart`

#### Verification
- [x] **2.1.3** Toggle dark mode and verify backgrounds

---

### 2.2 Optimistic Update Error Handling
**Priority:** P1 - Data Integrity  
**Effort:** 1-2 days

- [x] **2.2.1** Create `lib/shared/utils/optimistic_action.dart`
  ```dart
  class OptimisticAction<T> {
    Future<void> execute({
      required T currentValue,
      required T optimisticValue,
      required Future<T> Function() action,
      required void Function(T) onUpdate,
      required void Function(Object error, T rollback) onError,
    });
  }
  ```

- [x] **2.2.2** Update `lib/features/feed/widgets/post_widget.dart`
  - [x] `_handleLike()` - Add error handling with rollback
  - [x] `_handleChek()` - Add error handling with rollback
  - [x] `_handleBookmark()` - Add error handling with rollback

- [x] **2.2.3** Add user feedback on failure
  - Show SnackBar with error message
  - Provide retry option

#### Verification
- [x] **2.2.4** Test with network disabled
- [x] **2.2.5** Verify rollback works correctly

---

### 2.3 Image Error Fallbacks
**Priority:** P2 - Polish  
**Effort:** 1 day

- [x] **2.3.1** Create `lib/shared/ui/components/app_network_image.dart` (already exists)
  ```dart
  class AppNetworkImage extends StatelessWidget {
    final String url;
    final BoxFit fit;
    final Widget? placeholder;
    final Widget? errorWidget;
    final double? width;
    final double? height;
    final BorderRadius? borderRadius;
  }
  ```

- [x] **2.3.2** Update files to use `AppNetworkImage`:
  - [x] `lib/pages/profile/my_profile_page.dart` - video thumbnails
  - [x] `lib/features/feed/widgets/post_widget.dart` - post images
  - [x] `lib/shared/ui/components/app_avatar.dart` - avatar images

#### Verification
- [x] **2.3.3** Test with invalid image URLs
- [x] **2.3.4** Verify placeholder and error states display

---

### 2.4 Navigation State Consolidation
**Priority:** P2 - Maintainability  
**Effort:** 1 day

- [x] **2.4.1** Audit navigation state in:
  - `lib/core/navigation/nav_state.dart`
  - `lib/core/navigation/main_navigation.dart`
  - `lib/pages/home/home_page.dart`

- [x] **2.4.2** Remove duplicate state management from `HomePage`
  - Use `ref.watch(topNavTabProvider)` instead of local state
  - Remove `_currentTabIndex` local variable

- [x] **2.4.3** Ensure single source of truth for:
  - [x] Bottom navigation tab
  - [x] Top navigation tab
  - [x] Page view index

#### Verification
- [x] **2.4.4** Test navigation from all entry points
- [x] **2.4.5** Verify state persists correctly

---

### 2.5 Consistent Button Styling
**Priority:** P2 - Design System  
**Effort:** 0.5 days

- [x] **2.5.1** Find and replace direct `ElevatedButton` usage:
  ```bash
  grep -r "ElevatedButton(" lib/pages/
  ```

- [x] **2.5.2** Replace with `AppButton`:
  - [x] `lib/pages/home/home_page.dart` lines 347-358

#### Verification
- [x] **2.5.3** Verify button styling is consistent across app

---

## Sprint 3: Polish & Performance (5 Days)

### 3.1 Animation Timing Standardization
**Priority:** P3 - Polish  
**Effort:** 1 day

- [x] **3.1.1** Create `lib/core/theme/app_animations.dart` (already exists)
  ```dart
  class AppAnimations {
    // Durations
    static const Duration instant = Duration(milliseconds: 100);
    static const Duration fast = Duration(milliseconds: 200);
    static const Duration medium = Duration(milliseconds: 300);
    static const Duration slow = Duration(milliseconds: 400);
    static const Duration emphasis = Duration(milliseconds: 500);
    
    // Curves
    static const Curve standard = Curves.easeInOut;
    static const Curve decelerate = Curves.easeOut;
    static const Curve accelerate = Curves.easeIn;
    
    // Semantic aliases
    static const Duration pageTransition = medium;
    static const Duration microInteraction = fast;
    static const Duration tabSwipe = medium;
  }
  ```

- [x] **3.1.2** Update animation durations:
  - [x] `lib/shared/ui/animations/page_transitions.dart`
  - [x] `lib/features/feed/widgets/post_widget.dart`
  - [x] `lib/pages/home/home_page.dart`

#### Verification
- [x] **3.1.3** Verify animations feel consistent

---

### 3.2 Tooltips for Icon Buttons
**Priority:** P3 - Accessibility  
**Effort:** 0.5 days

- [x] **3.2.1** Update `lib/shared/ui/components/app_button.dart` (completed in Sprint 1)
  - Add `tooltip` parameter
  - Wrap with `Tooltip` widget when provided

- [x] **3.2.2** Add tooltips to icon-only buttons:
  - [x] `lib/pages/profile/my_profile_page.dart` - Notifications, Share, Settings
  - [x] `lib/features/feed/widgets/post_widget.dart` - All action buttons
  - [x] `lib/pages/messages/messages_page.dart` - New message button

#### Verification
- [x] **3.2.3** Long-press icon buttons to verify tooltips

---

### 3.3 Haptic Feedback Web Fallback
**Priority:** P3 - Polish  
**Effort:** 0.5 days

- [x] **3.3.1** Create `lib/shared/utils/haptic_feedback.dart` (already exists)
  ```dart
  class AppHaptics {
    static Future<void> light() async {
      if (kIsWeb) {
        // Visual feedback fallback for web
        return;
      }
      try {
        await HapticFeedback.lightImpact();
      } catch (_) {
        // Silently fail
      }
    }
  }
  ```

- [x] **3.3.2** Replace direct `HapticFeedback` calls with `AppHaptics`

#### Verification
- [x] **3.3.3** Test on web - no errors in console

---

### 3.4 Tablet-Optimized Layouts
**Priority:** P3 - Future-proofing  
**Effort:** 2-3 days

- [x] **3.4.1** Create tablet layout for Feed
  - [x] 2-column grid on tablet
  - [x] Use `ResponsiveBuilder` widget

- [x] **3.4.2** Create tablet layout for Messages
  - [x] Master-detail layout
  - [x] Conversation list + chat side by side

- [x] **3.4.3** Create tablet layout for Profile
  - [x] Wider content area
  - [x] Stats in sidebar

#### Verification
- [x] **3.4.4** Test on iPad simulator
- [x] **3.4.5** Test on Android tablet emulator

---

### 3.5 Telemetry Hooks
**Priority:** P3 - Monitoring  
**Effort:** 1-2 days

- [x] **3.5.1** Create `lib/core/services/telemetry_service.dart` (already exists)
  ```dart
  class TelemetryService {
    void trackScreenRender(String screen, Duration renderTime);
    void trackInteractionLatency(String action, Duration latency);
    void trackFrameDrop(int droppedFrames);
    void trackError(String context, Object error);
  }
  ```

- [x] **3.5.2** Add screen render tracking to key screens:
  - [x] `HomePage`
  - [x] `FeedPage`
  - [x] `MyProfilePage`

- [x] **3.5.3** Add interaction tracking to:
  - [x] Like action
  - [x] Post creation
  - [x] Navigation

#### Verification
- [x] **3.5.4** Verify events appear in Firebase Analytics

---

## File Reference

### Files to Create
```
lib/
├── shared/
│   ├── ui/
│   │   ├── accessibility/
│   │   │   └── semantic_wrappers.dart          # 1.1.1
│   │   └── components/
│   │       └── app_network_image.dart          # 2.3.1
│   └── utils/
│       ├── optimistic_action.dart              # 2.2.1
│       └── haptic_feedback.dart                # 3.3.1
├── features/
│   └── notifications/
│       ├── domain/
│       │   └── entities/
│       │       └── notification_entity.dart    # 1.2.1
│       ├── data/
│       │   └── repositories/
│       │       └── notifications_repository.dart # 1.2.2
│       └── presentation/
│           └── providers/
│               └── notifications_providers.dart # 1.2.3
├── pages/
│   └── notifications/
│       └── widgets/
│           └── notification_tile.dart          # 1.2.5
└── core/
    ├── theme/
    │   └── app_animations.dart                 # 3.1.1
    └── services/
        └── telemetry_service.dart              # 3.5.1
```

### Files to Modify
```
lib/
├── app.dart                                    # 1.4.1
├── core/
│   ├── theme/
│   │   ├── app_theme.dart                      # 1.3.1, 2.1.1
│   │   └── app_colors.dart                     # 1.3.2
│   └── navigation/
│       └── main_navigation.dart                # 1.1.5, 2.4.2
├── shared/
│   └── ui/
│       └── components/
│           ├── app_button.dart                 # 1.1.2, 3.2.1
│           └── app_avatar.dart                 # 1.1.4, 2.3.2
├── features/
│   └── feed/
│       ├── pages/
│       │   └── feed_page.dart                  # 1.1.6, 2.1.2
│       └── widgets/
│           └── post_widget.dart                # 1.1.3, 1.4.2, 2.2.2, 2.3.2, 3.2.2
├── pages/
│   ├── home/
│   │   └── home_page.dart                      # 1.4.2, 2.1.2, 2.4.2, 2.5.2
│   ├── profile/
│   │   └── my_profile_page.dart                # 2.1.2, 2.3.2, 3.2.2
│   ├── messages/
│   │   └── messages_page.dart                  # 2.1.2, 3.2.2
│   └── notifications/
│       └── notifications_page.dart             # 1.2.4 (replace)
```

---

## Testing Commands

### Run All Tests
```bash
cd flutter_chekmate
flutter test
```

### Run Specific Test File
```bash
flutter test test/shared/ui/components/app_button_test.dart
```

### Check Code Formatting
```bash
flutter format --set-exit-if-changed lib/
```

### Run Static Analysis
```bash
flutter analyze
```

### Test Accessibility (Manual)
```bash
# iOS Simulator with VoiceOver
# Settings > Accessibility > VoiceOver > On

# Android Emulator with TalkBack
# Settings > Accessibility > TalkBack > On
```

### Test Dark Mode
```bash
# Run app and toggle system dark mode
flutter run

# Or run Widgetbook with theme toggle
flutter run -t lib/widgetbook.dart
```

### Test Text Scaling
```bash
# iOS: Settings > Accessibility > Display & Text Size > Larger Text
# Android: Settings > Accessibility > Font size
```

### Generate Coverage Report
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Definition of Done

### Per Task
- [ ] Code implemented
- [ ] Code formatted (`flutter format`)
- [ ] Static analysis passes (`flutter analyze`)
- [ ] Manual testing completed
- [ ] Dark mode verified (if UI change)
- [ ] Accessibility verified (if interactive element)

### Per Sprint
- [ ] All tasks completed
- [ ] All tests passing
- [ ] No new lint warnings
- [ ] Code reviewed
- [ ] Documentation updated

### Release Ready
- [ ] All 3 sprints completed
- [ ] Full app walkthrough in light mode
- [ ] Full app walkthrough in dark mode
- [ ] Accessibility audit with screen reader
- [ ] Performance profiling completed
- [ ] Stakeholder demo approved

---

## Notes

### Sprint 1 Focus
The critical items in Sprint 1 are **legal and compliance blockers**. Semantic accessibility is required for app store compliance and legal accessibility requirements. The notifications page is a core feature promised in the README.

### Sprint 2 Focus
These items fix **broken functionality** that users will encounter. Dark mode backgrounds, error handling, and image fallbacks directly impact user experience.

### Sprint 3 Focus
Polish items that elevate the app from "functional" to "industry-grade". These can be deprioritized if timeline is tight, but should be completed before public launch.

---

*Last Updated: November 28, 2025*
