import 'package:cloud_firestore/cloud_firestore.dart';

/// ReadingEventModel captures granular learning-content interactions.
class ReadingEventModel {
  const ReadingEventModel({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.tags,
    required this.timeSpentMs,
    required this.completionPercent,
    required this.sentiment,
    required this.timestamp,
  });

  final String id;
  final String userId;
  final String contentId;
  final List<String> tags;
  final int timeSpentMs;
  final double completionPercent;
  final double sentiment;
  final DateTime timestamp;

  Map<String, dynamic> toJson() {
    return {
      'contentId': contentId,
      'userId': userId,
      'tags': tags,
      'timeSpentMs': timeSpentMs,
      'completionPercent': completionPercent,
      'sentiment': sentiment,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory ReadingEventModel.fromJson(
    String id,
    Map<String, dynamic> json,
  ) {
    return ReadingEventModel(
      id: id,
      userId: json['userId'] as String? ?? '',
      contentId: json['contentId'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((tag) => tag.toString())
          .toList(),
      timeSpentMs: (json['timeSpentMs'] as num?)?.toInt() ?? 0,
      completionPercent: (json['completionPercent'] as num?)?.toDouble() ?? 0.0,
      sentiment: (json['sentiment'] as num?)?.toDouble() ?? 0.0,
      timestamp:
          (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.utc(1970),
    );
  }
}
