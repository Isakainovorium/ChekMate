import 'package:flutter_chekmate/features/messages/domain/entities/conversation_entity.dart';
import 'package:flutter_chekmate/features/messages/domain/entities/message_entity.dart';

/// Messages Repository Interface - Domain Layer
///
/// This abstract class defines the contract for messages operations.
/// It has no implementation details - only the interface that the domain layer expects.
///
/// The data layer will provide the concrete implementation.
///
/// Clean Architecture: Domain Layer
abstract class MessagesRepository {
  /// Send a text message
  ///
  /// Parameters:
  /// - conversationId: ID of the conversation
  /// - senderId: ID of the user sending the message
  /// - senderName: Name of the sender
  /// - senderAvatar: Avatar URL of the sender
  /// - receiverId: ID of the user receiving the message
  /// - content: Text content of the message
  ///
  /// Returns: ID of the created message
  ///
  /// Throws:
  /// - Exception if message sending fails
  Future<String> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String receiverId,
    required String content,
  });

  /// Send a voice message
  ///
  /// Parameters:
  /// - conversationId: ID of the conversation
  /// - senderId: ID of the user sending the message
  /// - senderName: Name of the sender
  /// - senderAvatar: Avatar URL of the sender
  /// - receiverId: ID of the user receiving the message
  /// - voiceUrl: URL of the uploaded voice file
  /// - voiceDuration: Duration of the voice message in seconds
  ///
  /// Returns: ID of the created message
  ///
  /// Throws:
  /// - Exception if message sending fails
  Future<String> sendVoiceMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String receiverId,
    required String voiceUrl,
    required int voiceDuration,
  });

  /// Send an image message
  ///
  /// Parameters:
  /// - conversationId: ID of the conversation
  /// - senderId: ID of the user sending the message
  /// - senderName: Name of the sender
  /// - senderAvatar: Avatar URL of the sender
  /// - receiverId: ID of the user receiving the message
  /// - imageUrl: URL of the uploaded image
  ///
  /// Returns: ID of the created message
  ///
  /// Throws:
  /// - Exception if message sending fails
  Future<String> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String receiverId,
    required String imageUrl,
  });

  /// Get messages for a conversation (real-time stream)
  ///
  /// Parameters:
  /// - conversationId: ID of the conversation
  /// - limit: Maximum number of messages to retrieve (default: 50)
  ///
  /// Returns: Stream of list of MessageEntity
  ///
  /// The stream will emit new values whenever messages are added or updated
  Stream<List<MessageEntity>> getMessages(
    String conversationId, {
    int limit = 50,
  });

  /// Get conversations for a user (real-time stream)
  ///
  /// Parameters:
  /// - userId: ID of the user
  ///
  /// Returns: Stream of list of ConversationEntity
  ///
  /// The stream will emit new values whenever conversations are updated
  Stream<List<ConversationEntity>> getConversations(String userId);

  /// Mark a message as read
  ///
  /// Parameters:
  /// - messageId: ID of the message to mark as read
  /// - conversationId: ID of the conversation
  /// - userId: ID of the user marking the message as read
  ///
  /// Throws:
  /// - Exception if marking as read fails
  Future<void> markAsRead({
    required String messageId,
    required String conversationId,
    required String userId,
  });

  /// Mark all messages in a conversation as read
  ///
  /// Parameters:
  /// - conversationId: ID of the conversation
  /// - userId: ID of the user marking messages as read
  ///
  /// Throws:
  /// - Exception if marking as read fails
  Future<void> markConversationAsRead({
    required String conversationId,
    required String userId,
  });

  /// Delete a message
  ///
  /// Parameters:
  /// - messageId: ID of the message to delete
  /// - userId: ID of the user deleting the message (must be sender)
  ///
  /// Throws:
  /// - Exception if message not found
  /// - Exception if user is not authorized to delete
  /// - Exception if deletion fails
  Future<void> deleteMessage({
    required String messageId,
    required String userId,
  });

  /// Get or create a conversation between two users
  ///
  /// Parameters:
  /// - userId1: ID of the first user
  /// - userId2: ID of the second user
  /// - user1Name: Name of the first user
  /// - user2Name: Name of the second user
  /// - user1Avatar: Avatar URL of the first user
  /// - user2Avatar: Avatar URL of the second user
  ///
  /// Returns: ID of the conversation
  ///
  /// Throws:
  /// - Exception if conversation creation fails
  Future<String> getOrCreateConversation({
    required String userId1,
    required String userId2,
    required String user1Name,
    required String user2Name,
    required String user1Avatar,
    required String user2Avatar,
  });
}

