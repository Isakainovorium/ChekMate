import 'package:flutter_chekmate/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:flutter_chekmate/features/explore/domain/entities/explore_content_entity.dart';
import 'package:flutter_chekmate/features/explore/domain/repositories/explore_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Explore Repository Provider
final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  return ExploreRepositoryImpl();
});

/// Trending Content Provider
final trendingContentProvider =
    FutureProvider.autoDispose<List<ExploreContentEntity>>((ref) async {
  final repository = ref.watch(exploreRepositoryProvider);
  return repository.getTrendingContent();
});

/// Popular Content Provider
final popularContentProvider =
    FutureProvider.autoDispose<List<ExploreContentEntity>>((ref) async {
  final repository = ref.watch(exploreRepositoryProvider);
  return repository.getPopularContent();
});

/// Trending Hashtags Provider
final trendingHashtagsProvider =
    FutureProvider.autoDispose<List<HashtagEntity>>((ref) async {
  final repository = ref.watch(exploreRepositoryProvider);
  return repository.getTrendingHashtags();
});

/// Suggested Users Provider
final suggestedUsersProvider =
    FutureProvider.autoDispose<List<SuggestedUserEntity>>((ref) async {
  final repository = ref.watch(exploreRepositoryProvider);
  return repository.getSuggestedUsers();
});

/// Content by Hashtag Provider
final contentByHashtagProvider =
    FutureProvider.autoDispose.family<List<ExploreContentEntity>, String>(
  (ref, hashtag) async {
    final repository = ref.watch(exploreRepositoryProvider);
    return repository.getContentByHashtag(hashtag);
  },
);

/// Content by Category Provider
final contentByCategoryProvider =
    FutureProvider.autoDispose.family<List<ExploreContentEntity>, String>(
  (ref, category) async {
    final repository = ref.watch(exploreRepositoryProvider);
    return repository.getContentByCategory(category);
  },
);

/// Search Content Provider
final searchContentProvider =
    FutureProvider.autoDispose.family<List<ExploreContentEntity>, String>(
  (ref, query) async {
    final repository = ref.watch(exploreRepositoryProvider);
    return repository.searchContent(query);
  },
);

/// Explore Stats Provider
final exploreStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(exploreRepositoryProvider);
  return repository.getExploreStats();
});

/// Explore State Provider - Manages UI state
class ExploreState {
  const ExploreState({
    this.activeCategory = 'trending',
    this.searchQuery = '',
    this.followedUsers = const {},
  });

  final String activeCategory;
  final String searchQuery;
  final Set<String> followedUsers;

  ExploreState copyWith({
    String? activeCategory,
    String? searchQuery,
    Set<String>? followedUsers,
  }) {
    return ExploreState(
      activeCategory: activeCategory ?? this.activeCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      followedUsers: followedUsers ?? this.followedUsers,
    );
  }
}

/// Explore State Notifier
class ExploreStateNotifier extends StateNotifier<ExploreState> {
  ExploreStateNotifier() : super(const ExploreState());

  void setActiveCategory(String category) {
    state = state.copyWith(activeCategory: category);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleFollowUser(String userId) {
    final followedUsers = Set<String>.from(state.followedUsers);
    if (followedUsers.contains(userId)) {
      followedUsers.remove(userId);
    } else {
      followedUsers.add(userId);
    }
    state = state.copyWith(followedUsers: followedUsers);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }
}

/// Explore State Provider
final exploreStateProvider =
    StateNotifierProvider<ExploreStateNotifier, ExploreState>((ref) {
  return ExploreStateNotifier();
});
