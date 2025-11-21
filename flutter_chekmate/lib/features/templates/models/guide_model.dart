import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'guide_model.g.dart';

/// Guide category enumeration for different types of dating advice
enum GuideCategory {
  @JsonValue('long_distance')
  longDistance('long_distance', 'Long Distance Dating'),

  @JsonValue('polyamorous')
  polyamorous('polyamorous', 'Polyamorous Dating'),

  @JsonValue('post_divorce')
  postDivorce('post_divorce', 'Post-Divorce Dating'),

  @JsonValue('ghosting_recovery')
  ghostingRecovery('ghosting_recovery', 'Ghosting Recovery'),

  @JsonValue('age_gap')
  ageGap('age_gap', 'Age Gap Relationships'),

  @JsonValue('cultural_differences')
  culturalDifferences('cultural_differences', 'Cultural Dating'),

  @JsonValue('online_safety')
  onlineSafety('online_safety', 'Online Dating Safety'),

  @JsonValue('communication')
  communication('communication', 'Communication Skills'),

  @JsonValue('red_flags')
  redFlags('red_flags', 'Red Flags & Warning Signs'),

  @JsonValue('relationship_building')
  relationshipBuilding(
      'relationship_building', 'Building Healthy Relationships');

  const GuideCategory(this.value, this.displayName);

  final String value;
  final String displayName;
}

/// Guide difficulty level
enum GuideDifficulty {
  @JsonValue('beginner')
  beginner('beginner', 'Beginner'),

  @JsonValue('intermediate')
  intermediate('intermediate', 'Intermediate'),

  @JsonValue('advanced')
  advanced('advanced', 'Advanced');

  const GuideDifficulty(this.value, this.displayName);

  final String value;
  final String displayName;
}

/// Guide content section
@JsonSerializable()
class GuideSection extends Equatable {
  const GuideSection({
    required this.id,
    required this.title,
    required this.content,
    this.order = 0,
    this.estimatedMinutes = 5,
    this.isRequired = true,
    this.mediaUrls,
    this.actionItems,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'content')
  final String content;

  @JsonKey(name: 'order')
  final int order;

  @JsonKey(name: 'estimated_minutes')
  final int estimatedMinutes;

  @JsonKey(name: 'is_required')
  final bool isRequired;

  @JsonKey(name: 'media_urls')
  final List<String>? mediaUrls;

  @JsonKey(name: 'action_items')
  final List<String>? actionItems;

  factory GuideSection.fromJson(Map<String, dynamic> json) =>
      _$GuideSectionFromJson(json);

  Map<String, dynamic> toJson() => _$GuideSectionToJson(this);

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        order,
        estimatedMinutes,
        isRequired,
        mediaUrls,
        actionItems,
      ];
}

/// Community guide definition
@JsonSerializable()
class Guide extends Equatable {
  const Guide({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.icon,
    required this.color,
    required this.sections,
    required this.estimatedMinutes,
    required this.version,
    required this.isPublished,
    this.coverImageUrl,
    this.tags = const [],
    this.viewCount = 0,
    this.helpfulVotes = 0,
    this.totalVotes = 0,
    this.averageRating = 0,
    this.createdBy,
    this.authorName,
    required this.createdAt,
    this.updatedAt,
    this.publishedAt,
    this.metadata,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'category')
  final GuideCategory category;

  @JsonKey(name: 'difficulty')
  final GuideDifficulty difficulty;

  @JsonKey(name: 'icon')
  final String icon; // Material icon name

  @JsonKey(name: 'color')
  final String color; // Hex color code

  @JsonKey(name: 'sections')
  final List<GuideSection> sections;

  @JsonKey(name: 'estimated_minutes')
  final int estimatedMinutes;

  @JsonKey(name: 'version')
  final String version;

  @JsonKey(name: 'is_published')
  final bool isPublished;

  @JsonKey(name: 'cover_image_url')
  final String? coverImageUrl;

  @JsonKey(name: 'tags')
  final List<String> tags;

  @JsonKey(name: 'view_count')
  final int viewCount;

  @JsonKey(name: 'helpful_votes')
  final int helpfulVotes;

  @JsonKey(name: 'total_votes')
  final int totalVotes;

  @JsonKey(name: 'average_rating')
  final double averageRating;

  @JsonKey(name: 'created_by')
  final String? createdBy;

  @JsonKey(name: 'author_name')
  final String? authorName;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;

  @JsonKey(name: 'metadata')
  final Map<String, dynamic>? metadata;

  factory Guide.fromJson(Map<String, dynamic> json) => _$GuideFromJson(json);

  Map<String, dynamic> toJson() => _$GuideToJson(this);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        difficulty,
        icon,
        color,
        sections,
        estimatedMinutes,
        version,
        isPublished,
        coverImageUrl,
        tags,
        viewCount,
        helpfulVotes,
        totalVotes,
        averageRating,
        createdBy,
        authorName,
        createdAt,
        updatedAt,
        publishedAt,
        metadata,
      ];
}

/// User-specific guide instance
@JsonSerializable()
class UserGuide extends Equatable {
  const UserGuide({
    required this.id,
    required this.guideId,
    required this.userId,
    required this.progress,
    this.bookmarks = const [],
    this.completedSections = const [],
    this.notes = const {},
    this.rating,
    this.review,
    required this.startedAt,
    this.completedAt,
    this.lastAccessedAt,
    this.reminderEnabled = false,
    this.metadata,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'guide_id')
  final String guideId;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'progress')
  final double progress; // 0.0 to 1.0

  @JsonKey(name: 'bookmarks')
  final List<String> bookmarks; // Section IDs

  @JsonKey(name: 'completed_sections')
  final List<String> completedSections; // Section IDs

  @JsonKey(name: 'notes')
  final Map<String, String> notes; // Section ID -> user notes

  @JsonKey(name: 'rating')
  final int? rating; // 1-5 stars

  @JsonKey(name: 'review')
  final String? review;

  @JsonKey(name: 'started_at')
  final DateTime startedAt;

  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;

  @JsonKey(name: 'last_accessed_at')
  final DateTime? lastAccessedAt;

  @JsonKey(name: 'reminder_enabled')
  final bool reminderEnabled;

  @JsonKey(name: 'metadata')
  final Map<String, dynamic>? metadata;

  factory UserGuide.fromJson(Map<String, dynamic> json) =>
      _$UserGuideFromJson(json);

  Map<String, dynamic> toJson() => _$UserGuideToJson(this);

  @override
  List<Object?> get props => [
        id,
        guideId,
        userId,
        progress,
        bookmarks,
        completedSections,
        notes,
        rating,
        review,
        startedAt,
        completedAt,
        lastAccessedAt,
        reminderEnabled,
        metadata,
      ];
}

/// Guide vote/review by community member
@JsonSerializable()
class GuideVote extends Equatable {
  const GuideVote({
    required this.id,
    required this.guideId,
    required this.userId,
    required this.isHelpful,
    this.rating,
    this.reviewComment,
    required this.createdAt,
    this.metadata,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'guide_id')
  final String guideId;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'is_helpful')
  final bool isHelpful;

  @JsonKey(name: 'rating')
  final int? rating; // 1-5 stars

  @JsonKey(name: 'review_comment')
  final String? reviewComment;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'metadata')
  final Map<String, dynamic>? metadata;

  factory GuideVote.fromJson(Map<String, dynamic> json) =>
      _$GuideVoteFromJson(json);

  Map<String, dynamic> toJson() => _$GuideVoteToJson(this);

  @override
  List<Object?> get props => [
        id,
        guideId,
        userId,
        isHelpful,
        rating,
        reviewComment,
        createdAt,
        metadata,
      ];
}
