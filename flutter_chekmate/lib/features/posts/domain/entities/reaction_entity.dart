/// ReactionEntity - Domain Layer
///
/// Represents a reaction (emoji) on a post or message.
/// Contains no framework dependencies - only business logic.
///
/// Clean Architecture: Domain Layer
class ReactionEntity {
  const ReactionEntity({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    required this.emoji,
    required this.createdAt,
    this.messageId,
  });

  final String id;
  final String postId;
  final String? messageId;
  final String userId;
  final String username;
  final String emoji;
  final DateTime createdAt;

  // ========== BUSINESS LOGIC METHODS ==========

  /// Check if this reaction is on a post
  bool get isPostReaction => messageId == null;

  /// Check if this reaction is on a message
  bool get isMessageReaction => messageId != null;

  /// Check if this reaction was created by a specific user
  bool isCreatedBy(String currentUserId) {
    return userId == currentUserId;
  }

  /// Check if this reaction is recent (created within last hour)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 1;
  }

  /// Get formatted time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Create a copy with updated fields
  ReactionEntity copyWith({
    String? id,
    String? postId,
    String? messageId,
    String? userId,
    String? username,
    String? emoji,
    DateTime? createdAt,
  }) {
    return ReactionEntity(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      messageId: messageId ?? this.messageId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ========== EQUALITY ==========

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReactionEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReactionEntity(id: $id, userId: $userId, emoji: $emoji, postId: $postId, messageId: $messageId)';
  }
}

/// ReactionSummary - Domain Layer
///
/// Aggregates reactions by emoji for display.
/// Shows count and users who reacted with each emoji.
class ReactionSummary {
  const ReactionSummary({
    required this.emoji,
    required this.count,
    required this.userIds,
    required this.usernames,
  });

  final String emoji;
  final int count;
  final List<String> userIds;
  final List<String> usernames;

  /// Check if a specific user has reacted with this emoji
  bool hasUserReacted(String userId) {
    return userIds.contains(userId);
  }

  /// Get display text for who reacted
  /// Examples:
  /// - "You"
  /// - "John"
  /// - "You and John"
  /// - "You, John and 5 others"
  String getReactedByText(String currentUserId) {
    if (count == 0) return '';

    final hasCurrentUser = hasUserReacted(currentUserId);
    final otherUsers = usernames.where((name) {
      final index = usernames.indexOf(name);
      return userIds[index] != currentUserId;
    }).toList();

    if (count == 1) {
      return hasCurrentUser ? 'You' : usernames.first;
    } else if (count == 2) {
      if (hasCurrentUser) {
        return 'You and ${otherUsers.first}';
      } else {
        return '${usernames[0]} and ${usernames[1]}';
      }
    } else {
      if (hasCurrentUser) {
        final othersCount = count - 1;
        if (othersCount == 1) {
          return 'You and ${otherUsers.first}';
        } else {
          return 'You, ${otherUsers.first} and ${othersCount - 1} others';
        }
      } else {
        return '${usernames[0]}, ${usernames[1]} and ${count - 2} others';
      }
    }
  }

  /// Create a copy with updated fields
  ReactionSummary copyWith({
    String? emoji,
    int? count,
    List<String>? userIds,
    List<String>? usernames,
  }) {
    return ReactionSummary(
      emoji: emoji ?? this.emoji,
      count: count ?? this.count,
      userIds: userIds ?? this.userIds,
      usernames: usernames ?? this.usernames,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReactionSummary && other.emoji == emoji;
  }

  @override
  int get hashCode => emoji.hashCode;

  @override
  String toString() {
    return 'ReactionSummary(emoji: $emoji, count: $count)';
  }
}

