import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../models/wisdom_score_model.dart';
import '../../models/endorsement_model.dart';
import '../../models/achievement_model.dart';

/// Remote data source for wisdom scores, endorsements, and achievements
class WisdomRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  WisdomRemoteDataSource(this._firestore, this._uuid);

  // Collection references
  CollectionReference get _wisdomScores =>
      _firestore.collection('wisdom_scores');
  CollectionReference get _interactionRatings =>
      _firestore.collection('interaction_ratings');
  CollectionReference get _endorsements =>
      _firestore.collection('endorsements');
  CollectionReference get _endorsementVotes =>
      _firestore.collection('endorsement_votes');
  CollectionReference get _achievements =>
      _firestore.collection('achievements');

  // ===== WISDOM SCORE OPERATIONS =====

  /// Get user's wisdom score
  Future<WisdomScore> getWisdomScore(String userId) async {
    final doc = await _wisdomScores.doc(userId).get();
    if (!doc.exists) {
      throw Exception('Wisdom score not found for user: $userId');
    }
    return WisdomScore.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Create or update wisdom score
  Future<WisdomScore> upsertWisdomScore(WisdomScore score) async {
    await _wisdomScores.doc(score.userId).set(score.toJson());
    return score;
  }

  /// Get top wisdom scores (leaderboard)
  Future<List<WisdomScore>> getTopWisdomScores({
    int limit = 50,
    String timeframe = 'all_time',
  }) async {
    final snapshot = await _wisdomScores
        .orderBy('overall_score', descending: true)
        .limit(limit)
        .get();

    final scores = snapshot.docs
        .map((doc) => WisdomScore.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    return _filterScoresByTimeframe(scores, timeframe);
  }

  /// Get wisdom scores by category
  Future<List<WisdomScore>> getWisdomScoresByCategory({
    required String category,
    int limit = 20,
    String timeframe = 'all_time',
  }) async {
    final snapshot = await _wisdomScores
        .orderBy('category_scores.$category', descending: true)
        .limit(limit)
        .get();

    final scores = snapshot.docs
        .map((doc) => WisdomScore.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    return _filterScoresByTimeframe(scores, timeframe);
  }

  // ===== INTERACTION RATING OPERATIONS =====

  /// Submit interaction rating
  Future<InteractionRating> submitInteractionRating(
    InteractionRating rating,
  ) async {
    final id = _uuid.v4();
    final ratingWithId = InteractionRating(
      id: id,
      userId: rating.userId,
      targetUserId: rating.targetUserId,
      interactionId: rating.interactionId,
      interactionType: rating.interactionType,
      rating: rating.rating,
      category: rating.category,
      comment: rating.comment,
      createdAt: DateTime.now(),
    );

    await _interactionRatings.doc(id).set(ratingWithId.toJson());
    return ratingWithId;
  }

  /// Get interaction ratings for user
  Future<List<InteractionRating>> getUserInteractionRatings({
    required String userId,
    int limit = 100,
  }) async {
    final snapshot = await _interactionRatings
        .where('target_user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) =>
            InteractionRating.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get helpful ratings count
  Future<int> getHelpfulRatingsCount(String userId) async {
    final snapshot = await _interactionRatings
        .where('target_user_id', isEqualTo: userId)
        .where('rating', isEqualTo: true)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  /// Get unhelpful ratings count
  Future<int> getUnhelpfulRatingsCount(String userId) async {
    final snapshot = await _interactionRatings
        .where('target_user_id', isEqualTo: userId)
        .where('rating', isEqualTo: false)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  // ===== ENDORSEMENT OPERATIONS =====

  /// Get user endorsements
  Future<List<Endorsement>> getUserEndorsements(String userId) async {
    final snapshot = await _endorsements
        .where('user_id', isEqualTo: userId)
        .where('is_active', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => Endorsement.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Create endorsement
  Future<Endorsement> createEndorsement(Endorsement endorsement) async {
    final id = _uuid.v4();
    final endorsementWithId = Endorsement(
      id: id,
      userId: endorsement.userId,
      endorsedUserId: endorsement.endorsedUserId,
      badge: endorsement.badge,
      category: endorsement.category,
      endorserCount: 1,
      isActive: true,
      createdAt: DateTime.now(),
      expiresAt: endorsement.expiresAt,
      metadata: endorsement.metadata,
    );

    await _endorsements.doc(id).set(endorsementWithId.toJson());
    return endorsementWithId;
  }

  /// Add endorsement vote
  Future<EndorsementVote> addEndorsementVote(
    EndorsementVote vote,
  ) async {
    final id = _uuid.v4();
    final voteWithId = EndorsementVote(
      id: id,
      endorsementId: vote.endorsementId,
      endorserId: vote.endorserId,
      endorsedUserId: vote.endorsedUserId,
      badge: vote.badge,
      cost: vote.cost,
      createdAt: DateTime.now(),
    );

    await _endorsementVotes.doc(id).set(voteWithId.toJson());

    // Increment endorser count
    await _endorsements.doc(vote.endorsementId).update({
      'endorser_count': FieldValue.increment(1),
    });

    return voteWithId;
  }

  /// Get endorsement votes
  Future<List<EndorsementVote>> getEndorsementVotes(
    String endorsementId,
  ) async {
    final snapshot = await _endorsementVotes
        .where('endorsement_id', isEqualTo: endorsementId)
        .get();

    return snapshot.docs
        .map((doc) =>
            EndorsementVote.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // ===== ACHIEVEMENT OPERATIONS =====

  /// Get user achievements
  Future<List<Achievement>> getUserAchievements(String userId) async {
    final snapshot = await _achievements
        .where('user_id', isEqualTo: userId)
        .orderBy('unlocked_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Achievement.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Unlock achievement
  Future<Achievement> unlockAchievement(Achievement achievement) async {
    final id = _uuid.v4();
    final achievementWithId = Achievement(
      id: id,
      userId: achievement.userId,
      type: achievement.type,
      title: achievement.title,
      description: achievement.description,
      icon: achievement.icon,
      rarity: achievement.rarity,
      unlockedAt: DateTime.now(),
      progress: achievement.progress,
      progressTarget: achievement.progressTarget,
      metadata: achievement.metadata,
    );

    await _achievements.doc(id).set(achievementWithId.toJson());
    return achievementWithId;
  }

  /// Update achievement progress
  Future<void> updateAchievementProgress({
    required String achievementId,
    required int progress,
  }) async {
    await _achievements.doc(achievementId).update({
      'progress': progress,
    });
  }

  /// Get achievement statistics
  Future<Map<String, dynamic>> getAchievementStats(String userId) async {
    final achievements = await getUserAchievements(userId);

    return {
      'total_achievements': achievements.length,
      'by_rarity': _countByRarity(achievements),
      'by_type': _countByType(achievements),
      'latest_achievement': achievements.isNotEmpty ? achievements.first : null,
    };
  }

  // ===== HELPER METHODS =====

  Map<String, int> _countByRarity(List<Achievement> achievements) {
    final counts = <String, int>{};
    for (final achievement in achievements) {
      final rarity = achievement.rarity.toLowerCase();
      counts[rarity] = (counts[rarity] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> _countByType(List<Achievement> achievements) {
    final counts = <String, int>{};
    for (final achievement in achievements) {
      final type = achievement.type.value;
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return counts;
  }

  List<WisdomScore> _filterScoresByTimeframe(
    List<WisdomScore> scores,
    String timeframe,
  ) {
    final duration = _timeframeToDuration(timeframe);
    if (duration == null) return scores;

    final threshold = DateTime.now().subtract(duration);
    return scores.where((score) => score.updatedAt.isAfter(threshold)).toList();
  }

  Duration? _timeframeToDuration(String timeframe) {
    switch (timeframe) {
      case '24h':
        return const Duration(hours: 24);
      case '7d':
      case 'past_week':
        return const Duration(days: 7);
      case '30d':
      case 'past_month':
        return const Duration(days: 30);
      default:
        return null;
    }
  }
}
