/// Message Entity - Domain Layer
///
/// Pure Dart class representing a message in the ChekMate app.
/// Contains no framework dependencies - only business logic.
///
/// Clean Architecture: Domain Layer
class MessageEntity {
  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.receiverId,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.imageUrl,
    this.videoUrl,
    this.voiceUrl,
    this.voiceDuration,
    this.readAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String receiverId;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final String? voiceUrl;
  final int? voiceDuration;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  // ========== BUSINESS LOGIC METHODS ==========

  /// Check if this message is a voice message
  bool get isVoiceMessage => voiceUrl != null && voiceUrl!.isNotEmpty;

  /// Check if this message is an image message
  bool get isImageMessage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Check if this message is a video message
  bool get isVideoMessage => videoUrl != null && videoUrl!.isNotEmpty;

  /// Check if this message has any media
  bool get hasMedia => isVoiceMessage || isImageMessage || isVideoMessage;

  /// Check if this message is a text-only message
  bool get isTextOnly => !hasMedia;

  /// Check if a specific user can delete this message
  /// Only the sender can delete their own messages
  bool canDelete(String currentUserId) {
    return senderId == currentUserId;
  }

  /// Check if this message is from a specific user
  bool isFromUser(String userId) {
    return senderId == userId;
  }

  /// Check if this message is to a specific user
  bool isToUser(String userId) {
    return receiverId == userId;
  }

  /// Get formatted time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Get formatted voice duration (e.g., "1:23")
  String get formattedVoiceDuration {
    if (voiceDuration == null) return '0:00';

    final minutes = voiceDuration! ~/ 60;
    final seconds = voiceDuration! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Create a copy with updated fields
  MessageEntity copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? receiverId,
    String? content,
    String? imageUrl,
    String? videoUrl,
    String? voiceUrl,
    int? voiceDuration,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      voiceUrl: voiceUrl ?? this.voiceUrl,
      voiceDuration: voiceDuration ?? this.voiceDuration,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  // ========== EQUALITY ==========

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MessageEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MessageEntity(id: $id, senderId: $senderId, receiverId: $receiverId, content: $content, isRead: $isRead, hasMedia: $hasMedia)';
  }
}

