# Phase 4: Wisdom Score & Social Proof System - Implementation Guide

**Status:** ✅ **CORE IMPLEMENTATION COMPLETE**  
**Date:** November 20, 2025  
**Timeline:** 2-3 weeks  
**Priority:** High

---

## 📋 Overview

Phase 4 implements a comprehensive gamification and reputation system that rewards quality contributions and builds community trust through wisdom scores, endorsements, and achievements.

---

## 🎯 What Was Implemented

### 1. **Core Models** ✅

#### `wisdom_score_model.dart`
- **WisdomScore** - User's overall wisdom score with multi-factor calculation
- **WisdomScoreFactors** - Calculation factors (helpfulness, peer validation, verification, recency, consistency, engagement)
- **InteractionRating** - Helpful/unhelpful ratings on user contributions
- **WisdomCategory** - 8 expertise categories (dating strategy, emotional intelligence, safety, etc.)
- **AchievementLevel** - 4 progression levels (Sage, Mentor, Coach, Luminary)

#### `endorsement_model.dart`
- **Endorsement** - User endorsement with badge and category
- **EndorsementVote** - Individual endorsement votes with token cost
- **EndorsementBadge** - 8 specialized badges (Relationship Coach, Safety Advocate, etc.)

#### `achievement_model.dart`
- **Achievement** - User achievement with progress tracking
- **AchievementDefinition** - Achievement template with requirements
- **Badge** - Visual badge display model
- **AchievementType** - 6 achievement types (milestone, specialty, streak, community, verification, mentorship)

### 2. **Services** ✅

#### `wisdom_score_service.dart`
- Calculate wisdom scores from multi-factor inputs
- Determine achievement levels based on scores
- Calculate category-specific scores
- Apply decay to older scores
- Predict next achievement level
- Calculate points needed for progression

**Scoring Algorithm:**
```
Overall Score = (Helpfulness × 0.35) + (Peer Validation × 0.25) + 
                (Verification × 0.20) + (Recency × 0.10) + 
                (Consistency × 0.10) × Engagement Multiplier
```

**Achievement Thresholds:**
- Sage: 5.0+
- Mentor: 6.5+
- Coach: 8.0+
- Luminary: 9.0+

#### `endorsement_service.dart`
- Manage endorsement costs and requirements
- Validate endorsement eligibility
- Calculate endorsement strength
- Determine endorsement tiers
- Map badges to categories
- Calculate endorsement impact on wisdom score

**Endorsement Costs (Tokens):**
- Relationship Coach: 50
- Compatibility Expert: 50
- Safety Advocate: 40
- Communication Master: 50
- Emotional Guide: 45
- Conflict Resolver: 50
- Cultural Bridge: 45
- Mentor Extraordinaire: 100

#### `gamification_service.dart`
- Manage 15+ achievement definitions
- Track achievement progress
- Calculate achievement points
- Get achievement recommendations
- Generate achievement statistics
- Determine rarity levels

**Achievement Categories:**
- Milestones (4): Sage, Mentor, Coach, Luminary
- Community (3): First Interaction, Helpful Contributor, Community Pillar
- Verification (2): Story Verified, Verified Expert
- Streaks (2): Week Warrior, Month Master
- Mentorship (2): First Mentor, Mentor Circle
- Specialty (3): Dating Strategist, Emotional Expert, Safety Champion

### 3. **Data Layer** ✅

#### `wisdom_remote_data_source.dart`
- Get/create wisdom scores
- Get leaderboards (top scores)
- Get scores by category
- Submit interaction ratings
- Get user ratings
- Create/manage endorsements
- Add endorsement votes
- Unlock/track achievements
- Get achievement statistics

### 4. **Directory Structure** ✅

```
lib/features/wisdom/
├── models/
│   ├── wisdom_score_model.dart
│   ├── endorsement_model.dart
│   └── achievement_model.dart
├── data/
│   ├── datasources/
│   │   └── wisdom_remote_data_source.dart
│   └── repositories/
│       └── wisdom_repository_impl.dart (TO CREATE)
├── domain/
│   └── repositories/
│       └── wisdom_repository.dart (TO CREATE)
└── presentation/
    ├── providers/
    │   └── wisdom_providers.dart (TO CREATE)
    └── widgets/
        ├── wisdom_score_card.dart (TO CREATE)
        ├── achievement_badge.dart (TO CREATE)
        ├── leaderboard_view.dart (TO CREATE)
        └── profile_wisdom_dashboard.dart (TO CREATE)

lib/core/services/wisdom/
├── wisdom_score_service.dart
├── endorsement_service.dart
└── gamification_service.dart
```

---

## 🔄 Integration Points

### User Profile Integration
```dart
// Display wisdom score on profile
WisdomScoreCard(
  wisdomScore: userWisdomScore,
  achievements: userAchievements,
  endorsements: userEndorsements,
)
```

### Post/Comment Integration
```dart
// Show helpful/unhelpful buttons
HelpfulnessRating(
  targetUserId: commentAuthorId,
  interactionId: commentId,
  category: WisdomCategory.emotionalIntelligence,
)
```

### Leaderboard Integration
```dart
// Display top contributors
LeaderboardView(
  category: selectedCategory,
  timeframe: 'all_time',
)
```

### Achievement Notifications
```dart
// Notify user of new achievements
AchievementUnlockedNotification(
  achievement: newAchievement,
)
```

---

## 📊 Data Models

### Wisdom Score Structure
```json
{
  "id": "user_123_wisdom",
  "user_id": "user_123",
  "overall_score": 7.8,
  "category_scores": {
    "dating_strategy": 8.2,
    "emotional_intelligence": 7.5,
    "safety_awareness": 8.0
  },
  "factors": {
    "helpfulness_rating": 8.0,
    "peer_validation": 0.85,
    "story_verification": 0.9,
    "recency_bonus": 0.8,
    "consistency_score": 0.75,
    "engagement_multiplier": 1.3
  },
  "total_interactions": 156,
  "helpful_ratings": 142,
  "unhelpful_ratings": 14,
  "verified_stories": 12,
  "achievement_level": "coach",
  "created_at": "2025-11-20T10:00:00Z",
  "updated_at": "2025-11-20T15:30:00Z"
}
```

### Endorsement Structure
```json
{
  "id": "endorsement_456",
  "user_id": "user_123",
  "badge": "relationship_coach",
  "category": "relationship_skills",
  "endorser_count": 5,
  "is_active": true,
  "created_at": "2025-11-20T10:00:00Z",
  "expires_at": "2026-11-20T10:00:00Z"
}
```

### Achievement Structure
```json
{
  "id": "achievement_789",
  "user_id": "user_123",
  "type": "milestone",
  "title": "Coach Achieved",
  "description": "Reached Coach level (8.0+ wisdom score)",
  "icon": "sports_basketball",
  "rarity": "rare",
  "unlocked_at": "2025-11-20T15:30:00Z",
  "progress": 100,
  "progress_target": 100
}
```

---

## 🚀 Next Steps to Complete Phase 4

### 1. Create Repository Interface
```dart
// lib/features/wisdom/domain/repositories/wisdom_repository.dart
abstract class WisdomRepository {
  Future<WisdomScore> getWisdomScore(String userId);
  Future<WisdomScore> calculateAndUpdateWisdomScore(String userId);
  Future<List<WisdomScore>> getLeaderboard({int limit, String? category});
  Future<InteractionRating> rateInteraction({...});
  Future<Endorsement> createEndorsement({...});
  Future<List<Achievement>> getUserAchievements(String userId);
  Future<Achievement> unlockAchievement({...});
}
```

### 2. Create Repository Implementation
```dart
// lib/features/wisdom/data/repositories/wisdom_repository_impl.dart
class WisdomRepositoryImpl implements WisdomRepository {
  final WisdomRemoteDataSource _remoteDataSource;
  final WisdomScoreService _wisdomScoreService;
  final EndorsementService _endorsementService;
  final GamificationService _gamificationService;
  
  // Implement all abstract methods
}
```

### 3. Create Riverpod Providers
```dart
// lib/features/wisdom/presentation/providers/wisdom_providers.dart
final wisdomRepositoryProvider = Provider<WisdomRepository>((ref) {...});
final userWisdomScoreProvider = FutureProvider.family<WisdomScore, String>((ref, userId) {...});
final leaderboardProvider = FutureProvider<List<WisdomScore>>((ref) {...});
final userAchievementsProvider = FutureProvider.family<List<Achievement>, String>((ref, userId) {...});
```

### 4. Create UI Widgets
- **WisdomScoreCard** - Display wisdom score with breakdown
- **AchievementBadge** - Display individual achievement
- **LeaderboardView** - Display top contributors
- **ProfileWisdomDashboard** - Full wisdom profile view
- **EndorsementBadges** - Display user endorsements
- **AchievementProgress** - Show progress toward next achievement

### 5. Firebase Setup
```javascript
// Firestore Collections
- wisdom_scores/{userId}
- interaction_ratings/{ratingId}
- endorsements/{endorsementId}
- endorsement_votes/{voteId}
- achievements/{achievementId}

// Security Rules
match /wisdom_scores/{userId} {
  allow read: if request.auth != null;
  allow write: if request.auth.uid == userId;
}

match /interaction_ratings/{ratingId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null;
  allow update, delete: if request.auth.uid == resource.data.user_id;
}
```

### 6. Integration Points
- Add wisdom score to user profile
- Add helpful/unhelpful buttons to comments
- Add leaderboard to community section
- Add achievement notifications
- Add endorsement display to profiles
- Add wisdom score to post author info

---

## 📈 Key Metrics

### Wisdom Score Calculation
- **Helpfulness Rating** (35%): Based on helpful/unhelpful ratings
- **Peer Validation** (25%): Percentage of positive ratings
- **Story Verification** (20%): Percentage of verified stories
- **Recency Bonus** (10%): Bonus for recent activity
- **Consistency Score** (10%): Consistency of quality
- **Engagement Multiplier** (0-2x): Based on interaction count

### Achievement Points
- Common: 10 points
- Uncommon: 25 points
- Rare: 50 points
- Epic: 100 points
- Legendary: 250 points

---

## 🎓 Usage Examples

### Calculate Wisdom Score
```dart
final wisdomService = WisdomScoreService.instance;

final factors = await wisdomService.calculateFactors(
  helpfulRatings: 142,
  unhelpfulRatings: 14,
  totalInteractions: 156,
  verifiedStories: 12,
  lastActivityDate: DateTime.now().subtract(Duration(days: 2)),
  recentScores: [7.5, 7.8, 8.0, 7.9],
);

final score = await wisdomService.calculateWisdomScore(factors: factors);
final level = wisdomService.getAchievementLevel(score);
```

### Rate Interaction
```dart
final rating = InteractionRating(
  id: 'rating_123',
  userId: currentUserId,
  targetUserId: commentAuthorId,
  interactionId: commentId,
  interactionType: 'comment',
  rating: true, // helpful
  category: WisdomCategory.emotionalIntelligence,
  createdAt: DateTime.now(),
);

await wisdomRepository.rateInteraction(rating);
```

### Create Endorsement
```dart
final endorsement = Endorsement(
  id: 'endorsement_456',
  userId: targetUserId,
  endorsedUserId: targetUserId,
  badge: EndorsementBadge.relationshipCoach,
  category: WisdomCategory.relationshipSkills,
  endorserCount: 1,
  isActive: true,
  createdAt: DateTime.now(),
  expiresAt: DateTime.now().add(Duration(days: 365)),
);

await wisdomRepository.createEndorsement(endorsement);
```

### Unlock Achievement
```dart
final achievement = Achievement(
  id: 'achievement_789',
  userId: userId,
  type: AchievementType.milestone,
  title: 'Coach Achieved',
  description: 'Reached Coach level (8.0+ wisdom score)',
  icon: 'sports_basketball',
  rarity: 'rare',
  unlockedAt: DateTime.now(),
);

await wisdomRepository.unlockAchievement(achievement);
```

---

## 🧪 Testing Strategy

### Unit Tests
- Wisdom score calculation algorithm
- Achievement level determination
- Endorsement eligibility checks
- Gamification point calculation
- Decay algorithm

### Integration Tests
- Wisdom score update flow
- Achievement unlock flow
- Endorsement creation flow
- Leaderboard retrieval
- Category score calculation

### E2E Tests
- Complete user journey: Rate → Score Update → Achievement Unlock
- Endorsement flow: Check eligibility → Create → Vote
- Leaderboard: View → Filter by category → View details

---

## 📊 Success Metrics

### User Engagement
- % of users with wisdom score > 5.0
- Average wisdom score
- Achievement unlock rate
- Endorsement adoption rate

### Community Quality
- Helpful rating percentage (target: 85%+)
- Verified story percentage
- Interaction consistency
- Category expertise distribution

### Gamification Effectiveness
- Achievement unlock frequency
- Endorsement creation rate
- Leaderboard participation
- Repeat contribution rate

---

## 🔐 Security Considerations

### Data Protection
- Wisdom scores are public (for leaderboards)
- Interaction ratings are anonymous
- Endorsements require verification
- Achievement data is immutable

### Fraud Prevention
- Rate limiting on ratings
- Duplicate rating prevention
- Endorsement cost (token-based)
- Verification requirements

### Privacy
- User can opt-out of leaderboard
- Ratings don't show rater identity
- Endorsement votes are private
- Achievement data is user-owned

---

## 📚 Documentation

### For Developers
- Service documentation with examples
- Model structure and relationships
- Integration points and flows
- Testing guidelines

### For Users
- Wisdom score explanation
- Achievement guide
- Endorsement system
- Leaderboard rules

---

## 🎉 Conclusion

Phase 4 provides a comprehensive reputation and gamification system that:
- ✅ Rewards quality contributions
- ✅ Builds community trust
- ✅ Encourages mentorship
- ✅ Creates organic scarcity
- ✅ Drives user engagement

**Status: Core implementation complete, ready for repository and UI layer**

---

*Implementation Date: November 20, 2025*  
*Next Phase: Create repositories, providers, and UI widgets*
