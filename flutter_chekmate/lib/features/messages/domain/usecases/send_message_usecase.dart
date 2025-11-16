import 'package:flutter_chekmate/features/messages/domain/repositories/messages_repository.dart';

/// Send Message Use Case
/// Handles sending messages with validation and business logic
class SendMessageUseCase {
  final MessagesRepository _repository;

  SendMessageUseCase(this._repository);

  /// Execute send message operation
  Future<String> call({
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

    // Validate content (unless there's media)
    final hasMedia = voiceUrl != null || imageUrl != null || videoUrl != null;
    if (!hasMedia && content.trim().isEmpty) {
      throw Exception('Message content cannot be empty');
    }

    // Validate content length (max 1000 characters)
    if (content.length > 1000) {
      throw Exception('Message content cannot exceed 1000 characters');
    }

    // Validate voice message
    if (voiceUrl != null) {
      if (voiceUrl.trim().isEmpty) {
        throw Exception('Voice URL cannot be empty');
      }
      if (voiceDuration == null || voiceDuration <= 0) {
        throw Exception('Voice duration must be provided and greater than 0');
      }
    }

    // Validate image message
    if (imageUrl != null && imageUrl.trim().isEmpty) {
      throw Exception('Image URL cannot be empty');
    }

    // Validate video message
    if (videoUrl != null && videoUrl.trim().isEmpty) {
      throw Exception('Video URL cannot be empty');
    }

    // Trim whitespace from content
    final cleanContent = content.trim();

    // Call repository
    return await _repository.sendMessage(
      conversationId: conversationId.trim(),
      senderId: senderId.trim(),
      senderName: senderName.trim(),
      senderAvatar: senderAvatar.trim(),
      receiverId: receiverId.trim(),
      content: cleanContent,
      voiceUrl: voiceUrl?.trim(),
      voiceDuration: voiceDuration,
      imageUrl: imageUrl?.trim(),
      videoUrl: videoUrl?.trim(),
    );
  }
}
