import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'regional_pattern_model.g.dart';

/// Regional dating pattern insights
@JsonSerializable()
class RegionalPattern extends Equatable {
  const RegionalPattern({
    required this.id,
    required this.region,
    required this.patternType,
    required this.insights,
    required this.confidenceScore,
    this.sampleSize = 0,
    this.trendDirection,
    this.comparisonData = const {},
    required this.lastUpdated,
    this.metadata = const {},
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'region')
  final String region; // City, state, or country code

  @JsonKey(name: 'pattern_type')
  final PatternType patternType;

  @JsonKey(name: 'insights')
  final Map<String, dynamic> insights; // Pattern-specific data

  @JsonKey(name: 'confidence_score')
  final double confidenceScore; // 0.0-1.0

  @JsonKey(name: 'sample_size')
  final int sampleSize; // Number of data points

  @JsonKey(name: 'trend_direction')
  final TrendDirection? trendDirection;

  @JsonKey(name: 'comparison_data')
  final Map<String, dynamic> comparisonData; // Cross-regional comparisons

  @JsonKey(name: 'last_updated')
  final DateTime lastUpdated;

  @JsonKey(name: 'metadata')
  final Map<String, dynamic> metadata;

  factory RegionalPattern.fromJson(Map<String, dynamic> json) =>
      _$RegionalPatternFromJson(json);

  Map<String, dynamic> toJson() => _$RegionalPatternToJson(this);

  @override
  List<Object?> get props => [
        id,
        region,
        patternType,
        insights,
        confidenceScore,
        sampleSize,
        trendDirection,
        comparisonData,
        lastUpdated,
        metadata,
      ];

  RegionalPattern copyWith({
    String? id,
    String? region,
    PatternType? patternType,
    Map<String, dynamic>? insights,
    double? confidenceScore,
    int? sampleSize,
    TrendDirection? trendDirection,
    Map<String, dynamic>? comparisonData,
    DateTime? lastUpdated,
    Map<String, dynamic>? metadata,
  }) {
    return RegionalPattern(
      id: id ?? this.id,
      region: region ?? this.region,
      patternType: patternType ?? this.patternType,
      insights: insights ?? this.insights,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      sampleSize: sampleSize ?? this.sampleSize,
      trendDirection: trendDirection ?? this.trendDirection,
      comparisonData: comparisonData ?? this.comparisonData,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Pattern type classification
enum PatternType {
  @JsonValue('dating_behavior')
  datingBehavior,

  @JsonValue('communication_style')
  communicationStyle,

  @JsonValue('relationship_expectations')
  relationshipExpectations,

  @JsonValue('safety_concern')
  safetyConcern,

  @JsonValue('cultural_norm')
  culturalNorm,

  @JsonValue('success_factor')
  successFactor,

  @JsonValue('red_flag')
  redFlag,

  @JsonValue('compatibility_insight')
  compatibilityInsight;

  String get displayName {
    switch (this) {
      case PatternType.datingBehavior:
        return 'Dating Behavior';
      case PatternType.communicationStyle:
        return 'Communication Style';
      case PatternType.relationshipExpectations:
        return 'Relationship Expectations';
      case PatternType.safetyConcern:
        return 'Safety Concern';
      case PatternType.culturalNorm:
        return 'Cultural Norm';
      case PatternType.successFactor:
        return 'Success Factor';
      case PatternType.redFlag:
        return 'Red Flag';
      case PatternType.compatibilityInsight:
        return 'Compatibility Insight';
    }
  }
}

/// Trend direction for patterns
enum TrendDirection {
  @JsonValue('increasing')
  increasing,

  @JsonValue('decreasing')
  decreasing,

  @JsonValue('stable')
  stable,

  @JsonValue('emerging')
  emerging,

  @JsonValue('declining')
  declining;

  String get displayName {
    switch (this) {
      case TrendDirection.increasing:
        return 'Increasing';
      case TrendDirection.decreasing:
        return 'Decreasing';
      case TrendDirection.stable:
        return 'Stable';
      case TrendDirection.emerging:
        return 'Emerging';
      case TrendDirection.declining:
        return 'Declining';
    }
  }
}
