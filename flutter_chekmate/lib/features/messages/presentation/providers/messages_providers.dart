import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_chekmate/features/messages/data/datasources/messages_remote_datasource.dart';
import 'package:flutter_chekmate/features/messages/data/repositories/messages_repository_impl.dart';
import 'package:flutter_chekmate/features/messages/domain/entities/conversation_entity.dart';
import 'package:flutter_chekmate/features/messages/domain/entities/message_entity.dart';
import 'package:flutter_chekmate/features/messages/domain/repositories/messages_repository.dart';
import 'package:flutter_chekmate/features/messages/domain/usecases/delete_message_usecase.dart';
import 'package:flutter_chekmate/features/messages/domain/usecases/get_conversations_usecase.dart';
import 'package:flutter_chekmate/features/messages/domain/usecases/get_messages_usecase.dart';
import 'package:flutter_chekmate/features/messages/domain/usecases/mark_as_read_usecase.dart';
import 'package:flutter_chekmate/features/messages/domain/usecases/send_message_usecase.dart';
import 'package:flutter_chekmate/features/messages/domain/usecases/send_voice_message_usecase.dart';
import 'package:flutter_chekmate/features/messages/presentation/controllers/messages_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Messages Providers - Presentation Layer
///
/// Provides dependency injection for the messages feature using Riverpod.
/// Follows Clean Architecture dependency flow:
/// Presentation -> Domain -> Data
///
/// Clean Architecture: Presentation Layer

// ========== INFRASTRUCTURE PROVIDERS ==========

/// Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// ========== DATA LAYER PROVIDERS ==========

/// Messages remote data source provider
final messagesRemoteDataSourceProvider =
    Provider<MessagesRemoteDataSource>((ref) {
  return MessagesRemoteDataSource(
    firestore: ref.watch(firestoreProvider),
  );
});

/// Messages repository provider
final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepositoryImpl(
    ref.watch(messagesRemoteDataSourceProvider),
  );
});

// ========== DOMAIN LAYER PROVIDERS (USE CASES) ==========

/// Send message use case provider
final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(ref.watch(messagesRepositoryProvider));
});

/// Send voice message use case provider
final sendVoiceMessageUseCaseProvider =
    Provider<SendVoiceMessageUseCase>((ref) {
  return SendVoiceMessageUseCase(ref.watch(messagesRepositoryProvider));
});

/// Get messages use case provider
final getMessagesUseCaseProvider = Provider<GetMessagesUseCase>((ref) {
  return GetMessagesUseCase(ref.watch(messagesRepositoryProvider));
});

/// Get conversations use case provider
final getConversationsUseCaseProvider =
    Provider<GetConversationsUseCase>((ref) {
  return GetConversationsUseCase(ref.watch(messagesRepositoryProvider));
});

/// Mark as read use case provider
final markAsReadUseCaseProvider = Provider<MarkAsReadUseCase>((ref) {
  return MarkAsReadUseCase(ref.watch(messagesRepositoryProvider));
});

/// Mark conversation as read use case provider
final markConversationAsReadUseCaseProvider =
    Provider<MarkConversationAsReadUseCase>((ref) {
  return MarkConversationAsReadUseCase(ref.watch(messagesRepositoryProvider));
});

/// Delete message use case provider
final deleteMessageUseCaseProvider = Provider<DeleteMessageUseCase>((ref) {
  return DeleteMessageUseCase(ref.watch(messagesRepositoryProvider));
});

// ========== PRESENTATION LAYER PROVIDERS ==========

/// Messages controller provider
final messagesControllerProvider =
    StateNotifierProvider<MessagesController, MessagesControllerState>((ref) {
  return MessagesController(
    sendMessageUseCase: ref.watch(sendMessageUseCaseProvider),
    sendVoiceMessageUseCase: ref.watch(sendVoiceMessageUseCaseProvider),
    getMessagesUseCase: ref.watch(getMessagesUseCaseProvider),
    getConversationsUseCase: ref.watch(getConversationsUseCaseProvider),
    markAsReadUseCase: ref.watch(markAsReadUseCaseProvider),
    markConversationAsReadUseCase:
        ref.watch(markConversationAsReadUseCaseProvider),
    deleteMessageUseCase: ref.watch(deleteMessageUseCaseProvider),
    messagesRepository: ref.watch(messagesRepositoryProvider),
    authStateProvider: ref.watch(authStateProvider),
  );
});

/// Messages stream provider for a specific conversation
final messagesStreamProvider =
    StreamProvider.family<List<MessageEntity>, String>((ref, conversationId) {
  final getMessagesUseCase = ref.watch(getMessagesUseCaseProvider);
  return getMessagesUseCase(conversationId);
});

/// Conversations stream provider for current user
final conversationsStreamProvider =
    StreamProvider<List<ConversationEntity>>((ref) {
  final authState = ref.watch(authStateProvider);
  final getConversationsUseCase = ref.watch(getConversationsUseCaseProvider);

  final userId = authState.value?.uid;
  if (userId == null) {
    return Stream.value([]);
  }

  return getConversationsUseCase(userId);
});

/// Unread count provider for current user
final unreadCountProvider = Provider<int>((ref) {
  final authState = ref.watch(authStateProvider);
  final conversationsAsync = ref.watch(conversationsStreamProvider);

  final userId = authState.value?.uid;
  if (userId == null) return 0;

  return conversationsAsync.when(
    data: (conversations) {
      return conversations.fold<int>(
        0,
        (total, conversation) => total + conversation.getUnreadCount(userId),
      );
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});
