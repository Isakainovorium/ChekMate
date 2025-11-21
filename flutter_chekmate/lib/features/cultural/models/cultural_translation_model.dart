import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cultural_translation_model.g.dart';

/// Translation with cultural context preservation
@JsonSerializable()
class CulturalTranslation extends Equatable {
  const CulturalTranslation({
    required this.id,
    required this.originalContentId,
    required this.originalText,
    required this.translatedText,
    required this.sourceCulture,
    required this.targetCulture,
    this.culturalValidations = const {},
    required this.translationConfidence,
    this.preservedNuances = const [],
    this.warningFlags = const [],
    required this.createdAt,
    this.validatedBy,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'original_content_id')
  final String originalContentId;

  @JsonKey(name: 'original_text')
  final String originalText;

  @JsonKey(name: 'translated_text')
  final String translatedText;

  @JsonKey(name: 'source_culture')
  final String sourceCulture;

  @JsonKey(name: 'target_culture')
  final String targetCulture;

  @JsonKey(name: 'cultural_validations')
  final Map<String, dynamic> culturalValidations;

  @JsonKey(name: 'translation_confidence')
  final double translationConfidence; // 0.0-1.0

  @JsonKey(name: 'preserved_nuances')
  final List<String> preservedNuances;

  @JsonKey(name: 'warning_flags')
  final List<String> warningFlags;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'validated_by')
  final String? validatedBy; // Human validator ID

  factory CulturalTranslation.fromJson(Map<String, dynamic> json) =>
      _$CulturalTranslationFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalTranslationToJson(this);

  @override
  List<Object?> get props => [
        id,
        originalContentId,
        originalText,
        translatedText,
        sourceCulture,
        targetCulture,
        culturalValidations,
        translationConfidence,
        preservedNuances,
        warningFlags,
        createdAt,
        validatedBy,
      ];
}
