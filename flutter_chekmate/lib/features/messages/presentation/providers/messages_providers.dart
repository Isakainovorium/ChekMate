import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/messages/data/repositories/messages_repository_impl.dart';
import 'package:flutter_chekmate/features/messages/domain/entities/conversation_entity.dart';
import 'package:flutter_chekmate/features/messages/domain/entities/message_entity.dart';
import 'package:flutter_chekmate/features/messages/domain/repositories/messages_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Conversations Stream Provider
/// Provides a stream of conversations for the current user
final conversationsProvider =
    StreamProvider.family<List<ConversationEntity>, String>((ref, userId) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('conversations')
      .where('participantIds', arrayContains: userId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ConversationEntity(
        id: doc.id,
        name: data['name'] as String? ?? '',
        username: data['username'] as String? ?? '',
        avatar: data['avatar'] as String? ?? '',
        lastMessage: data['lastMessage'] as String? ?? '',
        timestamp:
            (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        unread: data['unread'] as bool? ?? false,
        online: data['online'] as bool? ?? false,
        participantIds:
            List<String>.from(data['participantIds'] as List? ?? []),
      );
    }).toList();
  });
});

/// Unread Messages Count Provider
/// Provides the count of unread messages for the current user
final unreadMessagesCountProvider =
    StreamProvider.family<int, String>((ref, userId) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('conversations')
      .where('participantIds', arrayContains: userId)
      .where('unread', isEqualTo: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

/// Single Conversation Provider
/// Provides a specific conversation by ID
final conversationProvider =
    StreamProvider.family<ConversationEntity?, String>((ref, conversationId) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('conversations')
      .doc(conversationId)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) return null;

    final data = snapshot.data()!;
    return ConversationEntity(
      id: snapshot.id,
      name: data['name'] as String? ?? '',
      username: data['username'] as String? ?? '',
      avatar: data['avatar'] as String? ?? '',
      lastMessage: data['lastMessage'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unread: data['unread'] as bool? ?? false,
      online: data['online'] as bool? ?? false,
      participantIds: List<String>.from(data['participantIds'] as List? ?? []),
    );
  });
});

/// Messages State Notifier
/// Manages messages state and operations
class MessagesNotifier
    extends StateNotifier<AsyncValue<List<ConversationEntity>>> {
  final FirebaseFirestore _firestore;
  final String _userId;

  MessagesNotifier(this._firestore, this._userId)
      : super(const AsyncValue.loading()) {
    _loadConversations();
  }

  void _loadConversations() {
    _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: _userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        final conversations = snapshot.docs.map((doc) {
          final data = doc.data();
          return ConversationEntity(
            id: doc.id,
            name: data['name'] as String? ?? '',
            username: data['username'] as String? ?? '',
            avatar: data['avatar'] as String? ?? '',
            lastMessage: data['lastMessage'] as String? ?? '',
            timestamp:
                (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            unread: data['unread'] as bool? ?? false,
            online: data['online'] as bool? ?? false,
            participantIds:
                List<String>.from(data['participantIds'] as List? ?? []),
          );
        }).toList();

        state = AsyncValue.data(conversations);
      },
      onError: (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  /// Mark conversation as read
  Future<void> markAsRead(String conversationId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({'unread': false});
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _firestore.collection('conversations').doc(conversationId).delete();
    } catch (e) {
      // Handle error
      rethrow;
    }
  }
}

/// Messages Notifier Provider
final messagesNotifierProvider = StateNotifierProvider.family<MessagesNotifier,
    AsyncValue<List<ConversationEntity>>, String>(
  (ref, userId) {
    final firestore = ref.watch(firestoreProvider);
    return MessagesNotifier(firestore, userId);
  },
);

/// Messages Stream Provider
/// Provides a stream of messages for a specific conversation
final messagesProvider = StreamProvider.family<List<MessageEntity>, String>((ref, conversationId) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('conversations')
      .doc(conversationId)
      .collection('messages')
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return MessageEntity(
        id: doc.id,
        conversationId: conversationId,
        senderId: data['senderId'] as String? ?? '',
        senderName: data['senderName'] as String? ?? '',
        senderAvatar: data['senderAvatar'] as String? ?? '',
        receiverId: data['receiverId'] as String? ?? '',
        content: data['content'] as String? ?? '',
        isRead: data['isRead'] as bool? ?? false,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        voiceUrl: data['voiceUrl'] as String?,
        voiceDuration: data['voiceDuration'] as int?,
        imageUrl: data['imageUrl'] as String?,
        videoUrl: data['videoUrl'] as String?,
      );
    }).toList();
  });
});

/// Messages Repository Provider
final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return MessagesRepositoryImpl(firestore: firestore);
});

/// Conversations Stream Provider (alias for conversationsProvider)
/// Used by legacy code
final conversationsStreamProvider = conversationsProvider;
