import 'package:flutter_chekmate/features/messages/domain/repositories/messages_repository.dart';

/// Send Message Use Case - Domain Layer
///
/// Encapsulates the business logic for sending a text message.
///
/// Clean Architecture: Domain Layer
class SendMessageUseCase {
  const SendMessageUseCase(this._repository);

  final MessagesRepository _repository;

  /// Execute the send message use case
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
  /// - Exception if validation fails
  /// - Exception if message sending fails
  Future<String> call({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String receiverId,
    required String content,
  }) async {
    // Business logic: Validate conversation ID
    if (conversationId.isEmpty) {
      throw Exception('Conversation ID cannot be empty');
    }

    // Business logic: Validate sender ID
    if (senderId.isEmpty) {
      throw Exception('Sender ID cannot be empty');
    }

    // Business logic: Validate sender name
    if (senderName.isEmpty) {
      throw Exception('Sender name cannot be empty');
    }

    // Business logic: Validate receiver ID
    if (receiverId.isEmpty) {
      throw Exception('Receiver ID cannot be empty');
    }

    // Business logic: Validate content
    if (content.trim().isEmpty) {
      throw Exception('Message content cannot be empty');
    }

    // Business logic: Validate content length
    if (content.length > 5000) {
      throw Exception('Message content cannot exceed 5000 characters');
    }

    // Delegate to repository
    return _repository.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      receiverId: receiverId,
      content: content.trim(),
    );
  }
}

