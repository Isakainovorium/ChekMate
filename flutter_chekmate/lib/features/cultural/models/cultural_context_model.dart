import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'cultural_identity_model.dart';

part 'cultural_context_model.g.dart';

/// Cultural context metadata for content
@JsonSerializable()
class CulturalContext extends Equatable {
  const CulturalContext({
    required this.id,
    required this.contentId,
    required this.regionCode,
    required this.cultureCategory,
    this.culturalIdentity,
    this.culturalNorms = const {},
    this.safetyPatterns = const {},
    this.contextAnnotations = const [],
    this.confidenceScore = 0.0,
    required this.createdAt,
    this.updatedAt,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'content_id')
  final String contentId; // Story, post, or comment ID

  @JsonKey(name: 'region_code')
  final String regionCode; // ISO 3166-1 alpha-2 (e.g., "US", "JP", "BR")

  @JsonKey(name: 'culture_category')
  final CultureCategory cultureCategory;

  /// Detailed cultural identity fingerprint (optional - for algorithmic matching)
  /// Used when content creator provides sub-cultural self-identification
  @JsonKey(name: 'cultural_identity')
  final CulturalIdentity? culturalIdentity;

  @JsonKey(name: 'cultural_norms')
  final Map<String, dynamic> culturalNorms; // Flexible norm storage

  @JsonKey(name: 'safety_patterns')
  final Map<String, dynamic> safetyPatterns; // Region-specific safety data

  @JsonKey(name: 'context_annotations')
  final List<String> contextAnnotations; // Human-readable context notes

  @JsonKey(name: 'confidence_score')
  final double confidenceScore; // 0.0-1.0 ML confidence

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  factory CulturalContext.fromJson(Map<String, dynamic> json) =>
      _$CulturalContextFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalContextToJson(this);

  @override
  List<Object?> get props => [
        id,
        contentId,
        regionCode,
        cultureCategory,
        culturalIdentity,
        culturalNorms,
        safetyPatterns,
        contextAnnotations,
        confidenceScore,
        createdAt,
        updatedAt,
      ];

  CulturalContext copyWith({
    String? id,
    String? contentId,
    String? regionCode,
    CultureCategory? cultureCategory,
    CulturalIdentity? culturalIdentity,
    Map<String, dynamic>? culturalNorms,
    Map<String, dynamic>? safetyPatterns,
    List<String>? contextAnnotations,
    double? confidenceScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CulturalContext(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      regionCode: regionCode ?? this.regionCode,
      cultureCategory: cultureCategory ?? this.cultureCategory,
      culturalIdentity: culturalIdentity ?? this.culturalIdentity,
      culturalNorms: culturalNorms ?? this.culturalNorms,
      safetyPatterns: safetyPatterns ?? this.safetyPatterns,
      contextAnnotations: contextAnnotations ?? this.contextAnnotations,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get the most detailed cultural information available for display/algorithmic matching
  String get displayCulture {
    if (culturalIdentity?.subEthnicities.isNotEmpty ?? false) {
      return culturalIdentity!.subEthnicities.first.displayName;
    }
    if (culturalIdentity?.primaryEthnicity != null) {
      return culturalIdentity!.primaryEthnicity!.displayName;
    }
    return cultureCategory.displayName;
  }

  /// Extract cultural fingerprint for algorithmic matching
  CulturalIdentity? get algorithmicFingerprint {
    return culturalIdentity ?? _inferFingerprintFromLegacy();
  }

  /// Infer basic fingerprint from legacy broad categories (for migration)
  CulturalIdentity? _inferFingerprintFromLegacy() {
    // This would map old CultureCategory to basic CulturalIdentity
    // For now, return null to use existing cultureCategory for backward compatibility
    return null; // Will be expanded in migration step
  }
}

/// Culture category classification
enum CultureCategory {
  @JsonValue('north_america')
  northAmerica,

  @JsonValue('western_europe')
  westernEurope,

  @JsonValue('nordic')
  nordic,

  @JsonValue('eastern_europe')
  easternEurope,

  @JsonValue('mediterranean')
  mediterranean,

  @JsonValue('middle_east')
  middleEast,

  @JsonValue('south_asia')
  southAsia,

  @JsonValue('east_asia')
  eastAsia,

  @JsonValue('southeast_asia')
  southeastAsia,

  @JsonValue('latin_america')
  latinAmerica,

  @JsonValue('africa')
  africa,

  @JsonValue('oceania')
  oceania,

  @JsonValue('unknown')
  unknown;

  String get displayName {
    switch (this) {
      case CultureCategory.northAmerica:
        return 'North America';
      case CultureCategory.westernEurope:
        return 'Western Europe';
      case CultureCategory.nordic:
        return 'Nordic Countries';
      case CultureCategory.easternEurope:
        return 'Eastern Europe';
      case CultureCategory.mediterranean:
        return 'Mediterranean';
      case CultureCategory.middleEast:
        return 'Middle East';
      case CultureCategory.southAsia:
        return 'South Asia';
      case CultureCategory.eastAsia:
        return 'East Asia';
      case CultureCategory.southeastAsia:
        return 'Southeast Asia';
      case CultureCategory.latinAmerica:
        return 'Latin America';
      case CultureCategory.africa:
        return 'Africa';
      case CultureCategory.oceania:
        return 'Oceania';
      case CultureCategory.unknown:
        return 'Unknown';
    }
  }
}
