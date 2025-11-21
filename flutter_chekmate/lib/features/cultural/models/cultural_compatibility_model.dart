import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cultural_compatibility_model.g.dart';

/// Cultural compatibility assessment
@JsonSerializable()
class CulturalCompatibility extends Equatable {
  const CulturalCompatibility({
    required this.id,
    required this.userCulture,
    required this.partnerCulture,
    required this.compatibilityScore,
    this.strengths = const [],
    this.potentialChallenges = const [],
    this.recommendations = const [],
    this.successStories = const [],
    required this.calculatedAt,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'user_culture')
  final String userCulture;

  @JsonKey(name: 'partner_culture')
  final String partnerCulture;

  @JsonKey(name: 'compatibility_score')
  final double compatibilityScore; // 0.0-10.0

  @JsonKey(name: 'strengths')
  final List<CompatibilityFactor> strengths;

  @JsonKey(name: 'potential_challenges')
  final List<CompatibilityFactor> potentialChallenges;

  @JsonKey(name: 'recommendations')
  final List<String> recommendations;

  @JsonKey(name: 'success_stories')
  final List<String> successStories; // Story IDs

  @JsonKey(name: 'calculated_at')
  final DateTime calculatedAt;

  factory CulturalCompatibility.fromJson(Map<String, dynamic> json) =>
      _$CulturalCompatibilityFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalCompatibilityToJson(this);

  @override
  List<Object?> get props => [
        id,
        userCulture,
        partnerCulture,
        compatibilityScore,
        strengths,
        potentialChallenges,
        recommendations,
        successStories,
        calculatedAt,
      ];
}

/// Compatibility factor detail
@JsonSerializable()
class CompatibilityFactor extends Equatable {
  const CompatibilityFactor({
    required this.category,
    required this.description,
    required this.impact,
    this.mitigation,
  });

  @JsonKey(name: 'category')
  final String category;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'impact')
  final FactorImpact impact;

  @JsonKey(name: 'mitigation')
  final String? mitigation;

  factory CompatibilityFactor.fromJson(Map<String, dynamic> json) =>
      _$CompatibilityFactorFromJson(json);

  Map<String, dynamic> toJson() => _$CompatibilityFactorToJson(this);

  @override
  List<Object?> get props => [category, description, impact, mitigation];
}

/// Impact level of compatibility factor
enum FactorImpact {
  @JsonValue('positive')
  positive,

  @JsonValue('neutral')
  neutral,

  @JsonValue('minor_challenge')
  minorChallenge,

  @JsonValue('moderate_challenge')
  moderateChallenge,

  @JsonValue('major_challenge')
  majorChallenge;

  String get displayName {
    switch (this) {
      case FactorImpact.positive:
        return 'Positive';
      case FactorImpact.neutral:
        return 'Neutral';
      case FactorImpact.minorChallenge:
        return 'Minor Challenge';
      case FactorImpact.moderateChallenge:
        return 'Moderate Challenge';
      case FactorImpact.majorChallenge:
        return 'Major Challenge';
    }
  }
}
