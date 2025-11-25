import '../../../wisdom/models/achievement_model.dart';
import '../../../wisdom/models/endorsement_model.dart';
import '../../../wisdom/models/wisdom_score_model.dart';

/// Wisdom repository contract describing the complete Phase 4 surface area.
abstract class WisdomRepository {
  /// Retrieve a user's persisted wisdom score document.
  Future<WisdomScore> getWisdomScore(String userId);

  /// Recalculate factors, update Firestore, and return the fresh wisdom score.
  Future<WisdomScore> calculateAndUpdateWisdomScore(String userId);

  /// Fetch the leaderboard ordered by overall score.
  Future<List<WisdomScore>> getLeaderboard({
    int limit = 50,
    String? category,
    String timeframe = 'all_time',
  });

  /// Submit a helpful/unhelpful interaction rating.
  Future<InteractionRating> rateInteraction(InteractionRating rating);

  /// Retrieve recent interaction ratings for a target user.
  Future<List<InteractionRating>> getInteractionRatings({
    required String userId,
    int limit,
  });

  /// Create an endorsement for a user (includes validation + persistence).
  Future<Endorsement> createEndorsement(Endorsement endorsement);

  /// Add an endorsement vote (used when additional peers co-sign an endorsement).
  Future<EndorsementVote> addEndorsementVote(EndorsementVote vote);

  /// Fetch active endorsements for a user.
  Future<List<Endorsement>> getUserEndorsements(String userId);

  /// Retrieve unlocked achievements for a user.
  Future<List<Achievement>> getUserAchievements(String userId);

  /// Unlock a new achievement instance for a user.
  Future<Achievement> unlockAchievement(Achievement achievement);

  /// Aggregate achievement statistics (totals, rarity mix, etc.).
  Future<Map<String, dynamic>> getAchievementStats(String userId);
}
