import 'dart:developer' as developer;

import 'package:flutter_chekmate/features/wisdom/models/cultural_expertise_model.dart';

/// Service for tracking cultural expertise in wisdom scoring
class CulturalExpertiseService {
  static final CulturalExpertiseService _instance =
      CulturalExpertiseService._internal();
  static CulturalExpertiseService get instance => _instance;

  CulturalExpertiseService._internal();

  // In-memory cache of user cultural expertise
  final Map<String, List<CulturalExpertise>> _userExpertise = {};

  /// Calculate cultural expertise score for a user in a specific culture
  Future<double> calculateCulturalExpertiseScore({
    required String userId,
    required String cultureCode,
    required int helpfulRatings,
    required int totalContributions,
  }) async {
    try {
      if (totalContributions == 0) return 0.0;

      // Base score from helpful ratio
      final helpfulRatio = helpfulRatings / totalContributions;
      final baseScore = helpfulRatio * 10;

      // Volume bonus (up to +2 points)
      final volumeBonus = _calculateVolumeBonus(totalContributions);

      // Final score clamped to 0-10
      final score = (baseScore + volumeBonus).clamp(0.0, 10.0);

      developer.log(
        'Cultural expertise for $userId in $cultureCode: $score',
        name: 'CulturalExpertise',
      );

      return score;
    } catch (e) {
      developer.log(
        'Failed to calculate cultural expertise: $e',
        name: 'CulturalExpertise',
        error: e,
      );
      return 0.0;
    }
  }

  /// Award or update cultural expertise badge
  Future<CulturalExpertise> awardCulturalBadge({
    required String userId,
    required String cultureCode,
    required String cultureName,
    required int helpfulRatings,
    required int totalContributions,
  }) async {
    try {
      final score = await calculateCulturalExpertiseScore(
        userId: userId,
        cultureCode: cultureCode,
        helpfulRatings: helpfulRatings,
        totalContributions: totalContributions,
      );

      final badgeLevel = _determineBadgeLevel(score, totalContributions);

      final expertise = CulturalExpertise(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        cultureCode: cultureCode,
        cultureName: cultureName,
        expertiseScore: score,
        helpfulRatingsInCulture: helpfulRatings,
        totalContributionsInCulture: totalContributions,
        badgeLevel: badgeLevel,
        earnedAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      // Cache the expertise
      _userExpertise.putIfAbsent(userId, () => []).add(expertise);

      developer.log(
        'Awarded ${badgeLevel.displayName} badge to $userId for $cultureName',
        name: 'CulturalExpertise',
      );

      return expertise;
    } catch (e) {
      developer.log(
        'Failed to award cultural badge: $e',
        name: 'CulturalExpertise',
        error: e,
      );
      rethrow;
    }
  }

  /// Get all cultural expertise badges for a user
  Future<List<CulturalExpertise>> getUserCulturalExpertise({
    required String userId,
  }) async {
    return _userExpertise[userId] ?? [];
  }

  /// Check if user has expertise in a specific culture
  Future<bool> hasExpertiseInCulture({
    required String userId,
    required String cultureCode,
    CulturalBadgeLevel minLevel = CulturalBadgeLevel.bronze,
  }) async {
    final expertise = _userExpertise[userId] ?? [];
    
    return expertise.any((e) =>
        e.cultureCode == cultureCode &&
        e.badgeLevel.index >= minLevel.index);
  }

  /// Get top cultural experts for a specific culture
  Future<List<String>> getTopCulturalExperts({
    required String cultureCode,
    int limit = 10,
  }) async {
    final allExperts = <String, double>{};

    for (final entry in _userExpertise.entries) {
      final userId = entry.key;
      final expertiseList = entry.value;

      final cultureExpertise = expertiseList
          .where((e) => e.cultureCode == cultureCode)
          .toList();

      if (cultureExpertise.isNotEmpty) {
        final maxScore = cultureExpertise
            .map((e) => e.expertiseScore)
            .reduce((a, b) => a > b ? a : b);
        allExperts[userId] = maxScore;
      }
    }

    // Sort by score and return top N
    final sorted = allExperts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).map((e) => e.key).toList();
  }

  // Private helper methods

  double _calculateVolumeBonus(int contributions) {
    if (contributions < 5) return 0.0;
    if (contributions < 15) return 0.5;
    if (contributions < 50) return 1.0;
    if (contributions < 100) return 1.5;
    return 2.0;
  }

  CulturalBadgeLevel _determineBadgeLevel(double score, int contributions) {
    if (score >= CulturalBadgeLevel.platinum.minScore &&
        contributions >= CulturalBadgeLevel.platinum.minContributions) {
      return CulturalBadgeLevel.platinum;
    } else if (score >= CulturalBadgeLevel.gold.minScore &&
        contributions >= CulturalBadgeLevel.gold.minContributions) {
      return CulturalBadgeLevel.gold;
    } else if (score >= CulturalBadgeLevel.silver.minScore &&
        contributions >= CulturalBadgeLevel.silver.minContributions) {
      return CulturalBadgeLevel.silver;
    } else if (score >= CulturalBadgeLevel.bronze.minScore &&
        contributions >= CulturalBadgeLevel.bronze.minContributions) {
      return CulturalBadgeLevel.bronze;
    }
    
    return CulturalBadgeLevel.bronze;
  }
}
