# ChekMate Flutter Routing Guide

**Version:** 1.0  
**Last Updated:** October 16, 2025  
**Author:** ChekMate Development Team

---

## Table of Contents

1. [Overview](#overview)
2. [Route Hierarchy](#route-hierarchy)
3. [Figma to Flutter Mapping](#figma-to-flutter-mapping)
4. [How to Add New Routes](#how-to-add-new-routes)
5. [Navigation Patterns](#navigation-patterns)
6. [State Management](#state-management)
7. [Bottom vs Top Navigation](#bottom-vs-top-navigation)
8. [Navigation Hiding Rules](#navigation-hiding-rules)
9. [Code Examples](#code-examples)
10. [Testing Approach](#testing-approach)
11. [Troubleshooting](#troubleshooting)

---

## Overview

ChekMate uses **GoRouter** for declarative, URL-based routing in Flutter. The routing system implements a two-layer navigation pattern:
- **Bottom Navigation**: 4 main tabs (Home, Messages, Notifications, Profile)
- **Top Navigation**: 6 tabs within Home (For you, Following, Explore, Live, Rate Date, Subscribe)

### Key Technologies

- **GoRouter** (`^12.1.3`) - Declarative routing
- **Riverpod** (`^2.4.9`) - State management
- **NavState Provider** - Custom navigation state management

### Architecture Principles

1. **URL-Based Navigation**: Every screen has a unique URL
2. **Declarative Routing**: Routes defined in `app_router.dart`
3. **State Management**: Navigation state managed via Riverpod
4. **Two-Layer Navigation**: Bottom nav + top tabs for rich UX
5. **Dual Access**: Some routes accessible both as tabs AND standalone routes

---

## Route Hierarchy

### Complete Route Structure

```
ChekMate App
│
├── Auth Routes (No Navigation Shell)
│   ├── /login                    → LoginPage
│   └── /signup                   → SignUpPage
│
├── Bottom Navigation Routes (MainNavigation Shell)
│   │
│   ├── Home Tab (Index 0)
│   │   ├── /                     → HomePage
│   │   │   ├── For you (tab)
│   │   │   ├── Following (tab)
│   │   │   ├── Explore (tab)    → ExplorePage (embedded)
│   │   │   ├── Live (tab)       → LivePage (embedded)
│   │   │   ├── Rate Date (tab)  → Navigates to /rate-date
│   │   │   └── Subscribe (tab)  → Premium preview
│   │   │
│   │   ├── /explore              → ExplorePage (standalone)
│   │   ├── /live                 → LivePage (standalone)
│   │   └── /subscribe            → SubscribePage (standalone)
│   │
│   ├── Messages Tab (Index 1)
│   │   ├── /messages             → MessagesPage
│   │   └── /chat/:conversationId → ChatPage (hides bottom nav)
│   │
│   ├── Notifications Tab (Index 3)
│   │   └── /notifications        → NotificationsPage
│   │
│   └── Profile Tab (Index 4)
│       └── /profile              → MyProfilePage
│
└── Full-Screen Routes (MainNavigation Shell, Hidden Bottom Nav)
    ├── /rate-date                → RateDatePage
    └── /create-post              → CreatePostPage
```

### Route Count: 13 Routes

- **Auth Routes**: 2 (login, signup)
- **Bottom Nav Routes**: 4 (home, messages, notifications, profile)
- **Top Nav Routes**: 3 (explore, live, subscribe - dual access)
- **Full-Screen Routes**: 2 (rate-date, create-post)
- **Parameterized Routes**: 1 (chat with conversationId)
- **Development Routes**: 1 (theme-test)

---

## Figma to Flutter Mapping

The Figma routing guide (React-based) has been translated to Flutter GoRouter.

### State Management Comparison

| Figma (React) | Flutter | Implementation |
|---------------|---------|----------------|
| `bottomNavTab` state | `currentIndex` parameter | MainNavigation widget |
| `activeTab` state | `NavState.activeTab` | Riverpod StateNotifier |
| `isViewingStories` state | `NavState.isViewingStories` | Riverpod StateNotifier |
| `isInConversation` state | `NavState.isInConversation` | Riverpod StateNotifier |
| `useState` hook | `StateNotifier` | Riverpod provider |

### Route Mapping Table

| Figma Route | React State | Flutter Route | Flutter Implementation |
|-------------|-------------|---------------|------------------------|
| Login | N/A | `/login` | GoRoute → LoginPage |
| Signup | N/A | `/signup` | GoRoute → SignUpPage |
| Home (For you) | `bottomNavTab: 0, activeTab: 'For you'` | `/` | GoRoute → HomePage (default tab) |
| Home (Following) | `bottomNavTab: 0, activeTab: 'Following'` | `/` | NavState.activeTab = 'Following' |
| Home (Explore) | `bottomNavTab: 0, activeTab: 'Explore'` | `/` OR `/explore` | Dual access (tab + route) |
| Home (Live) | `bottomNavTab: 0, activeTab: 'Live'` | `/` OR `/live` | Dual access (tab + route) |
| Home (Rate Date) | `bottomNavTab: 0, activeTab: 'Rate Date'` | `/rate-date` | Full-screen route |
| Home (Subscribe) | `bottomNavTab: 0, activeTab: 'Subscribe'` | `/` OR `/subscribe` | Tab preview + full route |
| Messages | `bottomNavTab: 1` | `/messages` | GoRoute → MessagesPage |
| Chat | `bottomNavTab: 1, isInConversation: true` | `/chat/:conversationId` | GoRoute with params |
| Notifications | `bottomNavTab: 3` | `/notifications` | GoRoute → NotificationsPage |
| Profile | `bottomNavTab: 4` | `/profile` | GoRoute → MyProfilePage |
| Create Post | Full-screen | `/create-post` | GoRoute (hideNavigation) |

### Key Differences

1. **React uses state** → **Flutter uses routes**
2. **React `useState`** → **Flutter Riverpod providers**
3. **React conditional rendering** → **Flutter GoRouter navigation**
4. **React `isInConversation` flag** → **Flutter `hideNavigation` parameter**

---

## How to Add New Routes

### Step-by-Step Guide

#### 1. Create the Page Widget

```dart
// lib/pages/my_feature/my_feature_page.dart
import 'package:flutter/material.dart';

class MyFeaturePage extends StatelessWidget {
  const MyFeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Feature')),
      body: const Center(child: Text('My Feature Content')),
    );
  }
}
```

#### 2. Add Route to `app_router.dart`

```dart
// lib/core/router/app_router.dart
import 'package:flutter_chekmate/pages/my_feature/my_feature_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      // ... existing routes ...
      
      // Add your new route
      GoRoute(
        path: '/my-feature',
        name: 'my-feature',
        builder: (context, state) => const MainNavigation(
          currentIndex: 0, // Bottom nav index (0-4)
          child: MyFeaturePage(),
        ),
      ),
    ],
  );
});
```

#### 3. Choose Navigation Shell Configuration

**Option A: With Bottom Navigation (Standard)**
```dart
GoRoute(
  path: '/my-feature',
  name: 'my-feature',
  builder: (context, state) => const MainNavigation(
    currentIndex: 0, // Which bottom tab to highlight
    child: MyFeaturePage(),
  ),
),
```

**Option B: Without Bottom Navigation (Full-Screen)**
```dart
GoRoute(
  path: '/my-feature',
  name: 'my-feature',
  builder: (context, state) => const MainNavigation(
    currentIndex: 0,
    hideNavigation: true, // Hides bottom nav
    child: MyFeaturePage(),
  ),
),
```

**Option C: No Navigation Shell (Auth Pages)**
```dart
GoRoute(
  path: '/my-feature',
  name: 'my-feature',
  builder: (context, state) => const MyFeaturePage(),
),
```

#### 4. Add Route Parameters (Optional)

**Path Parameters:**
```dart
GoRoute(
  path: '/my-feature/:id',
  name: 'my-feature',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return MainNavigation(
      currentIndex: 0,
      child: MyFeaturePage(id: id),
    );
  },
),
```

**Query Parameters:**
```dart
GoRoute(
  path: '/my-feature',
  name: 'my-feature',
  builder: (context, state) {
    final filter = state.uri.queryParameters['filter'] ?? 'all';
    return MainNavigation(
      currentIndex: 0,
      child: MyFeaturePage(filter: filter),
    );
  },
),
```

#### 5. Navigate to Your Route

```dart
// Using path
context.go('/my-feature');

// Using name
context.goNamed('my-feature');

// With path parameters
context.go('/my-feature/123');

// With query parameters
context.go('/my-feature?filter=active');

// With both
context.go('/my-feature/123?filter=active');
```

#### 6. Add Tests

```dart
// test/core/router/app_router_test.dart
testWidgets('Navigate to my-feature page', (tester) async {
  await mockNetworkImagesFor(() async {
    final router = container.read(appRouterProvider);
    
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    
    router.go('/my-feature');
    await tester.pumpAndSettle();
    
    expect(find.byType(MyFeaturePage), findsOneWidget);
  });
});
```

---

## Bottom vs Top Navigation

ChekMate implements a **two-layer navigation system** for rich user experience.

### Layer 1: Bottom Navigation (4 Tabs)

The bottom navigation provides primary app navigation with 4 main sections:

| Index | Route | Page | Icon |
|-------|-------|------|------|
| 0 | `/` | HomePage | Home |
| 1 | `/messages` | MessagesPage | Messages |
| 3 | `/notifications` | NotificationsPage | Notifications |
| 4 | `/profile` | MyProfilePage | Profile |

**Note:** Index 2 is intentionally skipped to match the design system.

#### Bottom Navigation Behavior

- **Always visible** on main routes (home, messages, notifications, profile)
- **Hidden** on full-screen routes (chat, rate-date, create-post)
- **Controlled by** `MainNavigation` widget's `currentIndex` parameter
- **Persists** across top navigation tab switches

### Layer 2: Top Navigation (6 Tabs)

The top navigation provides content filtering within the Home tab:

| Tab Name | Access Method | Implementation |
|----------|---------------|----------------|
| For you | Default tab | HomePage default content |
| Following | Tab switch | HomePage content switch |
| Explore | Tab + Route | Dual access (embedded + `/explore`) |
| Live | Tab + Route | Dual access (embedded + `/live`) |
| Rate Date | Navigation | Navigates to `/rate-date` |
| Subscribe | Tab + Route | Preview + `/subscribe` |

#### Top Navigation Behavior

- **Only visible** within HomePage (bottom nav index 0)
- **Controlled by** `NavState.activeTab` provider
- **Persists** when navigating away and back to home
- **Switches content** within the same page (no route change for most tabs)

### Navigation Hierarchy

```
Bottom Navigation (GoRouter Routes)
└── Home Tab (/)
    └── Top Navigation (NavState)
        ├── For you (default)
        ├── Following
        ├── Explore (also /explore)
        ├── Live (also /live)
        ├── Rate Date → /rate-date
        └── Subscribe (preview + /subscribe)
```

### When to Use Which Layer

**Use Bottom Navigation when:**
- Creating a new primary section of the app
- The feature needs its own dedicated space
- The feature should be accessible from anywhere
- Example: Adding a "Shop" tab

**Use Top Navigation when:**
- Filtering or categorizing content within Home
- The feature is a variation of the feed
- The feature should only be accessible from Home
- Example: Adding a "Trending" tab

---

## Navigation Hiding Rules

Some routes require full-screen experience and hide the bottom navigation.

### Routes That Hide Bottom Navigation

| Route | Reason | Implementation |
|-------|--------|----------------|
| `/chat/:conversationId` | Full-screen chat experience | `hideNavigation: true` |
| `/rate-date` | Full-screen rating interface | `hideNavigation: true` |
| `/create-post` | Full-screen post creation | `hideNavigation: true` |

### How to Hide Bottom Navigation

In `app_router.dart`, set `hideNavigation: true` in the `MainNavigation` wrapper:

```dart
GoRoute(
  path: '/my-fullscreen-route',
  name: 'my-fullscreen-route',
  builder: (context, state) => const MainNavigation(
    currentIndex: 0,
    hideNavigation: true, // ← This hides bottom nav
    child: MyFullScreenPage(),
  ),
),
```

### MainNavigation Widget

The `MainNavigation` widget is a wrapper that provides the bottom navigation shell:

```dart
class MainNavigation extends StatelessWidget {
  final int currentIndex;      // Which bottom tab is active (0-4)
  final bool hideNavigation;   // Hide bottom nav? (default: false)
  final Widget child;          // The page content

  const MainNavigation({
    required this.currentIndex,
    required this.child,
    this.hideNavigation = false,
    super.key,
  });
}
```

### When to Hide Bottom Navigation

✅ **Hide bottom navigation when:**
- User is in a focused task (chat, rating, creating content)
- Full-screen experience is needed
- Bottom nav would be distracting
- User needs maximum screen space

❌ **Don't hide bottom navigation when:**
- User is browsing content
- User needs quick access to other sections
- The page is a primary destination
- Navigation context is important

---

## Code Examples

### Example 1: Navigate to a Simple Route

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Navigate to explore page
        context.go('/explore');
      },
      child: const Text('Go to Explore'),
    );
  }
}
```

### Example 2: Navigate with Parameters

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConversationListItem extends StatelessWidget {
  final String conversationId;
  final String userId;
  final String userName;
  final String userAvatar;

  const ConversationListItem({
    required this.conversationId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(userName),
      onTap: () {
        // Navigate to chat with parameters
        context.go(
          '/chat/$conversationId?userId=$userId&userName=$userName&userAvatar=$userAvatar'
        );
      },
    );
  }
}
```

### Example 3: Switch Top Navigation Tabs

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chekmate/core/navigation/nav_state.dart';

class TabSwitcher extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navController = ref.read(navStateProvider.notifier);
    final currentTab = ref.watch(navStateProvider).activeTab;

    return Row(
      children: [
        TextButton(
          onPressed: () => navController.setActiveTab('For you'),
          child: Text(
            'For you',
            style: TextStyle(
              fontWeight: currentTab == 'For you'
                ? FontWeight.bold
                : FontWeight.normal,
            ),
          ),
        ),
        TextButton(
          onPressed: () => navController.setActiveTab('Following'),
          child: Text(
            'Following',
            style: TextStyle(
              fontWeight: currentTab == 'Following'
                ? FontWeight.bold
                : FontWeight.normal,
            ),
          ),
        ),
        TextButton(
          onPressed: () => navController.setActiveTab('Explore'),
          child: Text(
            'Explore',
            style: TextStyle(
              fontWeight: currentTab == 'Explore'
                ? FontWeight.bold
                : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
```

### Example 4: Handle Story Viewer State

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chekmate/core/navigation/nav_state.dart';

class StoryViewer extends ConsumerStatefulWidget {
  @override
  ConsumerState<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends ConsumerState<StoryViewer> {
  @override
  void initState() {
    super.initState();
    // Hide bottom nav when story viewer opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navStateProvider.notifier).setViewingStories(true);
    });
  }

  @override
  void dispose() {
    // Show bottom nav when story viewer closes
    ref.read(navStateProvider.notifier).setViewingStories(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Story content
          const Center(child: Text('Story Content')),

          // Close button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Example 5: Navigate Back with Result

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Page that returns a result
class SelectUserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select User')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('John Doe'),
            onTap: () {
              // Return selected user
              context.pop({'id': '123', 'name': 'John Doe'});
            },
          ),
          ListTile(
            title: const Text('Jane Smith'),
            onTap: () {
              // Return selected user
              context.pop({'id': '456', 'name': 'Jane Smith'});
            },
          ),
        ],
      ),
    );
  }
}

// Page that receives the result
class CreatePostPage extends StatefulWidget {
  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  String? selectedUserName;

  Future<void> _selectUser() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => SelectUserPage()),
    );

    if (result != null) {
      setState(() {
        selectedUserName = result['name'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _selectUser,
            child: const Text('Tag a User'),
          ),
          if (selectedUserName != null)
            Text('Tagged: $selectedUserName'),
        ],
      ),
    );
  }
}
```

### Example 6: Deep Linking

```dart
// Deep links are automatically handled by GoRouter
// Users can open these URLs directly:

// Open explore page
// chekmate://explore

// Open specific chat
// chekmate://chat/conversation-123?userId=456&userName=John

// Open rate date page
// chekmate://rate-date

// Configure deep linking in AndroidManifest.xml and Info.plist
```

---

## Testing Approach

### Test Structure

ChekMate routing tests are organized into three files:

1. **`test/core/router/app_router_test.dart`** - Route and navigation tests
2. **`test/core/navigation/nav_state_test.dart`** - NavState provider tests
3. **`test/core/navigation/bottom_nav_visibility_test.dart`** - Bottom nav visibility tests

### Test Categories

#### 1. Route Existence Tests

Verify all routes are configured correctly:

```dart
testWidgets('All routes from Figma guide are configured', (tester) async {
  final router = container.read(appRouterProvider);
  final routes = router.configuration.routes;

  expect(routes.length, greaterThanOrEqualTo(13));
});
```

#### 2. Navigation Tests

Verify navigation to each page works:

```dart
testWidgets('Navigate to explore page', (tester) async {
  await mockNetworkImagesFor(() async {
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.go('/explore');
    await tester.pumpAndSettle();

    expect(find.byType(ExplorePage), findsOneWidget);
    expect(find.byType(MainNavigation), findsOneWidget);
  });
});
```

#### 3. Route Parameter Tests

Verify parameters are handled correctly:

```dart
testWidgets('Chat route handles conversationId parameter', (tester) async {
  await mockNetworkImagesFor(() async {
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.go('/chat/test-conversation-123');
    await tester.pumpAndSettle();

    expect(find.byType(ChatPage), findsOneWidget);
  });
});
```

#### 4. NavState Tests

Verify navigation state management:

```dart
test('setActiveTab updates activeTab', () {
  final container = ProviderContainer();
  final controller = container.read(navStateProvider.notifier);

  controller.setActiveTab('Explore');
  final state = container.read(navStateProvider);

  expect(state.activeTab, equals('Explore'));
});
```

#### 5. Bottom Nav Visibility Tests

Verify bottom navigation is shown/hidden correctly:

```dart
testWidgets('Bottom navigation is HIDDEN in chat page', (tester) async {
  await mockNetworkImagesFor(() async {
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.go('/chat/test-conversation-123');
    await tester.pumpAndSettle();

    expect(find.byType(ChatPage), findsOneWidget);
    expect(find.byType(MainNavigation), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
  });
});
```

### Running Tests

```bash
# Run all routing tests
flutter test test/core/

# Run specific test file
flutter test test/core/router/app_router_test.dart

# Run with coverage
flutter test test/core/ --coverage

# Run specific test
flutter test test/core/router/app_router_test.dart --name "Navigate to explore page"
```

### Test Best Practices

✅ **Do:**
- Use `mockNetworkImagesFor` to prevent HTTP requests
- Use `ProviderScope` for Riverpod integration
- Use `pumpAndSettle` to wait for animations
- Test both success and error cases
- Test route parameters and query parameters
- Test navigation state changes

❌ **Don't:**
- Make actual HTTP requests in tests
- Rely on timing (use `pumpAndSettle` instead)
- Test implementation details
- Skip edge cases
- Forget to dispose providers

---

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: Route Not Found

**Error:** `GoException: no routes for location: /my-route`

**Solution:**
1. Check route is defined in `app_router.dart`
2. Verify path spelling matches exactly
3. Ensure route is not nested incorrectly

```dart
// ✅ Correct
GoRoute(
  path: '/my-route',
  builder: (context, state) => const MyPage(),
),

// ❌ Wrong - missing leading slash
GoRoute(
  path: 'my-route',
  builder: (context, state) => const MyPage(),
),
```

#### Issue 2: Bottom Navigation Not Showing

**Problem:** Bottom navigation is hidden when it should be visible

**Solution:**
1. Check `hideNavigation` parameter is not set to `true`
2. Verify route uses `MainNavigation` wrapper
3. Check `currentIndex` is set correctly (0-4)

```dart
// ✅ Correct - bottom nav visible
GoRoute(
  path: '/my-route',
  builder: (context, state) => const MainNavigation(
    currentIndex: 0,
    child: MyPage(),
  ),
),

// ❌ Wrong - bottom nav hidden
GoRoute(
  path: '/my-route',
  builder: (context, state) => const MainNavigation(
    currentIndex: 0,
    hideNavigation: true, // Remove this
    child: MyPage(),
  ),
),
```

#### Issue 3: NavState Not Updating

**Problem:** Tab switching doesn't work

**Solution:**
1. Ensure you're using `ref.read(navStateProvider.notifier)` to update
2. Verify you're using `ref.watch(navStateProvider)` to read
3. Check widget is a `ConsumerWidget` or `ConsumerStatefulWidget`

```dart
// ✅ Correct
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navController = ref.read(navStateProvider.notifier);
    final currentTab = ref.watch(navStateProvider).activeTab;

    return TextButton(
      onPressed: () => navController.setActiveTab('Explore'),
      child: Text(currentTab),
    );
  }
}

// ❌ Wrong - not a ConsumerWidget
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Can't access ref here!
    return const Text('Error');
  }
}
```

#### Issue 4: Route Parameters Not Working

**Problem:** Path parameters are null or incorrect

**Solution:**
1. Check parameter syntax uses `:paramName` in path
2. Access parameters using `state.pathParameters['paramName']`
3. For query parameters, use `state.uri.queryParameters['paramName']`

```dart
// ✅ Correct
GoRoute(
  path: '/chat/:conversationId',
  builder: (context, state) {
    final conversationId = state.pathParameters['conversationId']!;
    final userId = state.uri.queryParameters['userId'];
    return ChatPage(
      conversationId: conversationId,
      userId: userId,
    );
  },
),

// ❌ Wrong - incorrect parameter access
GoRoute(
  path: '/chat/:conversationId',
  builder: (context, state) {
    final conversationId = state.uri.queryParameters['conversationId']; // Wrong!
    return ChatPage(conversationId: conversationId);
  },
),
```

#### Issue 5: Tests Failing with Firebase Errors

**Error:** `[core/no-app] No Firebase App '[DEFAULT]' has been created`

**Solution:**
1. Mock Firebase in tests
2. Use `mockNetworkImagesFor` for network images
3. Mock Firestore providers

```dart
// ✅ Correct - mock network images
testWidgets('Navigate to messages page', (tester) async {
  await mockNetworkImagesFor(() async {
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.go('/messages');
    await tester.pumpAndSettle();

    expect(find.byType(MessagesPage), findsOneWidget);
  });
});
```

#### Issue 6: Dual Access Routes Not Working

**Problem:** Explore/Live don't work as both tabs and routes

**Solution:**
1. Ensure route is defined in `app_router.dart`
2. Ensure tab switching uses `NavState`
3. Verify page widget is the same in both cases

```dart
// In app_router.dart
GoRoute(
  path: '/explore',
  builder: (context, state) => const MainNavigation(
    currentIndex: 0,
    child: ExplorePage(),
  ),
),

// In HomePage
Widget _buildContent() {
  switch (activeTab) {
    case 'Explore':
      return const ExplorePage(); // Same widget
    // ...
  }
}
```

---

## Additional Resources

### Related Documentation

- **`ROUTING_COMPARISON.md`** - Figma to Flutter routing comparison
- **`ROUTER_VERIFICATION.md`** - Router configuration verification
- **`TASK_5_COMPLETION_REPORT.md`** - HomePage implementation details
- **`TASK_6_COMPLETION_REPORT.md`** - Routing tests documentation

### External Resources

- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Riverpod Documentation](https://riverpod.dev/)
- [Flutter Navigation Guide](https://docs.flutter.dev/development/ui/navigation)

### Getting Help

If you encounter issues not covered in this guide:

1. Check the test files for examples
2. Review the comparison documents
3. Check GoRouter and Riverpod documentation
4. Ask the development team

---

**End of Flutter Routing Guide**

## Navigation Patterns

### Pattern 1: Simple Navigation

```dart
// Navigate to a route
context.go('/explore');

// Navigate back
context.pop();

// Replace current route
context.replace('/login');
```

### Pattern 2: Named Routes

```dart
// Navigate using route name
context.goNamed('explore');

// Navigate with parameters
context.goNamed(
  'chat',
  pathParameters: {'conversationId': '123'},
  queryParameters: {'userId': '456'},
);
```

### Pattern 3: Bottom Navigation

```dart
// Navigate to bottom nav tabs
context.go('/');           // Home (index 0)
context.go('/messages');   // Messages (index 1)
context.go('/notifications'); // Notifications (index 3)
context.go('/profile');    // Profile (index 4)
```

### Pattern 4: Top Navigation (Tabs within Home)

```dart
// Use NavState provider to switch tabs
final navController = ref.read(navStateProvider.notifier);

navController.setActiveTab('For you');
navController.setActiveTab('Following');
navController.setActiveTab('Explore');
navController.setActiveTab('Live');
navController.setActiveTab('Subscribe');
```

### Pattern 5: Dual Access Routes

```dart
// Explore can be accessed two ways:

// 1. As a tab within Home
navController.setActiveTab('Explore');

// 2. As a standalone route
context.go('/explore');
```

### Pattern 6: Full-Screen Routes

```dart
// Routes that hide bottom navigation
context.go('/rate-date');
context.go('/create-post');
context.go('/chat/conversation-123');
```

### Pattern 7: Parameterized Routes

```dart
// Chat with conversation ID
final conversationId = 'conv-123';
final userId = 'user-456';
final userName = 'John Doe';
final userAvatar = 'https://example.com/avatar.jpg';

context.go(
  '/chat/$conversationId?userId=$userId&userName=$userName&userAvatar=$userAvatar'
);
```

---

## State Management

### NavState Provider

The `NavState` provider manages navigation-related state that persists across route changes.

#### NavState Structure

```dart
class NavState {
  final String activeTab;          // Current top nav tab
  final bool isViewingStories;     // Story viewer open?
  final bool isInConversation;     // In a chat?
  
  const NavState({
    this.activeTab = 'For you',
    this.isViewingStories = false,
    this.isInConversation = false,
  });
}
```

#### Using NavState

**Read State:**
```dart
// In a ConsumerWidget or ConsumerStatefulWidget
final navState = ref.watch(navStateProvider);
final currentTab = navState.activeTab;
final viewingStories = navState.isViewingStories;
```

**Update State:**
```dart
// Get the controller
final navController = ref.read(navStateProvider.notifier);

// Set active tab
navController.setActiveTab('Explore');

// Set story viewing state
navController.setViewingStories(true);

// Set conversation state
navController.setInConversation(true);

// Reset to home
navController.resetToHome();
```

#### When to Use NavState

✅ **Use NavState for:**
- Top navigation tab switching
- Story viewer state
- Conversation state
- Any state that should persist across route changes

❌ **Don't use NavState for:**
- Bottom navigation (use GoRouter routes instead)
- Page-specific state (use local state)
- Form data (use form controllers)

---


