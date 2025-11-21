import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wisdom_score_model.g.dart';

/// Wisdom score category enumeration
enum WisdomCategory {
  @JsonValue('dating_strategy')
  datingStrategy('dating_strategy', 'Dating Strategy'),

  @JsonValue('emotional_intelligence')
  emotionalIntelligence('emotional_intelligence', 'Emotional Intelligence'),

  @JsonValue('safety_awareness')
  safetyAwareness('safety_awareness', 'Safety Awareness'),

  @JsonValue('relationship_skills')
  relationshipSkills('relationship_skills', 'Relationship Skills'),

  @JsonValue('communication')
  communication('communication', 'Communication'),

  @JsonValue('conflict_resolution')
  conflictResolution('conflict_resolution', 'Conflict Resolution'),

  @JsonValue('self_awareness')
  selfAwareness('self_awareness', 'Self Awareness'),

  @JsonValue('cultural_sensitivity')
  culturalSensitivity('cultural_sensitivity', 'Cultural Sensitivity');

  const WisdomCategory(this.value, this.displayName);

  final String value;
  final String displayName;
}

/// Achievement level enumeration
enum AchievementLevel {
  @JsonValue('sage')
  sage('sage', 'Sage', 'Foundational wisdom contributor'),

  @JsonValue('mentor')
  mentor('mentor', 'Mentor', 'Experienced guide and advisor'),

  @JsonValue('coach')
  coach('coach', 'Coach', 'Expert coach and strategist'),

  @JsonValue('luminary')
  luminary('luminary', 'Luminary', 'Exceptional community leader');

  const AchievementLevel(this.value, this.displayName, this.description);

  final String value;
  final String displayName;
  final String description;
}

/// Wisdom score calculation factors
@JsonSerializable()
class WisdomScoreFactors extends Equatable {
  const WisdomScoreFactors({
    required this.helpfulnessRating,
    required this.peerValidation,
    required this.storyVerification,
    required this.recencyBonus,
    required this.consistencyScore,
    required this.engagementMultiplier,
  });

  @JsonKey(name: 'helpfulness_rating')
  final double helpfulnessRating; // 0-10

  @JsonKey(name: 'peer_validation')
  final double peerValidation; // 0-1 (percentage of positive ratings)

  @JsonKey(name: 'story_verification')
  final double storyVerification; // 0-1 (percentage of verified stories)

  @JsonKey(name: 'recency_bonus')
  final double recencyBonus; // 0-1 (bonus for recent activity)

  @JsonKey(name: 'consistency_score')
  final double consistencyScore; // 0-1 (consistency of quality)

  @JsonKey(name: 'engagement_multiplier')
  final double engagementMultiplier; // 0-2 (based on interaction count)

  factory WisdomScoreFactors.fromJson(Map<String, dynamic> json) =>
      _$WisdomScoreFactorsFromJson(json);

  Map<String, dynamic> toJson() => _$WisdomScoreFactorsToJson(this);

  @override
  List<Object?> get props => [
        helpfulnessRating,
        peerValidation,
        storyVerification,
        recencyBonus,
        consistencyScore,
        engagementMultiplier,
      ];
}

/// User's wisdom score
@JsonSerializable()
class WisdomScore extends Equatable {
  const WisdomScore({
    required this.id,
    required this.userId,
    required this.overallScore,
    required this.categoryScores,
    required this.factors,
    required this.totalInteractions,
    required this.helpfulRatings,
    required this.unhelpfulRatings,
    required this.verifiedStories,
    required this.achievementLevel,
    required this.createdAt,
    required this.updatedAt,
    this.lastCalculatedAt,
    this.metadata,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'overall_score')
  final double overallScore; // 0-10

  @JsonKey(name: 'category_scores')
  final Map<String, double> categoryScores; // Category -> score

  @JsonKey(name: 'factors')
  final WisdomScoreFactors factors;

  @JsonKey(name: 'total_interactions')
  final int totalInteractions;

  @JsonKey(name: 'helpful_ratings')
  final int helpfulRatings;

  @JsonKey(name: 'unhelpful_ratings')
  final int unhelpfulRatings;

  @JsonKey(name: 'verified_stories')
  final int verifiedStories;

  @JsonKey(name: 'achievement_level')
  final AchievementLevel achievementLevel;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @JsonKey(name: 'last_calculated_at')
  final DateTime? lastCalculatedAt;

  @JsonKey(name: 'metadata')
  final Map<String, dynamic>? metadata;

  factory WisdomScore.fromJson(Map<String, dynamic> json) =>
      _$WisdomScoreFromJson(json);

  Map<String, dynamic> toJson() => _$WisdomScoreToJson(this);

  /// Get helpful rating percentage
  double getHelpfulPercentage() {
    final total = helpfulRatings + unhelpfulRatings;
    if (total == 0) return 0;
    return (helpfulRatings / total) * 100;
  }

  /// Get top category
  String? getTopCategory() {
    if (categoryScores.isEmpty) return null;
    return categoryScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        overallScore,
        categoryScores,
        factors,
        totalInteractions,
        helpfulRatings,
        unhelpfulRatings,
        verifiedStories,
        achievementLevel,
        createdAt,
        updatedAt,
        lastCalculatedAt,
        metadata,
      ];
}

/// Interaction rating (helpful/unhelpful)
@JsonSerializable()
class InteractionRating extends Equatable {
  const InteractionRating({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.interactionId,
    required this.interactionType,
    required this.rating,
    required this.category,
    this.comment,
    required this.createdAt,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'user_id')
  final String userId; // Who is rating

  @JsonKey(name: 'target_user_id')
  final String targetUserId; // Who is being rated

  @JsonKey(name: 'interaction_id')
  final String interactionId; // Comment, advice, etc.

  @JsonKey(name: 'interaction_type')
  final String interactionType; // 'comment', 'advice', 'guide', etc.

  @JsonKey(name: 'rating')
  final bool rating; // true = helpful, false = unhelpful

  @JsonKey(name: 'category')
  final WisdomCategory category;

  @JsonKey(name: 'comment')
  final String? comment;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  factory InteractionRating.fromJson(Map<String, dynamic> json) =>
      _$InteractionRatingFromJson(json);

  Map<String, dynamic> toJson() => _$InteractionRatingToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        targetUserId,
        interactionId,
        interactionType,
        rating,
        category,
        comment,
        createdAt,
      ];
}
