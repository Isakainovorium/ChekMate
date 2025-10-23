import 'package:flutter_chekmate/features/messages/domain/repositories/messages_repository.dart';

/// Delete Message Use Case - Domain Layer
///
/// Encapsulates the business logic for deleting a message.
///
/// Clean Architecture: Domain Layer
class DeleteMessageUseCase {
  const DeleteMessageUseCase(this._repository);

  final MessagesRepository _repository;

  /// Execute the delete message use case
  ///
  /// Parameters:
  /// - messageId: ID of the message to delete
  /// - userId: ID of the user deleting the message (must be sender)
  ///
  /// Throws:
  /// - Exception if validation fails
  /// - Exception if user is not authorized
  /// - Exception if deletion fails
  Future<void> call({
    required String messageId,
    required String userId,
  }) async {
    // Business logic: Validate message ID
    if (messageId.isEmpty) {
      throw Exception('Message ID cannot be empty');
    }

    // Business logic: Validate user ID
    if (userId.isEmpty) {
      throw Exception('User ID cannot be empty');
    }

    // Delegate to repository
    // Repository will check if user is authorized to delete
    return _repository.deleteMessage(
      messageId: messageId,
      userId: userId,
    );
  }
}

