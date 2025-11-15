# ChekMate Flutter Routing Architecture

> **Complete routing structure using GoRouter for the dating experience platform**
>
> Last Updated: January 15, 2025

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Routing Strategy](#routing-strategy)
3. [Route Structure](#route-structure)
4. [Main Routes](#main-routes)
5. [Nested Routes](#nested-routes)
6. [Modal Routes](#modal-routes)
7. [Deep Linking](#deep-linking)
8. [Navigation Patterns](#navigation-patterns)
9. [Feature-to-Component Mapping](#feature-to-component-mapping)
10. [Implementation Guide](#implementation-guide)

---

## Overview

ChekMate uses **GoRouter** for declarative routing with support for:
- ✅ Deep linking
- ✅ Nested navigation
- ✅ Modal routes
- ✅ Route guards (authentication)
- ✅ Transition animations
- ✅ State preservation

### Why GoRouter?

- **Declarative**: Define routes in a clear, maintainable way
- **Type-safe**: Full type safety with route parameters
- **Deep linking**: Built-in support for web URLs and app links
- **Nested routing**: Support for complex navigation hierarchies
- **State management**: Works seamlessly with Riverpod

---

## Routing Strategy

### Navigation Hierarchy

```
ChekMate App
├── Shell Route (Bottom Navigation)
│   ├── Home Feed (/home)
│   ├── Messages (/messages)
│   ├── Notifications (/notifications)
│   └── Profile (/profile)
├── Authentication Flow
│   ├── Welcome (/welcome)
│   ├── Sign In (/signin)
│   └── Sign Up (/signup)
├── Feature Routes
│   ├── Rate Your Date (/rate-date)
│   ├── Live Streaming (/live)
│   ├── Explore (/explore)
│   └── Subscribe (/subscribe)
└── Modal Routes
    ├── Post Creation
    ├── Story Viewer
    ├── User Profile
    └── Settings
```

### Route Naming Convention

- **Main routes**: `/route-name`
- **Nested routes**: `/parent/child`
- **Detail routes**: `/resource/:id`
- **Modal routes**: Use `showModalBottomSheet` or `showDialog`

---

## Route Structure

### Complete Route Map

```dart
// lib/core/routing/app_router.dart

final goRouter = GoRouter(
  initialLocation: '/welcome',
  debugLogDiagnostics: true,
  redirect: _authGuard,
  routes: [
    // Authentication Routes
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      builder: (context, state) => WelcomeScreen(),
    ),
    GoRoute(
      path: '/signin',
      name: 'signin',
      builder: (context, state) => SignInScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => SignUpScreen(),
    ),
    
    // Main App Shell with Bottom Navigation
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        // Home Feed
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: HomeFeedScreen(),
            transitionsBuilder: _fadeTransition,
          ),
          routes: [
            // Top Navigation Tabs (nested under home)
            GoRoute(
              path: 'for-you',
              name: 'for-you',
              builder: (context, state) => ForYouFeed(),
            ),
            GoRoute(
              path: 'following',
              name: 'following',
              builder: (context, state) => FollowingFeed(),
            ),
            GoRoute(
              path: 'explore',
              name: 'explore',
              builder: (context, state) => ExploreFeed(),
            ),
            GoRoute(
              path: 'live',
              name: 'live',
              builder: (context, state) => LiveFeed(),
            ),
          ],
        ),
        
        // Messages
        GoRoute(
          path: '/messages',
          name: 'messages',
          builder: (context, state) => MessagesScreen(),
          routes: [
            GoRoute(
              path: ':conversationId',
              name: 'conversation',
              builder: (context, state) {
                final conversationId = state.pathParameters['conversationId']!;
                return ConversationScreen(conversationId: conversationId);
              },
            ),
          ],
        ),
        
        // Notifications
        GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (context, state) => NotificationsScreen(),
        ),
        
        // Profile
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => MyProfileScreen(),
          routes: [
            GoRoute(
              path: 'edit',
              name: 'edit-profile',
              builder: (context, state) => EditProfileScreen(),
            ),
            GoRoute(
              path: 'settings',
              name: 'settings',
              builder: (context, state) => SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    
    // Feature Routes (outside bottom nav)
    GoRoute(
      path: '/rate-date',
      name: 'rate-date',
      builder: (context, state) => RateYourDateScreen(),
      routes: [
        GoRoute(
          path: 'create',
          name: 'create-rating',
          builder: (context, state) => CreateRatingScreen(),
        ),
        GoRoute(
          path: ':ratingId',
          name: 'rating-detail',
          builder: (context, state) {
            final ratingId = state.pathParameters['ratingId']!;
            return RatingDetailScreen(ratingId: ratingId);
          },
        ),
      ],
    ),
    
    GoRoute(
      path: '/live/:streamId',
      name: 'live-stream',
      builder: (context, state) {
        final streamId = state.pathParameters['streamId']!;
        return LiveStreamScreen(streamId: streamId);
      },
    ),
    
    GoRoute(
      path: '/subscribe',
      name: 'subscribe',
      builder: (context, state) => SubscriptionScreen(),
    ),
    
    GoRoute(
      path: '/user/:userId',
      name: 'user-profile',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return UserProfileScreen(userId: userId);
      },
    ),
    
    GoRoute(
      path: '/post/:postId',
      name: 'post-detail',
      builder: (context, state) {
        final postId = state.pathParameters['postId']!;
        return PostDetailScreen(postId: postId);
      },
    ),
    
    GoRoute(
      path: '/stories/:userId',
      name: 'story-viewer',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        final initialIndex = int.tryParse(state.uri.queryParameters['index'] ?? '0') ?? 0;
        return StoryViewerScreen(
          userId: userId,
          initialIndex: initialIndex,
        );
      },
    ),
  ],
);

// Auth Guard
String? _authGuard(BuildContext context, GoRouterState state) {
  final isAuthenticated = /* check auth state */;
  final isAuthRoute = state.matchedLocation.startsWith('/signin') ||
                      state.matchedLocation.startsWith('/signup') ||
                      state.matchedLocation == '/welcome';
  
  if (!isAuthenticated && !isAuthRoute) {
    return '/welcome';
  }
  if (isAuthenticated && isAuthRoute) {
    return '/home';
  }
  return null;
}

// Transition Builder
Widget _fadeTransition(context, animation, secondaryAnimation, child) {
  return FadeTransition(opacity: animation, child: child);
}
```

---

## Main Routes

### 1. Authentication Flow

#### Welcome Screen (`/welcome`)
**Purpose**: App introduction and entry point

**Components Used**:
- `AppButton` - Sign In / Sign Up buttons
- `AppCard` - Feature highlights
- `LottieAnimation` - Welcome animation
- `AppCarousel` - Onboarding slides

**Navigation**:
```dart
context.go('/signin');  // Navigate to sign in
context.go('/signup');  // Navigate to sign up
```

#### Sign In Screen (`/signin`)
**Purpose**: User authentication

**Components Used**:
- `AppInput` - Email/phone input
- `AppInput` - Password input (with visibility toggle)
- `AppButton` - Sign in button
- `AppAlert` - Error messages
- `AppProgress` - Loading indicator

**Navigation**:
```dart
// After successful login
context.go('/home');
```

#### Sign Up Screen (`/signup`)
**Purpose**: New user registration

**Components Used**:
- `AppInput` - Name, email, password fields
- `AppDatePicker` - Date of birth
- `AppCheckbox` - Terms acceptance
- `AppButton` - Create account button
- `AppFileUpload` - Profile photo upload

---

## Nested Routes

### 2. Home Feed (`/home`)

#### Main Feed Screen
**Purpose**: Primary content feed with top navigation tabs

**Components Used**:
- `AppTabs` - Top navigation (For You, Following, Explore, Live)
- `AppVirtualizedList` - Infinite scroll feed
- `AppCard` - Post cards
- `PostFeedShimmer` - Loading states
- `AppEmptyState` - No posts state
- `PullToRefreshAnimation` - Pull to refresh

**Sub-routes**:
- `/home/for-you` - Personalized feed
- `/home/following` - Following feed
- `/home/explore` - Discovery feed
- `/home/live` - Live streams

**Navigation**:
```dart
// Navigate between tabs
context.go('/home/for-you');
context.go('/home/following');
context.go('/home/explore');
```

#### For You Feed (`/home/for-you`)
**Components Used**:
- `AppCard` - Post cards
- `AppAvatar` - User avatars
- `AppBadge` - Verification badges
- `DoubleTapLike` - Like animation
- `SwipeableCard` - Swipe interactions

#### Following Feed (`/home/following`)
**Components Used**:
- Same as For You, filtered by following

#### Explore Feed (`/home/explore`)
**Components Used**:
- `AppInput` - Search bar
- `AppDropdownMenu` - Sort/filter options
- `AppGridVirtualizedList` - Grid layout
- `AppChip` - Category filters

#### Live Feed (`/home/live`)
**Components Used**:
- `AppVideoPlayer` - Live stream preview
- `AppBadge` - Live indicator
- `AppCard` - Stream cards

---

### 3. Messages (`/messages`)

#### Messages List Screen
**Purpose**: Conversation list

**Components Used**:
- `AppInput` - Search conversations
- `AppVirtualizedList` - Conversation list
- `AppAvatar` - User avatars
- `AppBadge` - Unread count
- `MessageListShimmer` - Loading state
- `AppEmptyState` - No messages

**Navigation**:
```dart
// Open conversation
context.go('/messages/${conversationId}');
```

#### Conversation Screen (`/messages/:conversationId`)
**Purpose**: Individual chat

**Components Used**:
- `AppScrollArea` - Message history
- `AppInput` - Message input
- `AppButton` - Send button
- `TypingIndicator` - Typing animation
- `AppAvatar` - User avatar
- `AppContextMenu` - Message actions

---

### 4. Notifications (`/notifications`)

**Purpose**: Activity feed

**Components Used**:
- `AppTabs` - Filter tabs (All, Mentions, Likes)
- `AppVirtualizedList` - Notification list
- `AppCard` - Notification cards
- `AppAvatar` - User avatars
- `AppBadge` - Unread indicator
- `AppEmptyState` - No notifications

---

### 5. Profile (`/profile`)

#### My Profile Screen
**Purpose**: User's own profile

**Components Used**:
- `ProfileHeaderShimmer` - Loading state
- `AppAvatar` - Profile picture
- `AppButton` - Edit profile button
- `AppTabs` - Content tabs (Posts, Ratings, About)
- `AppCard` - Stats cards
- `AppGridVirtualizedList` - Post grid

**Sub-routes**:
- `/profile/edit` - Edit profile
- `/profile/settings` - Settings

**Navigation**:
```dart
context.go('/profile/edit');
context.go('/profile/settings');
```

#### Edit Profile Screen (`/profile/edit`)
**Purpose**: Edit user profile information

**Components Used**:
- `AppInput` - Name, bio, location fields
- `AppFileUpload` - Profile photo upload
- `AppDatePicker` - Date of birth
- `AppButton` - Save/cancel buttons
- `AppAlert` - Success/error messages

#### Settings Screen (`/profile/settings`)
**Purpose**: App settings and preferences

**Components Used**:
- `AppAccordion` - Settings categories
- `AppSwitch` - Toggle settings
- `AppSelect` - Dropdown settings
- `AppButton` - Action buttons
- `AppDialog` - Confirmation dialogs

---

## Feature Routes

### 6. Rate Your Date (`/rate-date`)

#### Rate Your Date Screen
**Purpose**: Main rating feed and creation

**Components Used**:
- `AppTabs` - Filter tabs (Recent, Top Rated, Following)
- `SwipeableCard` - Swipeable rating cards
- `AppButton` - Create rating button
- `AppCard` - Rating cards
- `AppAvatar` - User avatars
- `AppBadge` - Rating badges

**Sub-routes**:
- `/rate-date/create` - Create new rating
- `/rate-date/:ratingId` - View rating detail

**Navigation**:
```dart
// Create new rating
context.go('/rate-date/create');

// View rating detail
context.go('/rate-date/${ratingId}');
```

#### Create Rating Screen (`/rate-date/create`)
**Purpose**: Create a new date rating

**Components Used**:
- `AppInput` - Date name, location
- `AppDatePicker` - Date of the date
- `AppSlider` - Rating scales (1-10)
- `AppTextarea` - Experience description
- `AppFileUpload` - Photo upload
- `AppCheckbox` - Category selections
- `AppButton` - Submit button
- `AppProgress` - Upload progress

**Example Flow**:
```dart
// Step 1: Basic info
AppInput(label: 'Date Name', controller: nameController)
AppDatePicker(label: 'Date', onDateSelected: setDate)

// Step 2: Ratings
AppSlider(
  label: 'Overall Rating',
  min: 1,
  max: 10,
  value: overallRating,
  onChanged: setOverallRating,
)

// Step 3: Description
AppTextarea(
  label: 'Tell us about your experience',
  maxLength: 500,
  controller: descriptionController,
)

// Step 4: Submit
AppButton(
  variant: AppButtonVariant.primary,
  onPressed: submitRating,
  isLoading: isSubmitting,
  child: Text('Submit Rating'),
)
```

#### Rating Detail Screen (`/rate-date/:ratingId`)
**Purpose**: View detailed rating

**Components Used**:
- `AppCard` - Rating card
- `AppAvatar` - User avatar
- `AppBadge` - Rating badges
- `AppChart` - Rating breakdown
- `AppButton` - Like/share buttons
- `AppContextMenu` - Report/block options

---

### 7. Live Streaming (`/live/:streamId`)

**Purpose**: Watch live streams

**Components Used**:
- `AppVideoPlayer` - Live stream player
- `AppBadge` - Live indicator, viewer count
- `AppInput` - Chat input
- `AppVirtualizedList` - Chat messages
- `AppButton` - Follow/gift buttons
- `AppBottomSheet` - Gift selection

**Features**:
- Real-time chat
- Viewer count
- Gift sending
- Stream controls

---

### 8. Subscribe (`/subscribe`)

**Purpose**: Subscription plans and premium features

**Components Used**:
- `AppCard` - Plan cards
- `AppButton` - Subscribe buttons
- `AppBadge` - Popular/recommended badges
- `AppAccordion` - FAQ
- `AppDialog` - Payment confirmation

**Example**:
```dart
AppCard(
  child: Column(
    children: [
      Text('Premium Plan'),
      Text('\$9.99/month'),
      AppButton(
        variant: AppButtonVariant.primary,
        onPressed: () => subscribeToPlan('premium'),
        child: Text('Subscribe'),
      ),
    ],
  ),
)
```

---

### 9. User Profile (`/user/:userId`)

**Purpose**: View other users' profiles

**Components Used**:
- `ProfileHeaderShimmer` - Loading state
- `AppAvatar` - Profile picture with hero animation
- `AppButton` - Follow/message buttons
- `AppTabs` - Content tabs
- `AppGridVirtualizedList` - Post grid
- `AppBadge` - Verification badge

**Navigation**:
```dart
// From post
context.go('/user/${post.userId}');

// From search
context.go('/user/${searchResult.userId}');
```

**Hero Animation**:
```dart
// In feed
SharedAvatarTransition(
  tag: SharedElementTransition.avatarTag(userId),
  imageUrl: user.avatarUrl,
)

// In profile
SharedAvatarTransition(
  tag: SharedElementTransition.avatarTag(userId),
  imageUrl: user.avatarUrl,
  radius: 60,
)
```

---

### 10. Post Detail (`/post/:postId`)

**Purpose**: View individual post with comments

**Components Used**:
- `AppCard` - Post card
- `AppAvatar` - User avatar
- `AppVideoPlayer` - Video posts
- `AppImageViewer` - Image posts
- `AppVirtualizedList` - Comments
- `AppInput` - Comment input
- `AppButton` - Like/share buttons
- `AppBottomSheet` - Share options

**Navigation**:
```dart
// From feed
context.go('/post/${post.id}');

// Deep link
// chekmate://post/abc123
```

---

### 11. Story Viewer (`/stories/:userId`)

**Purpose**: View user stories (Instagram-style)

**Components Used**:
- `AppImageViewer` - Story images
- `AppVideoPlayer` - Story videos
- `AppProgress` - Story progress indicator
- `AppInput` - Reply input
- `AppButton` - Navigation buttons

**Query Parameters**:
- `index` - Initial story index

**Navigation**:
```dart
// View stories
context.go('/stories/${userId}?index=0');

// Navigate between stories
context.go('/stories/${userId}?index=${currentIndex + 1}');
```

**Gestures**:
- Tap left: Previous story
- Tap right: Next story
- Swipe down: Close viewer
- Long press: Pause

---

## Modal Routes

### Post Creation Modal

**Trigger**: Bottom nav "Create" button

**Implementation**:
```dart
void showPostCreationModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => AppBottomSheet(
      child: PostCreationForm(),
    ),
  );
}
```

**Components Used**:
- `AppBottomSheet` - Modal container
- `AppTextarea` - Caption input
- `AppFileUpload` - Media upload
- `AppButton` - Post button
- `AppProgress` - Upload progress

### Share Modal

**Trigger**: Share button on posts

**Implementation**:
```dart
void showShareModal(BuildContext context, Post post) {
  showModalBottomSheet(
    context: context,
    builder: (context) => AppBottomSheet(
      child: ShareOptions(post: post),
    ),
  );
}
```

**Components Used**:
- `AppBottomSheet` - Modal container
- `AppButton` - Share options
- `AppInput` - Message input

### Filter Modal

**Trigger**: Filter button on Explore

**Implementation**:
```dart
void showFilterModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => AppBottomSheet(
      child: FilterPanel(),
    ),
  );
}
```

**Components Used**:
- `AppBottomSheet` - Modal container
- `AppCheckbox` - Filter options
- `AppSlider` - Range filters
- `AppButton` - Apply/reset buttons

---

## Deep Linking

### URL Scheme

**App Scheme**: `chekmate://`

**Web URLs**: `https://chekmate.app/`

### Supported Deep Links

```dart
// User profile
chekmate://user/abc123
https://chekmate.app/user/abc123

// Post detail
chekmate://post/xyz789
https://chekmate.app/post/xyz789

// Rating detail
chekmate://rate-date/rating123
https://chekmate.app/rate-date/rating123

// Live stream
chekmate://live/stream456
https://chekmate.app/live/stream456

// Stories
chekmate://stories/user123?index=2
https://chekmate.app/stories/user123?index=2

// Conversation
chekmate://messages/conv789
https://chekmate.app/messages/conv789
```

### Implementation

```dart
// In main.dart
MaterialApp.router(
  routerConfig: goRouter,
  // Deep link handling is automatic with GoRouter
)

// Handle custom schemes in AndroidManifest.xml and Info.plist
```

---

## Navigation Patterns

### 1. Bottom Navigation Pattern

**Implementation**:
```dart
class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/messages');
        break;
      case 2:
        _showPostCreationModal();
        break;
      case 3:
        context.go('/notifications');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: AppBottomMenubar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          AppBottomMenubarItem(icon: Icons.home, label: 'Home'),
          AppBottomMenubarItem(icon: Icons.message, label: 'Messages'),
          AppBottomMenubarItem(icon: Icons.add_circle, label: 'Create'),
          AppBottomMenubarItem(icon: Icons.notifications, label: 'Notifications'),
          AppBottomMenubarItem(icon: Icons.person, label: 'Profile'),
        ],
      ),
    );
  }
}
```

### 2. Tab Navigation Pattern

**Implementation**:
```dart
class HomeFeedScreen extends StatefulWidget {
  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChekMate'),
        bottom: AppTabs(
          selectedIndex: _selectedTab,
          onTabChange: (index) {
            setState(() => _selectedTab = index);
            _navigateToTab(index);
          },
          tabs: [
            AppTab(label: 'For You'),
            AppTab(label: 'Following'),
            AppTab(label: 'Explore'),
            AppTab(label: 'Live'),
          ],
        ),
      ),
      body: _buildTabContent(),
    );
  }

  void _navigateToTab(int index) {
    final routes = [
      '/home/for-you',
      '/home/following',
      '/home/explore',
      '/home/live',
    ];
    context.go(routes[index]);
  }
}
```

### 3. Modal Navigation Pattern

**Implementation**:
```dart
// Show modal
void showModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => AppBottomSheet(
      child: ModalContent(),
    ),
  );
}

// Dismiss modal
Navigator.pop(context);

// Dismiss with result
Navigator.pop(context, result);
```

### 4. Hero Animation Pattern

**Implementation**:
```dart
// Source screen
GestureDetector(
  onTap: () => context.go('/post/${post.id}'),
  child: AppHero(
    tag: 'post-image-${post.id}',
    child: Image.network(post.imageUrl),
  ),
)

// Destination screen
AppHero(
  tag: 'post-image-${post.id}',
  child: Image.network(post.imageUrl),
)
```

---

## Feature-to-Component Mapping

### Authentication Pages

| Feature | Components |
|---------|-----------|
| Welcome Screen | `AppButton`, `AppCard`, `AppCarousel`, `LottieAnimation` |
| Sign In | `AppInput`, `AppButton`, `AppAlert`, `AppProgress` |
| Sign Up | `AppInput`, `AppDatePicker`, `AppCheckbox`, `AppFileUpload` |
| Password Reset | `AppInput`, `AppButton`, `AppAlert` |

### Feed Pages

| Feature | Components |
|---------|-----------|
| For You Feed | `AppVirtualizedList`, `AppCard`, `DoubleTapLike`, `PostFeedShimmer` |
| Following Feed | `AppVirtualizedList`, `AppCard`, `AppEmptyState` |
| Explore Feed | `AppGridVirtualizedList`, `AppInput`, `AppDropdownMenu` |
| Live Feed | `AppCard`, `AppVideoPlayer`, `AppBadge` |

### Social Features

| Feature | Components |
|---------|-----------|
| Post Creation | `AppBottomSheet`, `AppTextarea`, `AppFileUpload`, `AppButton` |
| Comments | `AppVirtualizedList`, `AppInput`, `AppAvatar` |
| Stories | `AppImageViewer`, `AppVideoPlayer`, `AppProgress` |
| Sharing | `AppBottomSheet`, `AppButton` |

### Messaging

| Feature | Components |
|---------|-----------|
| Message List | `AppVirtualizedList`, `AppAvatar`, `AppBadge`, `MessageListShimmer` |
| Conversation | `AppScrollArea`, `AppInput`, `TypingIndicator` |
| Search | `AppInput`, `AppVirtualizedList` |

### Profile

| Feature | Components |
|---------|-----------|
| Profile View | `AppAvatar`, `AppTabs`, `AppGridVirtualizedList`, `AppButton` |
| Edit Profile | `AppInput`, `AppFileUpload`, `AppDatePicker`, `AppButton` |
| Settings | `AppAccordion`, `AppSwitch`, `AppSelect`, `AppButton` |

### Rate Your Date

| Feature | Components |
|---------|-----------|
| Rating Feed | `SwipeableCard`, `AppCard`, `AppBadge` |
| Create Rating | `AppInput`, `AppSlider`, `AppTextarea`, `AppFileUpload` |
| Rating Detail | `AppCard`, `AppChart`, `AppButton` |

### Live Streaming

| Feature | Components |
|---------|-----------|
| Stream View | `AppVideoPlayer`, `AppVirtualizedList`, `AppInput` |
| Chat | `AppVirtualizedList`, `AppInput`, `AppBadge` |
| Gifts | `AppBottomSheet`, `AppButton` |

### Subscription

| Feature | Components |
|---------|-----------|
| Plans | `AppCard`, `AppButton`, `AppBadge` |
| Payment | `AppDialog`, `AppButton`, `AppProgress` |
| FAQ | `AppAccordion` |

---

## Implementation Guide

### Step 1: Setup GoRouter

```dart
// pubspec.yaml
dependencies:
  go_router: ^13.0.0
```

### Step 2: Create Router Configuration

```dart
// lib/core/routing/app_router.dart
import 'package:go_router/go_router.dart';

final goRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    // Add routes here
  ],
);
```

### Step 3: Update Main App

```dart
// lib/main.dart
import 'core/routing/app_router.dart';

class ChekMateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: goRouter,
      title: 'ChekMate',
      theme: ThemeData(/* ... */),
    );
  }
}
```

### Step 4: Create Page Screens

```dart
// lib/features/auth/presentation/screens/signin_screen.dart
class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: SignInForm(),
    );
  }
}
```

### Step 5: Implement Navigation

```dart
// Navigate to route
context.go('/home');

// Navigate with parameters
context.go('/user/${userId}');

// Navigate with query parameters
context.go('/stories/${userId}?index=2');

// Go back
context.pop();

// Replace current route
context.replace('/home');
```

---

## Best Practices

### 1. Route Organization

- Group related routes together
- Use nested routes for hierarchical navigation
- Keep route definitions close to feature code

### 2. Type Safety

```dart
// Define route names as constants
class Routes {
  static const home = '/home';
  static const profile = '/profile';
  static const userProfile = '/user/:userId';
}

// Use named routes
context.go(Routes.home);
```

### 3. Error Handling

```dart
final goRouter = GoRouter(
  routes: [/* ... */],
  errorBuilder: (context, state) => ErrorScreen(
    error: state.error,
  ),
);
```

### 4. Loading States

```dart
final goRouter = GoRouter(
  routes: [/* ... */],
  redirect: (context, state) {
    final isLoading = /* check loading state */;
    if (isLoading) return '/loading';
    return null;
  },
);
```

### 5. Analytics

```dart
final goRouter = GoRouter(
  routes: [/* ... */],
  observers: [
    AnalyticsObserver(),
  ],
);
```

---

## Next Steps

1. **Implement** the router configuration in `lib/core/routing/app_router.dart`
2. **Create** page screens for each route
3. **Add** navigation to existing components
4. **Test** deep linking on iOS and Android
5. **Review** the [Components Guide](./COMPONENTS_GUIDE.md) for component usage

---

**Last Updated**: January 15, 2025
**Total Routes**: 25+
**Status**: Ready for Implementation ✅


