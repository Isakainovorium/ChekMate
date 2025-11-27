# ChekMate Deployment Fixes - Codemap
**Created:** Nov 26, 2025
**Status:** ✅ COMPLETE

---

## Fix Order & Dependencies

```
┌─────────────────────────────────────────────────────────────────┐
│  ✅ FIX 1: Wire Splash Screen to Router                        │
│  File: lib/core/router/app_router_enhanced.dart                 │
│  Action: Add splash route as initial, redirect to welcome       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  ✅ FIX 2: Replace Mock Feed with Real FeedPage                │
│  File: lib/pages/home/home_page.dart                           │
│  Action: _buildForYouFeed() & _buildFollowingFeed() use FeedPage│
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  ✅ FIX 3: Remove Placeholder URLs                             │
│  Files: app_router_enhanced.dart, home_page.dart               │
│  Action: Replaced via.placeholder with empty string fallbacks  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  ✅ FIX 4: Implement ProfilePhotoScreen                        │
│  File: lib/pages/onboarding/profile_photo_screen.dart          │
│  Action: Full implementation with ImagePicker & animations     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  ✅ FIX 5: Implement Story Viewer                              │
│  File: lib/features/stories/presentation/story_viewer_screen.dart│
│  Action: Full-screen viewer with progress bars & gestures      │
└─────────────────────────────────────────────────────────────────┘

---

## Files Modified

| File | Changes |
|------|---------|
| `app_router_enhanced.dart` | Added /splash route, removed placeholder URLs |
| `home_page.dart` | Replaced mock data with FeedPage, added StoryViewer |
| `feed_page.dart` | Added showAppBar & initialFeedType params |
| `profile_photo_screen.dart` | Complete rewrite with ImagePicker |

## Files Created

| File | Purpose |
|------|---------|
| `splash_screen.dart` | Animated splash with logo & glow |
| `story_viewer_screen.dart` | Instagram-style story viewer |

---

## Completion Checklist

- [x] Fix 1: Splash route wired
- [x] Fix 2: Real feed connected (Firebase)
- [x] Fix 3: Placeholder URLs removed
- [x] Fix 4: ProfilePhotoScreen implemented
- [x] Fix 5: Story viewer implemented
- [ ] Final: Run `flutter pub get` & build verification

---
