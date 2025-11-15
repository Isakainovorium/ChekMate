# 🎯 Location + Interest-Based Content Discovery - Implementation Plan
**Date:** October 22, 2025  
**Status:** 📋 READY FOR IMPLEMENTATION  
**Estimated Timeline:** 6 weeks

---

## 📋 OVERVIEW

This plan implements a **hybrid content discovery algorithm** that combines:
1. **Location-based discovery** - Prioritize local content first
2. **Interest-based recommendations** - Match content to user preferences
3. **Expanding search radius** - Gradually expand if local content is sparse
4. **Engagement-based ranking** - Surface high-quality content

**Goal:** Create a TikTok/Instagram-quality feed that shows users content they care about, starting with their local area.

---

## PHASE 1: USER ONBOARDING & PREFERENCES (Week 1-2)

### **1.1 Create Onboarding Screens**

#### **Screen 1: Welcome Screen**
```dart
// lib/pages/onboarding/welcome_screen.dart
class WelcomeScreen extends StatelessWidget {
  - App logo and tagline
  - "Get Started" button
  - Skip option (discouraged)
}
```

#### **Screen 2: Interest Selection**
```dart
// lib/pages/onboarding/interests_screen.dart
class InterestsScreen extends StatefulWidget {
  - Grid of interest categories (20-30 options)
  - Multi-select chips
  - Minimum 3 selections required
  - Categories: Sports, Music, Food, Travel, Fashion, etc.
}
```

**Interest Categories:**
```dart
const List<String> interestCategories = [
  'Sports', 'Music', 'Food & Dining', 'Travel', 'Fashion',
  'Fitness', 'Art', 'Photography', 'Gaming', 'Technology',
  'Movies & TV', 'Books', 'Pets', 'Nature', 'Cars',
  'Beauty', 'Dance', 'Comedy', 'Business', 'Health',
  'Parenting', 'DIY', 'Cooking', 'Nightlife', 'Adventure',
];
```

#### **Screen 3: Location Permission**
```dart
// lib/pages/onboarding/location_screen.dart
class LocationScreen extends StatefulWidget {
  - Explanation of location benefits
  - "Enable Location" button (uses LocationService)
  - Manual location entry option
  - Skip option (not recommended)
}
```

#### **Screen 4: Profile Photo**
```dart
// lib/pages/onboarding/profile_photo_screen.dart
class ProfilePhotoScreen extends StatefulWidget {
  - Camera/gallery picker
  - Crop and resize
  - Skip option (can add later)
}
```

#### **Screen 5: Completion**
```dart
// lib/pages/onboarding/completion_screen.dart
class CompletionScreen extends StatelessWidget {
  - Success message
  - Profile summary
  - "Start Exploring" button → Navigate to home
}
```

### **1.2 Onboarding State Management**

```dart
// lib/features/onboarding/domain/entities/onboarding_state_entity.dart
class OnboardingStateEntity {
  final bool isCompleted;
  final bool interestsSelected;
  final bool locationEnabled;
  final bool profilePhotoAdded;
  final List<String> selectedInterests;
  final LocationEntity? location;
  final int currentStep; // 0-4
}

// lib/features/onboarding/presentation/providers/onboarding_provider.dart
final onboardingStateProvider = StateNotifierProvider<OnboardingNotifier, OnboardingStateEntity>((ref) {
  return OnboardingNotifier(ref);
});
```

### **1.3 Preferences Service**

```dart
// lib/core/services/preferences_service.dart
class PreferencesService {
  final SharedPreferences _prefs;

  // Onboarding
  Future<void> setOnboardingCompleted(bool value);
  Future<bool> isOnboardingCompleted();

  // Interests
  Future<void> saveInterests(List<String> interests);
  Future<List<String>> getInterests();

  // Location preference
  Future<void> setLocationEnabled(bool value);
  Future<bool> isLocationEnabled();
}
```

### **1.4 Update Firestore Schema**

```javascript
// Add to users collection
users/{userId}
├── ... (existing fields)
├── onboardingCompleted: boolean (NEW)
├── interests: array<string> (POPULATE during onboarding)
├── coordinates: geopoint (NEW - latitude/longitude)
├── geohash: string (NEW - for geospatial queries)
├── locationEnabled: boolean (NEW)
└── preferences: map (NEW)
    ├── showLocalContent: boolean
    ├── searchRadius: number (km)
    └── contentLanguage: string
```

### **1.5 Update Signup Flow**

```dart
// lib/pages/auth/signup_page.dart
// After successful signup:
if (mounted) {
  // OLD: context.go('/');
  // NEW: Check onboarding status
  final onboardingCompleted = await PreferencesService.isOnboardingCompleted();
  if (!onboardingCompleted) {
    context.go('/onboarding/welcome');
  } else {
    context.go('/');
  }
}
```

---

## PHASE 2: LOCATION-BASED CONTENT DISCOVERY (Week 3-4)

### **2.1 Add Geolocation to Data Models**

#### **Update User Model**
```dart
// lib/features/auth/data/models/user_model.dart
class UserModel extends UserEntity {
  final GeoPoint? coordinates; // NEW
  final String? geohash; // NEW
  final bool locationEnabled; // NEW
  final double searchRadiusKm; // NEW (default: 100)

  Map<String, dynamic> toFirestore() {
    return {
      // ... existing fields
      'coordinates': coordinates,
      'geohash': geohash,
      'locationEnabled': locationEnabled,
      'searchRadiusKm': searchRadiusKm,
    };
  }
}
```

#### **Update Post Model**
```dart
// lib/features/posts/data/models/post_model.dart
class PostModel extends PostEntity {
  final GeoPoint? coordinates; // NEW
  final String? geohash; // NEW
  final String? locationName; // EXISTING (keep for display)

  Map<String, dynamic> toFirestore() {
    return {
      // ... existing fields
      'coordinates': coordinates,
      'geohash': geohash,
      'locationName': locationName,
    };
  }
}
```

### **2.2 Implement Geohashing**

```dart
// lib/core/utils/geohash_utils.dart
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class GeohashUtils {
  /// Generate geohash from coordinates
  static String generateGeohash(double latitude, double longitude) {
    return GeoFirePoint(GeoPoint(latitude, longitude)).geohash;
  }

  /// Calculate distance between two geopoints
  static double calculateDistance(GeoPoint point1, GeoPoint point2) {
    return GeoFirePoint(point1).distanceBetween(to: GeoFirePoint(point2));
  }
}
```

**Add Package:**
```yaml
# pubspec.yaml
dependencies:
  geoflutterfire_plus: ^0.0.3 # Geospatial queries for Firestore
```

### **2.3 Location-Based Feed Algorithm**

```dart
// lib/features/feed/domain/usecases/get_location_based_feed_usecase.dart
class GetLocationBasedFeedUseCase {
  final PostsRepository _repository;
  final UserRepository _userRepository;

  Stream<List<PostEntity>> call({
    required String userId,
    int limit = 20,
  }) async* {
    // 1. Get user's location and preferences
    final user = await _userRepository.getUserById(userId);
    if (user.coordinates == null || !user.locationEnabled) {
      // Fallback to chronological feed
      yield* _repository.getPosts(limit: limit);
      return;
    }

    // 2. Start with small radius (5km)
    double radiusKm = 5.0;
    List<PostEntity> posts = [];

    // 3. Expand radius until we have enough posts
    while (posts.length < limit && radiusKm <= user.searchRadiusKm) {
      posts = await _repository.getPostsNearLocation(
        center: user.coordinates!,
        radiusKm: radiusKm,
        limit: limit,
      );

      if (posts.length < limit) {
        radiusKm *= 2; // Double the radius
      }
    }

    // 4. If still not enough, add interest-based posts
    if (posts.length < limit) {
      final interestPosts = await _repository.getPostsByInterests(
        interests: user.interests ?? [],
        limit: limit - posts.length,
      );
      posts.addAll(interestPosts);
    }

    // 5. Sort by engagement score
    posts.sort((a, b) => b.engagementScore.compareTo(a.engagementScore));

    yield posts;
  }
}
```

### **2.4 Geospatial Queries**

```dart
// lib/features/posts/data/datasources/posts_remote_datasource.dart
class PostsRemoteDataSource {
  final FirebaseFirestore _firestore;

  /// Get posts near a location using geohash
  Future<List<PostModel>> getPostsNearLocation({
    required GeoPoint center,
    required double radiusKm,
    int limit = 20,
  }) async {
    // Use GeoFlutterFire for geospatial queries
    final geo = GeoCollectionReference(_firestore.collection('posts'));

    final posts = await geo
        .fetchWithin(
          center: GeoFirePoint(center),
          radiusInKm: radiusKm,
          field: 'coordinates',
          geopointFrom: (data) => data['coordinates'] as GeoPoint?,
        )
        .first;

    return posts
        .map((doc) => PostModel.fromFirestore(doc))
        .take(limit)
        .toList();
  }
}
```

### **2.5 Update Post Creation**

```dart
// lib/pages/create_post/create_post_page.dart
Future<void> _handleCreatePost() async {
  // Get current location if enabled
  GeoPoint? coordinates;
  String? geohash;
  String? locationName;

  if (_includeLocation) {
    try {
      final location = await LocationService.getCurrentLocation();
      coordinates = GeoPoint(location.latitude, location.longitude);
      geohash = GeohashUtils.generateGeohash(location.latitude, location.longitude);
      locationName = location.displayName;
    } catch (e) {
      // Handle location error
    }
  }

  // Create post with location
  await postsController.createPost(
    content: _contentController.text,
    images: _selectedImages,
    coordinates: coordinates,
    geohash: geohash,
    locationName: locationName,
  );
}
```

---

## PHASE 3: INTEREST-BASED RECOMMENDATIONS (Week 5-6)

### **3.1 Content Matching Algorithm**

```dart
// lib/features/feed/domain/usecases/get_interest_based_feed_usecase.dart
class GetInterestBasedFeedUseCase {
  final PostsRepository _repository;
  final UserRepository _userRepository;

  Stream<List<PostEntity>> call({
    required String userId,
    int limit = 20,
  }) async* {
    // 1. Get user interests
    final user = await _userRepository.getUserById(userId);
    final interests = user.interests ?? [];

    if (interests.isEmpty) {
      // Fallback to trending content
      yield* _repository.getTrendingPosts(limit: limit);
      return;
    }

    // 2. Get posts matching user interests
    final posts = await _repository.getPostsByInterests(
      interests: interests,
      limit: limit * 2, // Get more for filtering
    );

    // 3. Score posts by relevance
    final scoredPosts = posts.map((post) {
      final score = _calculateRelevanceScore(post, interests);
      return ScoredPost(post, score);
    }).toList();

    // 4. Sort by score and return top N
    scoredPosts.sort((a, b) => b.score.compareTo(a.score));
    yield scoredPosts.take(limit).map((sp) => sp.post).toList();
  }

  double _calculateRelevanceScore(PostEntity post, List<String> userInterests) {
    double score = 0.0;

    // Match tags to interests (40% weight)
    final matchingTags = post.tags?.where((tag) => 
      userInterests.any((interest) => 
        tag.toLowerCase().contains(interest.toLowerCase())
      )
    ).length ?? 0;
    score += (matchingTags / (post.tags?.length ?? 1)) * 0.4;

    // Engagement score (30% weight)
    final engagementScore = (post.likes + post.comments * 2 + post.shares * 3) / 100;
    score += min(engagementScore, 1.0) * 0.3;

    // Recency score (20% weight)
    final hoursSincePost = DateTime.now().difference(post.createdAt).inHours;
    final recencyScore = max(0, 1 - (hoursSincePost / 168)); // 1 week decay
    score += recencyScore * 0.2;

    // Verified user bonus (10% weight)
    if (post.isVerified) {
      score += 0.1;
    }

    return score;
  }
}
```

### **3.2 Hybrid Feed Algorithm**

```dart
// lib/features/feed/domain/usecases/get_hybrid_feed_usecase.dart
class GetHybridFeedUseCase {
  final GetLocationBasedFeedUseCase _locationFeed;
  final GetInterestBasedFeedUseCase _interestFeed;

  Stream<List<PostEntity>> call({
    required String userId,
    int limit = 20,
  }) async* {
    // 1. Get location-based posts (60% of feed)
    final locationPosts = await _locationFeed(
      userId: userId,
      limit: (limit * 0.6).round(),
    ).first;

    // 2. Get interest-based posts (40% of feed)
    final interestPosts = await _interestFeed(
      userId: userId,
      limit: (limit * 0.4).round(),
    ).first;

    // 3. Merge and deduplicate
    final allPosts = <String, PostEntity>{};
    for (final post in locationPosts) {
      allPosts[post.id] = post;
    }
    for (final post in interestPosts) {
      allPosts[post.id] = post;
    }

    // 4. Sort by combined score
    final posts = allPosts.values.toList();
    posts.sort((a, b) {
      final scoreA = _calculateHybridScore(a, locationPosts, interestPosts);
      final scoreB = _calculateHybridScore(b, locationPosts, interestPosts);
      return scoreB.compareTo(scoreA);
    });

    yield posts.take(limit).toList();
  }

  double _calculateHybridScore(
    PostEntity post,
    List<PostEntity> locationPosts,
    List<PostEntity> interestPosts,
  ) {
    double score = 0.0;

    // Location match (50% weight)
    if (locationPosts.contains(post)) {
      score += 0.5;
    }

    // Interest match (50% weight)
    if (interestPosts.contains(post)) {
      score += 0.5;
    }

    // Engagement boost
    score += (post.likes + post.comments + post.shares) / 1000;

    return score;
  }
}
```

### **3.3 Engagement Tracking**

```dart
// Add to posts collection
posts/{postId}
├── ... (existing fields)
├── views: number (NEW)
├── viewedBy: array<string> (NEW - last 100 viewers)
├── engagementScore: number (NEW - calculated)
└── lastEngagementUpdate: timestamp (NEW)

// lib/features/posts/domain/usecases/track_post_view_usecase.dart
class TrackPostViewUseCase {
  final PostsRepository _repository;

  Future<void> call({
    required String postId,
    required String userId,
  }) async {
    await _repository.incrementViews(postId);
    await _repository.addViewer(postId, userId);
    await _repository.updateEngagementScore(postId);
  }
}
```

---

## 🔧 TECHNICAL IMPLEMENTATION DETAILS

### **Firestore Indexes Required**

```json
// firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "geohash", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "tags", "arrayConfig": "CONTAINS" },
        { "fieldPath": "engagementScore", "order": "DESCENDING" }
      ]
    }
  ]
}
```

### **Firestore Security Rules**

```javascript
// firestore.rules
match /users/{userId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && request.auth.uid == userId;

  // Allow reading coordinates for proximity queries
  allow get: if request.auth != null && 
    request.query.limit <= 100;
}

match /posts/{postId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && 
    request.resource.data.userId == request.auth.uid;

  // Allow view tracking
  allow update: if request.auth != null && 
    request.resource.data.diff(resource.data).affectedKeys()
      .hasOnly(['views', 'viewedBy', 'engagementScore']);
}
```

---

## 📊 TESTING STRATEGY

### **Unit Tests**
- ✅ Geohash generation
- ✅ Distance calculations
- ✅ Relevance scoring algorithm
- ✅ Hybrid feed merging logic

### **Integration Tests**
- ✅ Onboarding flow completion
- ✅ Location-based queries
- ✅ Interest matching
- ✅ Feed personalization

### **A/B Testing**
- **Group A:** Chronological feed (control)
- **Group B:** Location-based feed
- **Group C:** Interest-based feed
- **Group D:** Hybrid feed (location + interest)

**Metrics:**
- Session duration
- Posts viewed per session
- Engagement rate (likes/views)
- User retention (7-day, 30-day)

---

## 🚀 DEPLOYMENT PLAN

### **Week 1-2: Onboarding**
- Deploy onboarding screens
- Collect user preferences
- Monitor completion rates

### **Week 3-4: Location Features**
- Deploy geolocation updates
- Enable location-based feed for 10% of users
- Monitor performance and accuracy

### **Week 5-6: Interest Recommendations**
- Deploy interest-based algorithm
- Enable hybrid feed for 25% of users
- A/B test against chronological feed

### **Week 7: Full Rollout**
- Analyze A/B test results
- Roll out winning algorithm to 100% of users
- Monitor engagement metrics

---

**Plan Prepared By:** Augment Agent  
**Last Updated:** October 22, 2025  
**Status:** Ready for Phase 1 implementation

