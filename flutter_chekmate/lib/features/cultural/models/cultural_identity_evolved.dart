import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'cultural_identity_model.dart';

part 'cultural_identity_evolved.g.dart';

/// Evolved cultural identity supporting both enum-based and free-form text
/// This model enables gradual migration from categorical to ML-driven matching
@JsonSerializable()
class CulturalIdentityEvolved extends Equatable {
  const CulturalIdentityEvolved({
    required this.id,
    required this.userId,
    // Legacy enum fields (kept for backward compatibility)
    this.primaryEthnicity,
    this.subEthnicities = const [],
    this.communities = const [],
    this.generation,
    this.interests = const [],
    this.regionalInfluences = const [],
    // New free-form text fields
    this.heritageDescription,
    this.communityAffiliations = const [],
    this.generationalIdentity,
    this.culturalPractices = const [],
    this.culturalInterestsText = const [],
    // Vector and ML fields
    this.culturalVector,
    this.discoveredClusters = const [],
    this.profileRichness = 0.0,
    // Migration tracking
    this.migrationStatus = MigrationStatus.enumOnly,
    this.vectorGeneratedAt,
    this.lastVectorUpdate,
    // Metadata
    this.profileCompleteness = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  // ===== Legacy Enum Fields (Backward Compatibility) =====

  @JsonKey(name: 'primary_ethnicity')
  final Ethnicity? primaryEthnicity;

  @JsonKey(name: 'sub_ethnicities')
  final List<SubEthnicity> subEthnicities;

  @JsonKey(name: 'communities')
  final List<Community> communities;

  @JsonKey(name: 'generation')
  final GenerationType? generation;

  @JsonKey(name: 'interests')
  final List<CulturalInterest> interests;

  @JsonKey(name: 'regional_influences')
  final List<RegionalInfluence> regionalInfluences;

  // ===== New Free-Form Text Fields =====

  /// Free-form description of cultural heritage and background
  @JsonKey(name: 'heritage_description')
  final String? heritageDescription;

  /// List of community affiliations described in natural language
  @JsonKey(name: 'community_affiliations')
  final List<String> communityAffiliations;

  /// Free-form description of generational identity and experiences
  @JsonKey(name: 'generational_identity')
  final String? generationalIdentity;

  /// List of cultural practices and traditions
  @JsonKey(name: 'cultural_practices')
  final List<String> culturalPractices;

  /// Cultural interests described in natural language
  @JsonKey(name: 'cultural_interests_text')
  final List<String> culturalInterestsText;

  // ===== Vector and ML Fields =====

  /// 384-dimensional vector embedding of cultural identity
  @JsonKey(name: 'cultural_vector')
  final List<double>? culturalVector;

  /// Discovered pattern clusters this profile belongs to
  @JsonKey(name: 'discovered_clusters')
  final List<String> discoveredClusters;

  /// Profile richness score (0.0-1.0) based on depth of information
  @JsonKey(name: 'profile_richness')
  final double profileRichness;

  // ===== Migration Tracking =====

  /// Current migration status of this profile
  @JsonKey(name: 'migration_status')
  final MigrationStatus migrationStatus;

  /// Timestamp when vector was first generated
  @JsonKey(name: 'vector_generated_at')
  final DateTime? vectorGeneratedAt;

  /// Timestamp of last vector update
  @JsonKey(name: 'last_vector_update')
  final DateTime? lastVectorUpdate;

  // ===== Metadata =====

  @JsonKey(name: 'profile_completeness')
  final double profileCompleteness;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  factory CulturalIdentityEvolved.fromJson(Map<String, dynamic> json) =>
      _$CulturalIdentityEvolvedFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalIdentityEvolvedToJson(this);

  /// Create from legacy CulturalIdentity model
  factory CulturalIdentityEvolved.fromLegacy(CulturalIdentity legacy) {
    return CulturalIdentityEvolved(
      id: legacy.id,
      userId: legacy.id, // Assuming id is userId in legacy model
      primaryEthnicity: legacy.primaryEthnicity,
      subEthnicities: legacy.subEthnicities,
      communities: legacy.communities,
      generation: legacy.generation,
      interests: legacy.interests,
      regionalInfluences: legacy.regionalInfluences,
      profileCompleteness: legacy.profileCompleteness,
      createdAt: legacy.createdAt,
      updatedAt: legacy.updatedAt,
      migrationStatus: MigrationStatus.enumOnly,
    );
  }

  /// Check if profile has enum data
  bool get hasEnumData =>
      primaryEthnicity != null ||
      subEthnicities.isNotEmpty ||
      communities.isNotEmpty ||
      generation != null ||
      interests.isNotEmpty ||
      regionalInfluences.isNotEmpty;

  /// Check if profile has free-form data
  bool get hasFreeFormData =>
      (heritageDescription?.isNotEmpty ?? false) ||
      communityAffiliations.isNotEmpty ||
      (generationalIdentity?.isNotEmpty ?? false) ||
      culturalPractices.isNotEmpty ||
      culturalInterestsText.isNotEmpty;

  /// Check if profile has vector data
  bool get hasVectorData =>
      culturalVector != null && culturalVector!.isNotEmpty;

  /// Check if profile is ready for ML matching
  bool get isMLReady => hasVectorData && profileRichness > 0.3;

  /// Check if profile needs vector regeneration
  bool get needsVectorRegeneration {
    if (!hasVectorData) return true;
    if (lastVectorUpdate == null) return true;

    // Regenerate if text was updated after last vector generation
    final lastUpdate = updatedAt ?? DateTime.now();
    return lastUpdate.isAfter(lastVectorUpdate!);
  }

  /// Calculate similarity with another evolved identity
  double calculateSimilarity(CulturalIdentityEvolved other) {
    // If both have vectors, use cosine similarity
    if (hasVectorData && other.hasVectorData) {
      return _calculateVectorSimilarity(other);
    }

    // Fall back to enum-based similarity
    if (hasEnumData && other.hasEnumData) {
      return _calculateEnumSimilarity(other);
    }

    // No valid comparison possible
    return 0.0;
  }

  /// Calculate vector-based similarity
  double _calculateVectorSimilarity(CulturalIdentityEvolved other) {
    if (culturalVector == null || other.culturalVector == null) {
      return 0.0;
    }

    // Cosine similarity calculation
    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (int i = 0; i < culturalVector!.length; i++) {
      dotProduct += culturalVector![i] * other.culturalVector![i];
      norm1 += culturalVector![i] * culturalVector![i];
      norm2 += other.culturalVector![i] * other.culturalVector![i];
    }

    if (norm1 == 0.0 || norm2 == 0.0) {
      return 0.0;
    }

    return dotProduct / (math.sqrt(norm1) * math.sqrt(norm2));
  }

  /// Calculate enum-based similarity (legacy method)
  double _calculateEnumSimilarity(CulturalIdentityEvolved other) {
    double score = 0.0;
    int factors = 0;

    // Ethnicity similarity (30% weight)
    if (primaryEthnicity != null && other.primaryEthnicity != null) {
      if (primaryEthnicity == other.primaryEthnicity) {
        score += 0.3;
      }
      factors++;
    }

    // Sub-ethnicity overlap (25% weight)
    if (subEthnicities.isNotEmpty && other.subEthnicities.isNotEmpty) {
      int overlap = subEthnicities
          .where((se) => other.subEthnicities.contains(se))
          .length;
      int total = subEthnicities.length + other.subEthnicities.length;
      if (total > 0) {
        score += (overlap * 2.0 / total) * 0.25;
      }
      factors++;
    }

    // Community overlap (20% weight)
    if (communities.isNotEmpty && other.communities.isNotEmpty) {
      int overlap =
          communities.where((c) => other.communities.contains(c)).length;
      int total = communities.length + other.communities.length;
      if (total > 0) {
        score += (overlap * 2.0 / total) * 0.20;
      }
      factors++;
    }

    // Generation match (15% weight)
    if (generation != null && other.generation != null) {
      if (generation == other.generation) {
        score += 0.15;
      }
      factors++;
    }

    // Interest overlap (10% weight)
    if (interests.isNotEmpty && other.interests.isNotEmpty) {
      int overlap = interests.where((i) => other.interests.contains(i)).length;
      int total = interests.length + other.interests.length;
      if (total > 0) {
        score += (overlap * 2.0 / total) * 0.10;
      }
      factors++;
    }

    return factors > 0 ? score : 0.0;
  }

  /// Calculate profile completeness considering both enum and free-form data
  double calculateCompleteness() {
    double completeness = 0.0;

    // Enum factors (50% weight if present)
    if (primaryEthnicity != null) {
      completeness += 0.1;
    }
    if (subEthnicities.isNotEmpty) {
      completeness += 0.1;
    }
    if (communities.isNotEmpty) {
      completeness += 0.1;
    }
    if (generation != null) {
      completeness += 0.1;
    }
    if (interests.isNotEmpty) {
      completeness += 0.1;
    }

    // Free-form factors (50% weight if present)
    if (heritageDescription?.isNotEmpty ?? false) {
      completeness += 0.1;
    }
    if (communityAffiliations.isNotEmpty) {
      completeness += 0.1;
    }
    if (generationalIdentity?.isNotEmpty ?? false) {
      completeness += 0.1;
    }
    if (culturalPractices.isNotEmpty) {
      completeness += 0.1;
    }
    if (culturalInterestsText.isNotEmpty) {
      completeness += 0.1;
    }

    // Bonus for having both enum and free-form data
    if (hasEnumData && hasFreeFormData) {
      completeness *= 1.1;
    }

    return completeness.clamp(0.0, 1.0);
  }

  CulturalIdentityEvolved copyWith({
    String? id,
    String? userId,
    Ethnicity? primaryEthnicity,
    List<SubEthnicity>? subEthnicities,
    List<Community>? communities,
    GenerationType? generation,
    List<CulturalInterest>? interests,
    List<RegionalInfluence>? regionalInfluences,
    String? heritageDescription,
    List<String>? communityAffiliations,
    String? generationalIdentity,
    List<String>? culturalPractices,
    List<String>? culturalInterestsText,
    List<double>? culturalVector,
    List<String>? discoveredClusters,
    double? profileRichness,
    MigrationStatus? migrationStatus,
    DateTime? vectorGeneratedAt,
    DateTime? lastVectorUpdate,
    double? profileCompleteness,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CulturalIdentityEvolved(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      primaryEthnicity: primaryEthnicity ?? this.primaryEthnicity,
      subEthnicities: subEthnicities ?? this.subEthnicities,
      communities: communities ?? this.communities,
      generation: generation ?? this.generation,
      interests: interests ?? this.interests,
      regionalInfluences: regionalInfluences ?? this.regionalInfluences,
      heritageDescription: heritageDescription ?? this.heritageDescription,
      communityAffiliations:
          communityAffiliations ?? this.communityAffiliations,
      generationalIdentity: generationalIdentity ?? this.generationalIdentity,
      culturalPractices: culturalPractices ?? this.culturalPractices,
      culturalInterestsText:
          culturalInterestsText ?? this.culturalInterestsText,
      culturalVector: culturalVector ?? this.culturalVector,
      discoveredClusters: discoveredClusters ?? this.discoveredClusters,
      profileRichness: profileRichness ?? this.profileRichness,
      migrationStatus: migrationStatus ?? this.migrationStatus,
      vectorGeneratedAt: vectorGeneratedAt ?? this.vectorGeneratedAt,
      lastVectorUpdate: lastVectorUpdate ?? this.lastVectorUpdate,
      profileCompleteness: profileCompleteness ?? this.profileCompleteness,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        primaryEthnicity,
        subEthnicities,
        communities,
        generation,
        interests,
        regionalInfluences,
        heritageDescription,
        communityAffiliations,
        generationalIdentity,
        culturalPractices,
        culturalInterestsText,
        culturalVector,
        discoveredClusters,
        profileRichness,
        migrationStatus,
        vectorGeneratedAt,
        lastVectorUpdate,
        profileCompleteness,
        createdAt,
        updatedAt,
      ];
}

/// Migration status for tracking profile evolution
enum MigrationStatus {
  @JsonValue('enum_only')
  enumOnly, // Profile only has enum data

  @JsonValue('parallel')
  parallel, // Profile has both enum and free-form data

  @JsonValue('ml_ready')
  mlReady, // Profile has vectors and ready for ML matching

  @JsonValue('ml_only')
  mlOnly, // Profile fully migrated to ML system

  @JsonValue('completed')
  completed, // Migration completed and verified
}

extension MigrationStatusExtension on MigrationStatus {
  String get displayName {
    switch (this) {
      case MigrationStatus.enumOnly:
        return 'Enum Only';
      case MigrationStatus.parallel:
        return 'Parallel Systems';
      case MigrationStatus.mlReady:
        return 'ML Ready';
      case MigrationStatus.mlOnly:
        return 'ML Only';
      case MigrationStatus.completed:
        return 'Migration Completed';
    }
  }

  bool get canUseEnum =>
      this == MigrationStatus.enumOnly || this == MigrationStatus.parallel;

  bool get canUseML =>
      this == MigrationStatus.mlReady ||
      this == MigrationStatus.mlOnly ||
      this == MigrationStatus.completed;
}
