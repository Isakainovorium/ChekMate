import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cultural_identity_model.g.dart';

/// Multi-dimensional cultural identity for sophisticated diversity matching
/// Used for invisible algorithmic connections based on user's self-identified position
@JsonSerializable()
class CulturalIdentity extends Equatable {
  const CulturalIdentity({
    required this.id,
    this.primaryEthnicity,
    this.subEthnicities = const [],
    this.communities = const [],
    this.generation,
    this.interests = const [],
    this.regionalInfluences = const [],
    this.profileCompleteness = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  @JsonKey(name: 'id')
  final String id;

  /// Primary ethnic background (optional - user self-identification only)
  @JsonKey(name: 'primary_ethnicity')
  final Ethnicity? primaryEthnicity;

  /// Specific sub-ethnic identities (minimum 5 per major ethnicity)
  @JsonKey(name: 'sub_ethnicities')
  final List<SubEthnicity> subEthnicities;

  /// Communities beyond ethnicity (professional, cultural, interest-based)
  @JsonKey(name: 'communities')
  final List<Community> communities;

  /// Micro-generation for precise dating/connection styles
  @JsonKey(name: 'generation')
  final GenerationType? generation;

  /// Cultural interests and affiliations
  @JsonKey(name: 'interests')
  final List<CulturalInterest> interests;

  /// Geographic/regional cultural influences
  @JsonKey(name: 'regional_influences')
  final List<RegionalInfluence> regionalInfluences;

  /// How complete the cultural profile is (0.0-1.0)
  @JsonKey(name: 'profile_completeness')
  final double profileCompleteness;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  factory CulturalIdentity.fromJson(Map<String, dynamic> json) =>
      _$CulturalIdentityFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalIdentityToJson(this);

  CulturalIdentity copyWith({
    String? id,
    Ethnicity? primaryEthnicity,
    List<SubEthnicity>? subEthnicities,
    List<Community>? communities,
    GenerationType? generation,
    List<CulturalInterest>? interests,
    List<RegionalInfluence>? regionalInfluences,
    double? profileCompleteness,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CulturalIdentity(
      id: id ?? this.id,
      primaryEthnicity: primaryEthnicity ?? this.primaryEthnicity,
      subEthnicities: subEthnicities ?? this.subEthnicities,
      communities: communities ?? this.communities,
      generation: generation ?? this.generation,
      interests: interests ?? this.interests,
      regionalInfluences: regionalInfluences ?? this.regionalInfluences,
      profileCompleteness: profileCompleteness ?? this.profileCompleteness,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        primaryEthnicity,
        subEthnicities,
        communities,
        generation,
        interests,
        regionalInfluences,
        profileCompleteness,
        createdAt,
        updatedAt,
      ];

  /// Calculate cultural similarity score with another identity (0.0-1.0)
  double calculateSimilarity(CulturalIdentity other) {
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
      } else {
        // Partial credit for adjacent generations
        int thisIndex = generation!.index;
        int otherIndex = other.generation!.index;
        if ((thisIndex - otherIndex).abs() <= 1) {
          score += 0.075;
        }
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

  /// Calculate profile completeness based on provided information
  static double calculateProfileCompleteness(CulturalIdentity identity) {
    double completeness = 0.0;
    const double totalFactors = 5;
    const double weightPerFactor = 1.0 / totalFactors;

    if (identity.primaryEthnicity != null) completeness += weightPerFactor;
    if (identity.subEthnicities.isNotEmpty) completeness += weightPerFactor;
    if (identity.communities.isNotEmpty) completeness += weightPerFactor;
    if (identity.generation != null) completeness += weightPerFactor;
    if (identity.interests.isNotEmpty) completeness += weightPerFactor;

    return completeness;
  }
}

/// Primary ethnic categorization
enum Ethnicity {
  @JsonValue('african_diaspora')
  africanDiaspora,

  @JsonValue('european')
  european,

  @JsonValue('asian')
  asian,

  @JsonValue('hispanic_latino')
  hispanicLatino,

  @JsonValue('middle_eastern')
  middleEastern,

  @JsonValue('indigenous')
  indigenous,

  @JsonValue('mixed_heritage')
  mixedHeritage,

  @JsonValue('prefer_not_to_say')
  preferNotToSay;

  String get displayName {
    switch (this) {
      case Ethnicity.africanDiaspora:
        return 'African Diaspora';
      case Ethnicity.european:
        return 'European';
      case Ethnicity.asian:
        return 'Asian';
      case Ethnicity.hispanicLatino:
        return 'Hispanic/Latino';
      case Ethnicity.middleEastern:
        return 'Middle Eastern';
      case Ethnicity.indigenous:
        return 'Indigenous';
      case Ethnicity.mixedHeritage:
        return 'Mixed Heritage';
      case Ethnicity.preferNotToSay:
        return 'Prefer not to say';
    }
  }

  List<SubEthnicity> get standardSubgroups {
    switch (this) {
      case Ethnicity.africanDiaspora:
        return [
          SubEthnicity.africanAmerican,
          SubEthnicity.blackCaribbean,
          SubEthnicity.blackLatino,
          SubEthnicity.blackEuropean,
          SubEthnicity.continentalAfrican,
        ];
      case Ethnicity.european:
        return [
          SubEthnicity.whiteAmerican,
          SubEthnicity.northernEuropean,
          SubEthnicity.southernEuropean,
          SubEthnicity.whiteLatino,
          SubEthnicity.centralEuropean,
        ];
      case Ethnicity.hispanicLatino:
        return [
          SubEthnicity.mexicanAmerican,
          SubEthnicity.puertoRican,
          SubEthnicity.dominican,
          SubEthnicity.cubanAmerican,
          SubEthnicity.centralAmerican,
        ];
      case Ethnicity.asian:
        return [
          SubEthnicity.japaneseAmerican,
          SubEthnicity.koreanAmerican,
          SubEthnicity.chineseAmerican,
          SubEthnicity.indianAmerican,
          SubEthnicity.southeastAsianAmerican,
        ];
      case Ethnicity.middleEastern:
        return [
          SubEthnicity.arabAmerican,
          SubEthnicity.iranianAmerican,
          SubEthnicity.israeliAmerican,
          SubEthnicity.turkishAmerican,
          SubEthnicity.middleEasternChristian,
        ];
      case Ethnicity.indigenous:
        return [
          SubEthnicity.nativeAmerican,
          SubEthnicity.firstNations,
          SubEthnicity.maori,
          SubEthnicity.aboriginal,
          SubEthnicity.indigenousLatinAmerica,
        ];
      case Ethnicity.mixedHeritage:
        return [
          SubEthnicity.biracial,
          SubEthnicity.multiracial,
          SubEthnicity.blendedHeritage,
          SubEthnicity.transcendent,
          SubEthnicity.hybridCulture,
        ];
      default:
        return [];
    }
  }
}

/// Specific sub-ethnic identities (minimum 5 per major ethnicity)
enum SubEthnicity {
  // African Diaspora
  @JsonValue('african_american')
  africanAmerican,

  @JsonValue('black_caribbean')
  blackCaribbean,

  @JsonValue('black_latino')
  blackLatino,

  @JsonValue('black_european')
  blackEuropean,

  @JsonValue('continental_african')
  continentalAfrican,

  // European
  @JsonValue('white_american')
  whiteAmerican,

  @JsonValue('northern_european')
  northernEuropean,

  @JsonValue('southern_european')
  southernEuropean,

  @JsonValue('white_latino')
  whiteLatino,

  @JsonValue('central_european')
  centralEuropean,

  // Hispanic/Latino
  @JsonValue('mexican_american')
  mexicanAmerican,

  @JsonValue('puerto_rican')
  puertoRican,

  @JsonValue('dominican')
  dominican,

  @JsonValue('cuban_american')
  cubanAmerican,

  @JsonValue('central_american')
  centralAmerican,

  // Asian
  @JsonValue('japanese_american')
  japaneseAmerican,

  @JsonValue('korean_american')
  koreanAmerican,

  @JsonValue('chinese_american')
  chineseAmerican,

  @JsonValue('indian_american')
  indianAmerican,

  @JsonValue('southeast_asian_american')
  southeastAsianAmerican,

  // Middle Eastern
  @JsonValue('arab_american')
  arabAmerican,

  @JsonValue('iranian_american')
  iranianAmerican,

  @JsonValue('israeli_american')
  israeliAmerican,

  @JsonValue('turkish_american')
  turkishAmerican,

  @JsonValue('middle_eastern_christian')
  middleEasternChristian,

  // Indigenous
  @JsonValue('native_american')
  nativeAmerican,

  @JsonValue('first_nations')
  firstNations,

  @JsonValue('maori')
  maori,

  @JsonValue('aboriginal')
  aboriginal,

  @JsonValue('indigenous_latin_america')
  indigenousLatinAmerica,

  // Mixed Heritage
  @JsonValue('biracial')
  biracial,

  @JsonValue('multiracial')
  multiracial,

  @JsonValue('blended_heritage')
  blendedHeritage,

  @JsonValue('transcendent')
  transcendent,

  @JsonValue('hybrid_culture')
  hybridCulture;

  String get displayName {
    switch (this) {
      case SubEthnicity.africanAmerican:
        return 'African American';
      case SubEthnicity.blackCaribbean:
        return 'Black Caribbean';
      case SubEthnicity.blackLatino:
        return 'Black Latino';
      case SubEthnicity.blackEuropean:
        return 'Black European';
      case SubEthnicity.continentalAfrican:
        return 'Continental African';

      case SubEthnicity.whiteAmerican:
        return 'White American';
      case SubEthnicity.northernEuropean:
        return 'Northern European';
      case SubEthnicity.southernEuropean:
        return 'Southern European';
      case SubEthnicity.whiteLatino:
        return 'White Latino';
      case SubEthnicity.centralEuropean:
        return 'Central European';

      case SubEthnicity.mexicanAmerican:
        return 'Mexican American';
      case SubEthnicity.puertoRican:
        return 'Puerto Rican';
      case SubEthnicity.dominican:
        return 'Dominican';
      case SubEthnicity.cubanAmerican:
        return 'Cuban American';
      case SubEthnicity.centralAmerican:
        return 'Central American';

      case SubEthnicity.japaneseAmerican:
        return 'Japanese American';
      case SubEthnicity.koreanAmerican:
        return 'Korean American';
      case SubEthnicity.chineseAmerican:
        return 'Chinese American';
      case SubEthnicity.indianAmerican:
        return 'Indian American';
      case SubEthnicity.southeastAsianAmerican:
        return 'Southeast Asian American';

      case SubEthnicity.arabAmerican:
        return 'Arab American';
      case SubEthnicity.iranianAmerican:
        return 'Iranian American';
      case SubEthnicity.israeliAmerican:
        return 'Israeli American';
      case SubEthnicity.turkishAmerican:
        return 'Turkish American';
      case SubEthnicity.middleEasternChristian:
        return 'Middle Eastern Christian';

      case SubEthnicity.nativeAmerican:
        return 'Native American';
      case SubEthnicity.firstNations:
        return 'First Nations';
      case SubEthnicity.maori:
        return 'Maori';
      case SubEthnicity.aboriginal:
        return 'Aboriginal';
      case SubEthnicity.indigenousLatinAmerica:
        return 'Indigenous Latin America';

      case SubEthnicity.biracial:
        return 'Biracial';
      case SubEthnicity.multiracial:
        return 'Multiracial';
      case SubEthnicity.blendedHeritage:
        return 'Blended Heritage';
      case SubEthnicity.transcendent:
        return 'Transcendent';
      case SubEthnicity.hybridCulture:
        return 'Hybrid Culture';
    }
  }

  Ethnicity get parentEthnicity {
    switch (this) {
      case SubEthnicity.africanAmerican:
      case SubEthnicity.blackCaribbean:
      case SubEthnicity.blackLatino:
      case SubEthnicity.blackEuropean:
      case SubEthnicity.continentalAfrican:
        return Ethnicity.africanDiaspora;

      case SubEthnicity.whiteAmerican:
      case SubEthnicity.northernEuropean:
      case SubEthnicity.southernEuropean:
      case SubEthnicity.whiteLatino:
      case SubEthnicity.centralEuropean:
        return Ethnicity.european;

      case SubEthnicity.mexicanAmerican:
      case SubEthnicity.puertoRican:
      case SubEthnicity.dominican:
      case SubEthnicity.cubanAmerican:
      case SubEthnicity.centralAmerican:
        return Ethnicity.hispanicLatino;

      case SubEthnicity.japaneseAmerican:
      case SubEthnicity.koreanAmerican:
      case SubEthnicity.chineseAmerican:
      case SubEthnicity.indianAmerican:
      case SubEthnicity.southeastAsianAmerican:
        return Ethnicity.asian;

      case SubEthnicity.arabAmerican:
      case SubEthnicity.iranianAmerican:
      case SubEthnicity.israeliAmerican:
      case SubEthnicity.turkishAmerican:
      case SubEthnicity.middleEasternChristian:
        return Ethnicity.middleEastern;

      case SubEthnicity.nativeAmerican:
      case SubEthnicity.firstNations:
      case SubEthnicity.maori:
      case SubEthnicity.aboriginal:
      case SubEthnicity.indigenousLatinAmerica:
        return Ethnicity.indigenous;

      case SubEthnicity.biracial:
      case SubEthnicity.multiracial:
      case SubEthnicity.blendedHeritage:
      case SubEthnicity.transcendent:
      case SubEthnicity.hybridCulture:
        return Ethnicity.mixedHeritage;
    }
  }
}

/// Micro-generations for precise dating/connection styles
enum GenerationType {
  @JsonValue('gen_z_early')
  genZEarly, // 1997-2002: Pre-TikTok generation, digital natives

  @JsonValue('gen_z_mid')
  genZMid, // 2003-2007: Peak social media generation, Instagram/TikTok

  @JsonValue('gen_z_late')
  genZLate, // 2008-2012: Ephemeral apps, BeReal/Snap generation

  @JsonValue('millennial_early')
  millennialEarly, // 1981-1988: Pre-internet dating, AOL instant messaging

  @JsonValue('millennial_late')
  millennialLate, // 1989-1996: Peak MySpace/Facebook, broadband internet

  @JsonValue('gen_x_early')
  genXEarly, // 1965-1974: MTV generation, workplace relationships

  @JsonValue('gen_x_late')
  genXLate, // 1975-1980: AOL/Dial-up generation, internet adoption

  @JsonValue('boomer_early')
  boomerEarly, // 1946-1955: Traditional courtship, cohabitation norms

  @JsonValue('boomer_late')
  boomerLate, // 1956-1964: Vietnam/Watergate influenced, more progressive

  @JsonValue('silent_gen')
  silentGen, // Pre-1946: Formal dating rituals, post-war courtship

  @JsonValue('prefer_not_to_say')
  preferNotToSay;

  String get displayName {
    switch (this) {
      case GenerationType.genZEarly:
        return 'Gen Z Early (1997-2002)';
      case GenerationType.genZMid:
        return 'Gen Z Mid (2003-2007)';
      case GenerationType.genZLate:
        return 'Gen Z Late (2008-2012)';
      case GenerationType.millennialEarly:
        return 'Millennial Early (1981-1988)';
      case GenerationType.millennialLate:
        return 'Millennial Late (1989-1996)';
      case GenerationType.genXEarly:
        return 'Gen X Early (1965-1974)';
      case GenerationType.genXLate:
        return 'Gen X Late (1975-1980)';
      case GenerationType.boomerEarly:
        return 'Boomer Early (1946-1955)';
      case GenerationType.boomerLate:
        return 'Boomer Late (1956-1964)';
      case GenerationType.silentGen:
        return 'Silent Generation (Pre-1946)';
      case GenerationType.preferNotToSay:
        return 'Prefer not to say';
    }
  }

  DateTime? get birthYearRangeStart {
    switch (this) {
      case GenerationType.genZEarly:
        return DateTime(1997);
      case GenerationType.genZMid:
        return DateTime(2003);
      case GenerationType.genZLate:
        return DateTime(2008);
      case GenerationType.millennialEarly:
        return DateTime(1981);
      case GenerationType.millennialLate:
        return DateTime(1989);
      case GenerationType.genXEarly:
        return DateTime(1965);
      case GenerationType.genXLate:
        return DateTime(1975);
      case GenerationType.boomerEarly:
        return DateTime(1946);
      case GenerationType.boomerLate:
        return DateTime(1956);
      case GenerationType.silentGen:
        return null; // Pre-1946
      case GenerationType.preferNotToSay:
        return null;
    }
  }

  DateTime? get birthYearRangeEnd {
    switch (this) {
      case GenerationType.genZEarly:
        return DateTime(2002);
      case GenerationType.genZMid:
        return DateTime(2007);
      case GenerationType.genZLate:
        return DateTime(2012);
      case GenerationType.millennialEarly:
        return DateTime(1988);
      case GenerationType.millennialLate:
        return DateTime(1996);
      case GenerationType.genXEarly:
        return DateTime(1974);
      case GenerationType.genXLate:
        return DateTime(1980);
      case GenerationType.boomerEarly:
        return DateTime(1955);
      case GenerationType.boomerLate:
        return DateTime(1964);
      case GenerationType.silentGen:
        return DateTime(1945);
      case GenerationType.preferNotToSay:
        return null;
    }
  }
}

/// Communities beyond ethnicity for cultural connection
enum Community {
  // Professional/Identity Communities
  @JsonValue('black_excellence')
  blackExcellence,

  @JsonValue('latino_business')
  latinoBusiness,

  @JsonValue('asian_professionals')
  asianProfessionals,

  @JsonValue('queer_community')
  queerCommunity,

  @JsonValue('spiritual_community')
  spiritualCommunity,

  // Geographic/Urban Communities
  @JsonValue('atlanta_black_professionals')
  atlantaBlackProfessionals,

  @JsonValue('la_chicano')
  laChicano,

  @JsonValue('nyc_jewish')
  nycJewish,

  @JsonValue('seattle_asian_tech')
  seattleAsianTech,

  @JsonValue('miami_latino')
  miamiLatino,

  // Cultural/Interest Communities
  @JsonValue('hip_hop_culture')
  hipHopCulture,

  @JsonValue('reggaeton_aficionados')
  reggaetonAficionados,

  @JsonValue('korean_pop_fans')
  koreanPopFans,

  @JsonValue('latin_music_enthusiasts')
  latinMusicEnthusiasts,

  @JsonValue('traditional_music')
  traditionalMusic,

  // Lifestyle Communities
  @JsonValue('fitness_enthusiasts')
  fitnessEnthusiasts,

  @JsonValue('food_culture')
  foodCulture,

  @JsonValue('art_creative')
  artCreative,

  @JsonValue('political_activist')
  politicalActivist,

  @JsonValue('spiritual_growth')
  spiritualGrowth;

  String get displayName {
    switch (this) {
      case Community.blackExcellence:
        return 'Black Excellence';
      case Community.latinoBusiness:
        return 'Latino Business';
      case Community.asianProfessionals:
        return 'Asian Professionals';
      case Community.queerCommunity:
        return 'Queer Community';
      case Community.spiritualCommunity:
        return 'Spiritual Community';

      case Community.atlantaBlackProfessionals:
        return 'Atlanta Black Professionals';
      case Community.laChicano:
        return 'LA Chicano/Latina/o';
      case Community.nycJewish:
        return 'NYC Jewish Community';
      case Community.seattleAsianTech:
        return 'Seattle Asian Tech';
      case Community.miamiLatino:
        return 'Miami Latino Culture';

      case Community.hipHopCulture:
        return 'Hip-Hop Culture';
      case Community.reggaetonAficionados:
        return 'Reggaeton Aficionados';
      case Community.koreanPopFans:
        return 'K-Pop Fans';
      case Community.latinMusicEnthusiasts:
        return 'Latin Music Enthusiasts';
      case Community.traditionalMusic:
        return 'Traditional/Folk Music';

      case Community.fitnessEnthusiasts:
        return 'Fitness Enthusiasts';
      case Community.foodCulture:
        return 'Food Culture';
      case Community.artCreative:
        return 'Art & Creative';
      case Community.politicalActivist:
        return 'Political Activist';
      case Community.spiritualGrowth:
        return 'Spiritual Growth';
    }
  }
}

/// Cultural interests and affiliations
enum CulturalInterest {
  // Music Genres
  @JsonValue('hip_hop')
  hipHop,

  @JsonValue('reggaeton')
  reggaeton,

  @JsonValue('k_pop')
  kPop,

  @JsonValue('latin_music')
  latinMusic,

  @JsonValue('electronic_music')
  electronicMusic,

  @JsonValue('jazz_blues')
  jazzBlues,

  @JsonValue('classical_music')
  classicalMusic,

  @JsonValue('traditional_folk')
  traditionalFolk,

  // Arts & Culture
  @JsonValue('visual_arts')
  visualArts,

  @JsonValue('street_art')
  streetArt,

  @JsonValue('film_cinema')
  filmCinema,

  @JsonValue('literature')
  literature,

  @JsonValue('poetry')
  poetry,

  @JsonValue('theater_performance')
  theaterPerformance,

  // Food & Cuisine
  @JsonValue('soul_food')
  soulFood,

  @JsonValue('mexican_cuisine')
  mexicanCuisine,

  @JsonValue('asian_cuisine')
  asianCuisine,

  @JsonValue('mediterranean_cuisine')
  mediterraneanCuisine,

  @JsonValue('fusion_cuisine')
  fusionCuisine,

  // Dance & Movement
  @JsonValue('hip_hop_dance')
  hipHopDance,

  @JsonValue('latin_dance')
  latinDance,

  @JsonValue('ballroom_dance')
  ballroomDance,

  @JsonValue('yoga_mindfulness')
  yogaMindfulness,

  @JsonValue('martial_arts')
  martialArts,

  // Sports & Recreation
  @JsonValue('basketball')
  basketball,

  @JsonValue('football_soccer')
  footballSoccer,

  @JsonValue('tennis')
  tennis,

  @JsonValue('swimming_water_sports')
  swimmingWaterSports,

  @JsonValue('outdoor_adventure')
  outdoorAdventure;

  String get displayName {
    switch (this) {
      case CulturalInterest.hipHop:
        return 'Hip-Hop';
      case CulturalInterest.reggaeton:
        return 'Reggaeton';
      case CulturalInterest.kPop:
        return 'K-Pop';
      case CulturalInterest.latinMusic:
        return 'Latin Music';
      case CulturalInterest.electronicMusic:
        return 'Electronic Music';
      case CulturalInterest.jazzBlues:
        return 'Jazz & Blues';
      case CulturalInterest.classicalMusic:
        return 'Classical Music';
      case CulturalInterest.traditionalFolk:
        return 'Traditional/Folk Music';

      case CulturalInterest.visualArts:
        return 'Visual Arts';
      case CulturalInterest.streetArt:
        return 'Street Art';
      case CulturalInterest.filmCinema:
        return 'Film & Cinema';
      case CulturalInterest.literature:
        return 'Literature';
      case CulturalInterest.poetry:
        return 'Poetry';
      case CulturalInterest.theaterPerformance:
        return 'Theater & Performance';

      case CulturalInterest.soulFood:
        return 'Soul Food';
      case CulturalInterest.mexicanCuisine:
        return 'Mexican Cuisine';
      case CulturalInterest.asianCuisine:
        return 'Asian Cuisine';
      case CulturalInterest.mediterraneanCuisine:
        return 'Mediterranean Cuisine';
      case CulturalInterest.fusionCuisine:
        return 'Fusion Cuisine';

      case CulturalInterest.hipHopDance:
        return 'Hip-Hop Dance';
      case CulturalInterest.latinDance:
        return 'Latin Dance';
      case CulturalInterest.ballroomDance:
        return 'Ballroom Dance';
      case CulturalInterest.yogaMindfulness:
        return 'Yoga & Mindfulness';
      case CulturalInterest.martialArts:
        return 'Martial Arts';

      case CulturalInterest.basketball:
        return 'Basketball';
      case CulturalInterest.footballSoccer:
        return 'Football/Soccer';
      case CulturalInterest.tennis:
        return 'Tennis';
      case CulturalInterest.swimmingWaterSports:
        return 'Swimming & Water Sports';
      case CulturalInterest.outdoorAdventure:
        return 'Outdoor Adventure';
    }
  }
}

/// Geographic/regional cultural influences
enum RegionalInfluence {
  @JsonValue('east_coast_usa')
  eastCoastUsa,

  @JsonValue('west_coast_usa')
  westCoastUsa,

  @JsonValue('southern_usa')
  southernUsa,

  @JsonValue('midwest_usa')
  midwestUsa,

  @JsonValue('texas_culture')
  texasCulture,

  @JsonValue('florida_culture')
  floridaCulture,

  @JsonValue('california_diverse')
  californiaDiverse,

  @JsonValue('new_york_city')
  newYorkCity,

  @JsonValue('chicago_culture')
  chicagoCulture,

  @JsonValue('atlanta_culture')
  atlantaCulture,

  @JsonValue('detroit_motown')
  detroitMotown,

  @JsonValue('new_orleans')
  newOrleans,

  @JsonValue('caribbean_influence')
  caribbeanInfluence,

  @JsonValue('latin_american_influence')
  latinAmericanInfluence,

  @JsonValue('european_influence')
  europeanInfluence,

  @JsonValue('african_influence')
  africanInfluence,

  @JsonValue('asian_influence')
  asianInfluence,

  @JsonValue('middle_eastern_influence')
  middleEasternInfluence,

  @JsonValue('multicultural_city')
  multiculturalCity,

  @JsonValue('rural_america')
  ruralAmerica,

  @JsonValue('urban_professional')
  urbanProfessional,

  @JsonValue('college_town')
  collegeTown,

  @JsonValue('military_community')
  militaryCommunity;

  String get displayName {
    switch (this) {
      case RegionalInfluence.eastCoastUsa:
        return 'East Coast USA';
      case RegionalInfluence.westCoastUsa:
        return 'West Coast USA';
      case RegionalInfluence.southernUsa:
        return 'Southern USA';
      case RegionalInfluence.midwestUsa:
        return 'Midwest USA';
      case RegionalInfluence.texasCulture:
        return 'Texas Culture';
      case RegionalInfluence.floridaCulture:
        return 'Florida Culture';
      case RegionalInfluence.californiaDiverse:
        return 'California (Diverse)';
      case RegionalInfluence.newYorkCity:
        return 'New York City';
      case RegionalInfluence.chicagoCulture:
        return 'Chicago Culture';
      case RegionalInfluence.atlantaCulture:
        return 'Atlanta Culture';
      case RegionalInfluence.detroitMotown:
        return 'Detroit (Motown)';
      case RegionalInfluence.newOrleans:
        return 'New Orleans';
      case RegionalInfluence.caribbeanInfluence:
        return 'Caribbean Influence';
      case RegionalInfluence.latinAmericanInfluence:
        return 'Latin American Influence';
      case RegionalInfluence.europeanInfluence:
        return 'European Influence';
      case RegionalInfluence.africanInfluence:
        return 'African Influence';
      case RegionalInfluence.asianInfluence:
        return 'Asian Influence';
      case RegionalInfluence.middleEasternInfluence:
        return 'Middle Eastern Influence';
      case RegionalInfluence.multiculturalCity:
        return 'Multicultural City';
      case RegionalInfluence.ruralAmerica:
        return 'Rural America';
      case RegionalInfluence.urbanProfessional:
        return 'Urban Professional';
      case RegionalInfluence.collegeTown:
        return 'College Town';
      case RegionalInfluence.militaryCommunity:
        return 'Military Community';
    }
  }
}
