import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/providers.dart';
import '../../data/models/contextual_follow_suggestion_model.dart';
import '../../data/models/reading_event_model.dart';
import '../../data/models/serendipity_recommendation_model.dart';
import '../../data/models/user_behavior_profile_model.dart';
import '../../services/reading_analytics_service.dart';

/// ===== SERVICE PROVIDERS =====

/// Reading Analytics Service Provider
final readingAnalyticsServiceProvider =
    Provider<ReadingAnalyticsService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ReadingAnalyticsService(firestore);
});

/// ===== DATA PROVIDERS =====

/// User Behavior Profile Provider
/// Provides the aggregated reading behavior profile for the current user
final userBehaviorProfileProvider =
    StreamProvider<UserBehaviorProfileModel?>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final userId = ref.watch(currentUserIdProvider).value;

  if (userId == null) {
    return Stream.value(null);
  }

  return firestore
      .collection('userBehaviorProfiles')
      .doc(userId)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    return UserBehaviorProfileModel.fromJson(snapshot.data()!);
  });
});

/// Reading Events Stream Provider
/// Provides recent reading events for the current user
final userReadingEventsProvider =
    StreamProvider<List<ReadingEventModel>>((ref) {
  final service = ref.watch(readingAnalyticsServiceProvider);
  final userId = ref.watch(currentUserIdProvider).value;

  if (userId == null) {
    return Stream.value([]);
  }

  return service.getUserReadingEvents(userId, limit: 50);
});

/// Serendipity Recommendations Provider
/// Provides diverse content recommendations for the current user
final serendipityRecommendationsProvider =
    StreamProvider<SerendipityRecommendationModel?>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final userId = ref.watch(currentUserIdProvider).value;

  if (userId == null) {
    return Stream.value(null);
  }

  return firestore
      .collection('serendipityRecommendations')
      .doc(userId)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    return SerendipityRecommendationModel.fromJson(snapshot.data()!);
  });
});

/// Contextual Follow Suggestions Provider
/// Provides smart follow suggestions based on journey/topic matching
final contextualFollowSuggestionsProvider =
    StreamProvider<List<ContextualFollowSuggestionModel>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final userId = ref.watch(currentUserIdProvider).value;

  if (userId == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('contextualFollowSuggestions')
      .where('userId', isEqualTo: userId)
      .orderBy('similarityScore', descending: true)
      .limit(20)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => ContextualFollowSuggestionModel.fromJson(doc.data()))
        .toList();
  });
});

/// ===== CONTROLLER PROVIDERS =====

/// Reading Insights Controller
/// Manages reading pattern analysis features
final readingInsightsControllerProvider = Provider((ref) {
  return ReadingInsightsController(ref);
});

/// Reading Insights Controller
class ReadingInsightsController {
  ReadingInsightsController(this.ref);

  final Ref ref;

  /// Log a reading event
  Future<void> logReadingEvent({
    required String contentId,
    required List<String> tags,
    required int timeSpentMs,
    required double completionPercent,
    double sentiment = 0.0,
  }) async {
    final userId = ref.read(currentUserIdProvider).value;
    if (userId == null) return;

    final service = ref.read(readingAnalyticsServiceProvider);
    await service.logReadingEvent(
      userId: userId,
      contentId: contentId,
      tags: tags,
      timeSpentMs: timeSpentMs,
      completionPercent: completionPercent,
      sentiment: sentiment,
    );
  }

  /// Start a reading session
  String startReadingSession({
    required String contentId,
    required List<String> tags,
  }) {
    final userId = ref.read(currentUserIdProvider).value;
    if (userId == null) return '';

    final service = ref.read(readingAnalyticsServiceProvider);
    return service.startReadingSession(
      userId: userId,
      contentId: contentId,
      tags: tags,
    );
  }

  /// End a reading session
  Future<void> endReadingSession({
    required String sessionId,
    required String contentId,
    required List<String> tags,
    required int timeSpentMs,
    required double completionPercent,
    double sentiment = 0.0,
  }) async {
    final userId = ref.read(currentUserIdProvider).value;
    if (userId == null) return;

    final service = ref.read(readingAnalyticsServiceProvider);
    await service.endReadingSession(
      sessionId: sessionId,
      userId: userId,
      contentId: contentId,
      tags: tags,
      timeSpentMs: timeSpentMs,
      completionPercent: completionPercent,
      sentiment: sentiment,
    );
  }

  /// Get reading insights summary
  Map<String, dynamic> getReadingInsightsSummary(
      UserBehaviorProfileModel? profile) {
    if (profile == null) {
      return {
        'hasData': false,
        'message': 'Start reading content to see personalized insights',
      };
    }

    final topCategory = profile.topCategories.isNotEmpty
        ? profile.topCategories.first
        : 'general';
    final affinityPercent = (profile.emotionalAffinity * 100).round();

    return {
      'hasData': true,
      'topCategory': topCategory,
      'emotionalAffinity': affinityPercent,
      'learningPace': profile.learningPaceScore,
      'recommendedTags': profile.recommendedTags,
      'insight':
          'You respond well to $topCategory content with $affinityPercent% emotional engagement',
    };
  }
}

/// Serendipity Mode State Provider
final serendipityModeEnabledProvider = StateProvider<bool>((ref) => false);
