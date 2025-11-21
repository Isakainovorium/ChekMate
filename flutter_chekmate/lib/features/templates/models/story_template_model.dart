import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'story_template_model.g.dart';

/// Story template category enumeration
enum StoryTemplateCategory {
  @JsonValue('first_date')
  firstDate('first_date', 'First Dates'),

  @JsonValue('ghosting_recovery')
  ghostingRecovery('ghosting_recovery', 'Ghosting Recovery'),

  @JsonValue('success_stories')
  successStories('success_stories', 'Success Stories'),

  @JsonValue('red_flags')
  redFlags('red_flags', 'Red Flags'),

  @JsonValue('pattern_recognition')
  patternRecognition('pattern_recognition', 'Pattern Recognition'),

  @JsonValue('breakup_recovery')
  breakupRecovery('breakup_recovery', 'Breakup Recovery'),

  @JsonValue('long_distance')
  longDistance('long_distance', 'Long Distance'),

  @JsonValue('online_dating')
  onlineDating('online_dating', 'Online Dating'),

  @JsonValue('polyamorous')
  polyamorous('polyamorous', 'Polyamorous Dating'),

  @JsonValue('post_divorce')
  postDivorce('post_divorce', 'Post-Divorce Dating');

  const StoryTemplateCategory(this.value, this.displayName);

  final String value;
  final String displayName;
}

/// Story template section - defines what fields to collect
enum StoryTemplateSectionType {
  @JsonValue('text_input')
  textInput('text_input', 'Text Input'),

  @JsonValue('rating')
  rating('rating', 'Rating'),

  @JsonValue('multiple_choice')
  multipleChoice('multiple_choice', 'Multiple Choice'),

  @JsonValue('yes_no')
  yesNo('yes_no', 'Yes/No Question'),

  @JsonValue('date_picker')
  datePicker('date_picker', 'Date Picker');

  const StoryTemplateSectionType(this.value, this.displayName);

  final String value;
  final String displayName;
}

/// Template section definition
@JsonSerializable()
class StoryTemplateSection extends Equatable {
  const StoryTemplateSection({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.placeholder,
    this.required = false,
    this.options,
    this.ratingScale,
    this.helpText,
    this.conditionalDisplay,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'type')
  final StoryTemplateSectionType type;

  @JsonKey(name: 'placeholder')
  final String? placeholder;

  @JsonKey(name: 'required')
  final bool required;

  @JsonKey(name: 'options')
  final List<String>? options; // For multiple choice

  @JsonKey(name: 'rating_scale')
  final RatingScale? ratingScale; // For ratings

  @JsonKey(name: 'help_text')
  final String? helpText;

  @JsonKey(name: 'conditional_display')
  final ConditionalDisplay? conditionalDisplay;

  factory StoryTemplateSection.fromJson(Map<String, dynamic> json) =>
      _$StoryTemplateSectionFromJson(json);

  Map<String, dynamic> toJson() => _$StoryTemplateSectionToJson(this);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        placeholder,
        required,
        options,
        ratingScale,
        helpText,
        conditionalDisplay,
      ];
}

/// Rating scale configuration
@JsonSerializable()
class RatingScale extends Equatable {
  const RatingScale({
    this.min = 1,
    this.max = 10,
    this.step = 1,
    this.labels,
  });

  @JsonKey(name: 'min')
  final int min;

  @JsonKey(name: 'max')
  final int max;

  @JsonKey(name: 'step')
  final int step;

  @JsonKey(name: 'labels')
  final Map<String, String>? labels; // e.g., {"1": "Disaster", "10": "Perfect"}

  factory RatingScale.fromJson(Map<String, dynamic> json) =>
      _$RatingScaleFromJson(json);

  Map<String, dynamic> toJson() => _$RatingScaleToJson(this);

  @override
  List<Object?> get props => [min, max, step, labels];
}

/// Conditional display logic
@JsonSerializable()
class ConditionalDisplay extends Equatable {
  const ConditionalDisplay({
    required this.dependsOn,
    required this.condition,
    this.value,
  });

  @JsonKey(name: 'depends_on')
  final String dependsOn; // ID of field this depends on

  @JsonKey(name: 'condition')
  final String condition; // 'equals', 'not_equals', 'contains', etc.

  @JsonKey(name: 'value')
  final dynamic value; // Value to check against

  factory ConditionalDisplay.fromJson(Map<String, dynamic> json) =>
      _$ConditionalDisplayFromJson(json);

  Map<String, dynamic> toJson() => _$ConditionalDisplayToJson(this);

  @override
  List<Object?> get props => [dependsOn, condition, value];
}

/// Story template definition
@JsonSerializable()
class StoryTemplate extends Equatable {
  const StoryTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.sections,
    required this.version,
    required this.isActive,
    this.coverImageUrl,
    this.tags = const [],
    this.usageCount = 0,
    this.averageRating = 0,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'category')
  final StoryTemplateCategory category;

  @JsonKey(name: 'icon')
  final String icon; // Material icon name

  @JsonKey(name: 'color')
  final String color; // Hex color code

  @JsonKey(name: 'difficulty')
  final String difficulty; // 'Beginner', 'Intermediate', 'Advanced'

  @JsonKey(name: 'estimated_minutes')
  final int estimatedMinutes;

  @JsonKey(name: 'sections')
  final List<StoryTemplateSection> sections;

  @JsonKey(name: 'version')
  final String version;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'cover_image_url')
  final String? coverImageUrl;

  @JsonKey(name: 'tags')
  final List<String> tags;

  @JsonKey(name: 'usage_count')
  final int usageCount;

  @JsonKey(name: 'average_rating')
  final double averageRating;

  @JsonKey(name: 'created_by')
  final String? createdBy;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(name: 'metadata')
  final Map<String, dynamic>? metadata;

  factory StoryTemplate.fromJson(Map<String, dynamic> json) =>
      _$StoryTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$StoryTemplateToJson(this);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        icon,
        color,
        difficulty,
        estimatedMinutes,
        sections,
        version,
        isActive,
        coverImageUrl,
        tags,
        usageCount,
        averageRating,
        createdBy,
        createdAt,
        updatedAt,
        metadata,
      ];
}

/// User response to a template section
@JsonSerializable()
class TemplateResponse extends Equatable {
  const TemplateResponse({
    required this.sectionId,
    required this.response,
    this.metadata,
    required this.timestamp,
  });

  @JsonKey(name: 'section_id')
  final String sectionId;

  @JsonKey(name: 'response')
  final dynamic response; // Can be String, int, bool, List, etc.

  @JsonKey(name: 'metadata')
  final Map<String, dynamic>? metadata;

  @JsonKey(name: 'timestamp')
  final DateTime timestamp;

  factory TemplateResponse.fromJson(Map<String, dynamic> json) =>
      _$TemplateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateResponseToJson(this);

  @override
  List<Object?> get props => [sectionId, response, metadata, timestamp];
}

/// User's filled-out template story
@JsonSerializable()
class UserStorySubmission extends Equatable {
  const UserStorySubmission({
    required this.id,
    required this.templateId,
    required this.userId,
    required this.responses,
    required this.title,
    required this.summary,
    this.tags = const [],
    this.privacy = 'friends', // 'public', 'friends', 'private'
    this.isCompleted = false,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.metadata,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'template_id')
  final String templateId;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'responses')
  final List<TemplateResponse> responses;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'summary')
  final String summary;

  @JsonKey(name: 'tags')
  final List<String> tags;

  @JsonKey(name: 'privacy')
  final String privacy;

  @JsonKey(name: 'is_completed')
  final bool isCompleted;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;

  @JsonKey(name: 'metadata')
  final Map<String, dynamic>? metadata;

  factory UserStorySubmission.fromJson(Map<String, dynamic> json) =>
      _$UserStorySubmissionFromJson(json);

  Map<String, dynamic> toJson() => _$UserStorySubmissionToJson(this);

  @override
  List<Object?> get props => [
        id,
        templateId,
        userId,
        responses,
        title,
        summary,
        tags,
        privacy,
        isCompleted,
        createdAt,
        updatedAt,
        completedAt,
        metadata,
      ];
}
