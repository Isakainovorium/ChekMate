import 'package:flutter_chekmate/core/services/gamification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for gamification service
final gamificationServiceProvider = Provider<GamificationService>((ref) {
  return GamificationService();
});

/// Provider for login streak
final loginStreakProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(gamificationServiceProvider);
  return service.getLoginStreak();
});

/// Provider for total points
final totalPointsProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(gamificationServiceProvider);
  return service.getTotalPoints();
});

/// Provider for user level
final userLevelProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(gamificationServiceProvider);
  return service.getUserLevel();
});

/// Provider for gamification summary
final gamificationSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(gamificationServiceProvider);
  return service.getSummary();
});

