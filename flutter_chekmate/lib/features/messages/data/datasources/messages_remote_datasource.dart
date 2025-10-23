import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/messages/data/models/conversation_model.dart';
import 'package:flutter_chekmate/features/messages/data/models/message_model.dart';

/// Messages Remote Data Source - Data Layer
///
/// Handles all Firebase Firestore operations for messages and conversations.
/// This is the only class that knows about Firebase implementation details.
///
/// Clean Architecture: Data Layer
class MessagesRemoteDataSource {
  MessagesRemoteDataSource({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  // ========== CREATE OPERATIONS ==========

  /// Send a text message
  Future<String> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String receiverId,
    required String content,
  }) async {
    try {
      developer.log(
        'Sending message to conversation: $conversationId',
        name: 'MessagesRemoteDataSource',
      );

      final messageRef = _firestore.collection('messages').doc();
      final messageId = messageRef.id;

      final message = MessageModel(
        id: messageId,
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        senderAvatar: senderAvatar,
        receiverId: receiverId,
        content: content,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await messageRef.set(message.toFirestore());

      // Update conversation
      await _updateConversation(
        conversationId: conversationId,
        lastMessage: content,
        lastMessageSenderId: senderId,
        receiverId: receiverId,
      );

      developer.log(
        'Message sent successfully: $messageId',
        name: 'MessagesRemoteDataSource',
      );

      return messageId;
    } on Exception catch (e) {
      developer.log(
        'Error sending message: $e',
        name: 'MessagesRemoteDataSource',
        error: e,
      );
      throw Exception('Failed to send message: $e');
    }
  }

  /// Send a voice message
  Future<String> sendVoiceMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String receiverId,
    required String voiceUrl,
    required int voiceDuration,
  }) async {
    try {
      developer.log(
        'Sending voice message to conversation: $conversationId',
        name: 'MessagesRemoteDataSource',
      );

      final messageRef = _firestore.collection('messages').doc();
      final messageId = messageRef.id;

      final message = MessageModel(
        id: messageId,
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        senderAvatar: senderAvatar,
        receiverId: receiverId,
        content: '🎤 Voice message',
        voiceUrl: voiceUrl,
        voiceDuration: voiceDuration,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await messageRef.set(message.toFirestore());

      // Update conversation
      await _updateConversation(
        conversationId: conversationId,
        lastMessage: '🎤 Voice message',
        lastMessageSenderId: senderId,
        receiverId: receiverId,
      );

      developer.log(
        'Voice message sent successfully: $messageId',
        name: 'MessagesRemoteDataSource',
      );

      return messageId;
    } on Exception catch (e) {
      developer.log(
        'Error sending voice message: $e',
        name: 'MessagesRemoteDataSource',
        error: e,
      );
      throw Exception('Failed to send voice message: $e');
    }
  }

  /// Send an image message
  Future<String> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String receiverId,
    required String imageUrl,
  }) async {
    try {
      developer.log(
        'Sending image message to conversation: $conversationId',
        name: 'MessagesRemoteDataSource',
      );

      final messageRef = _firestore.collection('messages').doc();
      final messageId = messageRef.id;

      final message = MessageModel(
        id: messageId,
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        senderAvatar: senderAvatar,
        receiverId: receiverId,
        content: '📷 Photo',
        imageUrl: imageUrl,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await messageRef.set(message.toFirestore());

      // Update conversation
      await _updateConversation(
        conversationId: conversationId,
        lastMessage: '📷 Photo',
        lastMessageSenderId: senderId,
        receiverId: receiverId,
      );

      developer.log(
        'Image message sent successfully: $messageId',
        name: 'MessagesRemoteDataSource',
      );

      return messageId;
    } on Exception catch (e) {
      developer.log(
        'Error sending image message: $e',
        name: 'MessagesRemoteDataSource',
        error: e,
      );
      throw Exception('Failed to send image message: $e');
    }
  }

  // ========== READ OPERATIONS ==========

  /// Get messages for a conversation (real-time stream)
  Stream<List<MessageModel>> getMessages(
    String conversationId, {
    int limit = 50,
  }) {
    developer.log(
      'Getting messages for conversation: $conversationId',
      name: 'MessagesRemoteDataSource',
    );

    return _firestore
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get conversations for a user (real-time stream)
  Stream<List<ConversationModel>> getConversations(String userId) {
    developer.log(
      'Getting conversations for user: $userId',
      name: 'MessagesRemoteDataSource',
    );

    return _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ConversationModel.fromFirestore(doc))
          .toList();
    });
  }

  // ========== UPDATE OPERATIONS ==========

  /// Mark a message as read
  Future<void> markAsRead({
    required String messageId,
    required String conversationId,
    required String userId,
  }) async {
    try {
      developer.log(
        'Marking message as read: $messageId',
        name: 'MessagesRemoteDataSource',
      );

      await _firestore.collection('messages').doc(messageId).update({
        'isRead': true,
        'readAt': Timestamp.fromDate(DateTime.now()),
      });

      // Decrement unread count for user
      await _decrementUnreadCount(
        conversationId: conversationId,
        userId: userId,
      );

      developer.log(
        'Message marked as read: $messageId',
        name: 'MessagesRemoteDataSource',
      );
    } on Exception catch (e) {
      developer.log(
        'Error marking message as read: $e',
        name: 'MessagesRemoteDataSource',
        error: e,
      );
      throw Exception('Failed to mark message as read: $e');
    }
  }

  /// Mark all messages in a conversation as read
  Future<void> markConversationAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      developer.log(
        'Marking conversation as read: $conversationId',
        name: 'MessagesRemoteDataSource',
      );

      // Get all unread messages for this user
      final unreadMessages = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      // Mark all as read
      final batch = _firestore.batch();
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': Timestamp.fromDate(DateTime.now()),
        });
      }
      await batch.commit();

      // Reset unread count for user
      await _firestore.collection('conversations').doc(conversationId).update({
        'unreadCounts.$userId': 0,
      });

      developer.log(
        'Conversation marked as read: $conversationId',
        name: 'MessagesRemoteDataSource',
      );
    } on Exception catch (e) {
      developer.log(
        'Error marking conversation as read: $e',
        name: 'MessagesRemoteDataSource',
        error: e,
      );
      throw Exception('Failed to mark conversation as read: $e');
    }
  }

  // ========== DELETE OPERATIONS ==========

  /// Delete a message
  Future<void> deleteMessage({
    required String messageId,
    required String userId,
  }) async {
    try {
      developer.log(
        'Deleting message: $messageId',
        name: 'MessagesRemoteDataSource',
      );

      // Get message to verify ownership
      final messageDoc =
          await _firestore.collection('messages').doc(messageId).get();

      if (!messageDoc.exists) {
        throw Exception('Message not found');
      }

      final message = MessageModel.fromFirestore(messageDoc);

      // Check if user is authorized to delete
      if (message.senderId != userId) {
        throw Exception('Not authorized to delete this message');
      }

      // Delete message
      await _firestore.collection('messages').doc(messageId).delete();

      developer.log(
        'Message deleted successfully: $messageId',
        name: 'MessagesRemoteDataSource',
      );
    } on Exception catch (e) {
      developer.log(
        'Error deleting message: $e',
        name: 'MessagesRemoteDataSource',
        error: e,
      );
      throw Exception('Failed to delete message: $e');
    }
  }

  // ========== CONVERSATION OPERATIONS ==========

  /// Get or create a conversation between two users
  Future<String> getOrCreateConversation({
    required String userId1,
    required String userId2,
    required String user1Name,
    required String user2Name,
    required String user1Avatar,
    required String user2Avatar,
  }) async {
    try {
      developer.log(
        'Getting or creating conversation between $userId1 and $userId2',
        name: 'MessagesRemoteDataSource',
      );

      // Create conversation ID (sorted to ensure consistency)
      final ids = [userId1, userId2]..sort();
      final conversationId = '${ids[0]}_${ids[1]}';

      final conversationRef =
          _firestore.collection('conversations').doc(conversationId);
      final conversationDoc = await conversationRef.get();

      if (!conversationDoc.exists) {
        // Create new conversation
        final conversation = ConversationModel(
          id: conversationId,
          participants: [userId1, userId2],
          participantNames: {
            userId1: user1Name,
            userId2: user2Name,
          },
          participantAvatars: {
            userId1: user1Avatar,
            userId2: user2Avatar,
          },
          lastMessage: '',
          lastMessageSenderId: '',
          lastMessageTimestamp: DateTime.now(),
          unreadCount: {
            userId1: 0,
            userId2: 0,
          },
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await conversationRef.set(conversation.toFirestore());

        developer.log(
          'Conversation created: $conversationId',
          name: 'MessagesRemoteDataSource',
        );
      }

      return conversationId;
    } on Exception catch (e) {
      developer.log(
        'Error getting or creating conversation: $e',
        name: 'MessagesRemoteDataSource',
        error: e,
      );
      throw Exception('Failed to get or create conversation: $e');
    }
  }

  // ========== PRIVATE HELPER METHODS ==========

  /// Update conversation with last message info
  Future<void> _updateConversation({
    required String conversationId,
    required String lastMessage,
    required String lastMessageSenderId,
    required String receiverId,
  }) async {
    try {
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': lastMessage,
        'lastMessageSenderId': lastMessageSenderId,
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'unreadCounts.$receiverId': FieldValue.increment(1),
      });
    } on Exception catch (e) {
      developer.log(
        'Error updating conversation: $e',
        name: 'MessagesRemoteDataSource',
        error: e,
      );
      // Don't throw - conversation update is not critical
    }
  }

  /// Decrement unread count for a user
  Future<void> _decrementUnreadCount({
    required String conversationId,
    required String userId,
  }) async {
    try {
      await _firestore.collection('conversations').doc(conversationId).update({
        'unreadCounts.$userId': FieldValue.increment(-1),
      });
    } on Exception catch (e) {
      developer.log(
        'Error decrementing unread count: $e',
        name: 'MessagesRemoteDataSource',
        error: e,
      );
      // Don't throw - unread count update is not critical
    }
  }
}
