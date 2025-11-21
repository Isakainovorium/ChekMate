import 'package:cloud_firestore/cloud_firestore.dart';

/// ContextualFollowSuggestionModel stores smart follow recommendations.
class ContextualFollowSuggestionModel {
  const ContextualFollowSuggestionModel({
    required this.userId,
    required this.suggestedUserId,
    required this.reason,
    required this.similarityScore,
    required this.matchType,
    required this.sharedAttributes,
    required this.createdAt,
  });

  final String userId;
  final String suggestedUserId;
  final String reason;
  final double similarityScore;
  final MatchType matchType;
  final List<String> sharedAttributes;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'suggestedUserId': suggestedUserId,
      'reason': reason,
      'similarityScore': similarityScore,
      'matchType': matchType.name,
      'sharedAttributes': sharedAttributes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ContextualFollowSuggestionModel.fromJson(Map<String, dynamic> json) {
    return ContextualFollowSuggestionModel(
      userId: json['userId'] as String? ?? '',
      suggestedUserId: json['suggestedUserId'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      similarityScore: (json['similarityScore'] as num?)?.toDouble() ?? 0.0,
      matchType: MatchType.values.firstWhere(
        (e) => e.name == (json['matchType'] as String? ?? ''),
        orElse: () => MatchType.general,
      ),
      sharedAttributes: (json['sharedAttributes'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      createdAt:
          (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.utc(1970),
    );
  }
}

/// Match types for contextual suggestions
enum MatchType {
  journeyMatch,
  topicCluster,
  experienceCorrelation,
  general,
}
