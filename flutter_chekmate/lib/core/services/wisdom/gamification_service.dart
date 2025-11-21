import 'package:flutter_chekmate/features/wisdom/models/achievement_model.dart';
import 'package:flutter_chekmate/features/wisdom/models/wisdom_score_model.dart';

/// Service for managing gamification and achievements
class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  static GamificationService get instance => _instance;

  GamificationService._internal();

  // Achievement definitions
  static final List<AchievementDefinition> _achievementDefinitions = [
    // Wisdom Score Milestones
    AchievementDefinition(
      id: 'first_sage',
      type: AchievementType.milestone,
      title: 'First Sage',
      description: 'Reached Sage level (5.0+ wisdom score)',
      icon: 'star',
      rarity: 'common',
      requirement: 'wisdom_score',
      requirementValue: 5,
    ),
    AchievementDefinition(
      id: 'mentor_achieved',
      type: AchievementType.milestone,
      title: 'Mentor Achieved',
      description: 'Reached Mentor level (6.5+ wisdom score)',
      icon: 'school',
      rarity: 'uncommon',
      requirement: 'wisdom_score',
      requirementValue: 7,
    ),
    AchievementDefinition(
      id: 'coach_achieved',
      type: AchievementType.milestone,
      title: 'Coach Achieved',
      description: 'Reached Coach level (8.0+ wisdom score)',
      icon: 'sports_basketball',
      rarity: 'rare',
      requirement: 'wisdom_score',
      requirementValue: 8,
    ),
    AchievementDefinition(
      id: 'luminary_achieved',
      type: AchievementType.milestone,
      title: 'Luminary Achieved',
      description: 'Reached Luminary level (9.0+ wisdom score)',
      icon: 'brightness_7',
      rarity: 'epic',
      requirement: 'wisdom_score',
      requirementValue: 9,
    ),

    // Interaction Milestones
    AchievementDefinition(
      id: 'first_interaction',
      type: AchievementType.community,
      title: 'First Interaction',
      description: 'Made your first helpful contribution',
      icon: 'handshake',
      rarity: 'common',
      requirement: 'interactions',
      requirementValue: 1,
    ),
    AchievementDefinition(
      id: 'helpful_contributor',
      type: AchievementType.community,
      title: 'Helpful Contributor',
      description: 'Received 50 helpful ratings',
      icon: 'thumb_up',
      rarity: 'uncommon',
      requirement: 'helpful_ratings',
      requirementValue: 50,
    ),
    AchievementDefinition(
      id: 'community_pillar',
      type: AchievementType.community,
      title: 'Community Pillar',
      description: 'Received 250 helpful ratings',
      icon: 'public',
      rarity: 'rare',
      requirement: 'helpful_ratings',
      requirementValue: 250,
    ),

    // Verification Achievements
    AchievementDefinition(
      id: 'story_verified',
      type: AchievementType.verification,
      title: 'Story Verified',
      description: 'Had your first story verified',
      icon: 'verified',
      rarity: 'uncommon',
      requirement: 'verified_stories',
      requirementValue: 1,
    ),
    AchievementDefinition(
      id: 'verified_expert',
      type: AchievementType.verification,
      title: 'Verified Expert',
      description: 'Had 10 stories verified',
      icon: 'verified_user',
      rarity: 'rare',
      requirement: 'verified_stories',
      requirementValue: 10,
    ),

    // Streak Achievements
    AchievementDefinition(
      id: 'week_streak',
      type: AchievementType.streak,
      title: 'Week Warrior',
      description: 'Maintained a 7-day contribution streak',
      icon: 'local_fire_department',
      rarity: 'uncommon',
      requirement: 'streak_days',
      requirementValue: 7,
    ),
    AchievementDefinition(
      id: 'month_streak',
      type: AchievementType.streak,
      title: 'Month Master',
      description: 'Maintained a 30-day contribution streak',
      icon: 'whatshot',
      rarity: 'rare',
      requirement: 'streak_days',
      requirementValue: 30,
    ),

    // Mentorship Achievements
    AchievementDefinition(
      id: 'first_mentor',
      type: AchievementType.mentorship,
      title: 'First Mentor',
      description: 'Became a mentor to another user',
      icon: 'person_add',
      rarity: 'uncommon',
      requirement: 'mentees',
      requirementValue: 1,
    ),
    AchievementDefinition(
      id: 'mentor_circle',
      type: AchievementType.mentorship,
      title: 'Mentor Circle',
      description: 'Mentored 5 users',
      icon: 'group',
      rarity: 'rare',
      requirement: 'mentees',
      requirementValue: 5,
    ),

    // Specialty Achievements
    AchievementDefinition(
      id: 'dating_strategist',
      type: AchievementType.specialty,
      title: 'Dating Strategist',
      description: 'Specialized in Dating Strategy (7.0+ score)',
      icon: 'strategy',
      rarity: 'uncommon',
      requirement: 'category_score',
      requirementValue: 7,
    ),
    AchievementDefinition(
      id: 'emotional_expert',
      type: AchievementType.specialty,
      title: 'Emotional Expert',
      description: 'Specialized in Emotional Intelligence (7.0+ score)',
      icon: 'favorite',
      rarity: 'uncommon',
      requirement: 'category_score',
      requirementValue: 7,
    ),
    AchievementDefinition(
      id: 'safety_champion',
      type: AchievementType.specialty,
      title: 'Safety Champion',
      description: 'Specialized in Safety Awareness (7.0+ score)',
      icon: 'security',
      rarity: 'uncommon',
      requirement: 'category_score',
      requirementValue: 7,
    ),
  ];

  /// Get all achievement definitions
  List<AchievementDefinition> getAllAchievements() {
    return _achievementDefinitions;
  }

  /// Get achievement by ID
  AchievementDefinition? getAchievementById(String id) {
    try {
      return _achievementDefinitions.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get achievements by type
  List<AchievementDefinition> getAchievementsByType(AchievementType type) {
    return _achievementDefinitions.where((a) => a.type == type).toList();
  }

  /// Check if achievement should be unlocked
  bool shouldUnlockAchievement({
    required AchievementDefinition definition,
    required int currentValue,
  }) {
    return currentValue >= definition.requirementValue;
  }

  /// Get rarity color
  String getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return '#808080'; // Gray
      case 'uncommon':
        return '#4ECDC4'; // Teal
      case 'rare':
        return '#4169E1'; // Royal Blue
      case 'epic':
        return '#9370DB'; // Medium Purple
      case 'legendary':
        return '#FFD700'; // Gold
      default:
        return '#808080';
    }
  }

  /// Get rarity icon
  String getRarityIcon(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return 'star_border';
      case 'uncommon':
        return 'star_half';
      case 'rare':
        return 'star';
      case 'epic':
        return 'stars';
      case 'legendary':
        return 'grade';
      default:
        return 'star_border';
    }
  }

  /// Calculate total achievement points
  int calculateAchievementPoints(List<Achievement> achievements) {
    int points = 0;

    for (final achievement in achievements) {
      switch (achievement.rarity.toLowerCase()) {
        case 'common':
          points += 10;
          break;
        case 'uncommon':
          points += 25;
          break;
        case 'rare':
          points += 50;
          break;
        case 'epic':
          points += 100;
          break;
        case 'legendary':
          points += 250;
          break;
      }
    }

    return points;
  }

  /// Get achievement progress
  double getAchievementProgress(Achievement achievement) {
    if (achievement.progress == null || achievement.progressTarget == null) {
      return 100;
    }

    return ((achievement.progress! / achievement.progressTarget!) * 100)
        .clamp(0, 100)
        .toDouble();
  }

  /// Get next achievement milestone
  AchievementDefinition? getNextMilestone(
    List<Achievement> unlockedAchievements,
  ) {
    final unlockedIds = unlockedAchievements.map((a) => a.id).toSet();

    for (final definition in _achievementDefinitions) {
      if (!unlockedIds.contains(definition.id)) {
        return definition;
      }
    }

    return null;
  }

  /// Get achievement recommendations
  List<AchievementDefinition> getRecommendations({
    required double wisdomScore,
    required int totalInteractions,
    required int helpfulRatings,
    required List<Achievement> unlockedAchievements,
  }) {
    final unlockedIds = unlockedAchievements.map((a) => a.id).toSet();
    final recommendations = <AchievementDefinition>[];

    for (final definition in _achievementDefinitions) {
      if (unlockedIds.contains(definition.id)) continue;

      // Check if user is close to unlocking
      bool isClose = false;

      switch (definition.requirement) {
        case 'wisdom_score':
          isClose = wisdomScore >= (definition.requirementValue - 1);
          break;
        case 'interactions':
          isClose = totalInteractions >= (definition.requirementValue - 5);
          break;
        case 'helpful_ratings':
          isClose = helpfulRatings >= (definition.requirementValue - 10);
          break;
      }

      if (isClose) {
        recommendations.add(definition);
      }
    }

    return recommendations.take(3).toList();
  }

  /// Get achievement statistics
  Map<String, dynamic> getAchievementStats(
    List<Achievement> achievements,
  ) {
    final stats = <String, dynamic>{
      'total_achievements': achievements.length,
      'total_points': calculateAchievementPoints(achievements),
      'by_rarity': <String, int>{},
      'by_type': <String, int>{},
    };

    for (final achievement in achievements) {
      // Count by rarity
      final rarity = achievement.rarity.toLowerCase();
      stats['by_rarity'][rarity] = (stats['by_rarity'][rarity] ?? 0) + 1;

      // Count by type
      final type = achievement.type.value;
      stats['by_type'][type] = (stats['by_type'][type] ?? 0) + 1;
    }

    return stats;
  }
}
