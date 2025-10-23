import 'package:flutter_chekmate/features/messages/domain/repositories/messages_repository.dart';

/// Send Voice Message Use Case - Domain Layer
///
/// Encapsulates the business logic for sending a voice message.
///
/// Clean Architecture: Domain Layer
class SendVoiceMessageUseCase {
  const SendVoiceMessageUseCase(this._repository);

  final MessagesRepository _repository;

  /// Execute the send voice message use case
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
  /// - Exception if validation fails
  /// - Exception if message sending fails
  Future<String> call({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String receiverId,
    required String voiceUrl,
    required int voiceDuration,
  }) async {
    // Business logic: Validate conversation ID
    if (conversationId.isEmpty) {
      throw Exception('Conversation ID cannot be empty');
    }

    // Business logic: Validate sender ID
    if (senderId.isEmpty) {
      throw Exception('Sender ID cannot be empty');
    }

    // Business logic: Validate receiver ID
    if (receiverId.isEmpty) {
      throw Exception('Receiver ID cannot be empty');
    }

    // Business logic: Validate voice URL
    if (voiceUrl.isEmpty) {
      throw Exception('Voice URL cannot be empty');
    }

    // Business logic: Validate voice duration
    if (voiceDuration <= 0) {
      throw Exception('Voice duration must be greater than 0');
    }

    // Business logic: Validate max duration (5 minutes)
    if (voiceDuration > 300) {
      throw Exception('Voice message cannot exceed 5 minutes');
    }

    // Delegate to repository
    return _repository.sendVoiceMessage(
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      receiverId: receiverId,
      voiceUrl: voiceUrl,
      voiceDuration: voiceDuration,
    );
  }
}

