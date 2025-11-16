import 'package:equatable/equatable.dart';

/// Message Entity - Domain Layer
///
/// Represents a message in a chat conversation.
/// This is the domain model used throughout the application.
///
class MessageEntity extends Equatable {
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
    this.voiceUrl,
    this.voiceDuration,
    this.imageUrl,
    this.videoUrl,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String receiverId;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final String? voiceUrl;
  final int? voiceDuration;
  final String? imageUrl;
  final String? videoUrl;

  /// Check if message is a voice message
  bool get isVoiceMessage => voiceUrl != null && voiceUrl!.isNotEmpty;

  /// Check if message is an image message
  bool get isImageMessage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Check if message is a video message
  bool get isVideoMessage => videoUrl != null && videoUrl!.isNotEmpty;

  /// Check if message has any media (voice, image, or video)
  bool get hasMedia => isVoiceMessage || isImageMessage || isVideoMessage;

  /// Check if message is a text message
  bool get isTextMessage => !hasMedia;

  /// Check if message is text-only (alias for isTextMessage)
  bool get isTextOnly => isTextMessage;

  /// Get formatted timestamp
  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      final hour = createdAt.hour > 12 ? createdAt.hour - 12 : createdAt.hour;
      final period = createdAt.hour >= 12 ? 'PM' : 'AM';
      return '${createdAt.month}/${createdAt.day} $hour:${createdAt.minute.toString().padLeft(2, '0')} $period';
    }
  }

  /// Get formatted voice duration (e.g., "0:45", "1:23")
  String? get formattedVoiceDuration {
    if (voiceDuration == null) return null;

    final minutes = voiceDuration! ~/ 60;
    final seconds = voiceDuration! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get time ago string (alias for formattedTimestamp)
  String get timeAgo => formattedTimestamp;

  /// Get read timestamp (when message was marked as read)
  DateTime? get readAt {
    // In a real implementation, this would be stored in the entity
    // For now, return null if not read, or createdAt + some time if read
    return isRead ? createdAt.add(const Duration(seconds: 30)) : null;
  }

  /// Check if message can be deleted by current user
  bool canDelete(String userId) {
    // User can delete their own messages within 24 hours
    final timeDiff = DateTime.now().difference(createdAt);
    return senderId == userId && timeDiff.inHours < 24;
  }

  /// Check if message is from specific user
  bool isFromUser(String userId) {
    return senderId == userId;
  }

  /// Check if message is to specific user
  bool isToUser(String userId) {
    return receiverId == userId;
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
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    String? voiceUrl,
    int? voiceDuration,
    String? imageUrl,
    String? videoUrl,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      voiceUrl: voiceUrl ?? this.voiceUrl,
      voiceDuration: voiceDuration ?? this.voiceDuration,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        senderName,
        senderAvatar,
        receiverId,
        content,
        isRead,
        createdAt,
        voiceUrl,
        voiceDuration,
        imageUrl,
        videoUrl,
      ];
}
