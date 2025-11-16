import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Search Result Entity
class SearchResult {
  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.isHighlyRelevant = false,
  });

  final String id;
  final String type; // 'user', 'post', 'hashtag'
  final String title;
  final String subtitle;
  final String? imageUrl;
  final bool isHighlyRelevant;

  SearchResult copyWith({
    String? id,
    String? type,
    String? title,
    String? subtitle,
    String? imageUrl,
    bool? isHighlyRelevant,
  }) {
    return SearchResult(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      isHighlyRelevant: isHighlyRelevant ?? this.isHighlyRelevant,
    );
  }
}

/// Search State
class SearchState {
  const SearchState({
    this.query = '',
    this.activeFilter = 'all',
    this.isLoading = false,
    this.error,
    this.recentSearches = const [],
  });

  final String query;
  final String activeFilter; // 'all', 'users', 'posts', 'hashtags'
  final bool isLoading;
  final String? error;
  final List<String> recentSearches;

  SearchState copyWith({
    String? query,
    String? activeFilter,
    bool? isLoading,
    String? error,
    List<String>? recentSearches,
  }) {
    return SearchState(
      query: query ?? this.query,
      activeFilter: activeFilter ?? this.activeFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }
}

/// Search State Provider
final searchStateProvider =
    StateNotifierProvider<SearchStateNotifier, SearchState>((ref) {
  return SearchStateNotifier();
});

/// Search State Notifier
class SearchStateNotifier extends StateNotifier<SearchState> {
  SearchStateNotifier() : super(const SearchState()) {
    _loadRecentSearches();
  }

  static const String _recentSearchesKey = 'recent_searches';

  /// Load recent searches from SharedPreferences
  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
      state = state.copyWith(recentSearches: recentSearches);
    } catch (e) {
      // Silently fail if loading fails - use empty list as default
    }
  }

  /// Save recent searches to SharedPreferences
  Future<void> _saveRecentSearches(List<String> searches) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentSearchesKey, searches);
    } catch (e) {
      // Silently fail if saving fails - data will be lost but app continues
    }
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearSearch() {
    state = const SearchState();
  }

  /// Save a recent search query
  Future<void> saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;

    final recentSearches = List<String>.from(state.recentSearches);

    // Remove if already exists (to move to front)
    recentSearches.remove(query);

    // Add to front
    recentSearches.insert(0, query);

    // Keep only last 10 searches
    if (recentSearches.length > 10) {
      recentSearches.removeRange(10, recentSearches.length);
    }

    state = state.copyWith(recentSearches: recentSearches);

    // Persist to local storage
    await _saveRecentSearches(recentSearches);
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    state = state.copyWith(recentSearches: const []);
    await _saveRecentSearches([]);
  }
}

/// Search Users Provider
final searchUsersProvider =
    StreamProvider.family<List<SearchResult>, String>((ref, query) {
  if (query.isEmpty) {
    return Stream.value([]);
  }

  final firestore = FirebaseFirestore.instance;
  final queryLower = query.toLowerCase();

  return firestore
      .collection('users')
      .where('username', isGreaterThanOrEqualTo: queryLower)
      .where('username', isLessThanOrEqualTo: '$queryLower\uf8ff')
      .limit(20)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SearchResult(
        id: doc.id,
        type: 'user',
        title: data['username'] as String? ?? '',
        subtitle: data['bio'] as String? ?? '',
        imageUrl: data['avatar'] as String?,
        isHighlyRelevant: (data['isVerified'] as bool?) ?? false,
      );
    }).toList();
  });
});

/// Search Posts Provider
final searchPostsProvider =
    StreamProvider.family<List<SearchResult>, String>((ref, query) {
  if (query.isEmpty) {
    return Stream.value([]);
  }

  final firestore = FirebaseFirestore.instance;
  final queryLower = query.toLowerCase();

  return firestore
      .collection('posts')
      .where('content', isGreaterThanOrEqualTo: queryLower)
      .where('content', isLessThanOrEqualTo: '$queryLower\uf8ff')
      .limit(20)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final images = (data['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [];
      return SearchResult(
        id: doc.id,
        type: 'post',
        title: data['username'] as String? ?? '',
        subtitle: data['content'] as String? ?? '',
        imageUrl: images.isNotEmpty ? images.first : null,
        isHighlyRelevant: (data['likes'] as int? ?? 0) > 100,
      );
    }).toList();
  });
});

/// Search Hashtags Provider
final searchHashtagsProvider =
    StreamProvider.family<List<SearchResult>, String>((ref, query) {
  if (query.isEmpty) {
    return Stream.value([]);
  }

  final firestore = FirebaseFirestore.instance;
  final queryLower = query.toLowerCase().replaceAll('#', '');

  return firestore
      .collection('hashtags')
      .where('tag', isGreaterThanOrEqualTo: queryLower)
      .where('tag', isLessThanOrEqualTo: '$queryLower\uf8ff')
      .limit(20)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SearchResult(
        id: doc.id,
        type: 'hashtag',
        title: '#${data['tag'] as String? ?? ''}',
        subtitle: '${data['count'] as int? ?? 0} posts',
        isHighlyRelevant: (data['count'] as int? ?? 0) > 50,
      );
    }).toList();
  });
});

/// Search All Provider (combines users, posts, and hashtags)
final searchAllProvider =
    FutureProvider.family<List<SearchResult>, String>((ref, query) async {
  if (query.isEmpty) {
    return [];
  }

  // Watch all search providers
  final usersAsync = ref.watch(searchUsersProvider(query));
  final postsAsync = ref.watch(searchPostsProvider(query));
  final hashtagsAsync = ref.watch(searchHashtagsProvider(query));

  // Wait for all results to load
  final users = usersAsync.when(
    data: (data) => data,
    loading: () => <SearchResult>[],
    error: (_, __) => <SearchResult>[],
  );

  final posts = postsAsync.when(
    data: (data) => data,
    loading: () => <SearchResult>[],
    error: (_, __) => <SearchResult>[],
  );

  final hashtags = hashtagsAsync.when(
    data: (data) => data,
    loading: () => <SearchResult>[],
    error: (_, __) => <SearchResult>[],
  );

  // Combine all results
  final allResults = <SearchResult>[
    ...users,
    ...posts,
    ...hashtags,
  ];

  // Sort by relevance
  allResults.sort((a, b) {
    if (a.isHighlyRelevant && !b.isHighlyRelevant) return -1;
    if (!a.isHighlyRelevant && b.isHighlyRelevant) return 1;
    return 0;
  });

  return allResults;
});

/// Search Filters
const List<String> searchFilters = [
  'all',
  'users',
  'posts',
  'hashtags',
];
