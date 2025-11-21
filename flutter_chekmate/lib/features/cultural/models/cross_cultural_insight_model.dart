import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cross_cultural_insight_model.g.dart';

/// Cross-cultural relationship insights
@JsonSerializable()
class CrossCulturalInsight extends Equatable {
  const CrossCulturalInsight({
    required this.id,
    required this.culture1,
    required this.culture2,
    required this.insightType,
    required this.description,
    this.challenges = const [],
    this.successFactors = const [],
    this.recommendations = const [],
    required this.confidenceScore,
    this.basedOnSamples = 0,
    required this.createdAt,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'culture_1')
  final String culture1;

  @JsonKey(name: 'culture_2')
  final String culture2;

  @JsonKey(name: 'insight_type')
  final InsightType insightType;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'challenges')
  final List<String> challenges;

  @JsonKey(name: 'success_factors')
  final List<String> successFactors;

  @JsonKey(name: 'recommendations')
  final List<String> recommendations;

  @JsonKey(name: 'confidence_score')
  final double confidenceScore;

  @JsonKey(name: 'based_on_samples')
  final int basedOnSamples;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  factory CrossCulturalInsight.fromJson(Map<String, dynamic> json) =>
      _$CrossCulturalInsightFromJson(json);

  Map<String, dynamic> toJson() => _$CrossCulturalInsightToJson(this);

  @override
  List<Object?> get props => [
        id,
        culture1,
        culture2,
        insightType,
        description,
        challenges,
        successFactors,
        recommendations,
        confidenceScore,
        basedOnSamples,
        createdAt,
      ];
}

/// Insight type classification
enum InsightType {
  @JsonValue('compatibility')
  compatibility,

  @JsonValue('communication_gap')
  communicationGap,

  @JsonValue('expectation_mismatch')
  expectationMismatch,

  @JsonValue('success_pattern')
  successPattern,

  @JsonValue('common_challenge')
  commonChallenge,

  @JsonValue('cultural_bridge')
  culturalBridge;

  String get displayName {
    switch (this) {
      case InsightType.compatibility:
        return 'Compatibility';
      case InsightType.communicationGap:
        return 'Communication Gap';
      case InsightType.expectationMismatch:
        return 'Expectation Mismatch';
      case InsightType.successPattern:
        return 'Success Pattern';
      case InsightType.commonChallenge:
        return 'Common Challenge';
      case InsightType.culturalBridge:
        return 'Cultural Bridge';
    }
  }
}
