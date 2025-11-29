import '../../domain/repositories/wisdom_repository.dart';
import '../../models/achievement_model.dart';
import '../../models/endorsement_model.dart';
import '../../models/wisdom_score_model.dart';
import '../datasources/wisdom_remote_data_source.dart';
import '../../../../core/services/wisdom/wisdom_score_service.dart';
import '../../../../core/services/wisdom/endorsement_service.dart';
import '../../../../core/services/wisdom/gamification_service.dart';

/// Concrete implementation that wires Firestore datasource + services together.
class WisdomRepositoryImpl implements WisdomRepository {
  WisdomRepositoryImpl({
    required WisdomRemoteDataSource remoteDataSource,
    required WisdomScoreService scoreService,
    required EndorsementService endorsementService,
    required GamificationService gamificationService,
  })  : _remoteDataSource = remoteDataSource,
        _scoreService = scoreService,
        _endorsementService = endorsementService,
        _gamificationService = gamificationService;

  final WisdomRemoteDataSource _remoteDataSource;
  final WisdomScoreService _scoreService;
  final EndorsementService _endorsementService;
  final GamificationService _gamificationService;

  @override
  Future<WisdomScore> getWisdomScore(String userId) {
    return _remoteDataSource.getWisdomScore(userId);
  }

  @override
  Future<WisdomScore> calculateAndUpdateWisdomScore(String userId) async {
    final helpfulCount = await _remoteDataSource.getHelpfulRatingsCount(userId);
    final unhelpfulCount =
        await _remoteDataSource.getUnhelpfulRatingsCount(userId);
    final interactionRatings =
        await _remoteDataSource.getUserInteractionRatings(
      userId: userId,
    );

    // Derive category averages from ratings
    final categoryBuckets = <WisdomCategory, List<double>>{};
    for (final rating in interactionRatings) {
      categoryBuckets.putIfAbsent(rating.category, () => []);
      categoryBuckets[rating.category]!.add(rating.rating ? 10.0 : 0.0);
    }

    final factors = await _scoreService.calculateFactors(
      helpfulRatings: helpfulCount,
      unhelpfulRatings: unhelpfulCount,
      totalInteractions: interactionRatings.length,
      verifiedStories: 0,
      lastActivityDate: interactionRatings.isNotEmpty
          ? interactionRatings.first.createdAt
          : DateTime.now(),
      recentScores: interactionRatings.take(5).map((_) => 7.0).toList(),
    );

    final baseScore = await _scoreService.calculateWisdomScore(
      factors: factors,
    );

    // Apply endorsement impact
    final endorsements = await _remoteDataSource.getUserEndorsements(userId);
    final endorsementImpact = _endorsementService.calculateEndorsementImpact(
      endorsements: endorsements,
    );

    final finalScore = (baseScore + endorsementImpact).clamp(0, 10).toDouble();

    final categoryScores = await _scoreService.calculateCategoryScores(
      categoryRatings: categoryBuckets,
    );

    final achievementLevel = _scoreService.getAchievementLevel(finalScore);
    final userAchievements =
        await _remoteDataSource.getUserAchievements(userId);
    final nextMilestone =
        _gamificationService.getNextMilestone(userAchievements);

    final scoreModel = WisdomScore(
      id: userId,
      userId: userId,
      overallScore: finalScore,
      categoryScores: categoryScores,
      factors: factors,
      totalInteractions: interactionRatings.length,
      helpfulRatings: helpfulCount,
      unhelpfulRatings: unhelpfulCount,
      verifiedStories: 0,
      achievementLevel: achievementLevel,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastCalculatedAt: DateTime.now(),
      metadata: nextMilestone != null
          ? {
              'next_milestone_id': nextMilestone.id,
              'next_milestone_title': nextMilestone.title,
            }
          : null,
    );

    return _remoteDataSource.upsertWisdomScore(scoreModel);
  }

  @override
  Future<List<WisdomScore>> getLeaderboard({
    int limit = 50,
    String? category,
    String timeframe = 'all_time',
  }) {
    if (category != null) {
      return _remoteDataSource.getWisdomScoresByCategory(
        category: category,
        limit: limit,
        timeframe: timeframe,
      );
    }
    return _remoteDataSource.getTopWisdomScores(
      limit: limit,
      timeframe: timeframe,
    );
  }

  @override
  Future<InteractionRating> rateInteraction(InteractionRating rating) {
    return _remoteDataSource.submitInteractionRating(rating);
  }

  @override
  Future<List<InteractionRating>> getInteractionRatings({
    required String userId,
    int limit = 100,
  }) {
    return _remoteDataSource.getUserInteractionRatings(
      userId: userId,
      limit: limit,
    );
  }

  @override
  Future<Endorsement> createEndorsement(Endorsement endorsement) {
    return _remoteDataSource.createEndorsement(endorsement);
  }

  @override
  Future<EndorsementVote> addEndorsementVote(EndorsementVote vote) {
    return _remoteDataSource.addEndorsementVote(vote);
  }

  @override
  Future<List<Endorsement>> getUserEndorsements(String userId) {
    return _remoteDataSource.getUserEndorsements(userId);
  }

  @override
  Future<List<Achievement>> getUserAchievements(String userId) {
    return _remoteDataSource.getUserAchievements(userId);
  }

  @override
  Future<Achievement> unlockAchievement(Achievement achievement) {
    return _remoteDataSource.unlockAchievement(achievement);
  }

  @override
  Future<Map<String, dynamic>> getAchievementStats(String userId) {
    return _remoteDataSource.getAchievementStats(userId);
  }
}
