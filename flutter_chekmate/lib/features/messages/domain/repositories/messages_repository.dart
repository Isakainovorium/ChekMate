import 'package:flutter_chekmate/features/messages/domain/entities/conversation_entity.dart';
import 'package:flutter_chekmate/features/messages/domain/entities/message_entity.dart';

/// Messages Repository Interface
/// Defines the contract for message-related data operations
abstract class MessagesRepository {
  /// Send a message
  Future<String> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String receiverId,
    required String content,
    String? voiceUrl,
    int? voiceDuration,
    String? imageUrl,
    String? videoUrl,
  });

  /// Send a voice message
  Future<String> sendVoiceMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String receiverId,
    required String voiceUrl,
    required int voiceDuration,
  });

  /// Get messages for a conversation
  Future<List<MessageEntity>> getMessages(String conversationId, {
    int limit = 50,
    DateTime? before,
  });

  /// Mark messages as read
  Future<void> markMessagesAsRead(String conversationId, String userId);

  /// Get conversations for user
  Future<List<ConversationEntity>> getConversations(String userId);

  /// Create a new conversation
  Future<String> createConversation({
    required String creatorId,
    required String participantId,
    required String participantName,
    required String participantAvatar,
    String? initialMessage,
  });

  /// Delete a message
  Future<void> deleteMessage(String messageId, String conversationId);

  /// Get unread messages count
  Future<int> getUnreadMessagesCount(String userId);

  /// Search messages in a conversation
  Future<List<MessageEntity>> searchMessages(String conversationId, String query);

  /// Update conversation info
  Future<void> updateConversation(String conversationId, {
    String? name,
    String? avatar,
  });
}
