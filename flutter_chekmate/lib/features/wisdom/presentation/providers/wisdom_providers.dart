import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_chekmate/core/services/wisdom/endorsement_service.dart';
import 'package:flutter_chekmate/core/services/wisdom/gamification_service.dart';
import 'package:flutter_chekmate/core/services/wisdom/wisdom_score_service.dart';
import 'package:flutter_chekmate/features/wisdom/data/datasources/wisdom_remote_data_source.dart';
import 'package:flutter_chekmate/features/wisdom/data/repositories/wisdom_repository_impl.dart';
import 'package:flutter_chekmate/features/wisdom/domain/repositories/wisdom_repository.dart';
import 'package:flutter_chekmate/features/wisdom/models/achievement_model.dart';
import 'package:flutter_chekmate/features/wisdom/models/endorsement_model.dart';
import 'package:flutter_chekmate/features/wisdom/models/wisdom_score_model.dart';

/// ===== DATA LAYER PROVIDERS =====

/// Firestore instance dedicated to wisdom features
final firestoreWisdomProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Uuid provider (mirrors other features)
final uuidProvider = Provider<Uuid>((ref) => const Uuid());

/// Wisdom remote data source provider
final wisdomRemoteDataSourceProvider = Provider<WisdomRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreWisdomProvider);
  final uuid = ref.watch(uuidProvider);
  return WisdomRemoteDataSource(firestore, uuid);
});

/// Wisdom repository provider
final wisdomRepositoryProvider = Provider<WisdomRepository>((ref) {
  final remoteDataSource = ref.watch(wisdomRemoteDataSourceProvider);
  return WisdomRepositoryImpl(
    remoteDataSource: remoteDataSource,
    scoreService: WisdomScoreService.instance,
    endorsementService: EndorsementService.instance,
    gamificationService: GamificationService.instance,
  );
});

/// ===== BUSINESS LOGIC PROVIDERS =====

/// User wisdom score provider (reactive, per user)
final userWisdomScoreProvider =
    FutureProvider.family<WisdomScore, String>((ref, userId) {
  final repository = ref.watch(wisdomRepositoryProvider);
  return repository.getWisdomScore(userId);
});

/// Leaderboard provider (overall)
final wisdomLeaderboardProvider = FutureProvider.family<
    List<WisdomScore>,
    ({
      int limit,
      String timeframe,
    })>((ref, params) {
  final repository = ref.watch(wisdomRepositoryProvider);
  return repository.getLeaderboard(
    limit: params.limit,
    timeframe: params.timeframe,
  );
});

/// Category leaderboard provider
final wisdomCategoryLeaderboardProvider = FutureProvider.family<
    List<WisdomScore>, ({String category, int limit, String timeframe})>(
  (ref, params) {
    final repository = ref.watch(wisdomRepositoryProvider);
    return repository.getLeaderboard(
      limit: params.limit,
      category: params.category,
      timeframe: params.timeframe,
    );
  },
);

/// Interaction ratings provider for a user
final interactionRatingsProvider =
    FutureProvider.family<List<InteractionRating>, String>((ref, userId) {
  final repository = ref.watch(wisdomRepositoryProvider);
  return repository.getInteractionRatings(userId: userId);
});

/// Endorsements provider for a user
final userEndorsementsProvider =
    FutureProvider.family<List<Endorsement>, String>((ref, userId) {
  final repository = ref.watch(wisdomRepositoryProvider);
  return repository.getUserEndorsements(userId);
});

/// Achievements provider for a user
final userAchievementsProvider =
    FutureProvider.family<List<Achievement>, String>((ref, userId) {
  final repository = ref.watch(wisdomRepositoryProvider);
  return repository.getUserAchievements(userId);
});

/// Achievement stats provider
final userAchievementStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) {
  final repository = ref.watch(wisdomRepositoryProvider);
  return repository.getAchievementStats(userId);
});
