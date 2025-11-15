# ChekMate Routing Implementation Comparison

**Document Version:** 1.0  
**Date:** October 16, 2025  
**Purpose:** Comprehensive comparison of Figma routing guide (React) vs Flutter implementation

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Technology Stack Comparison](#technology-stack-comparison)
3. [Route Mapping: Figma Guide to Flutter](#route-mapping-figma-guide-to-flutter)
4. [Navigation State Management](#navigation-state-management)
5. [Current Implementation Status](#current-implementation-status)
6. [HomePage Implementations Comparison](#homepage-implementations-comparison)
7. [Missing Routes and Features](#missing-routes-and-features)
8. [Recommendations](#recommendations)

---

## Executive Summary

### Key Findings

- **Technology Mismatch**: Figma routing guide describes a React/TypeScript web app, while the codebase is a Flutter mobile app
- **Partial Implementation**: Someone has already started translating the Figma structure to Flutter (`home_page_new.dart`)
- **Wrong HomePage in Use**: Current router uses `home_page.dart` (4 tabs: Feed, Explore, Videos, Events) instead of `home_page_new.dart` (6 tabs matching Figma guide)
- **Missing Routes**: 5 routes from Figma guide are not implemented or commented out
- **File Structure Issues**: Pages scattered across multiple directories, making routing unclear

### Implementation Status

| Status | Count | Percentage |
|--------|-------|------------|
| ✅ Fully Implemented | 6 | 46% |
| ⚠️ Partially Implemented | 3 | 23% |
| ❌ Not Implemented | 4 | 31% |
| **Total Routes** | **13** | **100%** |

---

## Technology Stack Comparison

### Figma Guide (React/TypeScript)

```typescript
// State-based routing (no URL routing)
const [bottomNavTab, setBottomNavTab] = useState('home');
const [activeTab, setActiveTab] = useState('For you');
const [isInConversation, setIsInConversation] = useState(false);
const [isViewingStories, setIsViewingStories] = useState(false);

// Conditional rendering based on state
const renderContent = () => {
  if (bottomNavTab === 'notifications') return <Notifications />;
  if (activeTab === 'Following') return <Following />;
  // ...
};
```

### Flutter Implementation

```dart
// URL-based routing with GoRouter
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomePage()),
    GoRoute(path: '/messages', builder: (context, state) => MessagesPage()),
    // ...
  ],
);

// State management with Riverpod
class NavState {
  final String activeTab; // 'For you' | 'Following' | 'Explore' | 'Live' | 'Subscribe'
  final bool isViewingStories;
  final bool isInConversation;
}

final navStateProvider = StateNotifierProvider<NavController, NavState>(...);
```

### Key Differences

| Aspect | React (Figma Guide) | Flutter (Current) |
|--------|---------------------|-------------------|
| **Routing** | State-based (no URLs) | URL-based (GoRouter) |
| **State Management** | useState hooks | Riverpod StateNotifier |
| **Navigation Priority** | bottomNavTab > activeTab | Route-based with nested tabs |
| **Deep Linking** | Not supported | Supported via GoRouter |
| **Browser Back Button** | N/A (no URL changes) | Supported |

---

## Route Mapping: Figma Guide to Flutter

### Bottom Navigation Routes

#### 1. Home Route

**Figma Guide (React):**
```typescript
bottomNavTab === 'home'
// Shows: Header + NavigationTabs + Content based on activeTab
```

**Flutter Equivalent:**
```dart
GoRoute(
  path: '/',
  name: 'home',
  builder: (context, state) => MainNavigation(
    currentIndex: 0,
    child: HomePage(), // Should use home_page_new.dart
  ),
)
```

**Status:** ⚠️ Partially Implemented (using wrong HomePage)

---

#### 2. Messages Route

**Figma Guide (React):**
```typescript
bottomNavTab === 'messages'
// Shows: MessagesPage with custom header
// Hides bottom nav when isInConversation === true
```

**Flutter Equivalent:**
```dart
GoRoute(
  path: '/messages',
  name: 'messages',
  builder: (context, state) => MainNavigation(
    currentIndex: 1,
    child: MessagesPage(),
  ),
),
GoRoute(
  path: '/chat/:conversationId',
  name: 'chat',
  builder: (context, state) => MainNavigation(
    currentIndex: 1,
    hideNavigation: true, // Hides bottom nav
    child: ChatPage(...),
  ),
)
```

**Status:** ✅ Fully Implemented

---

#### 3. Notifications Route

**Figma Guide (React):**
```typescript
bottomNavTab === 'notifications'
// Shows: Notifications component with custom header
```

**Flutter Equivalent:**
```dart
GoRoute(
  path: '/notifications',
  name: 'notifications',
  builder: (context, state) => MainNavigation(
    currentIndex: 3,
    child: NotificationsPage(),
  ),
)
```

**Status:** ✅ Fully Implemented

---

#### 4. Profile Route

**Figma Guide (React):**
```typescript
bottomNavTab === 'profile'
// Shows: MyProfile component with custom ProfileHeader
```

**Flutter Equivalent:**
```dart
GoRoute(
  path: '/profile',
  name: 'profile',
  builder: (context, state) => MainNavigation(
    currentIndex: 4,
    child: MyProfilePage(),
  ),
)
```

**Status:** ✅ Fully Implemented

---

### Top Navigation Tabs (within Home)

#### 1. For You (Default Feed)

**Figma Guide (React):**
```typescript
activeTab === 'For you'
// Shows: Header + NavigationTabs + Stories + Posts feed
```

**Flutter Equivalent:**
```dart
// Within HomePage, managed by NavState
Widget _buildContent(String activeTab) {
  if (activeTab == 'For you') return _buildForYouFeed();
  // ...
}
```

**Status:** ⚠️ Partially Implemented (in home_page_new.dart, not in use)

---

#### 2. Following

**Figma Guide (React):**
```typescript
activeTab === 'Following'
// Shows: Header + NavigationTabs + Stories + Following feed
```

**Flutter Equivalent:**
```dart
// Within HomePage
if (activeTab == 'Following') return _buildFollowingFeed();
```

**Status:** ⚠️ Partially Implemented (in home_page_new.dart, not in use)

---

#### 3. Explore

**Figma Guide (React):**
```typescript
activeTab === 'Explore'
// Shows: Header + NavigationTabs + Explore content (no stories)
```

**Flutter Equivalent (Proposed):**
```dart
// Option 1: As tab within HomePage
if (activeTab == 'Explore') return ExplorePage();

// Option 2: As standalone route (RECOMMENDED - dual access)
GoRoute(
  path: '/explore',
  name: 'explore',
  builder: (context, state) => MainNavigation(
    currentIndex: 0,
    child: ExplorePage(),
  ),
)
```

**Status:** ❌ Not Implemented as route (exists as page file)

---

#### 4. Live

**Figma Guide (React):**
```typescript
activeTab === 'Live'
// Shows: Header + NavigationTabs + Live streams (no stories)
```

**Flutter Equivalent (Proposed):**
```dart
// Dual access: tab + standalone route
GoRoute(
  path: '/live',
  name: 'live',
  builder: (context, state) => MainNavigation(
    currentIndex: 0,
    child: LivePage(),
  ),
)
```

**Status:** ❌ Not Implemented as route (exists as page file, commented out in router)

---

## HomePage Implementations Comparison

### Current HomePage (`lib/features/feed/pages/home_page.dart`)

**Tabs:** 4 tabs
- Feed
- Explore
- Videos
- Events

**Structure:**
```dart
class HomePage extends StatefulWidget {
  // Uses TabController with 4 tabs
  TabController _tabController = TabController(length: 4, vsync: this);

  // Tabs don't match Figma guide
  tabs: [
    Tab(icon: Icon(Icons.home), text: 'Feed'),
    Tab(icon: Icon(Icons.explore), text: 'Explore'),
    Tab(icon: Icon(Icons.video_library), text: 'Videos'),
    Tab(icon: Icon(Icons.event), text: 'Events'),
  ]
}
```

**Issues:**
- ❌ Doesn't match Figma guide structure
- ❌ Missing "For you", "Following", "Live", "Subscribe", "Rate Date" tabs
- ❌ Has "Videos" and "Events" tabs not in Figma guide
- ❌ Doesn't use NavState provider
- ❌ No integration with top navigation tabs from Figma

---

### Correct HomePage (`lib/features/feed/pages/home/presentation/pages/home_page_new.dart`)

**Tabs:** 6 tabs (matches Figma guide)
- For you
- Following
- Explore
- Live
- Subscribe
- Rate Date

**Structure:**
```dart
class HomePageNew extends ConsumerStatefulWidget {
  // Uses NavState provider for tab management
  final nav = ref.watch(navStateProvider);

  // Includes HeaderWidget and NavTabsWidget
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column([
        HeaderWidget(scrollController: _scrollController, onSearch: _handleSearch),
        NavTabsWidget(activeTab: nav.activeTab, onTabChanged: _handleTabChange),
        Expanded(child: _buildContent(nav.activeTab)),
      ]),
    );
  }

  // Proper tab content switching
  Widget _buildContent(String activeTab) {
    switch (activeTab) {
      case 'For you': return _buildForYouFeed();
      case 'Following': return _buildFollowingFeed();
      case 'Explore': return _buildExplorePage();
      case 'Live': return _buildLivePage();
      case 'Rate Date': return _buildRateDatePage();
      case 'Subscribe': return _buildSubscribePage();
    }
  }
}
```

**Advantages:**
- ✅ Matches Figma guide structure exactly
- ✅ Uses NavState provider for state management
- ✅ Includes HeaderWidget and NavTabsWidget
- ✅ Proper tab switching logic
- ✅ Handles Rate Date navigation to full-screen route
- ✅ Integrates with story viewer (sets isViewingStories)

**Current Issues:**
- ⚠️ Not being used by router (router points to old home_page.dart)
- ⚠️ Explore and Live show placeholder content instead of actual pages
- ⚠️ Rate Date navigation implemented but route doesn't exist yet

---

## Missing Routes and Features

### 1. Explore Route (`/explore`)

**Figma Guide Requirement:**
- Accessible both as tab within Home AND as standalone route
- Shows trending content, hashtags, suggested users
- No stories component

**Current Status:**
- ✅ Page exists: `lib/features/feed/pages/explore/pages/explore_page.dart`
- ❌ Not configured in router
- ⚠️ home_page_new.dart shows placeholder instead of actual ExplorePage

**Action Required:**
1. Add route to app_router.dart
2. Update home_page_new.dart to use actual ExplorePage widget
3. Move page to lib/pages/explore/

---

### 2. Live Route (`/live`)

**Figma Guide Requirement:**
- Accessible both as tab within Home AND as standalone route
- Shows live streams with "Go Live" button
- Category filtering
- No stories component

**Current Status:**
- ✅ Page exists: `lib/features/feed/pages/live/pages/live_page.dart`
- ❌ Route commented out in app_router.dart
- ⚠️ home_page_new.dart shows placeholder instead of actual LivePage

**Action Required:**
1. Uncomment and configure route in app_router.dart
2. Update home_page_new.dart to use actual LivePage widget
3. Move page to lib/pages/live/

---

### 3. Subscribe Route (`/subscribe`)

**Figma Guide Requirement:**
- Accessible as tab within Home
- Shows subscription tiers (Free, Premium, VIP)
- Payment modal integration
- Billing cycle toggle (monthly/yearly)

**Current Status:**
- ✅ Page exists: `lib/features/subscription/pages/subscribe_page.dart`
- ✅ Fully implemented with payment modal
- ❌ Not configured in router
- ⚠️ home_page_new.dart shows placeholder instead of actual SubscribePage

**Action Required:**
1. Add route to app_router.dart
2. Update home_page_new.dart to use actual SubscribePage widget
3. Move page to lib/pages/subscribe/

---

### 4. Rate Date Route (`/rate-date`)

**Figma Guide Requirement:**
- Full-screen experience (hides all navigation)
- Flippable 3D rating cards
- Tea-style ratings
- Uses NavigationWidget instead of BottomNavigation
- Accessible from top navigation tab

**Current Status:**
- ❌ Page doesn't exist
- ❌ Route commented out in app_router.dart
- ⚠️ home_page_new.dart has navigation logic but no actual page

**Action Required:**
1. Create RateDatePage in lib/pages/rate_date/
2. Implement flippable card UI
3. Add route with hideNavigation: true
4. Implement NavigationWidget for navigation

---

### 5. Create Post Route (`/create-post`)

**Figma Guide Requirement:**
- Full-screen post creation (hides bottom navigation)
- Text input, image/video upload
- Creates new post in feed
- Can be modal OR route

**Current Status:**
- ❌ Page doesn't exist
- ❌ Route commented out in app_router.dart
- ⚠️ Currently implemented as modal in MainNavigation

**Action Required:**
1. Create CreatePostPage in lib/pages/create_post/
2. Add route with hideNavigation: true
3. Migrate modal logic to full page
4. Update bottom nav to navigate to route instead of showing modal

---

## File Structure Issues

### Current Structure (Messy)

```
lib/
├── features/
│   ├── auth/
│   │   └── pages/
│   │       ├── login_page.dart ✅
│   │       └── signup_page.dart ✅
│   ├── feed/
│   │   ├── pages/
│   │   │   ├── home_page.dart ❌ (wrong implementation)
│   │   │   ├── feed_page.dart
│   │   │   ├── home/
│   │   │   │   └── presentation/pages/
│   │   │   │       └── home_page_new.dart ✅ (correct, not used)
│   │   │   ├── explore/pages/
│   │   │   │   └── explore_page.dart ✅
│   │   │   ├── live/pages/
│   │   │   │   ├── live_page.dart ✅
│   │   │   │   └── live_feed_page.dart (duplicate?)
│   │   │   ├── messaging/pages/ ❌ (should be in features/messaging)
│   │   │   └── profile/pages/ ❌ (should be in subfeatures)
│   │   └── subfeatures/
│   │       ├── profile/pages/
│   │       │   └── my_profile_page.dart ✅
│   │       └── live/pages/
│   │           └── live_feed_page.dart (duplicate?)
│   ├── messaging/
│   │   └── pages/
│   │       ├── messages_page.dart ✅
│   │       └── chat_page.dart ✅
│   ├── notifications/
│   │   └── pages/
│   │       └── notifications_page.dart ✅
│   └── subscription/
│       ├── pages/
│       │   └── subscribe_page.dart ✅
│       └── presentation/pages/
│           └── subscription_page.dart (duplicate?)
```

**Problems:**
- 🔴 Pages scattered across multiple directories
- 🔴 Duplicate files (live_page.dart, subscription_page.dart)
- 🔴 Inconsistent nesting (pages/home/presentation/pages/)
- 🔴 Messaging and profile pages in wrong locations
- 🔴 Hard to identify which files are route destinations

---

### Proposed Structure (Clean)

```
lib/
├── pages/ ✨ NEW - All routable pages
│   ├── auth/
│   │   ├── login_page.dart
│   │   └── signup_page.dart
│   ├── home/
│   │   └── home_page.dart (from home_page_new.dart)
│   ├── messages/
│   │   ├── messages_page.dart
│   │   └── chat_page.dart
│   ├── notifications/
│   │   └── notifications_page.dart
│   ├── profile/
│   │   └── my_profile_page.dart
│   ├── explore/
│   │   └── explore_page.dart
│   ├── live/
│   │   └── live_page.dart
│   ├── subscribe/
│   │   └── subscribe_page.dart
│   ├── rate_date/
│   │   └── rate_date_page.dart ✨ NEW
│   └── create_post/
│       └── create_post_page.dart ✨ NEW
│
├── features/ - Feature-specific widgets/logic
│   ├── auth/
│   │   ├── widgets/
│   │   ├── providers/
│   │   └── services/
│   ├── feed/
│   │   ├── widgets/
│   │   └── models/
│   ├── messaging/
│   │   └── widgets/
│   ├── profile/
│   │   └── widgets/
│   └── ...
```

**Benefits:**
- ✅ Clear separation: pages vs components
- ✅ Easy to find route destinations
- ✅ No duplicate files
- ✅ Consistent structure
- ✅ Follows Flutter best practices

---

## Recommendations

### Priority 1: Critical (Do First)

1. **Switch to Correct HomePage**
   - Update app_router.dart to use home_page_new.dart
   - Rename HomePageNew to HomePage
   - Delete old home_page.dart

2. **Add Missing Routes**
   - Add /explore route
   - Add /live route
   - Add /subscribe route
   - Create and add /rate-date route
   - Create and add /create-post route

3. **Fix Explore/Live Dual Access**
   - Make Explore and Live accessible both as tabs AND routes
   - Update home_page_new.dart to use actual page widgets instead of placeholders

### Priority 2: Important (Do Next)

4. **Reorganize File Structure**
   - Create lib/pages/ directory
   - Move all page files to new structure
   - Update all imports
   - Delete duplicate files

5. **Update Router Configuration**
   - Add route names to all routes
   - Configure proper route parameters
   - Set hideNavigation flags correctly

### Priority 3: Nice to Have (Do Later)

6. **Create Comprehensive Tests**
   - Test all routes exist
   - Test navigation between pages
   - Test route parameters
   - Test navigation state management

7. **Create Flutter Routing Documentation**
   - Document complete route hierarchy
   - Explain Figma to Flutter mapping
   - Provide code examples
   - Document testing approach

---

## Summary

### What's Working ✅

- Basic bottom navigation routes (home, messages, notifications, profile)
- Chat route with conversation state management
- NavState provider for managing navigation state
- MainNavigation wrapper with hideNavigation support

### What's Broken ❌

- Wrong HomePage implementation in use
- 5 routes missing from router
- File structure is messy and inconsistent
- Explore and Live not accessible as standalone routes
- Duplicate page files in multiple locations

### What Needs to Be Done 🔧

1. Switch to home_page_new.dart (correct implementation)
2. Add 5 missing routes to app_router.dart
3. Reorganize all page files into lib/pages/
4. Update home_page_new.dart to use actual page widgets
5. Create RateDatePage and CreatePostPage
6. Write comprehensive routing tests
7. Create Flutter-specific routing documentation

---

**Next Steps:** Proceed with Task 3 (File Reorganization) to create clean structure, then Task 4 (Update Router Configuration) to add missing routes.

#### 5. Subscribe

**Figma Guide (React):**
```typescript
activeTab === 'Subscribe'
// Shows: Header + NavigationTabs + Subscription tiers
```

**Flutter Equivalent (Proposed):**
```dart
GoRoute(
  path: '/subscribe',
  name: 'subscribe',
  builder: (context, state) => MainNavigation(
    currentIndex: 0,
    child: SubscribePage(),
  ),
)
```

**Status:** ❌ Not Implemented as route (page exists in features/subscription/)

---

#### 6. Rate Date

**Figma Guide (React):**
```typescript
activeTab === 'Rate Date'
// Shows: Full-screen RateYourDate component
// Hides: Header, NavigationTabs, BottomNavigation
// Shows: NavigationWidget instead
```

**Flutter Equivalent (Proposed):**
```dart
GoRoute(
  path: '/rate-date',
  name: 'rate-date',
  builder: (context, state) => MainNavigation(
    currentIndex: 0,
    hideNavigation: true, // Full-screen
    child: RateDatePage(),
  ),
)
```

**Status:** ❌ Not Implemented (commented out in router)

---

### Modal/Overlay Routes

#### Post Creation

**Figma Guide (React):**
```typescript
// Modal overlay, not a route
<PostCreationModal isOpen={showPostCreationModal} />
```

**Flutter Equivalent (Proposed):**
```dart
// Can be modal OR route (route recommended for better UX)
GoRoute(
  path: '/create-post',
  name: 'create-post',
  builder: (context, state) => MainNavigation(
    currentIndex: 0,
    hideNavigation: true,
    child: CreatePostPage(),
  ),
)
```

**Status:** ❌ Not Implemented (currently modal in MainNavigation)

---

## Navigation State Management

### React (Figma Guide)

```typescript
// App.tsx state
const [bottomNavTab, setBottomNavTab] = useState('home');
const [activeTab, setActiveTab] = useState('For you');
const [isInConversation, setIsInConversation] = useState(false);
const [isViewingStories, setIsViewingStories] = useState(false);

// Priority: bottomNavTab > activeTab > default
```

### Flutter (Current)

```dart
// lib/core/navigation/nav_state.dart
class NavState {
  const NavState({
    this.activeTab = 'For you',
    this.isViewingStories = false,
    this.isInConversation = false,
  });
  
  final String activeTab;
  final bool isViewingStories;
  final bool isInConversation;
}

// Priority: Route > activeTab (within HomePage)
```

### Key Differences

| Feature | React | Flutter |
|---------|-------|---------|
| **Bottom Nav State** | `bottomNavTab` state variable | GoRouter route paths |
| **Top Nav State** | `activeTab` state variable | `NavState.activeTab` |
| **Conversation State** | `isInConversation` | `NavState.isInConversation` |
| **Story Viewing** | `isViewingStories` | `NavState.isViewingStories` |
| **State Persistence** | None (resets on refresh) | URL persists, state resets |

---

## Current Implementation Status

### Implemented Routes ✅

1. **`/` (home)** - HomePage (but wrong implementation)
2. **`/login`** - LoginPage
3. **`/signup`** - SignUpPage
4. **`/messages`** - MessagesPage
5. **`/chat/:conversationId`** - ChatPage
6. **`/notifications`** - NotificationsPage
7. **`/profile`** - MyProfilePage (uses old path)

### Missing Routes ❌

1. **`/explore`** - ExplorePage (file exists, not routed)
2. **`/live`** - LivePage (file exists, commented out)
3. **`/subscribe`** - SubscribePage (file exists, not routed)
4. **`/rate-date`** - RateDatePage (not created, commented out)
5. **`/create-post`** - CreatePostPage (not created, commented out)

### Partially Implemented ⚠️

1. **HomePage tabs** - home_page_new.dart has correct structure but not in use
2. **Explore/Live** - Pages exist but only as widgets, not accessible as routes

---


