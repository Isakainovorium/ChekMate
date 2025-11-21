# ChekMate Flutter Components Guide

> **Complete reference for all 70+ enterprise-grade UI components, animations, and loading states**
>
> Last Updated: november 15, 2025

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Component Categories](#component-categories)
3. [Form Components](#form-components)
4. [Layout Components](#layout-components)
5. [Feedback Components](#feedback-components)
6. [Data Display Components](#data-display-components)
7. [Navigation Components](#navigation-components)
8. [Advanced Components](#advanced-components)
9. [Animation Components](#animation-components)
10. [Loading Components](#loading-components)
11. [Best Practices](#best-practices)

---

## Overview

ChekMate includes **70+ production-ready Flutter components** designed for a modern dating experience platform. All components follow Material Design 3 principles, support dark mode, and are optimized for performance.

### Import Path
```dart
import 'package:flutter_chekmate/shared/ui/index.dart';
```

### Component Philosophy
- **Consistent**: All components follow the same design language
- **Accessible**: Built with accessibility in mind
- **Performant**: Optimized for smooth 60fps animations
- **Customizable**: Extensive theming and styling options
- **Type-safe**: Full Dart type safety with null safety

---

## Component Categories

### Quick Reference

| Category | Count | Use Cases |
|----------|-------|-----------|
| **Form Components** | 13 | User input, data collection, authentication |
| **Layout Components** | 11 | Page structure, content organization |
| **Feedback Components** | 8 | User notifications, loading states, errors |
| **Data Display** | 10 | Showing user data, statistics, content |
| **Navigation** | 9 | App navigation, menus, routing |
| **Advanced** | 7 | Complex interactions, media, lists |
| **Animations** | 12 | Page transitions, interactions, effects |
| **Loading States** | 9 | Skeleton screens, shimmer effects |

---

## Form Components

### 1. AppButton
**Purpose**: Primary action buttons with multiple variants and states

**Variants**:
- `primary` - Filled button for primary actions
- `secondary` - Elevated button for secondary actions
- `outline` - Outlined button for tertiary actions
- `text` - Text-only button for subtle actions

**Sizes**: `sm`, `md`, `lg`

**When to Use**:
- ✅ Authentication screens (Sign In, Sign Up)
- ✅ Post creation (Submit, Cancel)
- ✅ Profile actions (Edit Profile, Follow)
- ✅ Rate Your Date submission

**Example**:
```dart
AppButton(
  variant: AppButtonVariant.primary,
  size: AppButtonSize.lg,
  onPressed: () => submitRating(),
  isLoading: isSubmitting,
  child: Text('Submit Rating'),
)
```

### 2. AppInput
**Purpose**: Text input fields with validation and styling

**Features**:
- Label and hint text support
- Error state with messages
- Prefix/suffix icons
- Password visibility toggle
- Character counter

**When to Use**:
- ✅ Login/signup forms
- ✅ Profile editing
- ✅ Search functionality
- ✅ Comment/message input
- ✅ Date rating descriptions

**Example**:
```dart
AppInput(
  label: 'Email',
  hintText: 'Enter your email',
  prefixIcon: Icons.email,
  validator: (value) => EmailValidator.validate(value),
  errorText: emailError,
)
```

### 3. AppCheckbox
**Purpose**: Boolean selection with label support

**When to Use**:
- ✅ Terms & conditions acceptance
- ✅ Privacy settings
- ✅ Filter selections (Explore page)
- ✅ Multi-select options

### 4. AppRadioGroup
**Purpose**: Single selection from multiple options

**When to Use**:
- ✅ Gender selection
- ✅ Date rating categories
- ✅ Subscription plan selection
- ✅ Report reasons

### 5. AppSelect / AppDropdownMenu
**Purpose**: Dropdown selection from a list

**When to Use**:
- ✅ Location selection
- ✅ Age range filters
- ✅ Sort options (Explore)
- ✅ Language preferences

### 6. AppSwitch
**Purpose**: Toggle between two states

**When to Use**:
- ✅ Notification settings
- ✅ Privacy toggles (profile visibility)
- ✅ Dark mode toggle
- ✅ Live streaming status

### 7. AppSlider
**Purpose**: Select value from a range

**When to Use**:
- ✅ Age range filters
- ✅ Distance preferences
- ✅ Rating scales (1-10)
- ✅ Volume controls (Live streams)

### 8. AppTextarea
**Purpose**: Multi-line text input

**When to Use**:
- ✅ Bio/about me sections
- ✅ Date experience descriptions
- ✅ Post captions
- ✅ Message composition

### 9. AppDatePicker
**Purpose**: Date selection with calendar UI

**When to Use**:
- ✅ Date of birth input
- ✅ Date experience date selection
- ✅ Event scheduling
- ✅ Filter by date range

### 10. AppTimePicker
**Purpose**: Time selection

**When to Use**:
- ✅ Live stream scheduling
- ✅ Event time selection
- ✅ Reminder settings

### 11. AppColorPicker
**Purpose**: Color selection

**When to Use**:
- ✅ Theme customization
- ✅ Profile accent colors
- ✅ Story text colors

### 12. AppFileUpload
**Purpose**: File/image upload with preview

**When to Use**:
- ✅ Profile photo upload
- ✅ Post image/video upload
- ✅ Story creation
- ✅ Date experience photos

### 13. AppInputOTP
**Purpose**: One-time password input

**When to Use**:
- ✅ Phone verification
- ✅ Two-factor authentication
- ✅ Account recovery

---

## Layout Components

### 1. AppCard
**Purpose**: Standard content container with elevation

**When to Use**:
- ✅ Post cards in feed
- ✅ User profile cards
- ✅ Date rating cards
- ✅ Subscription plan cards
- ✅ Settings sections

**Example**:
```dart
AppCard(
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      UserAvatar(),
      PostContent(),
      PostActions(),
    ],
  ),
)
```

### 2. AppDrawer / AppMiniDrawer
**Purpose**: Side navigation drawer

**When to Use**:
- ✅ Desktop/tablet navigation
- ✅ Settings menu
- ✅ Account switching
- ✅ Quick actions menu

### 3. AppSheet / AppBottomSheet
**Purpose**: Modal sheets from bottom or side

**When to Use**:
- ✅ Post creation modal
- ✅ Share options
- ✅ Filter panels
- ✅ Comment sections
- ✅ Report/block options

### 4. AppTabs
**Purpose**: Tabbed content navigation

**When to Use**:
- ✅ Top navigation (For You, Following, Explore, etc.)
- ✅ Profile sections (Posts, Ratings, About)
- ✅ Settings categories
- ✅ Message filters (All, Unread, Archived)

### 5. AppAccordion
**Purpose**: Collapsible content sections

**When to Use**:
- ✅ FAQ sections
- ✅ Privacy policy
- ✅ Advanced settings
- ✅ Filter categories

### 6. AppSeparator
**Purpose**: Visual divider between content

**When to Use**:
- ✅ Between posts in feed
- ✅ Between settings sections
- ✅ Between navigation items

### 7. AppAspectRatio
**Purpose**: Maintain aspect ratio for media

**When to Use**:
- ✅ Post images (16:9, 4:3, 1:1)
- ✅ Video players
- ✅ Story frames
- ✅ Profile photos

### 8. AppResizable
**Purpose**: Resizable panels

**When to Use**:
- ✅ Desktop split views
- ✅ Chat + profile view
- ✅ Admin dashboards

### 9. AppScrollArea
**Purpose**: Custom scrollable area

**When to Use**:
- ✅ Long content sections
- ✅ Message history
- ✅ Feed scrolling
- ✅ Settings pages

---

## Feedback Components

### 1. AppAlert
**Purpose**: Inline alert messages

**Variants**: `info`, `success`, `warning`, `error`

**When to Use**:
- ✅ Form validation errors
- ✅ Success confirmations
- ✅ Warning messages
- ✅ Information banners

### 2. AppDialog / AppConfirmDialog
**Purpose**: Modal dialogs for important actions

**When to Use**:
- ✅ Delete confirmations
- ✅ Logout confirmation
- ✅ Block/report user
- ✅ Subscription cancellation
- ✅ Important announcements

### 3. AppNotificationBanner
**Purpose**: Toast-style notifications

**When to Use**:
- ✅ Post published
- ✅ Message sent
- ✅ New follower
- ✅ Rating submitted
- ✅ Error notifications

### 4. AppProgress
**Purpose**: Progress indicators (linear/circular)

**When to Use**:
- ✅ File upload progress
- ✅ Profile completion
- ✅ Loading states
- ✅ Story progress

### 5. AppSkeleton
**Purpose**: Skeleton loading placeholders

**When to Use**:
- ✅ Initial page load
- ✅ Lazy loading content
- ✅ Optimistic UI updates

### 6. AppEmptyState
**Purpose**: Empty state illustrations

**When to Use**:
- ✅ No posts yet
- ✅ No messages
- ✅ No notifications
- ✅ No search results
- ✅ No ratings yet

### 7. AppErrorBoundary
**Purpose**: Error handling wrapper

**When to Use**:
- ✅ Wrap entire app
- ✅ Wrap feature modules
- ✅ Wrap async operations

---

## Data Display Components

### 1. AppTable
**Purpose**: Tabular data display

**When to Use**:
- ✅ Admin dashboards
- ✅ Analytics data
- ✅ User lists (admin)
- ✅ Transaction history

### 2. AppChart / AppSparkline
**Purpose**: Data visualization

**When to Use**:
- ✅ Profile statistics
- ✅ Rating trends
- ✅ Engagement metrics
- ✅ Subscription analytics

### 3. AppBadge
**Purpose**: Small status indicators

**When to Use**:
- ✅ Notification counts
- ✅ Unread message badges
- ✅ New content indicators
- ✅ Verification badges
- ✅ Premium badges

### 4. AppAvatar
**Purpose**: User profile pictures

**When to Use**:
- ✅ User profiles
- ✅ Post headers
- ✅ Comment sections
- ✅ Message lists
- ✅ Follower lists

### 5. AppTooltip
**Purpose**: Hover information

**When to Use**:
- ✅ Icon explanations
- ✅ Feature hints
- ✅ Abbreviated text
- ✅ Help text

### 6. AppHoverCard
**Purpose**: Rich hover previews

**When to Use**:
- ✅ User profile previews
- ✅ Link previews
- ✅ Post previews

### 7. AppBreadcrumb
**Purpose**: Navigation trail

**When to Use**:
- ✅ Settings navigation
- ✅ Multi-step forms
- ✅ Deep navigation paths

### 8. AppLabel
**Purpose**: Form field labels

**When to Use**:
- ✅ All form inputs
- ✅ Settings options
- ✅ Filter labels

### 9. AppPagination
**Purpose**: Page navigation

**When to Use**:
- ✅ Search results
- ✅ User lists
- ✅ Content archives
- ✅ Admin panels

---

## Navigation Components

### 1. AppMenubar / AppBottomMenubar
**Purpose**: Main navigation bars

**When to Use**:
- ✅ Bottom navigation (Home, Messages, Create, Notifications, Profile)
- ✅ Top menu bar (desktop)
- ✅ Settings navigation

**Example**:
```dart
AppBottomMenubar(
  currentIndex: selectedIndex,
  onTap: (index) => navigateToPage(index),
  items: [
    AppBottomMenubarItem(icon: Icons.home, label: 'Home'),
    AppBottomMenubarItem(icon: Icons.message, label: 'Messages'),
    AppBottomMenubarItem(icon: Icons.add_circle, label: 'Create'),
    AppBottomMenubarItem(icon: Icons.notifications, label: 'Notifications'),
    AppBottomMenubarItem(icon: Icons.person, label: 'Profile'),
  ],
)
```

### 2. AppContextMenu
**Purpose**: Right-click/long-press context menus

**When to Use**:
- ✅ Post actions (Edit, Delete, Share, Report)
- ✅ Message actions (Copy, Delete, Forward)
- ✅ User actions (Block, Report, Mute)

### 3. AppCommandMenu
**Purpose**: Command palette for quick actions

**When to Use**:
- ✅ Quick search (Cmd+K)
- ✅ Navigation shortcuts
- ✅ Admin actions

### 4. AppPopover
**Purpose**: Floating content panels

**When to Use**:
- ✅ User profile previews
- ✅ Emoji picker
- ✅ Quick actions menu
- ✅ Filter panels

### 5. AppDropdownMenu
**Purpose**: Dropdown menus

**When to Use**:
- ✅ Sort options
- ✅ Filter menus
- ✅ Action menus
- ✅ Settings dropdowns

---

## Advanced Components

### 1. AppVirtualizedList / AppGridVirtualizedList
**Purpose**: Performance-optimized lists for large datasets

**When to Use**:
- ✅ Feed scrolling (thousands of posts)
- ✅ Message history
- ✅ User lists
- ✅ Search results
- ✅ Explore grid

**Example**:
```dart
AppVirtualizedList<Post>(
  items: posts,
  itemBuilder: (context, post, index) => PostCard(post: post),
  onItemTap: (post) => navigateToPost(post.id),
  emptyBuilder: (context) => AppEmptyState(
    title: 'No posts yet',
    description: 'Start following users to see their posts',
  ),
  loadingBuilder: (context) => PostFeedShimmer(),
)
```

### 2. AppInfiniteScroll
**Purpose**: Infinite scrolling with pagination

**When to Use**:
- ✅ Feed pagination
- ✅ Search results
- ✅ User lists
- ✅ Message history

### 3. AppCarousel
**Purpose**: Swipeable image/content carousel

**When to Use**:
- ✅ Post image galleries
- ✅ Onboarding slides
- ✅ Story highlights
- ✅ Featured content

### 4. AppImageViewer
**Purpose**: Full-screen image viewer with zoom

**When to Use**:
- ✅ View post images
- ✅ View profile photos
- ✅ View story images
- ✅ Photo galleries

### 5. AppVideoPlayer
**Purpose**: Video playback with controls

**When to Use**:
- ✅ Post videos
- ✅ Live streams
- ✅ Story videos
- ✅ Video messages

### 6. AppCalendar
**Purpose**: Calendar view and date selection

**When to Use**:
- ✅ Event scheduling
- ✅ Date range selection
- ✅ Availability calendar
- ✅ Booking system

### 7. AppToggleGroup
**Purpose**: Multiple toggle buttons

**When to Use**:
- ✅ View mode toggles (Grid/List)
- ✅ Filter toggles
- ✅ Text formatting (Bold, Italic, Underline)

---

## Animation Components

### Page Transitions

#### 1. SlidePageRoute
**Purpose**: Slide transition between pages

**When to Use**:
- ✅ Forward navigation (left to right)
- ✅ Back navigation (right to left)
- ✅ Modal presentations (bottom to top)

**Example**:
```dart
Navigator.push(
  context,
  SlidePageRoute(
    page: UserProfileScreen(userId: userId),
    direction: AxisDirection.left,
  ),
);
```

#### 2. FadePageRoute
**Purpose**: Fade transition between pages

**When to Use**:
- ✅ Tab switching
- ✅ Subtle transitions
- ✅ Modal overlays

#### 3. ScalePageRoute
**Purpose**: Scale/zoom transition

**When to Use**:
- ✅ Image detail view
- ✅ Modal dialogs
- ✅ Expanding cards

#### 4. SlideFadePageRoute
**Purpose**: Combined slide and fade

**When to Use**:
- ✅ Premium transitions
- ✅ Feature highlights
- ✅ Smooth page changes

### Interactive Animations

#### 5. AnimatedButton
**Purpose**: Button with press animation

**When to Use**:
- ✅ All interactive buttons
- ✅ Like buttons
- ✅ Action buttons

#### 6. AnimatedCard
**Purpose**: Card with hover/press effects

**When to Use**:
- ✅ Post cards
- ✅ User cards
- ✅ Interactive content

#### 7. AnimatedIcon
**Purpose**: Icon with tap animation

**When to Use**:
- ✅ Like/favorite icons
- ✅ Menu icons
- ✅ Action icons

### TikTok-Style Animations

#### 8. SwipeableCard
**Purpose**: Swipeable cards (Tinder-style)

**When to Use**:
- ✅ Rate Your Date cards
- ✅ User discovery
- ✅ Content browsing

**Example**:
```dart
SwipeableCard(
  onSwipeLeft: () => rejectDate(),
  onSwipeRight: () => approveDate(),
  child: DateRatingCard(date: currentDate),
)
```

#### 9. DoubleTapLike
**Purpose**: Double-tap to like animation

**When to Use**:
- ✅ Post likes (Instagram-style)
- ✅ Photo likes
- ✅ Story reactions

#### 10. PullToRefreshAnimation
**Purpose**: Pull-to-refresh gesture

**When to Use**:
- ✅ Feed refresh
- ✅ Message list refresh
- ✅ Notification refresh

### Hero Animations

#### 11. AppHero / SharedImageTransition
**Purpose**: Shared element transitions

**When to Use**:
- ✅ Image expansion (thumbnail to full)
- ✅ Avatar to profile
- ✅ Card to detail view

**Example**:
```dart
// In feed
AppHero(
  tag: 'post-${post.id}',
  child: PostImage(post: post),
)

// In detail view
AppHero(
  tag: 'post-${post.id}',
  child: FullScreenImage(post: post),
)
```

#### 12. SharedAvatarTransition
**Purpose**: Avatar shared element

**When to Use**:
- ✅ Avatar to profile transition
- ✅ Comment to user profile
- ✅ Message to user profile

---

## Loading Components

### Shimmer Effects

#### 1. ShimmerLoading
**Purpose**: Generic shimmer effect wrapper

**When to Use**:
- ✅ Any loading state
- ✅ Custom shimmer layouts

#### 2. PostFeedShimmer
**Purpose**: Post card loading skeleton

**When to Use**:
- ✅ Feed loading
- ✅ Profile posts loading
- ✅ Search results loading

**Example**:
```dart
isLoading
  ? PostFeedShimmer(itemCount: 5)
  : PostList(posts: posts)
```

#### 3. MessageListShimmer
**Purpose**: Message list loading skeleton

**When to Use**:
- ✅ Messages screen loading
- ✅ Conversation list loading

#### 4. ProfileHeaderShimmer
**Purpose**: Profile header loading skeleton

**When to Use**:
- ✅ Profile screen loading
- ✅ User profile loading

#### 5. StoryCircleShimmer
**Purpose**: Story circles loading skeleton

**When to Use**:
- ✅ Stories loading
- ✅ Highlights loading

#### 6. ShimmerCard
**Purpose**: Generic card shimmer

**When to Use**:
- ✅ Any card loading
- ✅ Custom card layouts

#### 7. ShimmerImage
**Purpose**: Image placeholder shimmer

**When to Use**:
- ✅ Image loading
- ✅ Thumbnail loading

#### 8. ShimmerListItem
**Purpose**: List item shimmer

**When to Use**:
- ✅ Generic list loading
- ✅ Settings list loading

#### 9. AppSkeleton
**Purpose**: Custom skeleton shapes

**When to Use**:
- ✅ Custom loading layouts
- ✅ Complex shimmer patterns

---

## Best Practices

### Component Selection

1. **Use the right component for the job**
   - Don't use `AppButton` for navigation - use `AppMenubar`
   - Don't use `AppDialog` for non-critical info - use `AppNotificationBanner`
   - Don't use `AppCard` for everything - consider `AppSheet` for modals

2. **Optimize for performance**
   - Use `AppVirtualizedList` for long lists (>50 items)
   - Use shimmer loading for better perceived performance
   - Lazy load images with `cached_network_image`

3. **Maintain consistency**
   - Use the same button variant for similar actions
   - Use consistent spacing (AppSpacing constants)
   - Follow Material Design 3 guidelines

### Accessibility

1. **Always provide labels**
   ```dart
   AppButton(
     onPressed: () => submitForm(),
     child: Text('Submit'),
     // Semantic label for screen readers
   )
   ```

2. **Use semantic colors**
   - Error states: Use error color scheme
   - Success states: Use success color scheme
   - Warnings: Use warning color scheme

3. **Support keyboard navigation**
   - All interactive elements should be focusable
   - Provide keyboard shortcuts for common actions

### Performance

1. **Use const constructors**
   ```dart
   const AppCard(
     child: Text('Static content'),
   )
   ```

2. **Avoid rebuilding unnecessarily**
   - Use `const` where possible
   - Use `ValueListenableBuilder` for targeted rebuilds
   - Use Riverpod providers for state management

3. **Optimize images**
   - Use `AppAspectRatio` to prevent layout shifts
   - Use `cached_network_image` for network images
   - Provide placeholder images

### Theming

1. **Use theme colors**
   ```dart
   AppButton(
     variant: AppButtonVariant.primary, // Uses theme primary color
     child: Text('Action'),
   )
   ```

2. **Support dark mode**
   - All components automatically support dark mode
   - Test in both light and dark themes
   - Use semantic colors from theme

3. **Customize when needed**
   ```dart
   AppCard(
     padding: EdgeInsets.all(AppSpacing.lg),
     elevation: 2.0,
     child: CustomContent(),
   )
   ```

---

## Quick Reference

### Component Import
```dart
import 'package:flutter_chekmate/shared/ui/index.dart';
```

### Common Patterns

**Form with validation**:
```dart
AppForm(
  children: [
    AppInput(label: 'Email', validator: EmailValidator.validate),
    AppInput(label: 'Password', obscureText: true),
    AppButton(onPressed: submit, child: Text('Sign In')),
  ],
)
```

**List with loading**:
```dart
isLoading
  ? PostFeedShimmer()
  : AppVirtualizedList(
      items: posts,
      itemBuilder: (context, post, index) => PostCard(post),
    )
```

**Modal sheet**:
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => AppBottomSheet(
    child: FilterOptions(),
  ),
);
```

**Navigation with animation**:
```dart
Navigator.push(
  context,
  SlidePageRoute(page: ProfileScreen()),
);
```

---

## Next Steps

1. **Review** the [Routing Architecture](./ROUTING_ARCHITECTURE.md) to understand navigation
2. **Explore** individual component files in `lib/shared/ui/components/`
3. **Check** the [Phase Tracker](../flutter_chekmate/docs/PHASE_TRACKER.md) for implementation status
4. **Reference** the [Component Fix Plan](../flutter_chekmate/docs/COMPONENT_FIX_PLAN.md) for integration details

---

**Last Updated**: January 15, 2025
**Component Count**: 70+
**Status**: Production Ready ✅


