import 'dart:developer' as developer;

import 'package:flutter_chekmate/core/services/location_service.dart';
import 'package:flutter_chekmate/core/services/cultural/location_context_service.dart';
import 'package:flutter_chekmate/core/services/cultural/cultural_vector_service.dart';
import 'package:flutter_chekmate/features/cultural/models/cultural_context_model.dart';

/// Core cultural intelligence engine for geographic content classification
class CulturalIntelligenceService {
  static final CulturalIntelligenceService _instance =
      CulturalIntelligenceService._internal();
  static CulturalIntelligenceService get instance => _instance;

  CulturalIntelligenceService._internal();

  static const Map<String, CultureCategory> _countryCultureMap = {
    'US': CultureCategory.northAmerica,
    'CA': CultureCategory.northAmerica,
    'MX': CultureCategory.latinAmerica,
    'GB': CultureCategory.westernEurope,
    'FR': CultureCategory.westernEurope,
    'DE': CultureCategory.westernEurope,
    'JP': CultureCategory.eastAsia,
    'KR': CultureCategory.eastAsia,
    'CN': CultureCategory.eastAsia,
    'IN': CultureCategory.southAsia,
    'BR': CultureCategory.latinAmerica,
    'AU': CultureCategory.oceania,
  };

  Future<CulturalContext> classifyContentGeographically({
    required String contentId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final location = await LocationService.getAddressFromCoordinates(
        latitude: latitude,
        longitude: longitude,
      );

      final countryCode = _extractCountryCode(location.country ?? '');
      final cultureCategory =
          _countryCultureMap[countryCode] ?? CultureCategory.unknown;

      return CulturalContext(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        contentId: contentId,
        regionCode: countryCode,
        cultureCategory: cultureCategory,
        culturalNorms: {
          'city': location.city,
          'state': location.state,
          'country': location.country,
        },
        confidenceScore: countryCode.isNotEmpty ? 0.9 : 0.5,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      developer.log('Failed to classify: $e', name: 'CulturalIntelligence');
      return CulturalContext(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        contentId: contentId,
        regionCode: 'UNKNOWN',
        cultureCategory: CultureCategory.unknown,
        confidenceScore: 0.0,
        createdAt: DateTime.now(),
      );
    }
  }

  String _extractCountryCode(String country) {
    final countryMap = {
      'United States': 'US',
      'Canada': 'CA',
      'Mexico': 'MX',
      'United Kingdom': 'GB',
      'France': 'FR',
      'Germany': 'DE',
      'Japan': 'JP',
      'South Korea': 'KR',
      'China': 'CN',
      'India': 'IN',
      'Brazil': 'BR',
      'Australia': 'AU',
    };
    return countryMap[country] ?? '';
  }

  /// NEW: ML-driven geographic classification with rich location context
  Future<EnhancedCulturalContext> classifyContentWithML({
    required String contentId,
    required double latitude,
    required double longitude,
    String? creatorHeritageDescription,
    List<String>? creatorCommunities,
    String? creatorGeneration,
    List<String>? creatorCulturalPractices,
    List<String>? creatorCulturalInterests,
  }) async {
    try {
      // Extract rich location context
      final locationContext =
          await LocationContextService.instance.extractLocationContext(
        latitude: latitude,
        longitude: longitude,
      );

      // Generate cultural vector including location
      final vectorService = CulturalVectorService();
      final culturalVector =
          await vectorService.generateCulturalVectorWithLocation(
        heritageDescription: creatorHeritageDescription,
        communityAffiliations: creatorCommunities ?? [],
        generationalIdentity: creatorGeneration,
        culturalPractices: creatorCulturalPractices ?? [],
        culturalInterests: creatorCulturalInterests ?? [],
        regionalInfluence: null,
        locationContext: locationContext,
      );

      return EnhancedCulturalContext(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        contentId: contentId,
        locationContext: locationContext,
        culturalVector: culturalVector,
        confidenceScore: _calculateConfidence(locationContext, culturalVector),
        createdAt: DateTime.now(),
        metadata: {
          'location_keywords': locationContext.locationKeywords,
          'has_heritage': creatorHeritageDescription != null,
          'community_count': creatorCommunities?.length ?? 0,
        },
      );
    } catch (e) {
      developer.log('ML classification failed: $e',
          name: 'CulturalIntelligence');

      // Fallback to basic classification
      return EnhancedCulturalContext(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        contentId: contentId,
        locationContext: null,
        culturalVector: List.filled(384, 0.0), // Empty vector
        confidenceScore: 0.0,
        createdAt: DateTime.now(),
        metadata: {'error': e.toString()},
      );
    }
  }

  /// Calculate confidence score based on data quality
  double _calculateConfidence(
    LocationContext locationContext,
    List<double> culturalVector,
  ) {
    double confidence = 0.5; // Base confidence

    // Add confidence for location detail
    if (locationContext.city != null) confidence += 0.2;
    if (locationContext.neighborhood != null) confidence += 0.1;
    if (locationContext.locationKeywords.isNotEmpty) confidence += 0.1;

    // Add confidence for non-zero vector
    final nonZeroCount = culturalVector.where((v) => v != 0.0).length;
    if (nonZeroCount > culturalVector.length * 0.5) confidence += 0.1;

    return confidence.clamp(0.0, 1.0);
  }

  /// Check if ML classification is available for a user
  Future<bool> isMLClassificationAvailable({
    required String userId,
  }) async {
    // Check if user has migrated profile or is in A/B test group
    // This would typically check database for migration status
    // For now, return true to enable for all
    return true;
  }

  /// Get classification method for a user (enum or ML)
  Future<ClassificationMethod> getClassificationMethod({
    required String userId,
  }) async {
    final mlAvailable = await isMLClassificationAvailable(userId: userId);
    return mlAvailable
        ? ClassificationMethod.mlDriven
        : ClassificationMethod.enumBased;
  }
}

/// Enhanced cultural context with ML vectors
class EnhancedCulturalContext {
  final String id;
  final String contentId;
  final LocationContext? locationContext;
  final List<double> culturalVector;
  final double confidenceScore;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  EnhancedCulturalContext({
    required this.id,
    required this.contentId,
    this.locationContext,
    required this.culturalVector,
    required this.confidenceScore,
    required this.createdAt,
    this.metadata = const {},
  });

  /// Check if this context has valid ML data
  bool get hasMLData => locationContext != null && culturalVector.isNotEmpty;

  /// Get location description for display
  String get locationDescription =>
      locationContext?.locationDescription ?? 'Unknown Location';

  /// Get primary location (city or country)
  String get primaryLocation {
    if (locationContext?.city != null) return locationContext!.city!;
    if (locationContext?.country != null) return locationContext!.country!;
    return 'Unknown';
  }
}

/// Classification method enum
enum ClassificationMethod {
  enumBased,
  mlDriven,
  hybrid,
}
