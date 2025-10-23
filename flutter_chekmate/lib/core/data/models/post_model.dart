import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  const PostModel({
    required this.id,
    required this.authorId,
    required this.createdAt,
    required this.updatedAt,
    this.content,
    this.mediaUrls = const [],
    this.mediaType = 'none',
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.bookmarksCount = 0,
    this.likedBy = const [],
    this.bookmarkedBy = const [],
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      authorId: data['authorId'] as String,
      content: data['content'] as String?,
      mediaUrls: List<String>.from(data['mediaUrls'] as List? ?? []),
      mediaType: data['mediaType'] as String? ?? 'none',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      likesCount: data['likesCount'] as int? ?? 0,
      commentsCount: data['commentsCount'] as int? ?? 0,
      sharesCount: data['sharesCount'] as int? ?? 0,
      bookmarksCount: data['bookmarksCount'] as int? ?? 0,
      likedBy: List<String>.from(data['likedBy'] as List? ?? []),
      bookmarkedBy: List<String>.from(data['bookmarkedBy'] as List? ?? []),
    );
  }
  final String id;
  final String authorId;
  final String? content;
  final List<String> mediaUrls;
  final String mediaType; // 'image', 'video', 'none'
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int bookmarksCount;
  final List<String> likedBy;
  final List<String> bookmarkedBy;

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'content': content,
      'mediaUrls': mediaUrls,
      'mediaType': mediaType,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'bookmarksCount': bookmarksCount,
      'likedBy': likedBy,
      'bookmarkedBy': bookmarkedBy,
    };
  }

  PostModel copyWith({
    String? id,
    String? authorId,
    String? content,
    List<String>? mediaUrls,
    String? mediaType,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? bookmarksCount,
    List<String>? likedBy,
    List<String>? bookmarkedBy,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      mediaType: mediaType ?? this.mediaType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      bookmarksCount: bookmarksCount ?? this.bookmarksCount,
      likedBy: likedBy ?? this.likedBy,
      bookmarkedBy: bookmarkedBy ?? this.bookmarkedBy,
    );
  }
}
