/// Conversation Entity
/// Represents a conversation between users
class ConversationEntity {
  final String id;
  final String name;
  final String username;
  final String avatar;
  final String lastMessage;
  final DateTime timestamp;
  final bool unread;
  final bool online;
  final List<String> participantIds;

  const ConversationEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.avatar,
    required this.lastMessage,
    required this.timestamp,
    required this.unread,
    this.online = false,
    this.participantIds = const [],
  });

  /// Create a copy with updated fields
  ConversationEntity copyWith({
    String? id,
    String? name,
    String? username,
    String? avatar,
    String? lastMessage,
    DateTime? timestamp,
    bool? unread,
    bool? online,
    List<String>? participantIds,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      unread: unread ?? this.unread,
      online: online ?? this.online,
      participantIds: participantIds ?? this.participantIds,
    );
  }

  /// Get formatted timestamp
  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }

  /// Get last message timestamp (alias for timestamp)
  DateTime get lastMessageTimestamp => timestamp;

  /// Get other participant ID (assumes 2-person conversation)
  String getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  /// Get other participant name (alias for name)
  String getOtherParticipantName(String currentUserId) {
    return name;
  }

  /// Get other participant avatar (alias for avatar)
  String getOtherParticipantAvatar(String currentUserId) {
    return avatar;
  }

  /// Get unread count (returns 1 if unread, 0 if read)
  int getUnreadCount([String? currentUserId]) {
    return unread ? 1 : 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ConversationEntity(id: $id, name: $name, username: $username, lastMessage: $lastMessage, unread: $unread)';
  }
}
