import 'package:equatable/equatable.dart';

/// Search Result Type Enum
enum SearchResultType {
  user,
  post,
  hashtag,
  video,
  image,
  event,
}

/// Search Suggestion Type Enum
enum SearchSuggestionType {
  query,
  hashtag,
  user,
  recent,
  trending,
  popular,
  category,
}

/// Search Result Entity - Domain Layer
///
/// Represents a search result in the ChekMate application.
/// This is the domain model used throughout the search feature.
///
class SearchResultEntity extends Equatable {
  const SearchResultEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.relevanceScore,
    this.imageUrl,
    this.metadata,
    this.resultCount,
  });

  final String id;
  final SearchResultType type;
  final String title;
  final String subtitle;
  final double relevanceScore;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;
  final int? resultCount;

  /// Check if this result is highly relevant (relevance score > 0.8)
  bool get isHighlyRelevant => relevanceScore > 0.8;

  /// Get the appropriate icon for the result type
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

  /// Get the human-readable label for the result type
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

  /// Create a copy with updated fields
  SearchResultEntity copyWith({
    String? id,
    SearchResultType? type,
    String? title,
    String? subtitle,
    double? relevanceScore,
    String? imageUrl,
    Map<String, dynamic>? metadata,
    int? resultCount,
  }) {
    return SearchResultEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      relevanceScore: relevanceScore ?? this.relevanceScore,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
      resultCount: resultCount ?? this.resultCount,
    );
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
        resultCount,
      ];
}

/// Search Suggestion Entity
class SearchSuggestionEntity extends Equatable {
  const SearchSuggestionEntity({
    required this.text,
    required this.type,
    this.icon,
    this.relevanceScore = 0.0,
  });

  final String text;
  final SearchSuggestionType type;
  final String? icon;
  final double relevanceScore;

  @override
  List<Object?> get props => [text, type, icon, relevanceScore];
}

/// Recent Search Entity
class RecentSearchEntity extends Equatable {
  const RecentSearchEntity({
    required this.query,
    required this.timestamp,
    this.type = 'query',
    this.resultCount,
  });

  final String query;
  final DateTime timestamp;
  final String type;
  final int? resultCount;

  /// Get human-readable time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  List<Object?> get props => [query, timestamp, type, resultCount];
}

/// Search Filter Entity
class SearchFilterEntity extends Equatable {
  const SearchFilterEntity({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.isSelected = false,
    this.count,
    this.label,
    this.isActive = false,
  });

  final String id;
  final String name;
  final String type; // 'category', 'date', 'location', etc.
  final String? icon;
  final bool isSelected;
  final int? count;
  final String? label;
  final bool isActive;

  /// Get formatted count string
  String get formattedCount {
    if (count == null) return '';
    if (count! >= 1000000) {
      return '${(count! / 1000000).toStringAsFixed(1)}M';
    } else if (count! >= 1000) {
      return '${(count! / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  /// Create a copy with updated fields
  SearchFilterEntity copyWith({
    String? id,
    String? name,
    String? type,
    String? icon,
    bool? isSelected,
    int? count,
    String? label,
    bool? isActive,
  }) {
    return SearchFilterEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      isSelected: isSelected ?? this.isSelected,
      count: count ?? this.count,
      label: label ?? this.label,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, type, icon, isSelected, count, label, isActive];
}
