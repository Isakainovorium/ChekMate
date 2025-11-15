# ChekMate Quick Reference Card

> **Fast lookup for components, routes, and common patterns**

---

## 🎯 Most Used Components

### Buttons
```dart
// Primary action
AppButton(
  variant: AppButtonVariant.primary,
  onPressed: () => action(),
  child: Text('Submit'),
)

// With loading
AppButton(
  isLoading: isSubmitting,
  onPressed: submit,
  child: Text('Save'),
)
```

### Inputs
```dart
// Basic input
AppInput(
  label: 'Email',
  hintText: 'Enter email',
  controller: emailController,
)

// With validation
AppInput(
  label: 'Password',
  obscureText: true,
  validator: (value) => value.isEmpty ? 'Required' : null,
  errorText: passwordError,
)
```

### Lists
```dart
// Infinite scroll list
AppVirtualizedList<Post>(
  items: posts,
  itemBuilder: (context, post, index) => PostCard(post),
  emptyBuilder: (context) => AppEmptyState(title: 'No posts'),
  loadingBuilder: (context) => PostFeedShimmer(),
)
```

### Cards
```dart
// Basic card
AppCard(
  child: Column(
    children: [
      Text('Title'),
      Text('Content'),
    ],
  ),
)
```

### Modals
```dart
// Bottom sheet
showModalBottomSheet(
  context: context,
  builder: (context) => AppBottomSheet(
    child: FilterPanel(),
  ),
);

// Dialog
showDialog(
  context: context,
  builder: (context) => AppDialog(
    title: 'Confirm',
    content: Text('Are you sure?'),
    actions: [
      AppButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
      AppButton(onPressed: confirm, child: Text('Confirm')),
    ],
  ),
);
```

---

## 🗺️ Navigation Cheat Sheet

### Basic Navigation
```dart
// Go to route
context.go('/home');

// Go with parameters
context.go('/user/${userId}');

// Go with query params
context.go('/stories/${userId}?index=2');

// Go back
context.pop();

// Replace route
context.replace('/home');
```

### Common Routes
```dart
// Authentication
context.go('/welcome');
context.go('/signin');
context.go('/signup');

// Main app
context.go('/home');
context.go('/messages');
context.go('/notifications');
context.go('/profile');

// Features
context.go('/rate-date');
context.go('/live/${streamId}');
context.go('/subscribe');

// Detail views
context.go('/user/${userId}');
context.go('/post/${postId}');
context.go('/stories/${userId}');
```

---

## 🎨 Common Patterns

### Form with Validation
```dart
final _formKey = GlobalKey<FormState>();

AppForm(
  key: _formKey,
  children: [
    AppInput(
      label: 'Email',
      validator: EmailValidator.validate,
    ),
    AppInput(
      label: 'Password',
      obscureText: true,
      validator: PasswordValidator.validate,
    ),
    AppButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          submit();
        }
      },
      child: Text('Submit'),
    ),
  ],
)
```

### List with Loading
```dart
isLoading
  ? PostFeedShimmer(itemCount: 5)
  : posts.isEmpty
    ? AppEmptyState(title: 'No posts')
    : AppVirtualizedList(
        items: posts,
        itemBuilder: (context, post, index) => PostCard(post),
      )
```

### Hero Animation
```dart
// Source
GestureDetector(
  onTap: () => context.go('/post/${post.id}'),
  child: AppHero(
    tag: 'post-${post.id}',
    child: Image.network(post.imageUrl),
  ),
)

// Destination
AppHero(
  tag: 'post-${post.id}',
  child: Image.network(post.imageUrl),
)
```

### Pull to Refresh
```dart
PullToRefreshAnimation(
  onRefresh: () async {
    await fetchNewPosts();
  },
  child: AppVirtualizedList(
    items: posts,
    itemBuilder: (context, post, index) => PostCard(post),
  ),
)
```

### Swipeable Card
```dart
SwipeableCard(
  onSwipeLeft: () => reject(),
  onSwipeRight: () => accept(),
  child: RatingCard(rating: currentRating),
)
```

---

## 🎭 Feature-Specific Components

### Authentication
- `AppInput` - Email/password
- `AppButton` - Sign in/up
- `AppCheckbox` - Terms
- `AppDatePicker` - DOB
- `AppFileUpload` - Profile photo

### Feed
- `AppVirtualizedList` - Post list
- `AppCard` - Post card
- `DoubleTapLike` - Like animation
- `PostFeedShimmer` - Loading
- `AppEmptyState` - No posts

### Messages
- `AppVirtualizedList` - Message list
- `AppInput` - Message input
- `TypingIndicator` - Typing
- `MessageListShimmer` - Loading

### Profile
- `AppAvatar` - Profile picture
- `AppTabs` - Content tabs
- `AppGridVirtualizedList` - Post grid
- `ProfileHeaderShimmer` - Loading

### Rate Your Date
- `SwipeableCard` - Rating cards
- `AppSlider` - Rating scales
- `AppTextarea` - Description
- `AppChart` - Rating breakdown

### Live Streaming
- `AppVideoPlayer` - Stream player
- `AppVirtualizedList` - Chat
- `AppBadge` - Live indicator

---

## 🎨 Theming

### Colors
```dart
// Use theme colors
Theme.of(context).colorScheme.primary
Theme.of(context).colorScheme.secondary
Theme.of(context).colorScheme.error

// ChekMate brand colors
Color(0xFFFF6B6B)  // Primary red
Color(0xFFF5A623)  // Golden orange
```

### Spacing
```dart
// Use AppSpacing constants
AppSpacing.xs   // 4
AppSpacing.sm   // 8
AppSpacing.md   // 16
AppSpacing.lg   // 24
AppSpacing.xl   // 32
AppSpacing.xxl  // 48
```

### Typography
```dart
// Use theme text styles
Theme.of(context).textTheme.displayLarge
Theme.of(context).textTheme.headlineMedium
Theme.of(context).textTheme.titleLarge
Theme.of(context).textTheme.bodyLarge
Theme.of(context).textTheme.bodyMedium
Theme.of(context).textTheme.labelLarge
```

---

## 🔥 Firebase Quick Reference

### Authentication
```dart
// Sign in
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Sign up
await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);

// Sign out
await FirebaseAuth.instance.signOut();

// Current user
final user = FirebaseAuth.instance.currentUser;
```

### Firestore
```dart
// Get collection
final posts = await FirebaseFirestore.instance
  .collection('posts')
  .get();

// Get document
final post = await FirebaseFirestore.instance
  .collection('posts')
  .doc(postId)
  .get();

// Add document
await FirebaseFirestore.instance
  .collection('posts')
  .add(postData);

// Update document
await FirebaseFirestore.instance
  .collection('posts')
  .doc(postId)
  .update(updates);

// Delete document
await FirebaseFirestore.instance
  .collection('posts')
  .doc(postId)
  .delete();

// Listen to changes
FirebaseFirestore.instance
  .collection('posts')
  .snapshots()
  .listen((snapshot) {
    // Handle updates
  });
```

### Storage
```dart
// Upload file
final ref = FirebaseStorage.instance
  .ref()
  .child('images/${fileName}');
await ref.putFile(file);

// Get download URL
final url = await ref.getDownloadURL();

// Delete file
await ref.delete();
```

---

## 🧪 Testing Patterns

### Widget Test
```dart
testWidgets('Button shows loading state', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AppButton(
        isLoading: true,
        onPressed: () {},
        child: Text('Submit'),
      ),
    ),
  );
  
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

### Integration Test
```dart
testWidgets('User can sign in', (tester) async {
  await tester.pumpWidget(MyApp());
  
  await tester.enterText(find.byType(AppInput).first, 'test@example.com');
  await tester.enterText(find.byType(AppInput).last, 'password123');
  await tester.tap(find.text('Sign In'));
  await tester.pumpAndSettle();
  
  expect(find.text('Home'), findsOneWidget);
});
```

---

## 🐛 Common Issues & Solutions

### Issue: Component not found
```dart
// Solution: Import shared UI
import 'package:flutter_chekmate/shared/ui/index.dart';
```

### Issue: Route not working
```dart
// Solution: Check route definition in app_router.dart
// Make sure route is registered in GoRouter
```

### Issue: State not updating
```dart
// Solution: Use Riverpod provider
final counterProvider = StateProvider((ref) => 0);

// In widget
final counter = ref.watch(counterProvider);
```

### Issue: Image not loading
```dart
// Solution: Use cached_network_image
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => ShimmerImage(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

---

## 📱 Platform-Specific Code

### iOS
```dart
if (Platform.isIOS) {
  // iOS-specific code
}
```

### Android
```dart
if (Platform.isAndroid) {
  // Android-specific code
}
```

### Web
```dart
if (kIsWeb) {
  // Web-specific code
}
```

---

## 🔗 Useful Links

- **[Components Guide](./COMPONENTS_GUIDE.md)** - Full component documentation
- **[Routing Architecture](./ROUTING_ARCHITECTURE.md)** - Complete routing guide
- **[Features Overview](./FEATURES_AND_COMPONENTS_OVERVIEW.md)** - App overview
- **[Flutter Docs](https://docs.flutter.dev/)** - Official Flutter documentation
- **[GoRouter Docs](https://pub.dev/packages/go_router)** - GoRouter documentation
- **[Riverpod Docs](https://riverpod.dev/)** - Riverpod documentation
- **[Firebase Docs](https://firebase.google.com/docs/flutter/setup)** - Firebase for Flutter

---

**Last Updated**: January 15, 2025  
**Quick Reference Version**: 1.0
