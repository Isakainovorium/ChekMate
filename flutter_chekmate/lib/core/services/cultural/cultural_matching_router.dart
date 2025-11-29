import 'package:flutter/foundation.dart';

import 'package:flutter_chekmate/core/config/environment_config.dart';
import 'package:flutter_chekmate/features/cultural/models/cultural_identity_evolved.dart';
import 'package:flutter_chekmate/core/services/cultural/cultural_vector_service.dart';

/// Router for managing parallel enum and ML-based cultural matching systems
/// Enables gradual migration and A/B testing during transition period
class CulturalMatchingRouter {
  final ABTestConfig _abTestConfig;

  // Threshold for determining which system to use
  static const double _mlConfidenceThreshold = 0.7;
  static const double _profileRichnessThreshold = 0.5;

  CulturalMatchingRouter({
    ABTestConfig? abTestConfig,
  }) : _abTestConfig = abTestConfig ?? ABTestConfig();

  /// Determine which matching system to use for a given profile
  MatchingSystemType getMatchingSystem(CulturalIdentityEvolved profile) {
    if (CulturalSystemConfig.mlFeaturesOnHold) {
      return MatchingSystemType.enumBased;
    }

    // Check migration status first
    if (!profile.migrationStatus.canUseML) {
      return MatchingSystemType.enumBased;
    }

    if (!profile.migrationStatus.canUseEnum) {
      return MatchingSystemType.mlBased;
    }

    // Profile is in parallel mode - decide based on A/B test and quality
    if (_abTestConfig.isInMLTestGroup(profile.userId)) {
      // User is in ML test group
      if (profile.isMLReady) {
        return MatchingSystemType.mlBased;
      }
    }

    // Check profile quality
    if (profile.profileRichness >= _profileRichnessThreshold &&
        profile.hasVectorData) {
      return MatchingSystemType.mlWithFallback;
    }

    // Default to enum for safety
    return MatchingSystemType.enumBased;
  }

  /// Calculate match score between two profiles using appropriate system
  Future<MatchResult> calculateMatch(
    CulturalIdentityEvolved profile1,
    CulturalIdentityEvolved profile2,
  ) async {
    final system1 = getMatchingSystem(profile1);
    final system2 = getMatchingSystem(profile2);

    // Both profiles must support the same system
    final effectiveSystem = _determineEffectiveSystem(system1, system2);

    switch (effectiveSystem) {
      case MatchingSystemType.mlBased:
        return await _calculateMLMatch(profile1, profile2);

      case MatchingSystemType.enumBased:
        return _calculateEnumMatch(profile1, profile2);

      case MatchingSystemType.mlWithFallback:
        // Try ML first, fall back to enum if needed
        try {
          final mlResult = await _calculateMLMatch(profile1, profile2);
          if (mlResult.confidence >= _mlConfidenceThreshold) {
            return mlResult;
          }
        } catch (e) {
          debugPrint('ML matching failed, falling back to enum: $e');
        }
        return _calculateEnumMatch(profile1, profile2);

      case MatchingSystemType.hybrid:
        // Combine both systems with weights
        return await _calculateHybridMatch(profile1, profile2);
    }
  }

  /// Determine effective matching system when profiles have different capabilities
  MatchingSystemType _determineEffectiveSystem(
    MatchingSystemType system1,
    MatchingSystemType system2,
  ) {
    // If either profile is enum-only, use enum
    if (system1 == MatchingSystemType.enumBased ||
        system2 == MatchingSystemType.enumBased) {
      return MatchingSystemType.enumBased;
    }

    // If both are ML-ready, use ML
    if (system1 == MatchingSystemType.mlBased &&
        system2 == MatchingSystemType.mlBased) {
      return MatchingSystemType.mlBased;
    }

    // Mixed capabilities - use hybrid approach
    return MatchingSystemType.hybrid;
  }

  /// Calculate match using ML/vector system
  Future<MatchResult> _calculateMLMatch(
    CulturalIdentityEvolved profile1,
    CulturalIdentityEvolved profile2,
  ) async {
    if (CulturalSystemConfig.mlFeaturesOnHold) {
      throw Exception(
          'ML matching temporarily disabled via CulturalSystemConfig');
    }

    if (!profile1.hasVectorData || !profile2.hasVectorData) {
      throw Exception('Profiles missing vector data for ML matching');
    }

    final similarity = CulturalVectorService.calculateCosineSimilarity(
      profile1.culturalVector!,
      profile2.culturalVector!,
    );

    // Calculate confidence based on profile richness
    final confidence =
        (profile1.profileRichness + profile2.profileRichness) / 2;

    // Identify shared clusters
    final sharedClusters = profile1.discoveredClusters
        .where((c) => profile2.discoveredClusters.contains(c))
        .toList();

    return MatchResult(
      score: similarity,
      confidence: confidence,
      matchingSystem: MatchingSystemType.mlBased,
      sharedPatterns: sharedClusters,
      metadata: {
        'vector_dimension': profile1.culturalVector!.length,
        'profile1_richness': profile1.profileRichness,
        'profile2_richness': profile2.profileRichness,
      },
    );
  }

  /// Calculate match using enum-based system
  MatchResult _calculateEnumMatch(
    CulturalIdentityEvolved profile1,
    CulturalIdentityEvolved profile2,
  ) {
    final score = profile1.calculateSimilarity(profile2);

    // Confidence is based on profile completeness
    final confidence =
        (profile1.profileCompleteness + profile2.profileCompleteness) / 2;

    // Identify shared enum values
    final sharedPatterns = <String>[];

    if (profile1.primaryEthnicity == profile2.primaryEthnicity &&
        profile1.primaryEthnicity != null) {
      sharedPatterns.add('ethnicity:${profile1.primaryEthnicity!.name}');
    }

    for (final community in profile1.communities) {
      if (profile2.communities.contains(community)) {
        sharedPatterns.add('community:${community.name}');
      }
    }

    return MatchResult(
      score: score,
      confidence: confidence,
      matchingSystem: MatchingSystemType.enumBased,
      sharedPatterns: sharedPatterns,
      metadata: {
        'enum_factors_matched': sharedPatterns.length,
        'profile1_completeness': profile1.profileCompleteness,
        'profile2_completeness': profile2.profileCompleteness,
      },
    );
  }

  /// Calculate hybrid match combining ML and enum systems
  Future<MatchResult> _calculateHybridMatch(
    CulturalIdentityEvolved profile1,
    CulturalIdentityEvolved profile2,
  ) async {
    MatchResult? mlResult;
    MatchResult? enumResult;

    // Try ML matching if possible
    if (profile1.hasVectorData && profile2.hasVectorData) {
      try {
        mlResult = await _calculateMLMatch(profile1, profile2);
      } catch (e) {
        debugPrint('ML matching failed in hybrid mode: $e');
      }
    }

    // Always calculate enum match as baseline
    enumResult = _calculateEnumMatch(profile1, profile2);

    if (mlResult == null) {
      // Only enum available
      return enumResult.copyWith(
        matchingSystem: MatchingSystemType.hybrid,
      );
    }

    // Combine scores with weights based on confidence
    final mlWeight = mlResult.confidence;
    final enumWeight = 1.0 - mlWeight;

    final combinedScore =
        (mlResult.score * mlWeight) + (enumResult.score * enumWeight);

    final combinedConfidence =
        (mlResult.confidence + enumResult.confidence) / 2;

    // Merge shared patterns
    final allPatterns = <String>{
      ...mlResult.sharedPatterns,
      ...enumResult.sharedPatterns,
    }.toList();

    return MatchResult(
      score: combinedScore,
      confidence: combinedConfidence,
      matchingSystem: MatchingSystemType.hybrid,
      sharedPatterns: allPatterns,
      metadata: {
        'ml_score': mlResult.score,
        'enum_score': enumResult.score,
        'ml_weight': mlWeight,
        'enum_weight': enumWeight,
        ...mlResult.metadata,
        ...enumResult.metadata,
      },
    );
  }

  /// Batch match a profile against multiple candidates
  Future<List<MatchResult>> batchMatch(
      CulturalIdentityEvolved profile, List<CulturalIdentityEvolved> candidates,
      {int? topK}) async {
    final results = <MatchResult>[];

    for (final candidate in candidates) {
      try {
        final result = await calculateMatch(profile, candidate);
        results.add(result);
      } catch (e) {
        debugPrint('Failed to match with candidate ${candidate.id}: $e');
      }
    }

    // Sort by score descending
    results.sort((a, b) => b.score.compareTo(a.score));

    // Return top K if specified
    if (topK != null && topK < results.length) {
      return results.take(topK).toList();
    }

    return results;
  }

  /// Monitor and log matching system usage
  void logMatchingMetrics(MatchResult result) {
    // This would integrate with your analytics system
    debugPrint('Match completed: '
        'System=${result.matchingSystem.name}, '
        'Score=${result.score.toStringAsFixed(3)}, '
        'Confidence=${result.confidence.toStringAsFixed(3)}');
  }
}

/// Types of matching systems available
enum MatchingSystemType {
  enumBased, // Traditional enum-based matching
  mlBased, // Pure ML/vector-based matching
  mlWithFallback, // ML with enum fallback
  hybrid, // Weighted combination of both
}

/// Result of a cultural match calculation
class MatchResult {
  final double score;
  final double confidence;
  final MatchingSystemType matchingSystem;
  final List<String> sharedPatterns;
  final Map<String, dynamic> metadata;

  MatchResult({
    required this.score,
    required this.confidence,
    required this.matchingSystem,
    this.sharedPatterns = const [],
    this.metadata = const {},
  });

  MatchResult copyWith({
    double? score,
    double? confidence,
    MatchingSystemType? matchingSystem,
    List<String>? sharedPatterns,
    Map<String, dynamic>? metadata,
  }) {
    return MatchResult(
      score: score ?? this.score,
      confidence: confidence ?? this.confidence,
      matchingSystem: matchingSystem ?? this.matchingSystem,
      sharedPatterns: sharedPatterns ?? this.sharedPatterns,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// A/B test configuration for gradual rollout
class ABTestConfig {
  final double mlTestPercentage;
  final Set<String> explicitMLUsers;
  final Set<String> explicitEnumUsers;
  final DateTime? testEndDate;

  ABTestConfig({
    this.mlTestPercentage = 0.1, // Start with 10% in ML test
    this.explicitMLUsers = const {},
    this.explicitEnumUsers = const {},
    this.testEndDate,
  });

  bool isInMLTestGroup(String userId) {
    // Check explicit lists first
    if (explicitMLUsers.contains(userId)) return true;
    if (explicitEnumUsers.contains(userId)) return false;

    // Check if test has ended
    if (testEndDate != null && DateTime.now().isAfter(testEndDate!)) {
      return true; // All users on ML after test ends
    }

    // Use deterministic hash for consistent assignment
    final hash = userId.hashCode.abs();
    final threshold = (mlTestPercentage * 1000).round();
    return (hash % 1000) < threshold;
  }
}
