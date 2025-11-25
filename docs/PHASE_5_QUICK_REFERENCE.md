# Phase 5 Quick Reference Card

## 🎯 Three Features at a Glance

| Feature | What It Does | Where to Use |
|---------|-------------|--------------|
| **Reading Pattern Analysis** | Tracks reading behavior, generates personalized insights | Content screens, Profile |
| **Serendipity Mode** | Shows diverse content recommendations | Feed (already integrated) |
| **Contextual Follow Suggestions** | Smart follow recommendations based on similarity | Explore, Profile |

---

## 📦 Key Imports

```dart
// Providers
import 'package:flutter_chekmate/features/intelligence/presentation/providers/intelligence_providers.dart';
import 'package:flutter_chekmate/features/intelligence/presentation/providers/serendipity_feed_provider.dart';

// Widgets
import 'package:flutter_chekmate/features/intelligence/presentation/widgets/reading_insights_card.dart';
import 'package:flutter_chekmate/features/intelligence/presentation/widgets/contextual_follow_suggestions_widget.dart';

// Models
import 'package:flutter_chekmate/features/intelligence/data/models/reading_event_model.dart';
import 'package:flutter_chekmate/features/intelligence/data/models/user_behavior_profile_model.dart';
import 'package:flutter_chekmate/features/intelligence/data/models/serendipity_recommendation_model.dart';
import 'package:flutter_chekmate/features/intelligence/data/models/contextual_follow_suggestion_model.dart';
```

---

## 🔥 Common Code Snippets

### Log a Reading Event

```dart
final controller = ref.read(readingInsightsControllerProvider);

await controller.logReadingEvent(
  contentId: 'article_123',
  tags: ['emotional-intelligence', 'communication'],
  timeSpentMs: 45000,
  completionPercent: 0.8,
  sentiment: 0.7,
);
```

### Display Reading Insights

```dart
ReadingInsightsCard()
```

### Display Follow Suggestions

```dart
ContextualFollowSuggestionsWidget()
```

### Access Serendipity Feed

```dart
// Already in feed - user selects from menu
// Or programmatically:
final posts = await ref.read(serendipityFeedProvider.future);
```

---

## 🗄️ Firestore Collections

| Collection | Purpose | Written By | Read By |
|------------|---------|------------|---------|
| `userReadingEvents/{userId}/events` | Raw reading data | App | Functions |
| `userBehaviorProfiles/{userId}` | Aggregated insights | Functions | App |
| `serendipityRecommendations/{userId}` | Diverse content | Functions | App |
| `contextualFollowSuggestions` | Follow suggestions | Functions | App |

---

## 🎨 UI Components

### ReadingInsightsCard
- Shows personalized reading insights
- Displays top category, emotional affinity, learning pace
- Shows recommended tags
- Auto-hides if no data

### ContextualFollowSuggestionsWidget
- Groups suggestions by match type
- Shows journey matches, topic clusters, experience correlations
- Includes follow buttons
- Auto-hides if no suggestions

---

## 🔌 Providers Reference

```dart
// Services
readingAnalyticsServiceProvider          // ReadingAnalyticsService
readingInsightsControllerProvider        // ReadingInsightsController

// Data Streams
userBehaviorProfileProvider              // UserBehaviorProfileModel?
userReadingEventsProvider                // List<ReadingEventModel>
serendipityRecommendationsProvider       // SerendipityRecommendationModel?
contextualFollowSuggestionsProvider      // List<ContextualFollowSuggestionModel>

// Feed
serendipityFeedProvider                  // List<PostEntity>

// State
serendipityModeEnabledProvider           // bool (StateProvider)
```

---

## ⚡ Quick Integration Steps

### 1. Add to Content Screen
```dart
// Start tracking
_sessionId = controller.startReadingSession(
  contentId: articleId,
  tags: tags,
);

// End tracking
await controller.endReadingSession(
  sessionId: _sessionId!,
  contentId: articleId,
  tags: tags,
  timeSpentMs: timeSpent,
  completionPercent: scrollProgress,
);
```

### 2. Add to Profile
```dart
ListView(
  children: [
    UserInfoCard(),
    ReadingInsightsCard(),  // ← Add this
    StatsCard(),
  ],
)
```

### 3. Add to Explore
```dart
ListView(
  children: [
    TrendingSection(),
    ContextualFollowSuggestionsWidget(),  // ← Add this
    HashtagsSection(),
  ],
)
```

---

## 🚀 Firebase Functions

Deploy these three functions:

```bash
firebase deploy --only functions:aggregateUserBehaviorProfiles
firebase deploy --only functions:generateSerendipityRecommendations
firebase deploy --only functions:generateContextualFollowSuggestions
```

Schedule:
- `aggregateUserBehaviorProfiles` - Daily at 2:00 AM UTC
- `generateSerendipityRecommendations` - Daily at 3:00 AM UTC
- `generateContextualFollowSuggestions` - Daily at 4:00 AM UTC

---

## 🧪 Testing Checklist

- [ ] Log reading event successfully
- [ ] View reading insights in profile
- [ ] Switch to serendipity feed
- [ ] See contextual follow suggestions
- [ ] Follow user from suggestions
- [ ] Verify Firestore data created
- [ ] Check Firebase Function logs

---

## 📊 Key Metrics

Track these in Firebase Analytics:

```dart
// Reading analytics
analytics.logEvent(name: 'reading_event_logged');
analytics.logEvent(name: 'reading_insights_viewed');

// Serendipity
analytics.logEvent(name: 'serendipity_mode_enabled');
analytics.logEvent(name: 'serendipity_content_engaged');

// Follow suggestions
analytics.logEvent(name: 'contextual_follow_viewed');
analytics.logEvent(name: 'contextual_follow_accepted');
```

---

## 🔒 Security Rules Summary

```javascript
// Users can write their own reading events
match /userReadingEvents/{userId}/events/{eventId} {
  allow write: if request.auth.uid == userId;
}

// Users can read their own profiles/recommendations
match /userBehaviorProfiles/{userId} {
  allow read: if request.auth.uid == userId;
}

// Only functions can write profiles/recommendations
match /userBehaviorProfiles/{userId} {
  allow write: if false;
}
```

---

## 🐛 Common Issues

| Issue | Solution |
|-------|----------|
| Events not logging | Check auth, permissions, network |
| No insights showing | Wait for function to run, check data |
| Serendipity feed empty | Fallback to trending (automatic) |
| No follow suggestions | Need more users with interests set |

---

## 📚 Documentation Links

- Full Implementation: `PHASE_5_IMPLEMENTATION_SUMMARY.md`
- Firebase Functions: `PHASE_5_FIREBASE_FUNCTIONS.md`
- Integration Guide: `PHASE_5_INTEGRATION_GUIDE.md`

---

## 💡 Pro Tips

1. **Always provide fallback content** when recommendations aren't ready
2. **Log events generously** - more data = better insights
3. **Test with sample data** before deploying functions
4. **Monitor function costs** - optimize if needed
5. **Respect user privacy** - allow opting out

---

## 🎉 You're Ready!

Phase 5 is fully implemented and ready to use. Start by:
1. Adding reading analytics to your content screens
2. Displaying insights in profile
3. Showing follow suggestions in explore
4. Deploying Firebase Functions

Happy coding! 🚀
