import 'package:cloud_firestore/cloud_firestore.dart';

/// SerendipityRecommendationModel stores diverse content suggestions.
class SerendipityRecommendationModel {
  const SerendipityRecommendationModel({
    required this.userId,
    required this.contentIds,
    required this.diversityScore,
    required this.curatedModuleIds,
    required this.updatedAt,
  });

  final String userId;
  final List<String> contentIds;
  final double diversityScore;
  final List<String> curatedModuleIds;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'contentIds': contentIds,
      'diversityScore': diversityScore,
      'curatedModuleIds': curatedModuleIds,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory SerendipityRecommendationModel.fromJson(Map<String, dynamic> json) {
    return SerendipityRecommendationModel(
      userId: json['userId'] as String? ?? '',
      contentIds: (json['contentIds'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      diversityScore: (json['diversityScore'] as num?)?.toDouble() ?? 0.0,
      curatedModuleIds: (json['curatedModuleIds'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      updatedAt:
          (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.utc(1970),
    );
  }
}
