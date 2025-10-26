import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gamification service for tracking user engagement
/// Handles streaks, points, badges, and achievements
class GamificationService {
  static const String _streakKey = 'login_streak';
  static const String _lastLoginKey = 'last_login_date';
  static const String _pointsKey = 'total_points';
  static const String _ratingsCountKey = 'ratings_count';
  static const String _badgesKey = 'earned_badges';

  /// Check and update login streak
  Future<int> updateLoginStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final lastLoginStr = prefs.getString(_lastLoginKey);
    final currentStreak = prefs.getInt(_streakKey) ?? 0;

    if (lastLoginStr == null) {
      // First login ever
      await prefs.setString(_lastLoginKey, today.toIso8601String());
      await prefs.setInt(_streakKey, 1);
      return 1;
    }

    final lastLogin = DateTime.parse(lastLoginStr);
    final lastLoginDate = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
    final daysDifference = today.difference(lastLoginDate).inDays;

    if (daysDifference == 0) {
      // Already logged in today
      return currentStreak;
    } else if (daysDifference == 1) {
      // Consecutive day - increment streak
      final newStreak = currentStreak + 1;
      await prefs.setInt(_streakKey, newStreak);
      await prefs.setString(_lastLoginKey, today.toIso8601String());
      
      // Award points for streak milestone
      if (newStreak % 7 == 0) {
        await addPoints(50, 'Weekly streak bonus!');
      }
      
      return newStreak;
    } else {
      // Streak broken - reset to 1
      await prefs.setInt(_streakKey, 1);
      await prefs.setString(_lastLoginKey, today.toIso8601String());
      return 1;
    }
  }

  /// Get current login streak
  Future<int> getLoginStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  /// Add points to user's total
  Future<int> addPoints(int points, String reason) async {
    final prefs = await SharedPreferences.getInstance();
    final currentPoints = prefs.getInt(_pointsKey) ?? 0;
    final newPoints = currentPoints + points;
    await prefs.setInt(_pointsKey, newPoints);
    
    if (kDebugMode) {
      debugPrint('🎮 +$points points: $reason (Total: $newPoints)');
    }
    
    // Check for point milestones
    await _checkPointMilestones(newPoints);
    
    return newPoints;
  }

  /// Get total points
  Future<int> getTotalPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pointsKey) ?? 0;
  }

  /// Increment rating count and award points
  Future<void> recordRating() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_ratingsCountKey) ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt(_ratingsCountKey, newCount);
    
    // Award points for rating
    await addPoints(10, 'Rated a date');
    
    // Check for rating milestones
    await _checkRatingMilestones(newCount);
  }

  /// Get total ratings count
  Future<int> getRatingsCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_ratingsCountKey) ?? 0;
  }

  /// Check and award badges for point milestones
  Future<void> _checkPointMilestones(int points) async {
    final milestones = [100, 500, 1000, 5000, 10000];
    
    for (final milestone in milestones) {
      if (points >= milestone) {
        await _awardBadge('points_$milestone', '${milestone}pts Master');
      }
    }
  }

  /// Check and award badges for rating milestones
  Future<void> _checkRatingMilestones(int count) async {
    final milestones = {
      1: 'First Rating',
      10: 'Rating Rookie',
      50: 'Rating Pro',
      100: 'Rating Expert',
      500: 'Rating Legend',
    };
    
    milestones.forEach((milestone, badgeName) async {
      if (count >= milestone) {
        await _awardBadge('ratings_$milestone', badgeName);
      }
    });
  }

  /// Award a badge to the user
  Future<void> _awardBadge(String badgeId, String badgeName) async {
    final prefs = await SharedPreferences.getInstance();
    final badgesJson = prefs.getStringList(_badgesKey) ?? [];
    
    if (!badgesJson.contains(badgeId)) {
      badgesJson.add(badgeId);
      await prefs.setStringList(_badgesKey, badgesJson);
      
      if (kDebugMode) {
        debugPrint('🏆 Badge earned: $badgeName');
      }
    }
  }

  /// Get all earned badges
  Future<List<String>> getEarnedBadges() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_badgesKey) ?? [];
  }

  /// Check if user has a specific badge
  Future<bool> hasBadge(String badgeId) async {
    final badges = await getEarnedBadges();
    return badges.contains(badgeId);
  }

  /// Get user level based on points
  Future<int> getUserLevel() async {
    final points = await getTotalPoints();
    
    // Level progression: 100pts per level for first 10 levels,
    // then 200pts per level
    if (points < 1000) {
      return (points / 100).floor() + 1;
    } else {
      return 10 + ((points - 1000) / 200).floor() + 1;
    }
  }

  /// Get points needed for next level
  Future<int> getPointsToNextLevel() async {
    final points = await getTotalPoints();
    final level = await getUserLevel();
    
    int nextLevelPoints;
    if (level < 10) {
      nextLevelPoints = level * 100;
    } else {
      nextLevelPoints = 1000 + ((level - 10) * 200);
    }
    
    return nextLevelPoints - points;
  }

  /// Reset all gamification data (for testing)
  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_streakKey);
    await prefs.remove(_lastLoginKey);
    await prefs.remove(_pointsKey);
    await prefs.remove(_ratingsCountKey);
    await prefs.remove(_badgesKey);
    
    if (kDebugMode) {
      debugPrint('🔄 Gamification data reset');
    }
  }

  /// Get gamification summary
  Future<Map<String, dynamic>> getSummary() async {
    return {
      'streak': await getLoginStreak(),
      'points': await getTotalPoints(),
      'level': await getUserLevel(),
      'pointsToNextLevel': await getPointsToNextLevel(),
      'ratingsCount': await getRatingsCount(),
      'badges': await getEarnedBadges(),
    };
  }
}

