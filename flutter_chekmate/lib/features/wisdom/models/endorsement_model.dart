import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'wisdom_score_model.dart';

part 'endorsement_model.g.dart';

/// Endorsement badge type
enum EndorsementBadge {
  @JsonValue('relationship_coach')
  relationshipCoach('relationship_coach', 'Relationship Coach', 'Expert in relationship dynamics'),

  @JsonValue('compatibility_expert')
  compatibilityExpert('compatibility_expert', 'Compatibility Expert', 'Skilled at identifying compatibility'),

  @JsonValue('safety_advocate')
  safetyAdvocate('safety_advocate', 'Safety Advocate', 'Dedicated to dating safety'),

  @JsonValue('communication_master')
  communicationMaster('communication_master', 'Communication Master', 'Expert communicator'),

  @JsonValue('emotional_guide')
  emotionalGuide('emotional_guide', 'Emotional Guide', 'Helps with emotional intelligence'),

  @JsonValue('conflict_resolver')
  conflictResolver('conflict_resolver', 'Conflict Resolver', 'Skilled at resolving conflicts'),

  @JsonValue('cultural_bridge')
  culturalBridge('cultural_bridge', 'Cultural Bridge', 'Bridges cultural differences'),

  @JsonValue('mentor_extraordinaire')
  mentorExtraordinaire('mentor_extraordinaire', 'Mentor Extraordinaire', 'Exceptional mentor');

  const EndorsementBadge(this.value, this.displayName, this.description);

  final String value;
  final String displayName;
  final String description;
}

/// User endorsement
@JsonSerializable()
class Endorsement extends Equatable {
  const Endorsement({
    required this.id,
    required this.userId,
    required this.endorsedUserId,
    required this.badge,
    required this.category,
    required this.endorserCount,
    required this.isActive,
    required this.createdAt,
    this.expiresAt,
    this.metadata,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'user_id')
  final String userId; // Who is being endorsed

  @JsonKey(name: 'endorsed_user_id')
  final String endorsedUserId; // Duplicate for clarity

  @JsonKey(name: 'badge')
  final EndorsementBadge badge;

  @JsonKey(name: 'category')
  final WisdomCategory category;

  @JsonKey(name: 'endorser_count')
  final int endorserCount; // How many people endorsed this

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt; // Optional expiration

  @JsonKey(name: 'metadata')
  final Map<String, dynamic>? metadata;

  factory Endorsement.fromJson(Map<String, dynamic> json) =>
      _$EndorsementFromJson(json);

  Map<String, dynamic> toJson() => _$EndorsementToJson(this);

  /// Check if endorsement is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        endorsedUserId,
        badge,
        category,
        endorserCount,
        isActive,
        createdAt,
        expiresAt,
        metadata,
      ];
}

/// Endorsement vote (who endorsed)
@JsonSerializable()
class EndorsementVote extends Equatable {
  const EndorsementVote({
    required this.id,
    required this.endorsementId,
    required this.endorserId,
    required this.endorsedUserId,
    required this.badge,
    required this.cost,
    required this.createdAt,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'endorsement_id')
  final String endorsementId;

  @JsonKey(name: 'endorser_id')
  final String endorserId; // Who is endorsing

  @JsonKey(name: 'endorsed_user_id')
  final String endorsedUserId; // Who is being endorsed

  @JsonKey(name: 'badge')
  final EndorsementBadge badge;

  @JsonKey(name: 'cost')
  final int cost; // Token cost to endorse

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  factory EndorsementVote.fromJson(Map<String, dynamic> json) =>
      _$EndorsementVoteFromJson(json);

  Map<String, dynamic> toJson() => _$EndorsementVoteToJson(this);

  @override
  List<Object?> get props => [
        id,
        endorsementId,
        endorserId,
        endorsedUserId,
        badge,
        cost,
        createdAt,
      ];
}
