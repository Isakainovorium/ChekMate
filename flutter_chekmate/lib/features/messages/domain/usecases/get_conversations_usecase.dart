import 'package:flutter_chekmate/features/messages/domain/entities/conversation_entity.dart';
import 'package:flutter_chekmate/features/messages/domain/repositories/messages_repository.dart';

/// Get Conversations Use Case - Domain Layer
///
/// Encapsulates the business logic for retrieving conversations.
///
/// Clean Architecture: Domain Layer
class GetConversationsUseCase {
  const GetConversationsUseCase(this._repository);

  final MessagesRepository _repository;

  /// Execute the get conversations use case
  ///
  /// Parameters:
  /// - userId: ID of the user
  ///
  /// Returns: Stream of list of ConversationEntity
  Stream<List<ConversationEntity>> call(String userId) {
    // Business logic: Validate user ID
    if (userId.isEmpty) {
      throw Exception('User ID cannot be empty');
    }

    // Delegate to repository
    return _repository.getConversations(userId);
  }
}

