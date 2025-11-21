import 'package:flutter_chekmate/features/wisdom/models/wisdom_score_model.dart';

/// Service for calculating and managing wisdom scores
class WisdomScoreService {
  static final WisdomScoreService _instance = WisdomScoreService._internal();
  static WisdomScoreService get instance => _instance;

  WisdomScoreService._internal();

  // Scoring weights
  static const double _helpfulnessWeight = 0.35;
  static const double _peerValidationWeight = 0.25;
  static const double _verificationWeight = 0.20;
  static const double _recencyWeight = 0.10;
  static const double _consistencyWeight = 0.10;

  // Thresholds for achievement levels
  static const double _sageThreshold = 5.0;
  static const double _mentorThreshold = 6.5;
  static const double _coachThreshold = 8.0;
  static const double _lumineryThreshold = 9.0;

  /// Calculate wisdom score from factors
  Future<double> calculateWisdomScore({
    required WisdomScoreFactors factors,
  }) async {
    final score = (factors.helpfulnessRating * _helpfulnessWeight) +
        (factors.peerValidation * 10 * _peerValidationWeight) +
        (factors.storyVerification * 10 * _verificationWeight) +
        (factors.recencyBonus * 10 * _recencyWeight) +
        (factors.consistencyScore * 10 * _consistencyWeight);

    // Apply engagement multiplier
    return (score * factors.engagementMultiplier).clamp(0, 10).toDouble();
  }

  /// Calculate factors from raw data
  Future<WisdomScoreFactors> calculateFactors({
    required int helpfulRatings,
    required int unhelpfulRatings,
    required int totalInteractions,
    required int verifiedStories,
    required DateTime lastActivityDate,
    required List<double> recentScores,
  }) async {
    // Helpfulness rating (0-10)
    final helpfulnessRating = _calculateHelpfulnessRating(
      helpfulRatings,
      unhelpfulRatings,
    );

    // Peer validation (0-1)
    final peerValidation = _calculatePeerValidation(
      helpfulRatings,
      unhelpfulRatings,
    );

    // Story verification (0-1)
    final storyVerification = _calculateStoryVerification(
      verifiedStories,
      totalInteractions,
    );

    // Recency bonus (0-1)
    final recencyBonus = _calculateRecencyBonus(lastActivityDate);

    // Consistency score (0-1)
    final consistencyScore = _calculateConsistencyScore(recentScores);

    // Engagement multiplier (0-2)
    final engagementMultiplier = _calculateEngagementMultiplier(
      totalInteractions,
    );

    return WisdomScoreFactors(
      helpfulnessRating: helpfulnessRating,
      peerValidation: peerValidation,
      storyVerification: storyVerification,
      recencyBonus: recencyBonus,
      consistencyScore: consistencyScore,
      engagementMultiplier: engagementMultiplier,
    );
  }

  /// Determine achievement level from score
  AchievementLevel getAchievementLevel(double score) {
    if (score >= _lumineryThreshold) {
      return AchievementLevel.luminary;
    } else if (score >= _coachThreshold) {
      return AchievementLevel.coach;
    } else if (score >= _mentorThreshold) {
      return AchievementLevel.mentor;
    } else if (score >= _sageThreshold) {
      return AchievementLevel.sage;
    }
    return AchievementLevel.sage;
  }

  /// Calculate category-specific scores
  Future<Map<String, double>> calculateCategoryScores({
    required Map<WisdomCategory, List<double>> categoryRatings,
  }) async {
    final scores = <String, double>{};

    for (final entry in categoryRatings.entries) {
      final category = entry.key;
      final ratings = entry.value;

      if (ratings.isEmpty) {
        scores[category.value] = 0;
      } else {
        final average = ratings.reduce((a, b) => a + b) / ratings.length;
        scores[category.value] = average.clamp(0, 10).toDouble();
      }
    }

    return scores;
  }

  /// Apply decay to older scores
  Future<double> applyDecay({
    required double score,
    required DateTime lastUpdated,
    double decayRate = 0.01, // 1% per day
  }) async {
    final daysSinceUpdate = DateTime.now().difference(lastUpdated).inDays;
    final decayFactor = 1 - (decayRate * daysSinceUpdate);
    return (score * decayFactor).clamp(0, 10).toDouble();
  }

  /// Get score trend
  Future<String> getScoreTrend({
    required double currentScore,
    required double previousScore,
  }) async {
    final difference = currentScore - previousScore;

    if (difference > 0.5) {
      return 'rising';
    } else if (difference < -0.5) {
      return 'falling';
    } else {
      return 'stable';
    }
  }

  /// Predict next achievement level
  AchievementLevel predictNextLevel(double currentScore) {
    final currentLevel = getAchievementLevel(currentScore);

    switch (currentLevel) {
      case AchievementLevel.sage:
        return AchievementLevel.mentor;
      case AchievementLevel.mentor:
        return AchievementLevel.coach;
      case AchievementLevel.coach:
        return AchievementLevel.luminary;
      case AchievementLevel.luminary:
        return AchievementLevel.luminary;
    }
  }

  /// Calculate points needed for next level
  double pointsNeededForNextLevel(double currentScore) {
    final nextLevel = predictNextLevel(currentScore);
    final threshold = _getThresholdForLevel(nextLevel);
    return (threshold - currentScore).clamp(0, 10).toDouble();
  }

  // ===== PRIVATE HELPER METHODS =====

  double _calculateHelpfulnessRating(int helpful, int unhelpful) {
    final total = helpful + unhelpful;
    if (total == 0) return 5.0; // Neutral if no ratings

    final percentage = (helpful / total) * 100;
    // Convert percentage to 0-10 scale
    return (percentage / 10).clamp(0, 10).toDouble();
  }

  double _calculatePeerValidation(int helpful, int unhelpful) {
    final total = helpful + unhelpful;
    if (total == 0) return 0.5; // Neutral if no ratings

    return (helpful / total).clamp(0, 1).toDouble();
  }

  double _calculateStoryVerification(int verified, int total) {
    if (total == 0) return 0;
    return (verified / total).clamp(0, 1).toDouble();
  }

  double _calculateRecencyBonus(DateTime lastActivity) {
    final daysSinceActivity = DateTime.now().difference(lastActivity).inDays;

    if (daysSinceActivity <= 7) {
      return 1.0; // Full bonus for recent activity
    } else if (daysSinceActivity <= 30) {
      return 0.7;
    } else if (daysSinceActivity <= 90) {
      return 0.4;
    } else {
      return 0.1;
    }
  }

  double _calculateConsistencyScore(List<double> recentScores) {
    if (recentScores.isEmpty) return 0.5;

    // Calculate standard deviation
    final mean = recentScores.reduce((a, b) => a + b) / recentScores.length;
    final variance = recentScores
            .map((score) => (score - mean) * (score - mean))
            .reduce((a, b) => a + b) /
        recentScores.length;
    final stdDev = variance.sqrt();

    // Lower standard deviation = higher consistency
    // Convert to 0-1 scale
    return (1 - (stdDev / 10)).clamp(0, 1).toDouble();
  }

  double _calculateEngagementMultiplier(int totalInteractions) {
    if (totalInteractions < 10) {
      return 0.5;
    } else if (totalInteractions < 50) {
      return 1.0;
    } else if (totalInteractions < 100) {
      return 1.3;
    } else if (totalInteractions < 250) {
      return 1.6;
    } else {
      return 2.0;
    }
  }

  double _getThresholdForLevel(AchievementLevel level) {
    switch (level) {
      case AchievementLevel.sage:
        return _sageThreshold;
      case AchievementLevel.mentor:
        return _mentorThreshold;
      case AchievementLevel.coach:
        return _coachThreshold;
      case AchievementLevel.luminary:
        return _lumineryThreshold;
    }
  }
}

extension on double {
  double sqrt() => this < 0 ? 0 : pow(this, 0.5).toDouble();
}

double pow(double base, double exponent) {
  return base == 0 ? 0 : base * base;
}
