import 'package:flutter_chekmate/features/messages/data/datasources/messages_remote_datasource.dart';
import 'package:flutter_chekmate/features/messages/domain/entities/conversation_entity.dart';
import 'package:flutter_chekmate/features/messages/domain/entities/message_entity.dart';
import 'package:flutter_chekmate/features/messages/domain/repositories/messages_repository.dart';

/// Messages Repository Implementation - Data Layer
///
/// Implements the MessagesRepository interface.
/// Delegates to MessagesRemoteDataSource for Firebase operations.
/// Converts models to entities.
///
/// Clean Architecture: Data Layer
class MessagesRepositoryImpl implements MessagesRepository {
  const MessagesRepositoryImpl(this._remoteDataSource);

  final MessagesRemoteDataSource _remoteDataSource;

  @override
  Future<String> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String receiverId,
    required String content,
  }) {
    return _remoteDataSource.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      receiverId: receiverId,
      content: content,
    );
  }

  @override
  Future<String> sendVoiceMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String receiverId,
    required String voiceUrl,
    required int voiceDuration,
  }) {
    return _remoteDataSource.sendVoiceMessage(
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      receiverId: receiverId,
      voiceUrl: voiceUrl,
      voiceDuration: voiceDuration,
    );
  }

  @override
  Future<String> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String receiverId,
    required String imageUrl,
  }) {
    return _remoteDataSource.sendImageMessage(
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      receiverId: receiverId,
      imageUrl: imageUrl,
    );
  }

  @override
  Stream<List<MessageEntity>> getMessages(
    String conversationId, {
    int limit = 50,
  }) {
    return _remoteDataSource
        .getMessages(conversationId, limit: limit)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Stream<List<ConversationEntity>> getConversations(String userId) {
    return _remoteDataSource
        .getConversations(userId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<void> markAsRead({
    required String messageId,
    required String conversationId,
    required String userId,
  }) {
    return _remoteDataSource.markAsRead(
      messageId: messageId,
      conversationId: conversationId,
      userId: userId,
    );
  }

  @override
  Future<void> markConversationAsRead({
    required String conversationId,
    required String userId,
  }) {
    return _remoteDataSource.markConversationAsRead(
      conversationId: conversationId,
      userId: userId,
    );
  }

  @override
  Future<void> deleteMessage({
    required String messageId,
    required String userId,
  }) {
    return _remoteDataSource.deleteMessage(
      messageId: messageId,
      userId: userId,
    );
  }

  @override
  Future<String> getOrCreateConversation({
    required String userId1,
    required String userId2,
    required String user1Name,
    required String user2Name,
    required String user1Avatar,
    required String user2Avatar,
  }) {
    return _remoteDataSource.getOrCreateConversation(
      userId1: userId1,
      userId2: userId2,
      user1Name: user1Name,
      user2Name: user2Name,
      user1Avatar: user1Avatar,
      user2Avatar: user2Avatar,
    );
  }
}

