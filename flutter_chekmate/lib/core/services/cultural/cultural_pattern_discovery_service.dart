import 'dart:math' as math;
import 'package:flutter_chekmate/core/services/cultural/cultural_vector_service.dart';
import 'package:flutter_chekmate/features/cultural/models/cultural_identity_evolved.dart';

/// Service for discovering emergent cultural patterns through ML clustering
class CulturalPatternDiscoveryService {
  final CulturalVectorService _vectorService;
  final PatternRepository _repository;

  // Clustering configuration
  static const int _minClusterSize = 5;
  static const double _minSimilarityThreshold = 0.7;
  static const int _maxPatterns = 100;

  CulturalPatternDiscoveryService({
    required CulturalVectorService vectorService,
    required PatternRepository repository,
  })  : _vectorService = vectorService,
        _repository = repository;

  /// Discover patterns from a collection of cultural profiles
  Future<List<CulturalPattern>> discoverPatterns({
    required List<CulturalIdentityEvolved> profiles,
    int? maxPatterns,
    double? minSimilarity,
  }) async {
    if (profiles.length < _minClusterSize) {
      return [];
    }

    // Extract vectors from profiles
    final vectorProfiles = profiles
        .where((p) => p.hasVectorData)
        .map((p) => VectorProfile(
              profileId: p.id,
              vector: p.culturalVector!,
              metadata: _extractMetadata(p),
            ))
        .toList();

    if (vectorProfiles.length < _minClusterSize) {
      return [];
    }

    // Perform clustering
    final clusters = await _performClustering(
      vectorProfiles,
      minSimilarity: minSimilarity ?? _minSimilarityThreshold,
    );

    // Convert clusters to patterns
    final patterns = <CulturalPattern>[];
    for (final cluster in clusters) {
      if (cluster.members.length >= _minClusterSize) {
        final pattern = await _createPatternFromCluster(cluster);
        patterns.add(pattern);
      }
    }

    // Sort by member count (most popular patterns first)
    patterns.sort((a, b) => b.memberCount.compareTo(a.memberCount));

    // Limit to max patterns
    final limit = maxPatterns ?? _maxPatterns;
    if (patterns.length > limit) {
      return patterns.take(limit).toList();
    }

    return patterns;
  }

  /// Perform DBSCAN-like clustering on vectors
  Future<List<Cluster>> _performClustering(List<VectorProfile> profiles,
      {required double minSimilarity}) async {
    final clusters = <Cluster>[];
    final visited = <String>{};
    final assigned = <String>{};

    for (final profile in profiles) {
      if (visited.contains(profile.profileId)) {
        continue;
      }

      visited.add(profile.profileId);

      // Find neighbors
      final neighbors = _findNeighbors(
        profile,
        profiles,
        minSimilarity,
      );

      if (neighbors.length < _minClusterSize) {
        continue; // Noise point
      }

      // Create new cluster
      final cluster = Cluster(
        id: 'cluster_${clusters.length + 1}',
        members: [profile],
      );

      assigned.add(profile.profileId);

      // Expand cluster
      final toProcess = List<VectorProfile>.from(neighbors);
      while (toProcess.isNotEmpty) {
        final neighbor = toProcess.removeAt(0);

        if (!visited.contains(neighbor.profileId)) {
          visited.add(neighbor.profileId);

          final neighborNeighbors = _findNeighbors(
            neighbor,
            profiles,
            minSimilarity,
          );

          if (neighborNeighbors.length >= _minClusterSize) {
            toProcess.addAll(neighborNeighbors);
          }
        }

        if (!assigned.contains(neighbor.profileId)) {
          cluster.members.add(neighbor);
          assigned.add(neighbor.profileId);
        }
      }

      clusters.add(cluster);
    }

    return clusters;
  }

  /// Find neighbors within similarity threshold
  List<VectorProfile> _findNeighbors(
    VectorProfile profile,
    List<VectorProfile> allProfiles,
    double minSimilarity,
  ) {
    final neighbors = <VectorProfile>[];

    for (final other in allProfiles) {
      if (other.profileId == profile.profileId) {
        continue;
      }

      final similarity = CulturalVectorService.calculateCosineSimilarity(
        profile.vector,
        other.vector,
      );

      if (similarity >= minSimilarity) {
        neighbors.add(other);
      }
    }

    return neighbors;
  }

  /// Create a cultural pattern from a cluster
  Future<CulturalPattern> _createPatternFromCluster(Cluster cluster) async {
    // Calculate centroid
    final centroid = _vectorService.calculateCentroid(
      cluster.members.map((m) => m.vector).toList(),
    );

    // Extract common characteristics
    final characteristics = _extractCommonCharacteristics(cluster);

    // Generate pattern name and description
    final patternInfo = _generatePatternInfo(characteristics);

    // Calculate average similarity within cluster
    final avgSimilarity = _calculateAverageSimilarity(cluster);

    return CulturalPattern(
      id: cluster.id,
      name: patternInfo.name,
      description: patternInfo.description,
      centroidVector: centroid,
      memberCount: cluster.members.length,
      memberIds: cluster.members.map((m) => m.profileId).toList(),
      averageSimilarity: avgSimilarity,
      characteristics: characteristics,
      discoveredAt: DateTime.now(),
      confidence: _calculatePatternConfidence(cluster, avgSimilarity),
    );
  }

  /// Extract metadata from profile for pattern analysis
  Map<String, dynamic> _extractMetadata(CulturalIdentityEvolved profile) {
    final metadata = <String, dynamic>{};

    // Extract enum-based metadata
    if (profile.primaryEthnicity != null) {
      metadata['ethnicity'] = profile.primaryEthnicity!.name;
    }

    if (profile.generation != null) {
      metadata['generation'] = profile.generation!.name;
    }

    if (profile.communities.isNotEmpty) {
      metadata['communities'] = profile.communities.map((c) => c.name).toList();
    }

    if (profile.interests.isNotEmpty) {
      metadata['interests'] = profile.interests.map((i) => i.name).toList();
    }

    // Extract free-form metadata
    if (profile.heritageDescription?.isNotEmpty ?? false) {
      metadata['has_heritage'] = true;
      metadata['heritage_length'] = profile.heritageDescription!.length;
    }

    if (profile.communityAffiliations.isNotEmpty) {
      metadata['affiliation_count'] = profile.communityAffiliations.length;
    }

    metadata['profile_richness'] = profile.profileRichness;
    metadata['migration_status'] = profile.migrationStatus.name;

    return metadata;
  }

  /// Extract common characteristics from cluster members
  Map<String, dynamic> _extractCommonCharacteristics(Cluster cluster) {
    final characteristics = <String, dynamic>{};

    // Count occurrences of each metadata field
    final fieldCounts = <String, Map<dynamic, int>>{};

    for (final member in cluster.members) {
      for (final entry in member.metadata.entries) {
        if (entry.value is List) {
          // Handle list values
          for (final item in entry.value as List) {
            fieldCounts.putIfAbsent(entry.key, () => {});
            fieldCounts[entry.key]![item] =
                (fieldCounts[entry.key]![item] ?? 0) + 1;
          }
        } else {
          // Handle single values
          fieldCounts.putIfAbsent(entry.key, () => {});
          fieldCounts[entry.key]![entry.value] =
              (fieldCounts[entry.key]![entry.value] ?? 0) + 1;
        }
      }
    }

    // Find common values (present in >50% of members)
    final threshold = cluster.members.length * 0.5;

    for (final entry in fieldCounts.entries) {
      final commonValues = entry.value.entries
          .where((e) => e.value >= threshold)
          .map((e) => e.key)
          .toList();

      if (commonValues.isNotEmpty) {
        characteristics[entry.key] =
            commonValues.length == 1 ? commonValues.first : commonValues;
      }
    }

    // Add cluster statistics
    characteristics['cluster_size'] = cluster.members.length;
    characteristics['avg_profile_richness'] = cluster.members
            .map((m) => m.metadata['profile_richness'] as double? ?? 0.0)
            .reduce((a, b) => a + b) /
        cluster.members.length;

    return characteristics;
  }

  /// Generate pattern name and description from characteristics
  PatternInfo _generatePatternInfo(Map<String, dynamic> characteristics) {
    final nameParts = <String>[];
    final descParts = <String>[];

    // Build name from key characteristics
    if (characteristics.containsKey('ethnicity')) {
      nameParts.add(_formatName(characteristics['ethnicity'].toString()));
    }

    if (characteristics.containsKey('generation')) {
      nameParts.add(_formatName(characteristics['generation'].toString()));
    }

    if (characteristics.containsKey('communities')) {
      final communities = characteristics['communities'];
      if (communities is List && communities.isNotEmpty) {
        nameParts.add(_formatName(communities.first.toString()));
      }
    }

    // Generate name
    String name = nameParts.isNotEmpty
        ? nameParts.join(' ')
        : 'Emergent Pattern ${DateTime.now().millisecondsSinceEpoch}';

    // Build description
    descParts.add(
        'A cultural pattern with ${characteristics['cluster_size']} members');

    if (characteristics.containsKey('avg_profile_richness')) {
      final richness = characteristics['avg_profile_richness'] as double;
      descParts
          .add('average profile richness of ${richness.toStringAsFixed(2)}');
    }

    if (characteristics.containsKey('interests')) {
      final interests = characteristics['interests'];
      if (interests is List && interests.isNotEmpty) {
        descParts.add('common interests in ${interests.take(3).join(', ')}');
      }
    }

    String description = descParts.join(', ');

    return PatternInfo(name: name, description: description);
  }

  /// Format name from enum value
  String _formatName(String enumValue) {
    return enumValue
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Calculate average similarity within cluster
  double _calculateAverageSimilarity(Cluster cluster) {
    if (cluster.members.length < 2) {
      return 1.0;
    }

    double totalSimilarity = 0.0;
    int comparisons = 0;

    for (int i = 0; i < cluster.members.length - 1; i++) {
      for (int j = i + 1; j < cluster.members.length; j++) {
        totalSimilarity += CulturalVectorService.calculateCosineSimilarity(
          cluster.members[i].vector,
          cluster.members[j].vector,
        );
        comparisons++;
      }
    }

    return comparisons > 0 ? totalSimilarity / comparisons : 0.0;
  }

  /// Calculate confidence score for pattern
  double _calculatePatternConfidence(Cluster cluster, double avgSimilarity) {
    // Factors affecting confidence:
    // 1. Cluster size (larger = more confident)
    // 2. Average similarity (higher = more confident)
    // 3. Profile richness (higher = more confident)

    final sizeFactor = math.min(cluster.members.length / 50.0, 1.0);
    final similarityFactor = avgSimilarity;

    final avgRichness = cluster.members
            .map((m) => m.metadata['profile_richness'] as double? ?? 0.0)
            .reduce((a, b) => a + b) /
        cluster.members.length;
    final richnessFactor = avgRichness;

    // Weighted average
    return (sizeFactor * 0.3 + similarityFactor * 0.5 + richnessFactor * 0.2)
        .clamp(0.0, 1.0);
  }

  /// Assign a profile to discovered patterns
  Future<List<String>> assignToPatterns(CulturalIdentityEvolved profile,
      {double? minSimilarity}) async {
    if (!profile.hasVectorData) {
      return [];
    }

    // Get all active patterns
    final patterns = await _repository.getActivePatterns();

    final assignedPatterns = <String>[];
    final threshold = minSimilarity ?? _minSimilarityThreshold;

    for (final pattern in patterns) {
      final similarity = CulturalVectorService.calculateCosineSimilarity(
        profile.culturalVector!,
        pattern.centroidVector,
      );

      if (similarity >= threshold) {
        assignedPatterns.add(pattern.id);

        // Update pattern with new member
        await _repository.addPatternMember(
          patternId: pattern.id,
          memberId: profile.id,
        );
      }
    }

    return assignedPatterns;
  }

  /// Update patterns with new profiles
  Future<PatternUpdateResult> updatePatterns({
    required List<CulturalIdentityEvolved> newProfiles,
  }) async {
    int assignedCount = 0;
    int newPatternsCount = 0;
    final updatedPatterns = <String>[];

    // Try to assign new profiles to existing patterns
    for (final profile in newProfiles) {
      final assigned = await assignToPatterns(profile);
      if (assigned.isNotEmpty) {
        assignedCount++;
        updatedPatterns.addAll(assigned);
      }
    }

    // Check if we need to discover new patterns
    final unassignedProfiles =
        newProfiles.where((p) => p.discoveredClusters.isEmpty).toList();

    if (unassignedProfiles.length >= _minClusterSize * 2) {
      // Discover new patterns from unassigned profiles
      final newPatterns = await discoverPatterns(profiles: unassignedProfiles);

      // Save new patterns
      for (final pattern in newPatterns) {
        await _repository.savePattern(pattern);
        newPatternsCount++;
      }
    }

    return PatternUpdateResult(
      processedProfiles: newProfiles.length,
      assignedToExisting: assignedCount,
      newPatternsDiscovered: newPatternsCount,
      updatedPatternIds: updatedPatterns.toSet().toList(),
    );
  }

  /// Get pattern recommendations for a profile
  Future<List<PatternRecommendation>> getPatternRecommendations(
      CulturalIdentityEvolved profile,
      {int maxRecommendations = 5}) async {
    if (!profile.hasVectorData) {
      return [];
    }

    final patterns = await _repository.getActivePatterns();
    final recommendations = <PatternRecommendation>[];

    for (final pattern in patterns) {
      final similarity = CulturalVectorService.calculateCosineSimilarity(
        profile.culturalVector!,
        pattern.centroidVector,
      );

      // Only recommend patterns with reasonable similarity
      if (similarity >= 0.5 && similarity < _minSimilarityThreshold) {
        recommendations.add(PatternRecommendation(
          pattern: pattern,
          similarity: similarity,
          reason: _generateRecommendationReason(pattern, similarity),
        ));
      }
    }

    // Sort by similarity
    recommendations.sort((a, b) => b.similarity.compareTo(a.similarity));

    // Return top recommendations
    return recommendations.take(maxRecommendations).toList();
  }

  /// Generate recommendation reason
  String _generateRecommendationReason(
      CulturalPattern pattern, double similarity) {
    final percentage = (similarity * 100).toStringAsFixed(0);
    return 'You have $percentage% similarity with the "${pattern.name}" community of ${pattern.memberCount} members';
  }
}

/// Repository interface for pattern persistence
abstract class PatternRepository {
  Future<List<CulturalPattern>> getActivePatterns();
  Future<void> savePattern(CulturalPattern pattern);
  Future<void> addPatternMember({
    required String patternId,
    required String memberId,
  });
  Future<void> updatePatternStatistics(CulturalPattern pattern);
}

/// Represents a discovered cultural pattern
class CulturalPattern {
  final String id;
  final String name;
  final String description;
  final List<double> centroidVector;
  final int memberCount;
  final List<String> memberIds;
  final double averageSimilarity;
  final Map<String, dynamic> characteristics;
  final DateTime discoveredAt;
  final double confidence;

  CulturalPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.centroidVector,
    required this.memberCount,
    required this.memberIds,
    required this.averageSimilarity,
    required this.characteristics,
    required this.discoveredAt,
    required this.confidence,
  });
}

/// Profile with vector for clustering
class VectorProfile {
  final String profileId;
  final List<double> vector;
  final Map<String, dynamic> metadata;

  VectorProfile({
    required this.profileId,
    required this.vector,
    required this.metadata,
  });
}

/// Cluster of similar profiles
class Cluster {
  final String id;
  final List<VectorProfile> members;

  Cluster({
    required this.id,
    required this.members,
  });
}

/// Pattern name and description
class PatternInfo {
  final String name;
  final String description;

  PatternInfo({
    required this.name,
    required this.description,
  });
}

/// Result of pattern update operation
class PatternUpdateResult {
  final int processedProfiles;
  final int assignedToExisting;
  final int newPatternsDiscovered;
  final List<String> updatedPatternIds;

  PatternUpdateResult({
    required this.processedProfiles,
    required this.assignedToExisting,
    required this.newPatternsDiscovered,
    required this.updatedPatternIds,
  });
}

/// Pattern recommendation for a profile
class PatternRecommendation {
  final CulturalPattern pattern;
  final double similarity;
  final String reason;

  PatternRecommendation({
    required this.pattern,
    required this.similarity,
    required this.reason,
  });
}
