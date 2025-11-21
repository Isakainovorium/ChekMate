# Phase 5 Integration Guide

This guide shows how to integrate the Phase 5 Smart Content Intelligence features into your existing Flutter app screens.

---

## Quick Start

### 1. Add Reading Analytics to Content Screens

Whenever users view educational content (articles, tips, stories), log their reading behavior:

```dart
import 'package:flutter_chekmate/features/intelligence/presentation/providers/intelligence_providers.dart';

class ArticleViewScreen extends ConsumerStatefulWidget {
  final String articleId;
  final List<String> tags;
  
  const ArticleViewScreen({
    required this.articleId,
    required this.tags,
    super.key,
  });

  @override
  ConsumerState<ArticleViewScreen> createState() => _ArticleViewScreenState();
}

class _ArticleViewScreenState extends ConsumerState<ArticleViewScreen> {
  String? _sessionId;
  DateTime? _startTime;
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _startReading();
  }

  void _startReading() {
    final controller = ref.read(readingInsightsControllerProvider);
    _sessionId = controller.startReadingSession(
      contentId: widget.articleId,
      tags: widget.tags,
    );
    _startTime = DateTime.now();
  }

  @override
  void dispose() {
    _endReading();
    super.dispose();
  }

  Future<void> _endReading() async {
    if (_sessionId == null || _startTime == null) return;

    final timeSpent = DateTime.now().difference(_startTime!).inMilliseconds;
    final controller = ref.read(readingInsightsControllerProvider);

    await controller.endReadingSession(
      sessionId: _sessionId!,
      contentId: widget.articleId,
      tags: widget.tags,
      timeSpentMs: timeSpent,
      completionPercent: _scrollProgress,
      sentiment: 0.5, // Can be calculated from user reactions
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Article')),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            final maxScroll = notification.metrics.maxScrollExtent;
            final currentScroll = notification.metrics.pixels;
            setState(() {
              _scrollProgress = maxScroll > 0 ? currentScroll / maxScroll : 0;
            });
          }
          return false;
        },
        child: SingleChildScrollView(
          child: ArticleContent(articleId: widget.articleId),
        ),
      ),
    );
  }
}
```

---

### 2. Display Reading Insights in Profile

Add the insights card to your profile or learning section:

```dart
import 'package:flutter_chekmate/features/intelligence/presentation/widgets/reading_insights_card.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info section
          UserInfoCard(),
          
          const SizedBox(height: 16),
          
          // Reading insights
          ReadingInsightsCard(),
          
          const SizedBox(height: 16),
          
          // Other profile sections
          StatsCard(),
          SettingsCard(),
        ],
      ),
    );
  }
}
```

---

### 3. Add Contextual Follow Suggestions to Explore

Integrate smart follow suggestions into your explore/discover page:

```dart
import 'package:flutter_chekmate/features/intelligence/presentation/widgets/contextual_follow_suggestions_widget.dart';

class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Trending content
          TrendingContentSection(),
          
          const SizedBox(height: 24),
          
          // Contextual follow suggestions
          ContextualFollowSuggestionsWidget(),
          
          const SizedBox(height: 24),
          
          // Other explore sections
          HashtagsSection(),
          PopularPostsSection(),
        ],
      ),
    );
  }
}
```

---

### 4. Serendipity Mode (Already Integrated)

Serendipity mode is already integrated into the feed page! Users can access it via:
1. Open main feed
2. Tap the feed type selector icon (top right)
3. Select "Serendipity" from the menu

The serendipity feed automatically shows diverse content recommendations.

---

## Advanced Integration

### Custom Reading Event Logging

For more control over what gets logged:

```dart
final controller = ref.read(readingInsightsControllerProvider);

await controller.logReadingEvent(
  contentId: 'custom_content_123',
  tags: ['relationship-advice', 'communication', 'emotional-intelligence'],
  timeSpentMs: 60000, // 1 minute
  completionPercent: 1.0, // 100% read
  sentiment: 0.8, // Positive sentiment (0-1 scale)
);
```

### Sentiment Calculation

Calculate sentiment from user reactions:

```dart
double calculateSentiment({
  required bool liked,
  required bool bookmarked,
  required bool shared,
}) {
  double sentiment = 0.5; // Neutral baseline
  
  if (liked) sentiment += 0.2;
  if (bookmarked) sentiment += 0.2;
  if (shared) sentiment += 0.1;
  
  return sentiment.clamp(0.0, 1.0);
}
```

### Conditional Feature Display

Show features only when data is available:

```dart
class SmartFeaturesSection extends ConsumerWidget {
  const SmartFeaturesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userBehaviorProfileProvider);
    final suggestionsAsync = ref.watch(contextualFollowSuggestionsProvider);

    return Column(
      children: [
        // Show insights only if profile exists
        profileAsync.when(
          data: (profile) => profile != null
              ? ReadingInsightsCard()
              : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        
        // Show suggestions only if available
        suggestionsAsync.when(
          data: (suggestions) => suggestions.isNotEmpty
              ? ContextualFollowSuggestionsWidget()
              : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
```

---

## Testing Integration

### 1. Test Reading Analytics

```dart
// In your test file
testWidgets('Reading analytics logs events correctly', (tester) async {
  final container = ProviderContainer();
  
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: ArticleViewScreen(
          articleId: 'test_article',
          tags: ['test', 'emotional-intelligence'],
        ),
      ),
    ),
  );
  
  // Wait for session to start
  await tester.pump();
  
  // Simulate reading
  await tester.pump(const Duration(seconds: 5));
  
  // Navigate away to trigger end session
  await tester.pageBack();
  await tester.pumpAndSettle();
  
  // Verify event was logged (check Firestore or mock)
  // ... assertions
});
```

### 2. Test Serendipity Feed

```dart
testWidgets('Serendipity feed shows diverse content', (tester) async {
  // Mock serendipity recommendations
  final mockRecommendations = SerendipityRecommendationModel(
    userId: 'test_user',
    contentIds: ['post1', 'post2', 'post3'],
    diversityScore: 0.8,
    curatedModuleIds: ['module1'],
    updatedAt: DateTime.now(),
  );
  
  // ... test feed switching and content display
});
```

---

## Firestore Security Rules

Add these rules to protect the new collections:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // User reading events - users can only write their own
    match /userReadingEvents/{userId}/events/{eventId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // User behavior profiles - users can only read their own
    match /userBehaviorProfiles/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false; // Only functions can write
    }
    
    // Serendipity recommendations - users can only read their own
    match /serendipityRecommendations/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false; // Only functions can write
    }
    
    // Contextual follow suggestions - users can read their own
    match /contextualFollowSuggestions/{suggestionId} {
      allow read: if request.auth != null && 
                     resource.data.userId == request.auth.uid;
      allow write: if false; // Only functions can write
    }
  }
}
```

---

## Firestore Indexes

Create these indexes for optimal performance:

```json
{
  "indexes": [
    {
      "collectionGroup": "events",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "contextualFollowSuggestions",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "similarityScore", "order": "DESCENDING" }
      ]
    }
  ]
}
```

---

## Performance Optimization

### Lazy Loading

Only load intelligence features when needed:

```dart
// Use autoDispose to clean up when not in use
final userBehaviorProfileProvider = StreamProvider.autoDispose<UserBehaviorProfileModel?>((ref) {
  // ... provider implementation
});
```

### Caching

Cache recommendations to reduce Firestore reads:

```dart
final cachedSerendipityProvider = FutureProvider.autoDispose<List<PostEntity>>((ref) async {
  // Check cache first
  final cache = ref.watch(cacheProvider);
  final cached = cache.get('serendipity_feed');
  
  if (cached != null && !cache.isExpired('serendipity_feed')) {
    return cached as List<PostEntity>;
  }
  
  // Fetch fresh data
  final fresh = await ref.watch(serendipityFeedProvider.future);
  cache.set('serendipity_feed', fresh, duration: const Duration(hours: 1));
  
  return fresh;
});
```

---

## Troubleshooting

### Issue: Events not logging

**Check:**
1. User is authenticated
2. Firestore permissions are correct
3. No console errors
4. Network connectivity

**Debug:**
```dart
// Enable debug logging
debugPrint('Logging event for user: $userId');
debugPrint('Content ID: $contentId');
debugPrint('Tags: $tags');
```

### Issue: No recommendations showing

**Check:**
1. Firebase Functions have run
2. User has reading history
3. Fallback content is available

**Debug:**
```dart
final recommendations = await ref.read(serendipityRecommendationsProvider.future);
debugPrint('Recommendations: ${recommendations?.contentIds.length ?? 0}');
```

---

## Best Practices

1. **Always log reading events** for educational content
2. **Show fallback content** when recommendations aren't ready
3. **Respect user privacy** - allow opting out of tracking
4. **Monitor performance** - track provider rebuild counts
5. **Test with real data** - seed Firestore with sample events

---

## Next Steps

1. ✅ Integrate reading analytics into content screens
2. ✅ Add insights card to profile
3. ✅ Add follow suggestions to explore
4. ⏳ Deploy Firebase Functions
5. ⏳ Test with real users
6. ⏳ Monitor metrics and iterate

---

## Support

For questions or issues:
- Check `PHASE_5_IMPLEMENTATION_SUMMARY.md` for overview
- Review `PHASE_5_FIREBASE_FUNCTIONS.md` for backend details
- Check Firebase Console logs for function errors
- Review Firestore security rules if permission errors occur

Happy integrating! 🚀
