import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/messages/data/models/message_model.dart';
import 'package:flutter_chekmate/features/messages/domain/entities/message_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MessageModel', () {
    late MessageModel testModel;
    late DateTime testDate;
    late Map<String, dynamic> testJson;

    setUp(() {
      testDate = DateTime(2025, 10, 17, 12);
      testModel = MessageModel(
        id: 'message1',
        conversationId: 'conv1',
        senderId: 'user1',
        senderName: 'Test User',
        senderAvatar: 'https://example.com/avatar.jpg',
        receiverId: 'user2',
        content: 'Test message',
        isRead: false,
        createdAt: testDate,
      );

      testJson = {
        'id': 'message1',
        'conversationId': 'conv1',
        'senderId': 'user1',
        'senderName': 'Test User',
        'senderAvatar': 'https://example.com/avatar.jpg',
        'receiverId': 'user2',
        'content': 'Test message',
        'isRead': false,
        'createdAt': Timestamp.fromDate(testDate),
      };
    });

    group('Serialization', () {
      test('fromJson creates correct model', () {
        final model = MessageModel.fromJson(testJson);

        expect(model.id, 'message1');
        expect(model.conversationId, 'conv1');
        expect(model.senderId, 'user1');
        expect(model.senderName, 'Test User');
        expect(model.senderAvatar, 'https://example.com/avatar.jpg');
        expect(model.receiverId, 'user2');
        expect(model.content, 'Test message');
        expect(model.isRead, false);
        expect(model.createdAt, testDate);
      });

      test('toJson creates correct map', () {
        final json = testModel.toJson();

        expect(json['id'], 'message1');
        expect(json['conversationId'], 'conv1');
        expect(json['senderId'], 'user1');
        expect(json['senderName'], 'Test User');
        expect(json['senderAvatar'], 'https://example.com/avatar.jpg');
        expect(json['receiverId'], 'user2');
        expect(json['content'], 'Test message');
        expect(json['isRead'], false);
        expect(json['createdAt'], isA<Timestamp>());
      });

      test('toFirestore excludes id field', () {
        final firestoreData = testModel.toFirestore();

        expect(firestoreData.containsKey('id'), false);
        expect(firestoreData['conversationId'], 'conv1');
        expect(firestoreData['content'], 'Test message');
      });

      test('fromJson handles voice message', () {
        final voiceJson = {
          ...testJson,
          'voiceUrl': 'https://example.com/voice.m4a',
          'voiceDuration': 30,
        };

        final model = MessageModel.fromJson(voiceJson);

        expect(model.voiceUrl, 'https://example.com/voice.m4a');
        expect(model.voiceDuration, 30);
        expect(model.isVoiceMessage, true);
      });

      test('fromJson handles image message', () {
        final imageJson = {
          ...testJson,
          'imageUrl': 'https://example.com/image.jpg',
        };

        final model = MessageModel.fromJson(imageJson);

        expect(model.imageUrl, 'https://example.com/image.jpg');
        expect(model.isImageMessage, true);
      });

      test('fromJson handles read message', () {
        final readDate = testDate.add(const Duration(minutes: 5));
        final readJson = {
          ...testJson,
          'isRead': true,
          'readAt': Timestamp.fromDate(readDate),
        };

        final model = MessageModel.fromJson(readJson);

        expect(model.isRead, true);
        expect(model.readAt, readDate);
      });
    });

    group('Entity Conversion', () {
      test('toEntity creates correct MessageEntity', () {
        final entity = testModel.toEntity();

        expect(entity, isA<MessageEntity>());
        expect(entity.id, testModel.id);
        expect(entity.conversationId, testModel.conversationId);
        expect(entity.senderId, testModel.senderId);
        expect(entity.senderName, testModel.senderName);
        expect(entity.content, testModel.content);
        expect(entity.isRead, testModel.isRead);
      });

      test('fromEntity creates correct MessageModel', () {
        final entity = MessageEntity(
          id: 'message1',
          conversationId: 'conv1',
          senderId: 'user1',
          senderName: 'Test User',
          senderAvatar: 'https://example.com/avatar.jpg',
          receiverId: 'user2',
          content: 'Test message',
          isRead: false,
          createdAt: testDate,
        );

        final model = MessageModel.fromEntity(entity);

        expect(model, isA<MessageModel>());
        expect(model.id, entity.id);
        expect(model.conversationId, entity.conversationId);
        expect(model.senderId, entity.senderId);
        expect(model.content, entity.content);
      });

      test('toEntity and fromEntity are inverse operations', () {
        final entity = testModel.toEntity();
        final model = MessageModel.fromEntity(entity);

        expect(model.id, testModel.id);
        expect(model.conversationId, testModel.conversationId);
        expect(model.content, testModel.content);
      });
    });

    group('CopyWith', () {
      test('copyWith creates new instance with updated fields', () {
        final updated = testModel.copyWith(
          content: 'Updated message',
          isRead: true,
        );

        expect(updated.id, testModel.id);
        expect(updated.content, 'Updated message');
        expect(updated.isRead, true);
        expect(updated.senderName, testModel.senderName);
      });

      test('copyWith preserves original when no fields provided', () {
        final copied = testModel.copyWith();

        expect(copied.id, testModel.id);
        expect(copied.content, testModel.content);
        expect(copied.isRead, testModel.isRead);
      });
    });

    group('Inheritance', () {
      test('MessageModel extends MessageEntity', () {
        expect(testModel, isA<MessageEntity>());
      });

      test('MessageModel inherits business logic methods', () {
        expect(testModel.isTextOnly, true);
        expect(testModel.canDelete('user1'), true);
        expect(testModel.canDelete('user2'), false);
      });
    });
  });
}

