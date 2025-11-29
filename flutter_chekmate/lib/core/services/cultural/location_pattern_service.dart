import 'dart:math' as math;
import 'package:flutter_chekmate/core/services/cultural/location_context_service.dart';
import 'package:flutter_chekmate/core/services/cultural/cultural_vector_service.dart';
import 'package:flutter_chekmate/features/cultural/models/cultural_identity_evolved.dart';

/// Discovers location-based cultural patterns from user data
class LocationPatternService {
  static final LocationPatternService _instance =
      LocationPatternService._internal();
  static LocationPatternService get instance => _instance;

  final CulturalVectorService _vectorService;
  final LocationPatternRepository _repository;

  // Pattern discovery configuration
  static const int _minClusterSize = 20;
  static const double _minLocationSimilarity = 0.7;
  static const int _maxPatternsPerLocation = 10;

  LocationPatternService._internal()
      : _vectorService = CulturalVectorService(),
        _repository = LocationPatternRepository();

  /// Discover location-based cultural clusters
  Future<List<LocationCulturalPattern>> discoverLocationPatterns({
    required List<UserLocationProfile> allUsers,
    int? minClusterSize,
    double? minSimilarity,
  }) async {
    final patterns = <LocationCulturalPattern>[];
    final minSize = minClusterSize ?? _minClusterSize;
    final minSim = minSimilarity ?? _minLocationSimilarity;

    // Group users by location
    final locationGroups = _groupByLocation(allUsers);

    // For each location group, find common cultural themes
    for (final entry in locationGroups.entries) {
      final location = entry.key;
      final users = entry.value;

      if (users.length < minSize) continue;

      // Extract common cultural themes
      final commonThemes = _extractCommonThemes(users);

      // Calculate centroid vector for this location cluster
      final vectors = users
          .where((u) => u.culturalVector != null)
          .map((u) => u.culturalVector!)
          .toList();

      if (vectors.isEmpty) continue;

      final centroidVector = _vectorService.calculateCentroid(vectors);

      // Calculate average similarity within cluster
      final avgSimilarity = _calculateAverageSimilarity(vectors);

      if (avgSimilarity < minSim) continue;

      // Calculate confidence score
      final confidence = _calculateConfidence(
        userCount: users.length,
        avgSimilarity: avgSimilarity,
        themeCount: commonThemes.length,
      );

      patterns.add(LocationCulturalPattern(
        id: 'loc_pattern_${DateTime.now().millisecondsSinceEpoch}_${location.hashCode}',
        location: location,
        userCount: users.length,
        commonThemes: commonThemes,
        centroidVector: centroidVector,
        averageSimilarity: avgSimilarity,
        confidence: confidence,
        discoveredAt: DateTime.now(),
        metadata: _extractMetadata(users),
      ));
    }

    // Sort by confidence and user count
    patterns.sort((a, b) {
      final confidenceCompare = b.confidence.compareTo(a.confidence);
      if (confidenceCompare != 0) return confidenceCompare;
      return b.userCount.compareTo(a.userCount);
    });

    // Limit patterns per location
    final limitedPatterns = _limitPatternsPerLocation(patterns);

    // Save patterns to repository
    for (final pattern in limitedPatterns) {
      await _repository.saveLocationPattern(pattern);
    }

    return limitedPatterns;
  }

  /// Group users by their primary location
  Map<String, List<UserLocationProfile>> _groupByLocation(
    List<UserLocationProfile> users,
  ) {
    final groups = <String, List<UserLocationProfile>>{};

    for (final user in users) {
      // Use city as primary grouping, fallback to state/country
      String locationKey = 'Unknown';

      if (user.locationContext != null) {
        if (user.locationContext!.city != null) {
          locationKey = user.locationContext!.city!;
          if (user.locationContext!.state != null) {
            locationKey += ', ${user.locationContext!.state}';
          }
        } else if (user.locationContext!.state != null) {
          locationKey = user.locationContext!.state!;
        } else if (user.locationContext!.country != null) {
          locationKey = user.locationContext!.country!;
        }
      }

      groups.putIfAbsent(locationKey, () => []).add(user);
    }

    return groups;
  }

  /// Extract common cultural themes from users
  List<String> _extractCommonThemes(List<UserLocationProfile> users) {
    final themeFrequency = <String, int>{};

    for (final user in users) {
      // Count heritage keywords
      if (user.heritageDescription != null) {
        final words = _extractKeywords(user.heritageDescription!);
        for (final word in words) {
          themeFrequency[word] = (themeFrequency[word] ?? 0) + 1;
        }
      }

      // Count community affiliations
      for (final community in user.communityAffiliations) {
        themeFrequency[community] = (themeFrequency[community] ?? 0) + 1;
      }

      // Count cultural practices
      for (final practice in user.culturalPractices) {
        themeFrequency[practice] = (themeFrequency[practice] ?? 0) + 1;
      }

      // Count location keywords
      if (user.locationContext != null) {
        for (final keyword in user.locationContext!.locationKeywords) {
          themeFrequency[keyword] = (themeFrequency[keyword] ?? 0) + 1;
        }
      }
    }

    // Return themes appearing in >30% of users
    final threshold = (users.length * 0.3).round();
    final commonThemes = themeFrequency.entries
        .where((e) => e.value >= threshold)
        .map((e) => e.key)
        .toList();

    // Sort by frequency
    commonThemes.sort(
        (a, b) => (themeFrequency[b] ?? 0).compareTo(themeFrequency[a] ?? 0));

    return commonThemes.take(20).toList(); // Limit to top 20 themes
  }

  /// Extract keywords from text
  List<String> _extractKeywords(String text) {
    // Simple keyword extraction - can be enhanced with NLP
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 3)
        .where((w) => !_isStopWord(w))
        .toList();

    return words;
  }

  /// Check if word is a stop word
  bool _isStopWord(String word) {
    const stopWords = {
      'the',
      'and',
      'for',
      'with',
      'from',
      'that',
      'this',
      'have',
      'been',
      'were',
      'what',
      'when',
      'where',
      'which',
      'their',
      'would',
      'could',
      'should',
      'about',
      'after',
      'before',
      'during',
      'through',
      'under',
      'over',
      'between',
    };
    return stopWords.contains(word);
  }

  /// Calculate average similarity within vectors
  double _calculateAverageSimilarity(List<List<double>> vectors) {
    if (vectors.length < 2) return 1.0;

    double totalSimilarity = 0.0;
    int comparisons = 0;

    for (int i = 0; i < vectors.length - 1; i++) {
      for (int j = i + 1; j < vectors.length; j++) {
        totalSimilarity += CulturalVectorService.calculateCosineSimilarity(
          vectors[i],
          vectors[j],
        );
        comparisons++;
      }
    }

    return comparisons > 0 ? totalSimilarity / comparisons : 0.0;
  }

  /// Calculate confidence score for pattern
  double _calculateConfidence({
    required int userCount,
    required double avgSimilarity,
    required int themeCount,
  }) {
    // Factors:
    // 1. User count (more users = higher confidence)
    // 2. Average similarity (higher cohesion = higher confidence)
    // 3. Theme count (more common themes = higher confidence)

    final userFactor = math.min(userCount / 100.0, 1.0);
    final similarityFactor = avgSimilarity;
    final themeFactor = math.min(themeCount / 10.0, 1.0);

    // Weighted average
    return (userFactor * 0.4 + similarityFactor * 0.4 + themeFactor * 0.2)
        .clamp(0.0, 1.0);
  }

  /// Extract metadata from users
  Map<String, dynamic> _extractMetadata(List<UserLocationProfile> users) {
    final metadata = <String, dynamic>{};

    // Calculate average profile richness
    final avgRichness =
        users.map((u) => u.profileRichness).reduce((a, b) => a + b) /
            users.length;
    metadata['avg_profile_richness'] = avgRichness;

    // Count migration statuses
    final statusCounts = <String, int>{};
    for (final user in users) {
      final status = user.migrationStatus.name;
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }
    metadata['migration_status_distribution'] = statusCounts;

    // Extract age distribution if available
    final ages = users.where((u) => u.age != null).map((u) => u.age!).toList();
    if (ages.isNotEmpty) {
      ages.sort();
      metadata['age_range'] = {
        'min': ages.first,
        'max': ages.last,
        'median': ages[ages.length ~/ 2],
      };
    }

    return metadata;
  }

  /// Limit patterns per location to prevent over-representation
  List<LocationCulturalPattern> _limitPatternsPerLocation(
    List<LocationCulturalPattern> patterns,
  ) {
    final locationCounts = <String, int>{};
    final limitedPatterns = <LocationCulturalPattern>[];

    for (final pattern in patterns) {
      final count = locationCounts[pattern.location] ?? 0;
      if (count < _maxPatternsPerLocation) {
        limitedPatterns.add(pattern);
        locationCounts[pattern.location] = count + 1;
      }
    }

    return limitedPatterns;
  }

  /// Find similar locations based on cultural patterns
  Future<List<LocationSimilarity>> findSimilarLocations({
    required String targetLocation,
    int maxResults = 10,
  }) async {
    // Get pattern for target location
    final targetPattern = await _repository.getLocationPattern(targetLocation);
    if (targetPattern == null) {
      return [];
    }

    // Get all other patterns
    final allPatterns = await _repository.getAllLocationPatterns();
    final similarities = <LocationSimilarity>[];

    for (final pattern in allPatterns) {
      if (pattern.location == targetLocation) continue;

      // Calculate vector similarity
      final vectorSimilarity = CulturalVectorService.calculateCosineSimilarity(
        targetPattern.centroidVector,
        pattern.centroidVector,
      );

      // Calculate theme overlap
      final themeOverlap = _calculateThemeOverlap(
        targetPattern.commonThemes,
        pattern.commonThemes,
      );

      // Combined similarity score
      final combinedSimilarity = (vectorSimilarity * 0.7 + themeOverlap * 0.3);

      similarities.add(LocationSimilarity(
        location: pattern.location,
        similarity: combinedSimilarity,
        sharedThemes: _findSharedThemes(
          targetPattern.commonThemes,
          pattern.commonThemes,
        ),
        userCount: pattern.userCount,
      ));
    }

    // Sort by similarity
    similarities.sort((a, b) => b.similarity.compareTo(a.similarity));

    return similarities.take(maxResults).toList();
  }

  /// Calculate theme overlap between two sets
  double _calculateThemeOverlap(List<String> themes1, List<String> themes2) {
    if (themes1.isEmpty || themes2.isEmpty) return 0.0;

    final set1 = themes1.toSet();
    final set2 = themes2.toSet();
    final intersection = set1.intersection(set2);
    final union = set1.union(set2);

    return union.isEmpty ? 0.0 : intersection.length / union.length;
  }

  /// Find shared themes between two lists
  List<String> _findSharedThemes(List<String> themes1, List<String> themes2) {
    return themes1.toSet().intersection(themes2.toSet()).toList();
  }

  /// Get location recommendations for a user
  Future<List<LocationRecommendation>> getLocationRecommendations({
    required CulturalIdentityEvolved userProfile,
    required LocationContext currentLocation,
    int maxRecommendations = 5,
  }) async {
    if (!userProfile.hasVectorData) {
      return [];
    }

    // Get all location patterns
    final patterns = await _repository.getAllLocationPatterns();
    final recommendations = <LocationRecommendation>[];

    for (final pattern in patterns) {
      // Skip current location
      if (pattern.location == currentLocation.city) continue;

      // Calculate cultural fit
      final culturalFit = CulturalVectorService.calculateCosineSimilarity(
        userProfile.culturalVector!,
        pattern.centroidVector,
      );

      // Only recommend if good cultural fit
      if (culturalFit >= 0.6) {
        // Find matching themes
        final userThemes = _extractUserThemes(userProfile);
        final matchingThemes =
            _findSharedThemes(userThemes, pattern.commonThemes);

        recommendations.add(LocationRecommendation(
          location: pattern.location,
          culturalFit: culturalFit,
          matchingThemes: matchingThemes,
          userCount: pattern.userCount,
          confidence: pattern.confidence,
          reason: _generateRecommendationReason(
            pattern,
            culturalFit,
            matchingThemes,
          ),
        ));
      }
    }

    // Sort by cultural fit
    recommendations.sort((a, b) => b.culturalFit.compareTo(a.culturalFit));

    return recommendations.take(maxRecommendations).toList();
  }

  /// Extract themes from user profile
  List<String> _extractUserThemes(CulturalIdentityEvolved profile) {
    final themes = <String>[];

    if (profile.heritageDescription != null) {
      themes.addAll(_extractKeywords(profile.heritageDescription!));
    }

    themes.addAll(profile.communityAffiliations);
    themes.addAll(profile.culturalPractices);
    themes.addAll(profile.culturalInterestsText);

    return themes;
  }

  /// Generate recommendation reason
  String _generateRecommendationReason(
    LocationCulturalPattern pattern,
    double culturalFit,
    List<String> matchingThemes,
  ) {
    final fitPercent = (culturalFit * 100).toStringAsFixed(0);
    final themeText = matchingThemes.take(3).join(', ');

    return '$fitPercent% cultural match with ${pattern.location}. '
        '${pattern.userCount} similar users. '
        '${matchingThemes.isNotEmpty ? 'Shared interests: $themeText' : 'Diverse cultural community'}';
  }
}

/// Repository for location pattern persistence
class LocationPatternRepository {
  final Map<String, LocationCulturalPattern> _patterns = {};

  Future<void> saveLocationPattern(LocationCulturalPattern pattern) async {
    _patterns[pattern.location] = pattern;
  }

  Future<LocationCulturalPattern?> getLocationPattern(String location) async {
    return _patterns[location];
  }

  Future<List<LocationCulturalPattern>> getAllLocationPatterns() async {
    return _patterns.values.toList();
  }
}

/// User profile with location context
class UserLocationProfile {
  final String userId;
  final String? heritageDescription;
  final List<String> communityAffiliations;
  final List<String> culturalPractices;
  final List<double>? culturalVector;
  final LocationContext? locationContext;
  final double profileRichness;
  final MigrationStatus migrationStatus;
  final int? age;

  UserLocationProfile({
    required this.userId,
    this.heritageDescription,
    required this.communityAffiliations,
    required this.culturalPractices,
    this.culturalVector,
    this.locationContext,
    required this.profileRichness,
    required this.migrationStatus,
    this.age,
  });
}

/// Discovered location-based cultural pattern
class LocationCulturalPattern {
  final String id;
  final String location;
  final int userCount;
  final List<String> commonThemes;
  final List<double> centroidVector;
  final double averageSimilarity;
  final double confidence;
  final DateTime discoveredAt;
  final Map<String, dynamic> metadata;

  LocationCulturalPattern({
    required this.id,
    required this.location,
    required this.userCount,
    required this.commonThemes,
    required this.centroidVector,
    required this.averageSimilarity,
    required this.confidence,
    required this.discoveredAt,
    required this.metadata,
  });
}

/// Location similarity result
class LocationSimilarity {
  final String location;
  final double similarity;
  final List<String> sharedThemes;
  final int userCount;

  LocationSimilarity({
    required this.location,
    required this.similarity,
    required this.sharedThemes,
    required this.userCount,
  });
}

/// Location recommendation for a user
class LocationRecommendation {
  final String location;
  final double culturalFit;
  final List<String> matchingThemes;
  final int userCount;
  final double confidence;
  final String reason;

  LocationRecommendation({
    required this.location,
    required this.culturalFit,
    required this.matchingThemes,
    required this.userCount,
    required this.confidence,
    required this.reason,
  });
}
