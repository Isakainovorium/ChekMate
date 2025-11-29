import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/messages/domain/entities/conversation_entity.dart';
import 'package:flutter_chekmate/features/messages/domain/entities/message_entity.dart';
import 'package:flutter_chekmate/features/messages/domain/repositories/messages_repository.dart';

/// Messages Repository Implementation
/// Handles message-related data operations with Firestore
class MessagesRepositoryImpl implements MessagesRepository {
  final FirebaseFirestore _firestore;

  MessagesRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<String> sendMessage({
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
    try {
      final messageData = {
        'conversationId': conversationId,
        'senderId': senderId,
        'senderName': senderName,
        'senderAvatar': senderAvatar,
        'receiverId': receiverId,
        'content': content,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        if (voiceUrl != null) 'voiceUrl': voiceUrl,
        if (voiceDuration != null) 'voiceDuration': voiceDuration,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (videoUrl != null) 'videoUrl': videoUrl,
      };

      final docRef = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add(messageData);

      // Update conversation's last message
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': content.isNotEmpty ? content : 'Image',
        'timestamp': FieldValue.serverTimestamp(),
        'unread': true,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<String> sendVoiceMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String receiverId,
    required String voiceUrl,
    required int voiceDuration,
  }) async {
    return sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      receiverId: receiverId,
      content: '',
      voiceUrl: voiceUrl,
      voiceDuration: voiceDuration,
    );
  }

  @override
  Future<List<MessageEntity>> getMessages(String conversationId, {
    int limit = 50,
    DateTime? before,
  }) async {
    try {
      var query = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (before != null) {
        query = query.where('createdAt', isLessThan: before);
      }

      final snapshot = await query.get();

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
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  @override
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      final batch = _firestore.batch();

      final unreadMessages = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  @override
  Future<List<ConversationEntity>> getConversations(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .where('participantIds', arrayContains: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ConversationEntity(
          id: doc.id,
          name: data['name'] as String? ?? '',
          username: data['username'] as String? ?? '',
          avatar: data['avatar'] as String? ?? '',
          lastMessage: data['lastMessage'] as String? ?? '',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          unread: data['unread'] as bool? ?? false,
          online: data['online'] as bool? ?? false,
          participantIds: List<String>.from(data['participantIds'] as List? ?? []),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get conversations: $e');
    }
  }

  @override
  Future<String> createConversation({
    required String creatorId,
    required String participantId,
    required String participantName,
    required String participantAvatar,
    String? initialMessage,
  }) async {
    try {
      final conversationData = {
        'name': participantName,
        'username': participantName,
        'avatar': participantAvatar,
        'lastMessage': initialMessage ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'unread': false,
        'online': false,
        'participantIds': [creatorId, participantId],
      };

      final docRef = await _firestore.collection('conversations').add(conversationData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  @override
  Future<void> deleteMessage(String messageId, String conversationId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  @override
  Future<int> getUnreadMessagesCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .where('participantIds', arrayContains: userId)
          .where('unread', isEqualTo: true)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  @override
  Future<List<MessageEntity>> searchMessages(String conversationId, String query) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThan: '${query}z')
          .orderBy('content')
          .orderBy('createdAt', descending: true)
          .get();

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
    } catch (e) {
      throw Exception('Failed to search messages: $e');
    }
  }

  @override
  Future<void> updateConversation(String conversationId, {
    String? name,
    String? avatar,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (avatar != null) updates['avatar'] = avatar;

      if (updates.isNotEmpty) {
        await _firestore.collection('conversations').doc(conversationId).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update conversation: $e');
    }
  }
}
