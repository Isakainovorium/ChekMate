import 'package:cloud_firestore/cloud_firestore.dart';

/// UserBehaviorProfileModel surfaces smart reading insights.
class UserBehaviorProfileModel {
  const UserBehaviorProfileModel({
    required this.userId,
    required this.topCategories,
    required this.categoryWeights,
    required this.emotionalAffinity,
    required this.learningPaceScore,
    required this.recommendedTags,
    required this.updatedAt,
  });

  final String userId;
  final List<String> topCategories;
  final Map<String, double> categoryWeights;
  final double emotionalAffinity;
  final double learningPaceScore;
  final List<String> recommendedTags;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'topCategories': topCategories,
      'categoryWeights': categoryWeights,
      'emotionalAffinity': emotionalAffinity,
      'learningPaceScore': learningPaceScore,
      'recommendedTags': recommendedTags,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserBehaviorProfileModel.fromJson(Map<String, dynamic> json) {
    final weights = <String, double>{};
    final map = json['categoryWeights'] as Map<String, dynamic>? ?? {};
    map.forEach((key, value) {
      weights[key] = (value as num).toDouble();
    });

    return UserBehaviorProfileModel(
      userId: json['userId'] as String? ?? '',
      topCategories: (json['topCategories'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      categoryWeights: weights,
      emotionalAffinity: (json['emotionalAffinity'] as num?)?.toDouble() ?? 0,
      learningPaceScore: (json['learningPaceScore'] as num?)?.toDouble() ?? 0,
      recommendedTags: (json['recommendedTags'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      updatedAt:
          (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.utc(1970),
    );
  }
}
