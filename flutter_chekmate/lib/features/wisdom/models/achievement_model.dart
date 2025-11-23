import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'achievement_model.g.dart';

/// Achievement type enumeration
enum AchievementType {
  @JsonValue('milestone')
  milestone('milestone', 'Milestone', 'Reached a significant milestone'),

  @JsonValue('specialty')
  specialty('specialty', 'Specialty', 'Specialized expertise area'),

  @JsonValue('streak')
  streak('streak', 'Streak', 'Maintained a streak of quality contributions'),

  @JsonValue('community')
  community('community', 'Community', 'Community contribution achievement'),

  @JsonValue('verification')
  verification('verification', 'Verification', 'Story verification achievement'),

  @JsonValue('mentorship')
  mentorship('mentorship', 'Mentorship', 'Mentorship achievement');

  const AchievementType(this.value, this.displayName, this.description);

  final String value;
  final String displayName;
  final String description;
}

/// User achievement
@JsonSerializable()
class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.unlockedAt,
    this.progress,
    this.progressTarget,
    this.metadata,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'type')
  final AchievementType type;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'icon')
  final String icon; // Icon name or URL

  @JsonKey(name: 'rarity')
  final String rarity; // 'common', 'rare', 'epic', 'legendary'

  @JsonKey(name: 'unlocked_at')
  final DateTime unlockedAt;

  @JsonKey(name: 'progress')
  final int? progress; // Current progress

  @JsonKey(name: 'progress_target')
  final int? progressTarget; // Target for completion

  @JsonKey(name: 'metadata')
  final Map<String, dynamic>? metadata;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementToJson(this);

  /// Get progress percentage
  double getProgressPercentage() {
    if (progress == null || progressTarget == null || progressTarget == 0) {
      return 100;
    }
    return (progress! / progressTarget!) * 100;
  }

  /// Check if achievement is complete
  bool get isComplete {
    if (progress == null || progressTarget == null) return true;
    return progress! >= progressTarget!;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        description,
        icon,
        rarity,
        unlockedAt,
        progress,
        progressTarget,
        metadata,
      ];
}

/// Achievement definition (template)
@JsonSerializable()
class AchievementDefinition extends Equatable {
  const AchievementDefinition({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.requirement,
    required this.requirementValue,
    this.metadata,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'type')
  final AchievementType type;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'icon')
  final String icon;

  @JsonKey(name: 'rarity')
  final String rarity;

  @JsonKey(name: 'requirement')
  final String requirement; // 'wisdom_score', 'interactions', 'endorsements', etc.

  @JsonKey(name: 'requirement_value')
  final int requirementValue;

  @JsonKey(name: 'metadata')
  final Map<String, dynamic>? metadata;

  factory AchievementDefinition.fromJson(Map<String, dynamic> json) =>
      _$AchievementDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementDefinitionToJson(this);

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        icon,
        rarity,
        requirement,
        requirementValue,
        metadata,
      ];
}

/// Badge display model
@JsonSerializable()
class Badge extends Equatable {
  const Badge({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.earnedAt,
    this.expiresAt,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'icon')
  final String icon;

  @JsonKey(name: 'color')
  final String color; // Hex color code

  @JsonKey(name: 'earned_at')
  final DateTime earnedAt;

  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);

  Map<String, dynamic> toJson() => _$BadgeToJson(this);

  /// Check if badge is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        icon,
        color,
        earnedAt,
        expiresAt,
      ];
}
