import 'package:equatable/equatable.dart';

/// SearchResultEntity - Domain Entity for Search Results
///
/// Represents a search result item that can be a user, post, hashtag, or other content.
///
/// Business Logic:
/// - Result type classification
/// - Relevance scoring
/// - Match highlighting
/// - Result ranking
class SearchResultEntity extends Equatable {
  const SearchResultEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.relevanceScore,
    this.imageUrl,
    this.metadata = const {},
  });

  final String id;
  final SearchResultType type;
  final String title;
  final String subtitle;
  final double relevanceScore;
  final String? imageUrl;
  final Map<String, dynamic> metadata;

  /// Check if result is highly relevant (score > 0.8)
  bool get isHighlyRelevant => relevanceScore > 0.8;

  /// Get result type icon
  String get typeIcon {
    switch (type) {
      case SearchResultType.user:
        return '👤';
      case SearchResultType.post:
        return '📝';
      case SearchResultType.hashtag:
        return '#️⃣';
      case SearchResultType.video:
        return '🎥';
      case SearchResultType.image:
        return '🖼️';
      case SearchResultType.event:
        return '📅';
    }
  }

  /// Get result type label
  String get typeLabel {
    switch (type) {
      case SearchResultType.user:
        return 'User';
      case SearchResultType.post:
        return 'Post';
      case SearchResultType.hashtag:
        return 'Hashtag';
      case SearchResultType.video:
        return 'Video';
      case SearchResultType.image:
        return 'Image';
      case SearchResultType.event:
        return 'Event';
    }
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        subtitle,
        relevanceScore,
        imageUrl,
        metadata,
      ];

  SearchResultEntity copyWith({
    String? id,
    SearchResultType? type,
    String? title,
    String? subtitle,
    double? relevanceScore,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return SearchResultEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      relevanceScore: relevanceScore ?? this.relevanceScore,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// SearchResultType - Type of search result
enum SearchResultType {
  user,
  post,
  hashtag,
  video,
  image,
  event,
}

/// SearchFilterEntity - Domain Entity for Search Filters
class SearchFilterEntity extends Equatable {
  const SearchFilterEntity({
    required this.id,
    required this.label,
    required this.count,
    this.isActive = false,
  });

  final String id;
  final String label;
  final int count;
  final bool isActive;

  /// Get formatted count
  String get formattedCount {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }

  @override
  List<Object?> get props => [id, label, count, isActive];

  SearchFilterEntity copyWith({
    String? id,
    String? label,
    int? count,
    bool? isActive,
  }) {
    return SearchFilterEntity(
      id: id ?? this.id,
      label: label ?? this.label,
      count: count ?? this.count,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// SearchSuggestionEntity - Domain Entity for Search Suggestions
class SearchSuggestionEntity extends Equatable {
  const SearchSuggestionEntity({
    required this.text,
    required this.type,
    this.subtitle,
    this.metadata = const {},
  });

  final String text;
  final SearchSuggestionType type;
  final String? subtitle;
  final Map<String, dynamic> metadata;

  /// Get suggestion icon
  String get icon {
    switch (type) {
      case SearchSuggestionType.recent:
        return '🕐';
      case SearchSuggestionType.trending:
        return '🔥';
      case SearchSuggestionType.popular:
        return '⭐';
      case SearchSuggestionType.category:
        return '📁';
    }
  }

  @override
  List<Object?> get props => [text, type, subtitle, metadata];
}

/// SearchSuggestionType - Type of search suggestion
enum SearchSuggestionType {
  recent,
  trending,
  popular,
  category,
}

/// RecentSearchEntity - Domain Entity for Recent Searches
class RecentSearchEntity extends Equatable {
  const RecentSearchEntity({
    required this.query,
    required this.timestamp,
    this.resultCount = 0,
  });

  final String query;
  final DateTime timestamp;
  final int resultCount;

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  @override
  List<Object?> get props => [query, timestamp, resultCount];
}

