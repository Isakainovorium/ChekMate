import 'package:flutter_chekmate/features/cultural/models/cultural_identity_model.dart';
import 'package:flutter_chekmate/core/services/cultural/cultural_vector_service.dart';

/// Adapter for converting between enum-based and free-form cultural profiles
/// Provides backward compatibility during migration period
class CulturalProfileAdapter {
  final CulturalVectorService _vectorService;

  CulturalProfileAdapter({
    required CulturalVectorService vectorService,
  }) : _vectorService = vectorService;

  /// Convert enum-based ethnicity to descriptive text
  static String convertEthnicityToText(Ethnicity? ethnicity) {
    if (ethnicity == null) return '';

    switch (ethnicity) {
      case Ethnicity.africanDiaspora:
        return "African diaspora heritage with deep cultural roots and community connections";
      case Ethnicity.hispanicLatino:
        return "Hispanic/Latino background celebrating vibrant traditions and family values";
      case Ethnicity.european:
        return "European heritage with diverse cultural influences and traditions";
      case Ethnicity.asian:
        return "Asian cultural background with rich traditions and community values";
      case Ethnicity.middleEastern:
        return "Middle Eastern heritage blending ancient traditions with modern identity";
      case Ethnicity.indigenous:
        return "Indigenous heritage preserving ancestral wisdom and cultural practices";
      case Ethnicity.mixedHeritage:
        return "Mixed heritage celebrating multiple cultural identities and perspectives";
      case Ethnicity.preferNotToSay:
        return "";
    }
  }

  /// Convert sub-ethnicity enum to descriptive text
  static String convertSubEthnicityToText(SubEthnicity subEthnicity) {
    switch (subEthnicity) {
      // African Diaspora
      case SubEthnicity.africanAmerican:
        return "African American with deep roots in Black culture and history";
      case SubEthnicity.blackCaribbean:
        return "Black Caribbean heritage blending African and island cultures";
      case SubEthnicity.blackLatino:
        return "Black Latino identity bridging African and Latin American cultures";
      case SubEthnicity.blackEuropean:
        return "Black European background with multicultural perspectives";
      case SubEthnicity.continentalAfrican:
        return "Continental African heritage maintaining strong cultural connections";

      // European
      case SubEthnicity.whiteAmerican:
        return "White American with diverse European ancestral roots";
      case SubEthnicity.northernEuropean:
        return "Northern European heritage from Scandinavian and Baltic regions";
      case SubEthnicity.southernEuropean:
        return "Southern European background from Mediterranean cultures";
      case SubEthnicity.whiteLatino:
        return "White Latino identity with European and Latin American heritage";
      case SubEthnicity.centralEuropean:
        return "Central European heritage from the heart of Europe";

      // Hispanic/Latino
      case SubEthnicity.mexicanAmerican:
        return "Mexican American celebrating both Mexican and American cultures";
      case SubEthnicity.puertoRican:
        return "Puerto Rican heritage with island pride and mainland connections";
      case SubEthnicity.dominican:
        return "Dominican background with Caribbean and Latin influences";
      case SubEthnicity.cubanAmerican:
        return "Cuban American preserving Cuban traditions in American context";
      case SubEthnicity.centralAmerican:
        return "Central American heritage from diverse nations and cultures";

      // Asian
      case SubEthnicity.japaneseAmerican:
        return "Japanese American balancing traditional values with modern identity";
      case SubEthnicity.koreanAmerican:
        return "Korean American bridging Korean heritage and American experience";
      case SubEthnicity.chineseAmerican:
        return "Chinese American with rich cultural traditions and family values";
      case SubEthnicity.indianAmerican:
        return "Indian American celebrating South Asian heritage and diversity";
      case SubEthnicity.southeastAsianAmerican:
        return "Southeast Asian American from diverse regional backgrounds";

      // Middle Eastern
      case SubEthnicity.arabAmerican:
        return "Arab American with Middle Eastern and North African roots";
      case SubEthnicity.iranianAmerican:
        return "Iranian American preserving Persian culture and traditions";
      case SubEthnicity.israeliAmerican:
        return "Israeli American with connections to Israel and Jewish heritage";
      case SubEthnicity.turkishAmerican:
        return "Turkish American bridging European and Asian influences";
      case SubEthnicity.middleEasternChristian:
        return "Middle Eastern Christian with ancient faith traditions";

      // Indigenous
      case SubEthnicity.nativeAmerican:
        return "Native American preserving indigenous traditions and sovereignty";
      case SubEthnicity.firstNations:
        return "First Nations maintaining cultural practices and connections";
      case SubEthnicity.maori:
        return "Maori heritage from Aotearoa New Zealand";
      case SubEthnicity.aboriginal:
        return "Aboriginal Australian with ancient cultural connections";
      case SubEthnicity.indigenousLatinAmerica:
        return "Indigenous Latin American preserving pre-Columbian heritage";

      // Mixed Heritage
      case SubEthnicity.biracial:
        return "Biracial identity navigating and celebrating two cultures";
      case SubEthnicity.multiracial:
        return "Multiracial background embracing multiple cultural identities";
      case SubEthnicity.blendedHeritage:
        return "Blended heritage creating unique cultural fusion";
      case SubEthnicity.transcendent:
        return "Transcendent identity beyond traditional categories";
      case SubEthnicity.hybridCulture:
        return "Hybrid culture creating new traditions from multiple sources";
    }
  }

  /// Convert generation enum to descriptive text
  static String convertGenerationToText(GenerationType? generation) {
    if (generation == null) return '';

    switch (generation) {
      case GenerationType.genZEarly:
        return "Early Gen Z (1997-2002), digital native pre-TikTok generation";
      case GenerationType.genZMid:
        return "Mid Gen Z (2003-2007), peak social media generation with Instagram and TikTok";
      case GenerationType.genZLate:
        return "Late Gen Z (2008-2012), ephemeral apps generation with BeReal and Snapchat";
      case GenerationType.millennialEarly:
        return "Early Millennial (1981-1988), pre-internet dating with AOL instant messaging";
      case GenerationType.millennialLate:
        return "Late Millennial (1989-1996), MySpace and Facebook generation";
      case GenerationType.genXEarly:
        return "Early Gen X (1965-1974), MTV generation with workplace relationships";
      case GenerationType.genXLate:
        return "Late Gen X (1975-1980), dial-up internet adoption generation";
      case GenerationType.boomerEarly:
        return "Early Boomer (1946-1955), traditional courtship and cohabitation norms";
      case GenerationType.boomerLate:
        return "Late Boomer (1956-1964), Vietnam and Watergate influenced generation";
      case GenerationType.silentGen:
        return "Silent Generation (Pre-1946), formal dating rituals and post-war courtship";
      case GenerationType.preferNotToSay:
        return "";
    }
  }

  /// Convert community enum to descriptive text
  static String convertCommunityToText(Community community) {
    switch (community) {
      // Professional/Identity Communities
      case Community.blackExcellence:
        return "Black Excellence community celebrating achievement and empowerment";
      case Community.latinoBusiness:
        return "Latino Business network fostering entrepreneurship and success";
      case Community.asianProfessionals:
        return "Asian Professionals advancing careers and community";
      case Community.queerCommunity:
        return "LGBTQ+ community creating inclusive spaces and connections";
      case Community.spiritualCommunity:
        return "Spiritual community exploring faith and mindfulness";

      // Geographic/Urban Communities
      case Community.atlantaBlackProfessionals:
        return "Atlanta Black Professionals in the cultural hub of the South";
      case Community.laChicano:
        return "LA Chicano/Latina/o culture in Southern California";
      case Community.nycJewish:
        return "NYC Jewish community with rich cultural traditions";
      case Community.seattleAsianTech:
        return "Seattle Asian Tech professionals in the Pacific Northwest";
      case Community.miamiLatino:
        return "Miami Latino culture with Caribbean and Latin influences";

      // Cultural/Interest Communities
      case Community.hipHopCulture:
        return "Hip-Hop culture enthusiast celebrating music and lifestyle";
      case Community.reggaetonAficionados:
        return "Reggaeton aficionados passionate about Latin urban music";
      case Community.koreanPopFans:
        return "K-Pop fans celebrating Korean pop culture and music";
      case Community.latinMusicEnthusiasts:
        return "Latin music enthusiasts across salsa, bachata, and more";
      case Community.traditionalMusic:
        return "Traditional and folk music preserving cultural heritage";

      // Lifestyle Communities
      case Community.fitnessEnthusiasts:
        return "Fitness enthusiasts committed to health and wellness";
      case Community.foodCulture:
        return "Food culture explorers celebrating culinary diversity";
      case Community.artCreative:
        return "Art and creative community expressing through various mediums";
      case Community.politicalActivist:
        return "Political activists working for social change";
      case Community.spiritualGrowth:
        return "Spiritual growth seekers on personal development journeys";
    }
  }

  /// Convert cultural interest enum to descriptive text
  static String convertInterestToText(CulturalInterest interest) {
    switch (interest) {
      // Music
      case CulturalInterest.hipHop:
        return "Hip-hop music and culture";
      case CulturalInterest.reggaeton:
        return "Reggaeton and Latin urban beats";
      case CulturalInterest.kPop:
        return "K-Pop and Korean music culture";
      case CulturalInterest.latinMusic:
        return "Latin music across genres";
      case CulturalInterest.electronicMusic:
        return "Electronic and dance music";
      case CulturalInterest.jazzBlues:
        return "Jazz and blues traditions";
      case CulturalInterest.classicalMusic:
        return "Classical music appreciation";
      case CulturalInterest.traditionalFolk:
        return "Traditional and folk music";

      // Arts
      case CulturalInterest.visualArts:
        return "Visual arts and galleries";
      case CulturalInterest.streetArt:
        return "Street art and urban expression";
      case CulturalInterest.filmCinema:
        return "Film and cinema appreciation";
      case CulturalInterest.literature:
        return "Literature and reading";
      case CulturalInterest.poetry:
        return "Poetry and spoken word";
      case CulturalInterest.theaterPerformance:
        return "Theater and live performance";

      // Food
      case CulturalInterest.soulFood:
        return "Soul food and comfort cuisine";
      case CulturalInterest.mexicanCuisine:
        return "Mexican cuisine and flavors";
      case CulturalInterest.asianCuisine:
        return "Asian culinary traditions";
      case CulturalInterest.mediterraneanCuisine:
        return "Mediterranean food culture";
      case CulturalInterest.fusionCuisine:
        return "Fusion cuisine innovation";

      // Dance & Movement
      case CulturalInterest.hipHopDance:
        return "Hip-hop dance and breaking";
      case CulturalInterest.latinDance:
        return "Latin dance styles";
      case CulturalInterest.ballroomDance:
        return "Ballroom and partner dancing";
      case CulturalInterest.yogaMindfulness:
        return "Yoga and mindfulness practice";
      case CulturalInterest.martialArts:
        return "Martial arts training";

      // Sports
      case CulturalInterest.basketball:
        return "Basketball culture and games";
      case CulturalInterest.footballSoccer:
        return "Football/soccer passion";
      case CulturalInterest.tennis:
        return "Tennis and racquet sports";
      case CulturalInterest.swimmingWaterSports:
        return "Swimming and water activities";
      case CulturalInterest.outdoorAdventure:
        return "Outdoor adventures and nature";
    }
  }

  /// Convert regional influence enum to descriptive text
  static String convertRegionalInfluenceToText(RegionalInfluence influence) {
    switch (influence) {
      case RegionalInfluence.eastCoastUsa:
        return "East Coast USA with urban sophistication and historical roots";
      case RegionalInfluence.westCoastUsa:
        return "West Coast USA with innovation and laid-back lifestyle";
      case RegionalInfluence.southernUsa:
        return "Southern USA with hospitality and cultural traditions";
      case RegionalInfluence.midwestUsa:
        return "Midwest USA with heartland values and community";
      case RegionalInfluence.texasCulture:
        return "Texas culture blending Southern and Western influences";
      case RegionalInfluence.floridaCulture:
        return "Florida culture with Caribbean and Latin influences";
      case RegionalInfluence.californiaDiverse:
        return "California's diverse multicultural landscape";
      case RegionalInfluence.newYorkCity:
        return "New York City's global melting pot";
      case RegionalInfluence.chicagoCulture:
        return "Chicago's urban culture and Midwest charm";
      case RegionalInfluence.atlantaCulture:
        return "Atlanta's Black cultural capital influence";
      case RegionalInfluence.detroitMotown:
        return "Detroit's Motown legacy and resilience";
      case RegionalInfluence.newOrleans:
        return "New Orleans' unique cultural gumbo";
      case RegionalInfluence.caribbeanInfluence:
        return "Caribbean cultural influences and island vibes";
      case RegionalInfluence.latinAmericanInfluence:
        return "Latin American cultural connections";
      case RegionalInfluence.europeanInfluence:
        return "European cultural heritage and traditions";
      case RegionalInfluence.africanInfluence:
        return "African cultural roots and connections";
      case RegionalInfluence.asianInfluence:
        return "Asian cultural influences and values";
      case RegionalInfluence.middleEasternInfluence:
        return "Middle Eastern cultural traditions";
      case RegionalInfluence.multiculturalCity:
        return "Multicultural urban environment";
      case RegionalInfluence.ruralAmerica:
        return "Rural American values and lifestyle";
      case RegionalInfluence.urbanProfessional:
        return "Urban professional culture and networking";
      case RegionalInfluence.collegeTown:
        return "College town academic and social environment";
      case RegionalInfluence.militaryCommunity:
        return "Military community service and values";
    }
  }

  /// Build comprehensive text description from enum-based identity
  static String buildTextFromEnums(CulturalIdentity identity) {
    final StringBuffer description = StringBuffer();

    // Add primary ethnicity
    if (identity.primaryEthnicity != null) {
      description.writeln(convertEthnicityToText(identity.primaryEthnicity));
    }

    // Add sub-ethnicities
    if (identity.subEthnicities.isNotEmpty) {
      description.writeln('\nCultural background includes:');
      for (final subEthnicity in identity.subEthnicities) {
        description.writeln('- ${convertSubEthnicityToText(subEthnicity)}');
      }
    }

    // Add generation
    if (identity.generation != null) {
      description.writeln('\n${convertGenerationToText(identity.generation)}');
    }

    // Add communities
    if (identity.communities.isNotEmpty) {
      description.writeln('\nActive in communities:');
      for (final community in identity.communities) {
        description.writeln('- ${convertCommunityToText(community)}');
      }
    }

    // Add interests
    if (identity.interests.isNotEmpty) {
      description.writeln('\nCultural interests include:');
      for (final interest in identity.interests) {
        description.writeln('- ${convertInterestToText(interest)}');
      }
    }

    // Add regional influences
    if (identity.regionalInfluences.isNotEmpty) {
      description.writeln('\nRegional influences:');
      for (final influence in identity.regionalInfluences) {
        description.writeln('- ${convertRegionalInfluenceToText(influence)}');
      }
    }

    return description.toString();
  }

  /// Generate initial vectors from converted enum data
  Future<List<double>> generateVectorFromEnum(
    CulturalIdentity oldIdentity,
  ) async {
    final textDescription = buildTextFromEnums(oldIdentity);

    if (textDescription.isEmpty) {
      // Return zero vector if no data
      return List.filled(384, 0.0);
    }

    return await _vectorService.generateEmbedding(textDescription);
  }

  /// Convert enum-based identity to free-form fields
  Map<String, dynamic> convertToFreeForm(CulturalIdentity identity) {
    final heritageTexts = <String>[];
    final communityTexts = <String>[];
    final interestTexts = <String>[];
    final practiceTexts = <String>[];

    // Convert primary ethnicity to heritage description
    if (identity.primaryEthnicity != null) {
      heritageTexts.add(convertEthnicityToText(identity.primaryEthnicity));
    }

    // Convert sub-ethnicities to heritage descriptions
    for (final subEthnicity in identity.subEthnicities) {
      heritageTexts.add(convertSubEthnicityToText(subEthnicity));
    }

    // Convert communities
    for (final community in identity.communities) {
      communityTexts.add(convertCommunityToText(community));
    }

    // Convert interests
    for (final interest in identity.interests) {
      interestTexts.add(convertInterestToText(interest));
    }

    // Convert regional influences to practices
    for (final influence in identity.regionalInfluences) {
      practiceTexts.add(convertRegionalInfluenceToText(influence));
    }

    return {
      'heritage_description': heritageTexts.join(' '),
      'community_affiliations': communityTexts,
      'generational_identity': identity.generation != null
          ? convertGenerationToText(identity.generation)
          : null,
      'cultural_practices': practiceTexts,
      'cultural_interests_text': interestTexts,
    };
  }

  /// Calculate profile richness from free-form text
  static double calculateProfileRichness(Map<String, dynamic> freeFormData) {
    double richness = 0.0;
    int factorsPresent = 0;
    int totalFactors = 5;

    // Heritage description (20%)
    final heritage = freeFormData['heritage_description'] as String?;
    if (heritage != null && heritage.isNotEmpty) {
      // More points for longer, detailed descriptions
      final wordCount = heritage.split(' ').length;
      richness += (wordCount.clamp(0, 100) / 100.0) * 0.2;
      factorsPresent++;
    }

    // Community affiliations (20%)
    final communities = freeFormData['community_affiliations'] as List<String>?;
    if (communities != null && communities.isNotEmpty) {
      // More points for multiple communities
      richness += (communities.length.clamp(0, 10) / 10.0) * 0.2;
      factorsPresent++;
    }

    // Generational identity (20%)
    final generation = freeFormData['generational_identity'] as String?;
    if (generation != null && generation.isNotEmpty) {
      richness += 0.2;
      factorsPresent++;
    }

    // Cultural practices (20%)
    final practices = freeFormData['cultural_practices'] as List<String>?;
    if (practices != null && practices.isNotEmpty) {
      richness += (practices.length.clamp(0, 10) / 10.0) * 0.2;
      factorsPresent++;
    }

    // Cultural interests (20%)
    final interests = freeFormData['cultural_interests_text'] as List<String>?;
    if (interests != null && interests.isNotEmpty) {
      richness += (interests.length.clamp(0, 10) / 10.0) * 0.2;
      factorsPresent++;
    }

    // Bonus for having all factors present
    if (factorsPresent == totalFactors) {
      richness = (richness * 1.1).clamp(0.0, 1.0);
    }

    return richness;
  }
}
