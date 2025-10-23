import 'dart:developer' as developer;

import 'package:flutter_chekmate/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_chekmate/features/messages/domain/repositories/messages_repository.dart';
import 'package:flutter_chekmate/features/messages/domain/usecases/delete_message_usecase.dart';
import 'package:flutter_chekmate/features/messages/domain/usecases/get_conversations_usecase.dart';
import 'package:flutter_chekmate/features/messages/domain/usecases/get_messages_usecase.dart';
import 'package:flutter_chekmate/features/messages/domain/usecases/mark_as_read_usecase.dart';
import 'package:flutter_chekmate/features/messages/domain/usecases/send_message_usecase.dart';
import 'package:flutter_chekmate/features/messages/domain/usecases/send_voice_message_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Messages Controller State - Presentation Layer
///
/// Represents the state of the messages controller.
///
/// Clean Architecture: Presentation Layer
class MessagesControllerState {
  const MessagesControllerState({
    this.isLoading = false,
    this.error,
  });

  final bool isLoading;
  final String? error;

  MessagesControllerState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return MessagesControllerState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Messages Controller - Presentation Layer
///
/// Manages the state and business logic for messages.
/// Uses use cases from the domain layer.
///
/// Clean Architecture: Presentation Layer
class MessagesController extends StateNotifier<MessagesControllerState> {
  MessagesController({
    required SendMessageUseCase sendMessageUseCase,
    required SendVoiceMessageUseCase sendVoiceMessageUseCase,
    required GetMessagesUseCase getMessagesUseCase,
    required GetConversationsUseCase getConversationsUseCase,
    required MarkAsReadUseCase markAsReadUseCase,
    required MarkConversationAsReadUseCase markConversationAsReadUseCase,
    required DeleteMessageUseCase deleteMessageUseCase,
    required MessagesRepository messagesRepository,
    required AsyncValue<UserEntity?> authStateProvider,
  })  : _sendMessageUseCase = sendMessageUseCase,
        _sendVoiceMessageUseCase = sendVoiceMessageUseCase,
        _getMessagesUseCase = getMessagesUseCase,
        _getConversationsUseCase = getConversationsUseCase,
        _markAsReadUseCase = markAsReadUseCase,
        _markConversationAsReadUseCase = markConversationAsReadUseCase,
        _deleteMessageUseCase = deleteMessageUseCase,
        _messagesRepository = messagesRepository,
        _authState = authStateProvider,
        super(const MessagesControllerState());

  final SendMessageUseCase _sendMessageUseCase;
  final SendVoiceMessageUseCase _sendVoiceMessageUseCase;
  // ignore: unused_field
  final GetMessagesUseCase _getMessagesUseCase;
  // ignore: unused_field
  final GetConversationsUseCase _getConversationsUseCase;
  final MarkAsReadUseCase _markAsReadUseCase;
  final MarkConversationAsReadUseCase _markConversationAsReadUseCase;
  final DeleteMessageUseCase _deleteMessageUseCase;
  final MessagesRepository _messagesRepository;
  final AsyncValue<UserEntity?> _authState;

  // ========== GETTERS ==========

  /// Get current user ID from auth state
  String? get currentUserId => _authState.value?.uid;

  /// Get current user name from auth state
  String get currentUserName => _authState.value?.displayName ?? 'Unknown';

  /// Get current user avatar from auth state
  String get currentUserAvatar => _authState.value?.avatar ?? '';

  // ========== SEND MESSAGE OPERATIONS ==========

  /// Send a text message
  Future<void> sendMessage({
    required String conversationId,
    required String receiverId,
    required String content,
  }) async {
    if (currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }

    try {
      state = state.copyWith(isLoading: true);

      await _sendMessageUseCase(
        conversationId: conversationId,
        senderId: currentUserId!,
        senderName: currentUserName,
        senderAvatar: currentUserAvatar,
        receiverId: receiverId,
        content: content,
      );

      state = state.copyWith(isLoading: false);

      developer.log(
        'Message sent successfully',
        name: 'MessagesController',
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      developer.log(
        'Error sending message: $e',
        name: 'MessagesController',
        error: e,
      );
    }
  }

  /// Send a voice message
  Future<void> sendVoiceMessage({
    required String conversationId,
    required String receiverId,
    required String voiceUrl,
    required int voiceDuration,
  }) async {
    if (currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }

    try {
      state = state.copyWith(isLoading: true);

      await _sendVoiceMessageUseCase(
        conversationId: conversationId,
        senderId: currentUserId!,
        senderName: currentUserName,
        senderAvatar: currentUserAvatar,
        receiverId: receiverId,
        voiceUrl: voiceUrl,
        voiceDuration: voiceDuration,
      );

      state = state.copyWith(isLoading: false);

      developer.log(
        'Voice message sent successfully',
        name: 'MessagesController',
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      developer.log(
        'Error sending voice message: $e',
        name: 'MessagesController',
        error: e,
      );
    }
  }

  // ========== READ OPERATIONS ==========

  /// Mark a message as read
  Future<void> markAsRead({
    required String messageId,
    required String conversationId,
  }) async {
    if (currentUserId == null) return;

    try {
      await _markAsReadUseCase(
        messageId: messageId,
        conversationId: conversationId,
        userId: currentUserId!,
      );

      developer.log(
        'Message marked as read: $messageId',
        name: 'MessagesController',
      );
    } on Exception catch (e) {
      developer.log(
        'Error marking message as read: $e',
        name: 'MessagesController',
        error: e,
      );
    }
  }

  /// Mark all messages in a conversation as read
  Future<void> markConversationAsRead({
    required String conversationId,
  }) async {
    if (currentUserId == null) return;

    try {
      await _markConversationAsReadUseCase(
        conversationId: conversationId,
        userId: currentUserId!,
      );

      developer.log(
        'Conversation marked as read: $conversationId',
        name: 'MessagesController',
      );
    } on Exception catch (e) {
      developer.log(
        'Error marking conversation as read: $e',
        name: 'MessagesController',
        error: e,
      );
    }
  }

  // ========== DELETE OPERATIONS ==========

  /// Delete a message
  Future<void> deleteMessage({
    required String messageId,
  }) async {
    if (currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }

    try {
      state = state.copyWith(isLoading: true);

      await _deleteMessageUseCase(
        messageId: messageId,
        userId: currentUserId!,
      );

      state = state.copyWith(isLoading: false);

      developer.log(
        'Message deleted successfully: $messageId',
        name: 'MessagesController',
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      developer.log(
        'Error deleting message: $e',
        name: 'MessagesController',
        error: e,
      );
    }
  }

  // ========== CONVERSATION OPERATIONS ==========

  /// Get or create a conversation between current user and another user
  Future<String?> getOrCreateConversation({
    required String otherUserId,
    required String otherUserName,
    required String otherUserAvatar,
  }) async {
    if (currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return null;
    }

    try {
      state = state.copyWith(isLoading: true);

      final conversationId = await _messagesRepository.getOrCreateConversation(
        userId1: currentUserId!,
        userId2: otherUserId,
        user1Name: currentUserName,
        user2Name: otherUserName,
        user1Avatar: currentUserAvatar,
        user2Avatar: otherUserAvatar,
      );

      state = state.copyWith(isLoading: false);

      developer.log(
        'Conversation retrieved/created: $conversationId',
        name: 'MessagesController',
      );

      return conversationId;
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      developer.log(
        'Error getting/creating conversation: $e',
        name: 'MessagesController',
        error: e,
      );

      return null;
    }
  }

  // ========== ERROR HANDLING ==========

  /// Clear error state
  void clearError() {
    state = state.copyWith();
  }
}
