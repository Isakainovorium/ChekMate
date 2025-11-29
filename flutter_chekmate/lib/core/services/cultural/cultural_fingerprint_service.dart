import 'dart:developer' as developer;

import '../../../features/cultural/models/cultural_identity_model.dart';
import '../../../features/cultural/models/cultural_context_model.dart';

/// Service for creating and managing invisible cultural fingerprints
/// Used for algorithmic content matching based on cultural identities
class CulturalFingerprintService {
  static final CulturalFingerprintService _instance =
      CulturalFingerprintService._internal();
  static CulturalFingerprintService get instance => _instance;

  CulturalFingerprintService._internal();

  /// Generate cultural fingerprint for content based on creator's profile
  Map<String, dynamic> generateContentFingerprint({
    required String contentId,
    CulturalIdentity? creatorIdentity,
    CulturalContext? existingContext,
    bool includeMicroGenerations = true,
    bool includeCommunities = true,
  }) {
    final fingerprint = <String, dynamic>{};

    if (creatorIdentity == null && existingContext == null) {
      return fingerprint; // No cultural data available
    }

    final cultureIdentity = creatorIdentity ??
        existingContext?.culturalIdentity ??
        existingContext?.algorithmicFingerprint;

    if (cultureIdentity == null) {
      return fingerprint; // Still no cultural data
    }

    // Core ethnicity fingerprints
    if (cultureIdentity.primaryEthnicity != null) {
      fingerprint['primary_ethnicity'] =
          cultureIdentity.primaryEthnicity!.displayName;
      fingerprint['ethnicity_family'] =
          _getEthnicityFamily(cultureIdentity.primaryEthnicity!);

      // Add standardized subgroups for algorithmic matching
      final standardSubgroups = cultureIdentity
          .primaryEthnicity!.standardSubgroups
          .map((sub) => sub.displayName)
          .toList();
      fingerprint['ethnicity_subgroups'] = standardSubgroups;
    }

    // Sub-ethnicity matching tags
    if (cultureIdentity.subEthnicities.isNotEmpty) {
      fingerprint['sub_ethnicities'] =
          cultureIdentity.subEthnicities.map((sub) => sub.displayName).toList();

      fingerprint['sub_ethnicity_families'] = cultureIdentity.subEthnicities
          .map((sub) => sub.parentEthnicity.displayName)
          .toSet() // Remove duplicates
          .toList();
    }

    // Community-based matching
    if (includeCommunities && cultureIdentity.communities.isNotEmpty) {
      fingerprint['communities'] = cultureIdentity.communities
          .map((community) => community.displayName)
          .toList();

      // Add community categories for broader matching
      fingerprint['community_categories'] = cultureIdentity.communities
          .map((community) => _getCommunityCategory(community))
          .toSet() // Remove duplicates
          .toList();
    }

    // Micro-generation fingerprints
    if (includeMicroGenerations && cultureIdentity.generation != null) {
      final generation = cultureIdentity.generation!;
      fingerprint['generation'] = generation.displayName;
      fingerprint['generation_type'] = generation.displayName;
      fingerprint['generation_period'] = _getGenerationPeriod(generation);

      // Add adjacent generations for broader matching (e.g., Gen Z Mid matches with Gen Z Early/Late)
      fingerprint['adjacent_generations'] = _getAdjacentGenerations(generation)
          .map((gen) => gen.displayName)
          .toList();
    }

    // Interest-based tags
    if (cultureIdentity.interests.isNotEmpty) {
      fingerprint['interests'] = cultureIdentity.interests
          .map((interest) => interest.displayName)
          .toList();

      // Add interest categories for cultural matching
      fingerprint['interest_categories'] = cultureIdentity.interests
          .map((interest) => _getInterestCategory(interest))
          .toSet() // Remove duplicates
          .toList();
    }

    // Regional influence tags
    if (cultureIdentity.regionalInfluences.isNotEmpty) {
      fingerprint['regional_influences'] = cultureIdentity.regionalInfluences
          .map((region) => region.displayName)
          .toList();

      fingerprint['regional_categories'] = cultureIdentity.regionalInfluences
          .map((region) => _getRegionalCategory(region))
          .toSet() // Remove duplicates
          .toList();
    }

    // Cultural compatibility score (for algorithmic sorting)
    fingerprint['cultural_compatibility_weight'] =
        _calculateCompatibilityWeight(cultureIdentity);

    // Content-specific tags based on cultural context
    if (existingContext?.contextAnnotations.isNotEmpty ?? false) {
      fingerprint['content_themes'] =
          _extractThemesFromContext(existingContext!.contextAnnotations);
    }

    developer.log(
      'Generated cultural fingerprint for content $contentId: '
      '${cultureIdentity.primaryEthnicity?.displayName ?? "Unknown"}',
      name: 'CulturalFingerprint',
    );

    return fingerprint;
  }

  /// Calculate compatibility score for content prioritizing (0.0-1.0)
  double _calculateCompatibilityWeight(CulturalIdentity identity) {
    double weight = 0.0;

    // Higher weight for more detailed cultural profiles
    if (identity.primaryEthnicity != null) weight += 0.3;
    if (identity.subEthnicities.isNotEmpty) weight += 0.25;
    if (identity.communities.isNotEmpty) weight += 0.2;
    if (identity.generation != null) weight += 0.15;
    if (identity.interests.isNotEmpty) weight += 0.1;

    // Extra weight for profile completeness
    weight += identity.profileCompleteness * 0.2;

    return weight.clamp(0.0, 1.0);
  }

  /// Find content that matches a user's cultural preferences
  List<String> findCulturallyMatchingContent({
    required CulturalIdentity userIdentity,
    required Map<String, Map<String, dynamic>> contentFingerprints,
    double minSimilarityScore = 0.3,
    int maxResults = 50,
  }) {
    final matches = <MapEntry<String, double>>[];

    for (final entry in contentFingerprints.entries) {
      final contentId = entry.key;
      final fingerprint = entry.value;

      final similarityScore = calculateFingerprintSimilarity(
        userFingerprint: _generateUserFingerprint(userIdentity),
        contentFingerprint: fingerprint,
      );

      if (similarityScore >= minSimilarityScore) {
        matches.add(MapEntry(contentId, similarityScore));
      }
    }

    // Sort by similarity score (highest first) and return top results
    matches.sort((a, b) => b.value.compareTo(a.value));
    return matches.take(maxResults).map((entry) => entry.key).toList();
  }

  /// Calculate similarity between user preferences and content fingerprint
  double calculateFingerprintSimilarity({
    required Map<String, dynamic> userFingerprint,
    required Map<String, dynamic> contentFingerprint,
  }) {
    double totalScore = 0.0;
    int factorCount = 0;

    // Ethnicity similarity (35% weight)
    final userEthnicity = userFingerprint['primary_ethnicity'] as String?;
    final contentEthnicity = contentFingerprint['primary_ethnicity'] as String?;
    if (userEthnicity != null && contentEthnicity != null) {
      totalScore += (userEthnicity == contentEthnicity ? 1.0 : 0.0) * 0.35;
      factorCount++;
    }

    // Sub-ethnicity overlap (25% weight)
    final userSubEthnicities =
        userFingerprint['sub_ethnicities'] as List<String>?;
    final contentSubEthnicities =
        contentFingerprint['sub_ethnicities'] as List<String>?;
    if (userSubEthnicities != null &&
        userSubEthnicities.isNotEmpty &&
        contentSubEthnicities != null &&
        contentSubEthnicities.isNotEmpty) {
      final overlapCount =
          userSubEthnicities.where(contentSubEthnicities.contains).length;
      final unionCount =
          {...userSubEthnicities, ...contentSubEthnicities}.length;
      if (unionCount > 0) {
        totalScore += (overlapCount / unionCount) * 0.25;
      } else {
        totalScore += 0.25; // Both have sub-ethnicities, even if no overlap
      }
      factorCount++;
    }

    // Generation similarity (15% weight)
    final userGeneration = userFingerprint['generation_type'] as String?;
    final contentGeneration = contentFingerprint['generation_type'] as String?;
    if (userGeneration != null && contentGeneration != null) {
      if (userGeneration == contentGeneration) {
        totalScore += 0.15;
      } else {
        // Check adjacent generations
        final adjacentGens =
            userFingerprint['adjacent_generations'] as List<String>? ?? [];
        if (adjacentGens.contains(contentGeneration)) {
          totalScore += 0.075; // Partial credit for adjacent
        }
      }
      factorCount++;
    }

    // Community overlap (15% weight)
    final userCommunities = userFingerprint['communities'] as List<String>?;
    final contentCommunities =
        contentFingerprint['communities'] as List<String>?;
    if (userCommunities != null &&
        userCommunities.isNotEmpty &&
        contentCommunities != null &&
        contentCommunities.isNotEmpty) {
      final overlapCount =
          userCommunities.where(contentCommunities.contains).length;
      final maxCount = [userCommunities.length, contentCommunities.length]
          .reduce((a, b) => a > b ? a : b);
      if (maxCount > 0) {
        totalScore += (overlapCount / maxCount) * 0.15;
      }
      factorCount++;
    }

    // Interest overlap (10% weight)
    final userInterests = userFingerprint['interests'] as List<String>?;
    final contentInterests = contentFingerprint['interests'] as List<String>?;
    if (userInterests != null &&
        userInterests.isNotEmpty &&
        contentInterests != null &&
        contentInterests.isNotEmpty) {
      final overlapCount =
          userInterests.where(contentInterests.contains).length;
      final maxCount = [userInterests.length, contentInterests.length]
          .reduce((a, b) => a > b ? a : b);
      if (maxCount > 0) {
        totalScore += (overlapCount / maxCount) * 0.10;
      }
      factorCount++;
    }

    return factorCount > 0 ? totalScore : 0.0;
  }

  /// Convert user identity to fingerprint format for comparison
  Map<String, dynamic> _generateUserFingerprint(CulturalIdentity identity) {
    return generateContentFingerprint(
      contentId: 'user_preferences',
      creatorIdentity: identity,
      existingContext: null,
    );
  }

  /// Get ethnicity family for broader matching
  String _getEthnicityFamily(Ethnicity ethnicity) {
    switch (ethnicity) {
      case Ethnicity.africanDiaspora:
      case Ethnicity.indigenous:
        return 'diaspora_and_indigenous';
      case Ethnicity.european:
        return 'european_descent';
      case Ethnicity.hispanicLatino:
        return 'latin_american_culture';
      case Ethnicity.asian:
        return 'asian_cultures';
      case Ethnicity.middleEastern:
        return 'middle_east_and_north_africa';
      case Ethnicity.mixedHeritage:
        return 'mixed_and_blended';
      default:
        return 'global';
    }
  }

  /// Get community category for grouping
  String _getCommunityCategory(Community community) {
    switch (community) {
      case Community.blackExcellence:
      case Community.atlantaBlackProfessionals:
        return 'professional_black_communities';

      case Community.latinoBusiness:
      case Community.laChicano:
      case Community.miamiLatino:
        return 'hispanic_latino_networks';

      case Community.asianProfessionals:
      case Community.seattleAsianTech:
        return 'asian_professional_networks';

      case Community.queerCommunity:
        return 'lgbtq_plus_communities';

      case Community.spiritualCommunity:
      case Community.spiritualGrowth:
        return 'spiritual_and_faith_bases';

      case Community.hipHopCulture:
      case Community.reggaetonAficionados:
      case Community.koreanPopFans:
      case Community.latinMusicEnthusiasts:
      case Community.traditionalMusic:
        return 'music_and_performance';

      case Community.fitnessEnthusiasts:
      case Community.foodCulture:
      case Community.artCreative:
        return 'lifestyle_and_creativity';

      case Community.politicalActivist:
        return 'political_and_social_change';

      case Community.nycJewish:
        return 'faith_and_religious_networks';
    }
  }

  /// Get generation period for historical context
  String _getGenerationPeriod(GenerationType generation) {
    switch (generation) {
      case GenerationType.genZEarly:
      case GenerationType.genZMid:
      case GenerationType.genZLate:
        return 'gen_z_era';

      case GenerationType.millennialEarly:
      case GenerationType.millennialLate:
        return 'millennial_era';

      case GenerationType.genXEarly:
      case GenerationType.genXLate:
        return 'gen_x_era';

      case GenerationType.boomerEarly:
      case GenerationType.boomerLate:
        return 'boomer_era';

      case GenerationType.silentGen:
        return 'silent_generation_era';

      default:
        return 'contemporary';
    }
  }

  /// Get adjacent generations for broader compatibility matching
  List<GenerationType> _getAdjacentGenerations(GenerationType generation) {
    switch (generation) {
      case GenerationType.genZEarly:
        return [GenerationType.genZMid, GenerationType.millennialLate];
      case GenerationType.genZMid:
        return [GenerationType.genZEarly, GenerationType.genZLate];
      case GenerationType.genZLate:
        return [GenerationType.genZMid, GenerationType.millennialEarly];

      case GenerationType.millennialEarly:
        return [
          GenerationType.genZLate,
          GenerationType.millennialLate,
          GenerationType.genXLate
        ];
      case GenerationType.millennialLate:
        return [GenerationType.millennialEarly, GenerationType.genZEarly];

      case GenerationType.genXEarly:
        return [GenerationType.genXLate, GenerationType.boomerLate];
      case GenerationType.genXLate:
        return [GenerationType.genXEarly, GenerationType.millennialEarly];

      case GenerationType.boomerEarly:
        return [GenerationType.boomerLate, GenerationType.silentGen];
      case GenerationType.boomerLate:
        return [GenerationType.boomerEarly, GenerationType.genXEarly];

      case GenerationType.silentGen:
        return [GenerationType.boomerEarly];

      default:
        return [];
    }
  }

  /// Get interest category for thematic grouping
  String _getInterestCategory(CulturalInterest interest) {
    switch (interest) {
      case CulturalInterest.hipHop:
      case CulturalInterest.jazzBlues:
      case CulturalInterest.traditionalFolk:
        return 'music_traditional';

      case CulturalInterest.reggaeton:
      case CulturalInterest.latinMusic:
      case CulturalInterest.electronicMusic:
        return 'music_modern';

      case CulturalInterest.kPop:
        return 'music_asian_pop';

      case CulturalInterest.visualArts:
      case CulturalInterest.filmCinema:
      case CulturalInterest.poetry:
      case CulturalInterest.theaterPerformance:
        return 'arts_and_performance';

      case CulturalInterest.streetArt:
        return 'arts_street_culture';

      case CulturalInterest.literature:
        return 'literature_and_stories';

      case CulturalInterest.soulFood:
      case CulturalInterest.mexicanCuisine:
      case CulturalInterest.asianCuisine:
      case CulturalInterest.mediterraneanCuisine:
      case CulturalInterest.fusionCuisine:
        return 'culinary_arts';

      case CulturalInterest.hipHopDance:
      case CulturalInterest.latinDance:
      case CulturalInterest.ballroomDance:
        return 'performing_arts_dance';

      case CulturalInterest.yogaMindfulness:
      case CulturalInterest.martialArts:
        return 'mind_body_practices';

      case CulturalInterest.basketball:
      case CulturalInterest.footballSoccer:
      case CulturalInterest.tennis:
      case CulturalInterest.swimmingWaterSports:
      case CulturalInterest.outdoorAdventure:
        return 'sports_and_athletics';
      default:
        return 'general_interest';
    }
  }

  /// Get regional category for geographic grouping
  String _getRegionalCategory(RegionalInfluence region) {
    switch (region) {
      case RegionalInfluence.eastCoastUsa:
      case RegionalInfluence.newYorkCity:
        return 'east_coast_urban';

      case RegionalInfluence.westCoastUsa:
      case RegionalInfluence.californiaDiverse:
        return 'west_coast_urban';

      case RegionalInfluence.southernUsa:
      case RegionalInfluence.atlantaCulture:
      case RegionalInfluence.texasCulture:
        return 'southern_american';

      case RegionalInfluence.midwestUsa:
      case RegionalInfluence.chicagoCulture:
        return 'midwestern_american';

      case RegionalInfluence.floridaCulture:
      case RegionalInfluence.latinAmericanInfluence:
      case RegionalInfluence.caribbeanInfluence:
        return 'latin_influenced_southern';

      case RegionalInfluence.detroitMotown:
      case RegionalInfluence.newOrleans:
        return 'southern_cultural_hubs';

      case RegionalInfluence.africanInfluence:
        return 'african_cultural_influences';

      case RegionalInfluence.asianInfluence:
        return 'asian_cultural_influences';

      case RegionalInfluence.europeanInfluence:
        return 'european_cultural_influences';

      case RegionalInfluence.middleEasternInfluence:
        return 'middle_eastern_influences';

      case RegionalInfluence.multiculturalCity:
        return 'multicultural_urban_centers';

      case RegionalInfluence.ruralAmerica:
        return 'rural_american_life';

      case RegionalInfluence.urbanProfessional:
        return 'urban_professional_class';

      case RegionalInfluence.collegeTown:
        return 'academic_and_college_culture';

      case RegionalInfluence.militaryCommunity:
        return 'military_and_veteran_communities';
    }
  }

  /// Extract themes from content context annotations
  List<String> _extractThemesFromContext(List<String> annotations) {
    const themeKeywords = {
      'family': ['family', 'parent', 'sibling', 'relationship'],
      'love_loss': ['heartbreak', 'breakup', 'lost love'],
      'career_challenges': ['career', 'job', 'work', 'promotion'],
      'personal_growth': ['growth', 'change', 'self-improvement'],
      'cultural_identity': ['culture', 'heritage', 'tradition', 'identity'],
      'dating_difficulties': ['ghosting', 'rejection', 'dating apps'],
      'success_stories': ['success', 'achievement', 'milestone'],
    };

    final themes = <String>[];
    for (final annotation in annotations) {
      for (final entry in themeKeywords.entries) {
        if (entry.value
            .any((keyword) => annotation.toLowerCase().contains(keyword))) {
          themes.add(entry.key);
          break; // Only add each theme once per annotation
        }
      }
    }

    return themes.toSet().toList(); // Remove duplicates
  }
}
