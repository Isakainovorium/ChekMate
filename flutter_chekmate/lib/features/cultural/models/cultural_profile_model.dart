import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cultural_profile_model.g.dart';

/// Free-form cultural profile model (ML-driven)
/// Replaces enum-based CulturalIdentity for new system
@JsonSerializable()
class CulturalProfile extends Equatable {
  final String id;
  final String userId;

  // Free-form user inputs (their own words)
  @JsonKey(name: 'heritage_description')
  final String? heritageDescription;

  @JsonKey(name: 'community_affiliations')
  final List<String> communityAffiliations;

  @JsonKey(name: 'generational_identity')
  final String? generationalIdentity;

  @JsonKey(name: 'cultural_practices')
  final List<String> culturalPractices;

  @JsonKey(name: 'cultural_interests')
  final List<String> culturalInterests; // Now free-form strings!

  @JsonKey(name: 'regional_influence')
  final String? regionalInfluence;

  // System-generated (invisible to user)
  @JsonKey(name: 'cultural_vector')
  final List<double>? culturalVector;

  @JsonKey(name: 'discovered_clusters')
  final List<String> discoveredClusters;

  @JsonKey(name: 'affinity_scores')
  final Map<String, double> affinityScores;

  @JsonKey(name: 'last_vector_update')
  final DateTime? lastVectorUpdate;

  @JsonKey(name: 'profile_richness')
  final double profileRichness;

  // Migration support
  @JsonKey(name: 'migration_status')
  final ProfileMigrationStatus migrationStatus;

  @JsonKey(name: 'legacy_interests')
  final List<String>? legacyInterests; // Old enum values during migration

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const CulturalProfile({
    required this.id,
    required this.userId,
    this.heritageDescription,
    this.communityAffiliations = const [],
    this.generationalIdentity,
    this.culturalPractices = const [],
    this.culturalInterests = const [],
    this.regionalInfluence,
    this.culturalVector,
    this.discoveredClusters = const [],
    this.affinityScores = const {},
    this.lastVectorUpdate,
    this.profileRichness = 0.0,
    this.migrationStatus = ProfileMigrationStatus.freeForm,
    this.legacyInterests,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CulturalProfile.fromJson(Map<String, dynamic> json) =>
      _$CulturalProfileFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalProfileToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        heritageDescription,
        communityAffiliations,
        generationalIdentity,
        culturalPractices,
        culturalInterests,
        regionalInfluence,
        culturalVector,
        discoveredClusters,
        affinityScores,
        lastVectorUpdate,
        profileRichness,
        migrationStatus,
        legacyInterests,
        createdAt,
        updatedAt,
      ];

  /// Check if profile has meaningful content
  bool get hasContent {
    return (heritageDescription?.isNotEmpty ?? false) ||
        communityAffiliations.isNotEmpty ||
        (generationalIdentity?.isNotEmpty ?? false) ||
        culturalPractices.isNotEmpty ||
        culturalInterests.isNotEmpty ||
        (regionalInfluence?.isNotEmpty ?? false);
  }

  /// Check if profile has vector data
  bool get hasVectorData =>
      culturalVector != null && culturalVector!.isNotEmpty;

  /// Check if this is a migrated profile
  bool get isMigrated => migrationStatus == ProfileMigrationStatus.migrated;

  /// Calculate profile richness based on input completeness
  static double calculateRichness(CulturalProfile profile) {
    double richness = 0.0;

    // Each field contributes to richness
    if (profile.heritageDescription?.isNotEmpty ?? false) {
      richness += 0.25 * _calculateTextRichness(profile.heritageDescription!);
    }
    if (profile.communityAffiliations.isNotEmpty) {
      richness += 0.20 * (profile.communityAffiliations.length / 5).clamp(0, 1);
    }
    if (profile.generationalIdentity?.isNotEmpty ?? false) {
      richness += 0.15 * _calculateTextRichness(profile.generationalIdentity!);
    }
    if (profile.culturalPractices.isNotEmpty) {
      richness += 0.20 * (profile.culturalPractices.length / 5).clamp(0, 1);
    }
    if (profile.culturalInterests.isNotEmpty) {
      richness += 0.20 * (profile.culturalInterests.length / 5).clamp(0, 1);
    }

    return richness.clamp(0.0, 1.0);
  }

  static double _calculateTextRichness(String text) {
    final wordCount = text.split(' ').where((w) => w.isNotEmpty).length;
    return (wordCount / 20).clamp(0, 1); // 20+ words = full score
  }

  /// Create copy with updated fields
  CulturalProfile copyWith({
    String? heritageDescription,
    List<String>? communityAffiliations,
    String? generationalIdentity,
    List<String>? culturalPractices,
    List<String>? culturalInterests,
    String? regionalInfluence,
    List<double>? culturalVector,
    List<String>? discoveredClusters,
    Map<String, double>? affinityScores,
    DateTime? lastVectorUpdate,
    double? profileRichness,
    ProfileMigrationStatus? migrationStatus,
    List<String>? legacyInterests,
  }) {
    return CulturalProfile(
      id: id,
      userId: userId,
      heritageDescription: heritageDescription ?? this.heritageDescription,
      communityAffiliations:
          communityAffiliations ?? this.communityAffiliations,
      generationalIdentity: generationalIdentity ?? this.generationalIdentity,
      culturalPractices: culturalPractices ?? this.culturalPractices,
      culturalInterests: culturalInterests ?? this.culturalInterests,
      regionalInfluence: regionalInfluence ?? this.regionalInfluence,
      culturalVector: culturalVector ?? this.culturalVector,
      discoveredClusters: discoveredClusters ?? this.discoveredClusters,
      affinityScores: affinityScores ?? this.affinityScores,
      lastVectorUpdate: lastVectorUpdate ?? this.lastVectorUpdate,
      profileRichness: profileRichness ?? this.profileRichness,
      migrationStatus: migrationStatus ?? this.migrationStatus,
      legacyInterests: legacyInterests ?? this.legacyInterests,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Create from legacy enum-based interests
  factory CulturalProfile.fromLegacyInterests({
    required String userId,
    required List<String> legacyInterests,
    String? location,
  }) {
    // Convert enum interests to free-form text
    final textInterests = _convertEnumInterests(legacyInterests);

    return CulturalProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      culturalInterests: textInterests,
      regionalInfluence: location,
      legacyInterests: legacyInterests,
      migrationStatus: ProfileMigrationStatus.migrated,
      profileRichness: 0.2, // Low richness for migrated profiles
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static List<String> _convertEnumInterests(List<String> enumInterests) {
    final textMap = {
      'hipHop': 'Hip-hop culture and music',
      'jazzBlues': 'Jazz and blues music',
      'reggaeton': 'Reggaeton and Latin urban music',
      'kPop': 'K-pop music and Korean culture',
      'traditionalFolk': 'Traditional folk music and heritage',
      'visualArts': 'Visual arts and creative expression',
      'streetArt': 'Street art and urban culture',
      'filmCinema': 'Film and cinema appreciation',
      'soulFood': 'Soul food and cultural cuisine',
      'caribbeanCuisine': 'Caribbean food and culinary traditions',
      'asianCuisine': 'Asian cuisine and food culture',
      'latinCuisine': 'Latin American food traditions',
      'africanCuisine': 'African cuisine and culinary heritage',
      'mediterraneanCuisine': 'Mediterranean food culture',
      'streetFashion': 'Street fashion and urban style',
      'traditionalClothing': 'Traditional clothing and cultural dress',
      'contemporaryDance': 'Contemporary and modern dance',
      'traditionalDance': 'Traditional and folk dance',
      'poetry': 'Poetry and spoken word',
      'literature': 'Literature and creative writing',
      'gaming': 'Gaming and digital culture',
      'anime': 'Anime and Japanese animation',
      'sports': 'Sports and athletic culture',
      'martialArts': 'Martial arts and combat sports',
      'yoga': 'Yoga and mindfulness practices',
      'meditation': 'Meditation and spiritual practices',
      'religiousPractices': 'Religious and spiritual traditions',
      'socialActivism': 'Social activism and community organizing',
      'environmentalism': 'Environmental consciousness and sustainability',
      'technology': 'Technology and digital innovation',
    };

    return enumInterests
        .map((e) => textMap[e] ?? e)
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Generate a display summary of the profile
  String get displaySummary {
    final parts = <String>[];

    if (heritageDescription != null) {
      parts.add(heritageDescription!);
    }

    if (communityAffiliations.isNotEmpty) {
      parts.add('Part of ${communityAffiliations.take(2).join(" and ")}');
    }

    if (culturalInterests.isNotEmpty) {
      parts.add('Interested in ${culturalInterests.take(2).join(" and ")}');
    }

    return parts.isNotEmpty ? parts.join('. ') : 'Cultural profile in progress';
  }

  /// Get profile completeness percentage
  double get completenessPercentage {
    int filledFields = 0;
    const int totalFields = 6;

    if (heritageDescription?.isNotEmpty ?? false) filledFields++;
    if (communityAffiliations.isNotEmpty) filledFields++;
    if (generationalIdentity?.isNotEmpty ?? false) filledFields++;
    if (culturalPractices.isNotEmpty) filledFields++;
    if (culturalInterests.isNotEmpty) filledFields++;
    if (regionalInfluence?.isNotEmpty ?? false) filledFields++;

    return filledFields / totalFields;
  }
}

/// Profile migration status
enum ProfileMigrationStatus {
  @JsonValue('legacy')
  legacy, // Old enum-based profile

  @JsonValue('migrated')
  migrated, // Converted from enum to text

  @JsonValue('free_form')
  freeForm, // Created with free-form inputs

  @JsonValue('enhanced')
  enhanced, // User updated migrated profile
}
