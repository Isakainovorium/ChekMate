import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/search/domain/entities/search_result_entity.dart';

/// SearchResultModel - Data Model for Search Results
///
/// Handles serialization/deserialization for Firebase.
class SearchResultModel extends SearchResultEntity {
  /// From Entity
  factory SearchResultModel.fromEntity(SearchResultEntity entity) {
    return SearchResultModel(
      id: entity.id,
      type: entity.type,
      title: entity.title,
      subtitle: entity.subtitle,
      relevanceScore: entity.relevanceScore,
      imageUrl: entity.imageUrl,
      metadata: entity.metadata,
    );
  }
  const SearchResultModel({
    required super.id,
    required super.type,
    required super.title,
    required super.subtitle,
    required super.relevanceScore,
    super.imageUrl,
    super.metadata,
  });

  /// From JSON
  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id'] as String,
      type: _parseResultType(json['type'] as String?),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      relevanceScore: (json['relevanceScore'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': _resultTypeToString(type),
      'title': title,
      'subtitle': subtitle,
      'relevanceScore': relevanceScore,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  /// Parse result type from string
  static SearchResultType _parseResultType(String? type) {
    switch (type) {
      case 'user':
        return SearchResultType.user;
      case 'post':
        return SearchResultType.post;
      case 'hashtag':
        return SearchResultType.hashtag;
      case 'video':
        return SearchResultType.video;
      case 'image':
        return SearchResultType.image;
      case 'event':
        return SearchResultType.event;
      default:
        return SearchResultType.post;
    }
  }

  /// Convert result type to string
  static String _resultTypeToString(SearchResultType type) {
    switch (type) {
      case SearchResultType.user:
        return 'user';
      case SearchResultType.post:
        return 'post';
      case SearchResultType.hashtag:
        return 'hashtag';
      case SearchResultType.video:
        return 'video';
      case SearchResultType.image:
        return 'image';
      case SearchResultType.event:
        return 'event';
    }
  }
}

/// SearchFilterModel - Data Model for Search Filters
class SearchFilterModel extends SearchFilterEntity {
  /// From Entity
  factory SearchFilterModel.fromEntity(SearchFilterEntity entity) {
    return SearchFilterModel(
      id: entity.id,
      label: entity.label,
      itemCount: entity.count,
      isActive: entity.isActive,
    );
  }
  const SearchFilterModel({
    required super.id,
    required super.label,
    required int itemCount,
    super.isActive,
  }) : super(count: itemCount);

  /// From JSON
  factory SearchFilterModel.fromJson(Map<String, dynamic> json) {
    return SearchFilterModel(
      id: json['id'] as String,
      label: json['label'] as String,
      itemCount: json['count'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'count': count,
      'isActive': isActive,
    };
  }
}

/// SearchSuggestionModel - Data Model for Search Suggestions
class SearchSuggestionModel extends SearchSuggestionEntity {
  /// From Entity
  factory SearchSuggestionModel.fromEntity(SearchSuggestionEntity entity) {
    return SearchSuggestionModel(
      text: entity.text,
      type: entity.type,
      subtitle: entity.subtitle,
      metadata: entity.metadata,
    );
  }
  const SearchSuggestionModel({
    required super.text,
    required super.type,
    super.subtitle,
    super.metadata,
  });

  /// From JSON
  factory SearchSuggestionModel.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionModel(
      text: json['text'] as String,
      type: _parseSuggestionType(json['type'] as String?),
      subtitle: json['subtitle'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'type': _suggestionTypeToString(type),
      'subtitle': subtitle,
      'metadata': metadata,
    };
  }

  /// Parse suggestion type from string
  static SearchSuggestionType _parseSuggestionType(String? type) {
    switch (type) {
      case 'recent':
        return SearchSuggestionType.recent;
      case 'trending':
        return SearchSuggestionType.trending;
      case 'popular':
        return SearchSuggestionType.popular;
      case 'category':
        return SearchSuggestionType.category;
      default:
        return SearchSuggestionType.recent;
    }
  }

  /// Convert suggestion type to string
  static String _suggestionTypeToString(SearchSuggestionType type) {
    switch (type) {
      case SearchSuggestionType.recent:
        return 'recent';
      case SearchSuggestionType.trending:
        return 'trending';
      case SearchSuggestionType.popular:
        return 'popular';
      case SearchSuggestionType.category:
        return 'category';
    }
  }
}

/// RecentSearchModel - Data Model for Recent Searches
class RecentSearchModel extends RecentSearchEntity {
  /// From Entity
  factory RecentSearchModel.fromEntity(RecentSearchEntity entity) {
    return RecentSearchModel(
      query: entity.query,
      timestamp: entity.timestamp,
      resultCount: entity.resultCount,
    );
  }
  const RecentSearchModel({
    required super.query,
    required super.timestamp,
    super.resultCount,
  });

  /// From JSON
  factory RecentSearchModel.fromJson(Map<String, dynamic> json) {
    return RecentSearchModel(
      query: json['query'] as String,
      timestamp: _parseTimestamp(json['timestamp']),
      resultCount: json['resultCount'] as int? ?? 0,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'timestamp': Timestamp.fromDate(timestamp),
      'resultCount': resultCount,
    };
  }

  /// Parse Firestore Timestamp
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else {
      return DateTime.now();
    }
  }
}
