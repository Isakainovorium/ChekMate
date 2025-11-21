import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cultural_norms_model.g.dart';

/// Cultural norms and expectations for a region
@JsonSerializable()
class CulturalNorms extends Equatable {
  const CulturalNorms({
    required this.id,
    required this.region,
    required this.category,
    required this.norms,
    this.examples = const [],
    this.dosList = const [],
    this.dontsList = const [],
    this.severity,
    this.sources = const [],
    required this.lastValidated,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'region')
  final String region;

  @JsonKey(name: 'category')
  final NormCategory category;

  @JsonKey(name: 'norms')
  final Map<String, dynamic> norms;

  @JsonKey(name: 'examples')
  final List<String> examples;

  @JsonKey(name: 'dos_list')
  final List<String> dosList;

  @JsonKey(name: 'donts_list')
  final List<String> dontsList;

  @JsonKey(name: 'severity')
  final NormSeverity? severity;

  @JsonKey(name: 'sources')
  final List<String> sources; // References/citations

  @JsonKey(name: 'last_validated')
  final DateTime lastValidated;

  factory CulturalNorms.fromJson(Map<String, dynamic> json) =>
      _$CulturalNormsFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalNormsToJson(this);

  @override
  List<Object?> get props => [
        id,
        region,
        category,
        norms,
        examples,
        dosList,
        dontsList,
        severity,
        sources,
        lastValidated,
      ];
}

/// Norm category classification
enum NormCategory {
  @JsonValue('dating_etiquette')
  datingEtiquette,

  @JsonValue('communication')
  communication,

  @JsonValue('physical_boundaries')
  physicalBoundaries,

  @JsonValue('relationship_progression')
  relationshipProgression,

  @JsonValue('family_involvement')
  familyInvolvement,

  @JsonValue('gender_roles')
  genderRoles,

  @JsonValue('religious_considerations')
  religiousConsiderations,

  @JsonValue('social_expectations')
  socialExpectations;

  String get displayName {
    switch (this) {
      case NormCategory.datingEtiquette:
        return 'Dating Etiquette';
      case NormCategory.communication:
        return 'Communication';
      case NormCategory.physicalBoundaries:
        return 'Physical Boundaries';
      case NormCategory.relationshipProgression:
        return 'Relationship Progression';
      case NormCategory.familyInvolvement:
        return 'Family Involvement';
      case NormCategory.genderRoles:
        return 'Gender Roles';
      case NormCategory.religiousConsiderations:
        return 'Religious Considerations';
      case NormCategory.socialExpectations:
        return 'Social Expectations';
    }
  }
}

/// Severity of norm violation
enum NormSeverity {
  @JsonValue('low')
  low,

  @JsonValue('medium')
  medium,

  @JsonValue('high')
  high,

  @JsonValue('critical')
  critical;

  String get displayName {
    switch (this) {
      case NormSeverity.low:
        return 'Low';
      case NormSeverity.medium:
        return 'Medium';
      case NormSeverity.high:
        return 'High';
      case NormSeverity.critical:
        return 'Critical';
    }
  }
}
