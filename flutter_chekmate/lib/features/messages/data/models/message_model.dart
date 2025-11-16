import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/messages/domain/entities/message_entity.dart';

/// Message Model - Data Layer
///
/// Data transfer object for message data.
/// Converts between domain entities and Firestore documents.
/// Extends MessageEntity to inherit business logic.
///
class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.senderName,
    required super.senderAvatar,
    required super.receiverId,
    required super.content,
    required super.isRead,
    required super.createdAt,
    super.voiceUrl,
    super.voiceDuration,
    super.imageUrl,
    super.videoUrl,
  });

  /// Get read timestamp (when message was marked as read)
  @override
  DateTime? get readAt {
    // In a real implementation, this would be stored in Firestore
    // For now, return null if not read, or createdAt + some time if read
    return isRead ? createdAt.add(const Duration(seconds: 30)) : null;
  }

  /// Check if message is text-only (no media)
  @override
  bool get isTextOnly => isTextMessage;

  /// Check if message can be deleted by current user
  @override
  bool canDelete(String currentUserId) {
    // User can delete their own messages within 24 hours
    final timeDiff = DateTime.now().difference(createdAt);
    return senderId == currentUserId && timeDiff.inHours < 24;
  }

  /// Create MessageModel from MessageEntity
  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      conversationId: entity.conversationId,
      senderId: entity.senderId,
      senderName: entity.senderName,
      senderAvatar: entity.senderAvatar,
      receiverId: entity.receiverId,
      content: entity.content,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
      voiceUrl: entity.voiceUrl,
      voiceDuration: entity.voiceDuration,
      imageUrl: entity.imageUrl,
      videoUrl: entity.videoUrl,
    );
  }

  /// Convert to MessageEntity
  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      receiverId: receiverId,
      content: content,
      isRead: isRead,
      createdAt: createdAt,
      voiceUrl: voiceUrl,
      voiceDuration: voiceDuration,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
    );
  }

  /// Create MessageModel from Firestore document
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel.fromJson(data);
  }

  /// Convert to JSON for Firestore (with id for updates)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'receiverId': receiverId,
      'content': content,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'voiceUrl': voiceUrl,
      'voiceDuration': voiceDuration,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
    };
  }

  /// Create MessageModel from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final timestamp = json['createdAt'];
    DateTime createdAt;

    if (timestamp is Timestamp) {
      createdAt = timestamp.toDate();
    } else if (timestamp is String) {
      createdAt = DateTime.parse(timestamp);
    } else {
      createdAt = DateTime.now();
    }

    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderAvatar: json['senderAvatar'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: createdAt,
      voiceUrl: json['voiceUrl'] as String?,
      voiceDuration: json['voiceDuration'] as int?,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
    );
  }

  /// Convert to Firestore data (excluding id for document creation)
  Map<String, dynamic> toFirestore() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'receiverId': receiverId,
      'content': content,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'voiceUrl': voiceUrl,
      'voiceDuration': voiceDuration,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
    };
  }

  /// Create a copy with updated fields
  @override
  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? receiverId,
    String? content,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    String? voiceUrl,
    int? voiceDuration,
    String? imageUrl,
    String? videoUrl,
  }) {
    return MessageModel(
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
}
