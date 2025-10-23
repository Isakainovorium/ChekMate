import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/messages/domain/entities/message_entity.dart';

/// Message Model - Data Layer
///
/// Extends MessageEntity and adds JSON/Firestore serialization.
/// Handles conversion between Firestore documents and domain entities.
///
/// Clean Architecture: Data Layer
class MessageModel extends MessageEntity {

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
      imageUrl: entity.imageUrl,
      videoUrl: entity.videoUrl,
      voiceUrl: entity.voiceUrl,
      voiceDuration: entity.voiceDuration,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
      readAt: entity.readAt,
    );
  }
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
    super.imageUrl,
    super.videoUrl,
    super.voiceUrl,
    super.voiceDuration,
    super.readAt,
  });

  /// Create MessageModel from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderAvatar: json['senderAvatar'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      voiceUrl: json['voiceUrl'] as String?,
      voiceDuration: json['voiceDuration'] as int?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      readAt: json['readAt'] != null
          ? (json['readAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create MessageModel from Firestore document
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  /// Convert MessageModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'receiverId': receiverId,
      'content': content,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (voiceUrl != null) 'voiceUrl': voiceUrl,
      if (voiceDuration != null) 'voiceDuration': voiceDuration,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
    };
  }

  /// Convert MessageModel to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // Remove id from Firestore document (it's stored as document ID)
    json.remove('id');
    return json;
  }

  /// Convert MessageModel to MessageEntity
  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      receiverId: receiverId,
      content: content,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      voiceUrl: voiceUrl,
      voiceDuration: voiceDuration,
      isRead: isRead,
      createdAt: createdAt,
      readAt: readAt,
    );
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
    String? imageUrl,
    String? videoUrl,
    String? voiceUrl,
    int? voiceDuration,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return MessageModel(
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
}

