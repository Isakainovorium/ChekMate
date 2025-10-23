import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/messages/domain/entities/conversation_entity.dart';

/// Conversation Model - Data Layer
///
/// Extends ConversationEntity and adds JSON/Firestore serialization.
/// Handles conversion between Firestore documents and domain entities.
///
/// Clean Architecture: Data Layer
class ConversationModel extends ConversationEntity {

  /// Create ConversationModel from ConversationEntity
  factory ConversationModel.fromEntity(ConversationEntity entity) {
    return ConversationModel(
      id: entity.id,
      participants: entity.participants,
      participantNames: entity.participantNames,
      participantAvatars: entity.participantAvatars,
      lastMessage: entity.lastMessage,
      lastMessageSenderId: entity.lastMessageSenderId,
      lastMessageTimestamp: entity.lastMessageTimestamp,
      unreadCount: entity.unreadCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
  const ConversationModel({
    required super.id,
    required super.participants,
    required super.participantNames,
    required super.participantAvatars,
    required super.lastMessage,
    required super.lastMessageSenderId,
    required super.lastMessageTimestamp,
    required super.unreadCount,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create ConversationModel from JSON
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      participants: List<String>.from(json['participantIds'] as List),
      participantNames:
          Map<String, String>.from(json['participantNames'] as Map),
      participantAvatars:
          Map<String, String>.from(json['participantAvatars'] as Map),
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageSenderId: json['lastMessageSenderId'] as String? ?? '',
      lastMessageTimestamp: json['lastMessageTime'] != null
          ? (json['lastMessageTime'] as Timestamp).toDate()
          : DateTime.now(),
      unreadCount: Map<String, int>.from(json['unreadCounts'] as Map),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Create ConversationModel from Firestore document
  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  /// Convert ConversationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participants,
      'participantNames': participantNames,
      'participantAvatars': participantAvatars,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': Timestamp.fromDate(lastMessageTimestamp),
      'unreadCounts': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convert ConversationModel to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // Remove id from Firestore document (it's stored as document ID)
    json.remove('id');
    return json;
  }

  /// Convert ConversationModel to ConversationEntity
  ConversationEntity toEntity() {
    return ConversationEntity(
      id: id,
      participants: participants,
      participantNames: participantNames,
      participantAvatars: participantAvatars,
      lastMessage: lastMessage,
      lastMessageSenderId: lastMessageSenderId,
      lastMessageTimestamp: lastMessageTimestamp,
      unreadCount: unreadCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create a copy with updated fields
  @override
  ConversationModel copyWith({
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
    return ConversationModel(
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
}

