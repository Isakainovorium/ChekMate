import 'package:flutter_chekmate/features/messages/domain/repositories/messages_repository.dart';

/// Send Voice Message Use Case
/// Handles sending voice messages with validation and business logic
class SendVoiceMessageUseCase {
  final MessagesRepository _repository;

  SendVoiceMessageUseCase(this._repository);

  /// Execute send voice message operation
  Future<String> call({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String receiverId,
    required String voiceUrl,
    required int voiceDuration,
  }) async {
    // Validate conversationId
    if (conversationId.trim().isEmpty) {
      throw Exception('Conversation ID cannot be empty');
    }

    // Validate senderId
    if (senderId.trim().isEmpty) {
      throw Exception('Sender ID cannot be empty');
    }

    // Validate senderName
    if (senderName.trim().isEmpty) {
      throw Exception('Sender name cannot be empty');
    }

    // Validate senderAvatar
    if (senderAvatar.trim().isEmpty) {
      throw Exception('Sender avatar cannot be empty');
    }

    // Validate receiverId
    if (receiverId.trim().isEmpty) {
      throw Exception('Receiver ID cannot be empty');
    }

    // Validate voiceUrl
    if (voiceUrl.trim().isEmpty) {
      throw Exception('Voice URL cannot be empty');
    }

    // Validate voiceDuration
    if (voiceDuration <= 0) {
      throw Exception('Voice duration must be greater than 0');
    }

    // Validate voice duration is reasonable (max 5 minutes)
    if (voiceDuration > 300) {
      throw Exception('Voice message cannot be longer than 5 minutes');
    }

    // Call repository
    return await _repository.sendVoiceMessage(
      conversationId: conversationId.trim(),
      senderId: senderId.trim(),
      senderName: senderName.trim(),
      senderAvatar: senderAvatar.trim(),
      receiverId: receiverId.trim(),
      voiceUrl: voiceUrl.trim(),
      voiceDuration: voiceDuration,
    );
  }
}
