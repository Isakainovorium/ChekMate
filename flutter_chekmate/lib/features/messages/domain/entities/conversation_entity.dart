/// Conversation Entity - Domain Layer
///
/// Pure Dart class representing a conversation in the ChekMate app.
/// Contains no framework dependencies - only business logic.
///
/// Clean Architecture: Domain Layer
class ConversationEntity {
  const ConversationEntity({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.participantAvatars,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.lastMessageTimestamp,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final Map<String, String> participantAvatars;
  final String lastMessage;
  final String lastMessageSenderId;
  final DateTime lastMessageTimestamp;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ========== BUSINESS LOGIC METHODS ==========

  /// Get the other participant's ID in a 1-on-1 conversation
  String? getOtherParticipantId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  /// Get the other participant's name
  String getOtherParticipantName(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    if (otherId == null || otherId.isEmpty) return 'Unknown';
    return participantNames[otherId] ?? 'Unknown';
  }

  /// Get the other participant's avatar
  String getOtherParticipantAvatar(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    if (otherId == null || otherId.isEmpty) return '';
    return participantAvatars[otherId] ?? '';
  }

  /// Get unread count for a specific user
  int getUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }

  /// Check if conversation has unread messages for a user
  bool hasUnreadMessages(String userId) {
    return getUnreadCount(userId) > 0;
  }

  /// Check if the last message was sent by a specific user
  bool wasLastMessageFromUser(String userId) {
    return lastMessageSenderId == userId;
  }

  /// Get formatted time ago string for last message
  String get lastMessageTimeAgo {
    final now = DateTime.now();
    final difference = now.difference(lastMessageTimestamp);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Now';
    }
  }

  /// Create a copy with updated fields
  ConversationEntity copyWith({
    String? id,
    List<String>? participants,
    Map<String, String>? participantNames,
    Map<String, String>? participantAvatars,
    String? lastMessage,
    String? lastMessageSenderId,
    DateTime? lastMessageTimestamp,
    Map<String, int>? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      participantNames: participantNames ?? this.participantNames,
      participantAvatars: participantAvatars ?? this.participantAvatars,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ========== EQUALITY ==========

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConversationEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ConversationEntity(id: $id, participants: $participants, lastMessage: $lastMessage)';
  }
}

