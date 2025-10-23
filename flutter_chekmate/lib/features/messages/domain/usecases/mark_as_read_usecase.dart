import 'package:flutter_chekmate/features/messages/domain/repositories/messages_repository.dart';

/// Mark As Read Use Case - Domain Layer
///
/// Encapsulates the business logic for marking messages as read.
///
/// Clean Architecture: Domain Layer
class MarkAsReadUseCase {
  const MarkAsReadUseCase(this._repository);

  final MessagesRepository _repository;

  /// Execute the mark as read use case
  ///
  /// Parameters:
  /// - messageId: ID of the message to mark as read
  /// - conversationId: ID of the conversation
  /// - userId: ID of the user marking the message as read
  ///
  /// Throws:
  /// - Exception if validation fails
  /// - Exception if marking as read fails
  Future<void> call({
    required String messageId,
    required String conversationId,
    required String userId,
  }) async {
    // Business logic: Validate message ID
    if (messageId.isEmpty) {
      throw Exception('Message ID cannot be empty');
    }

    // Business logic: Validate conversation ID
    if (conversationId.isEmpty) {
      throw Exception('Conversation ID cannot be empty');
    }

    // Business logic: Validate user ID
    if (userId.isEmpty) {
      throw Exception('User ID cannot be empty');
    }

    // Delegate to repository
    return _repository.markAsRead(
      messageId: messageId,
      conversationId: conversationId,
      userId: userId,
    );
  }
}

/// Mark Conversation As Read Use Case - Domain Layer
///
/// Encapsulates the business logic for marking all messages in a conversation as read.
///
/// Clean Architecture: Domain Layer
class MarkConversationAsReadUseCase {
  const MarkConversationAsReadUseCase(this._repository);

  final MessagesRepository _repository;

  /// Execute the mark conversation as read use case
  ///
  /// Parameters:
  /// - conversationId: ID of the conversation
  /// - userId: ID of the user marking messages as read
  ///
  /// Throws:
  /// - Exception if validation fails
  /// - Exception if marking as read fails
  Future<void> call({
    required String conversationId,
    required String userId,
  }) async {
    // Business logic: Validate conversation ID
    if (conversationId.isEmpty) {
      throw Exception('Conversation ID cannot be empty');
    }

    // Business logic: Validate user ID
    if (userId.isEmpty) {
      throw Exception('User ID cannot be empty');
    }

    // Delegate to repository
    return _repository.markConversationAsRead(
      conversationId: conversationId,
      userId: userId,
    );
  }
}

