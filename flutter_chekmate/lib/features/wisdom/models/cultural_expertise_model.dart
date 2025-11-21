import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cultural_expertise_model.g.dart';

/// Cultural expertise badge for wisdom contributors
@JsonSerializable()
class CulturalExpertise extends Equatable {
  const CulturalExpertise({
    required this.id,
    required this.userId,
    required this.cultureCode,
    required this.cultureName,
    required this.expertiseScore,
    required this.helpfulRatingsInCulture,
    required this.totalContributionsInCulture,
    required this.badgeLevel,
    required this.earnedAt,
    this.lastUpdated,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'culture_code')
  final String cultureCode; // e.g., 'US', 'JP', 'BR'

  @JsonKey(name: 'culture_name')
  final String cultureName; // e.g., 'North America', 'East Asia'

  @JsonKey(name: 'expertise_score')
  final double expertiseScore; // 0-10

  @JsonKey(name: 'helpful_ratings_in_culture')
  final int helpfulRatingsInCulture;

  @JsonKey(name: 'total_contributions_in_culture')
  final int totalContributionsInCulture;

  @JsonKey(name: 'badge_level')
  final CulturalBadgeLevel badgeLevel;

  @JsonKey(name: 'earned_at')
  final DateTime earnedAt;

  @JsonKey(name: 'last_updated')
  final DateTime? lastUpdated;

  factory CulturalExpertise.fromJson(Map<String, dynamic> json) =>
      _$CulturalExpertiseFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalExpertiseToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        cultureCode,
        cultureName,
        expertiseScore,
        helpfulRatingsInCulture,
        totalContributionsInCulture,
        badgeLevel,
        earnedAt,
        lastUpdated,
      ];
}

/// Cultural badge level
enum CulturalBadgeLevel {
  @JsonValue('bronze')
  bronze,

  @JsonValue('silver')
  silver,

  @JsonValue('gold')
  gold,

  @JsonValue('platinum')
  platinum;

  String get displayName {
    switch (this) {
      case CulturalBadgeLevel.bronze:
        return 'Bronze';
      case CulturalBadgeLevel.silver:
        return 'Silver';
      case CulturalBadgeLevel.gold:
        return 'Gold';
      case CulturalBadgeLevel.platinum:
        return 'Platinum';
    }
  }

  int get minContributions {
    switch (this) {
      case CulturalBadgeLevel.bronze:
        return 5;
      case CulturalBadgeLevel.silver:
        return 15;
      case CulturalBadgeLevel.gold:
        return 50;
      case CulturalBadgeLevel.platinum:
        return 100;
    }
  }

  double get minScore {
    switch (this) {
      case CulturalBadgeLevel.bronze:
        return 5.0;
      case CulturalBadgeLevel.silver:
        return 6.5;
      case CulturalBadgeLevel.gold:
        return 8.0;
      case CulturalBadgeLevel.platinum:
        return 9.0;
    }
  }
}
