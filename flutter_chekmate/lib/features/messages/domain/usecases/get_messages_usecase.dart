import 'package:flutter_chekmate/features/messages/domain/entities/message_entity.dart';
import 'package:flutter_chekmate/features/messages/domain/repositories/messages_repository.dart';

/// Get Messages Use Case - Domain Layer
///
/// Encapsulates the business logic for retrieving messages.
///
/// Clean Architecture: Domain Layer
class GetMessagesUseCase {
  const GetMessagesUseCase(this._repository);

  final MessagesRepository _repository;

  /// Execute the get messages use case
  ///
  /// Parameters:
  /// - conversationId: ID of the conversation
  /// - limit: Maximum number of messages to retrieve (default: 50)
  ///
  /// Returns: Stream of list of MessageEntity
  Stream<List<MessageEntity>> call(
    String conversationId, {
    int limit = 50,
  }) {
    // Business logic: Validate conversation ID
    if (conversationId.isEmpty) {
      throw Exception('Conversation ID cannot be empty');
    }

    // Business logic: Validate limit
    if (limit <= 0) {
      throw Exception('Limit must be greater than 0');
    }

    if (limit > 100) {
      throw Exception('Limit cannot exceed 100 messages');
    }

    // Delegate to repository
    return _repository.getMessages(
      conversationId,
      limit: limit,
    );
  }
}

