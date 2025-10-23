import 'package:flutter_chekmate/features/search/data/repositories/search_repository_impl.dart';
import 'package:flutter_chekmate/features/search/domain/entities/search_result_entity.dart';
import 'package:flutter_chekmate/features/search/domain/repositories/search_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Search Repository Provider
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepositoryImpl();
});

/// Search All Provider
final searchAllProvider = FutureProvider.autoDispose.family<List<SearchResultEntity>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];
    final repository = ref.watch(searchRepositoryProvider);
    return repository.searchAll(query);
  },
);

/// Search Users Provider
final searchUsersProvider = FutureProvider.autoDispose.family<List<SearchResultEntity>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];
    final repository = ref.watch(searchRepositoryProvider);
    return repository.searchUsers(query);
  },
);

/// Search Posts Provider
final searchPostsProvider = FutureProvider.autoDispose.family<List<SearchResultEntity>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];
    final repository = ref.watch(searchRepositoryProvider);
    return repository.searchPosts(query);
  },
);

/// Search Hashtags Provider
final searchHashtagsProvider = FutureProvider.autoDispose.family<List<SearchResultEntity>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];
    final repository = ref.watch(searchRepositoryProvider);
    return repository.searchHashtags(query);
  },
);

/// Search Suggestions Provider
final searchSuggestionsProvider = FutureProvider.autoDispose.family<List<SearchSuggestionEntity>, String>(
  (ref, query) async {
    final repository = ref.watch(searchRepositoryProvider);
    return repository.getSearchSuggestions(query);
  },
);

/// Recent Searches Provider
final recentSearchesProvider = FutureProvider.autoDispose<List<RecentSearchEntity>>((ref) async {
  final repository = ref.watch(searchRepositoryProvider);
  return repository.getRecentSearches();
});

/// Trending Searches Provider
final trendingSearchesProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final repository = ref.watch(searchRepositoryProvider);
  return repository.getTrendingSearches();
});

/// Search State Provider - Manages UI state
class SearchState {
  const SearchState({
    this.query = '',
    this.activeFilter = 'all',
    this.isSearching = false,
  });

  final String query;
  final String activeFilter;
  final bool isSearching;

  SearchState copyWith({
    String? query,
    String? activeFilter,
    bool? isSearching,
  }) {
    return SearchState(
      query: query ?? this.query,
      activeFilter: activeFilter ?? this.activeFilter,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

/// Search State Notifier
class SearchStateNotifier extends StateNotifier<SearchState> {
  SearchStateNotifier(this.ref) : super(const SearchState());

  final Ref ref;

  void setQuery(String query) {
    state = state.copyWith(query: query, isSearching: query.isNotEmpty);
  }

  void setActiveFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  void clearSearch() {
    state = state.copyWith(query: '', isSearching: false);
  }

  Future<void> saveRecentSearch(String query) async {
    final repository = ref.read(searchRepositoryProvider);
    await repository.saveRecentSearch(query);
  }

  Future<void> clearRecentSearches() async {
    final repository = ref.read(searchRepositoryProvider);
    await repository.clearRecentSearches();
    ref.invalidate(recentSearchesProvider);
  }

  Future<void> removeRecentSearch(String query) async {
    final repository = ref.read(searchRepositoryProvider);
    await repository.removeRecentSearch(query);
    ref.invalidate(recentSearchesProvider);
  }
}

/// Search State Provider
final searchStateProvider = StateNotifierProvider<SearchStateNotifier, SearchState>((ref) {
  return SearchStateNotifier(ref);
});

