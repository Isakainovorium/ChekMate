import 'package:flutter_chekmate/features/messages/domain/entities/message_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MessageEntity', () {
    late MessageEntity testMessage;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 10, 17, 12);
      testMessage = MessageEntity(
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
    });

    group('Business Logic Methods', () {
      test('isVoiceMessage returns true when message has voice URL', () {
        final voiceMessage = testMessage.copyWith(
          voiceUrl: 'https://example.com/voice.m4a',
          voiceDuration: 30,
        );
        expect(voiceMessage.isVoiceMessage, true);
      });

      test('isVoiceMessage returns false when message has no voice URL', () {
        expect(testMessage.isVoiceMessage, false);
      });

      test('isImageMessage returns true when message has image URL', () {
        final imageMessage = testMessage.copyWith(
          imageUrl: 'https://example.com/image.jpg',
        );
        expect(imageMessage.isImageMessage, true);
      });

      test('isImageMessage returns false when message has no image URL', () {
        expect(testMessage.isImageMessage, false);
      });

      test('isVideoMessage returns true when message has video URL', () {
        final videoMessage = testMessage.copyWith(
          videoUrl: 'https://example.com/video.mp4',
        );
        expect(videoMessage.isVideoMessage, true);
      });

      test('isVideoMessage returns false when message has no video URL', () {
        expect(testMessage.isVideoMessage, false);
      });

      test('hasMedia returns true when message has voice', () {
        final voiceMessage = testMessage.copyWith(
          voiceUrl: 'https://example.com/voice.m4a',
        );
        expect(voiceMessage.hasMedia, true);
      });

      test('hasMedia returns true when message has image', () {
        final imageMessage = testMessage.copyWith(
          imageUrl: 'https://example.com/image.jpg',
        );
        expect(imageMessage.hasMedia, true);
      });

      test('hasMedia returns true when message has video', () {
        final videoMessage = testMessage.copyWith(
          videoUrl: 'https://example.com/video.mp4',
        );
        expect(videoMessage.hasMedia, true);
      });

      test('hasMedia returns false when message has no media', () {
        expect(testMessage.hasMedia, false);
      });

      test('isTextOnly returns true when message has no media', () {
        expect(testMessage.isTextOnly, true);
      });

      test('isTextOnly returns false when message has media', () {
        final voiceMessage = testMessage.copyWith(
          voiceUrl: 'https://example.com/voice.m4a',
        );
        expect(voiceMessage.isTextOnly, false);
      });

      test('canDelete returns true when user is the sender', () {
        expect(testMessage.canDelete('user1'), true);
      });

      test('canDelete returns false when user is not the sender', () {
        expect(testMessage.canDelete('user2'), false);
      });

      test('isFromUser returns true when user is the sender', () {
        expect(testMessage.isFromUser('user1'), true);
      });

      test('isFromUser returns false when user is not the sender', () {
        expect(testMessage.isFromUser('user2'), false);
      });

      test('isToUser returns true when user is the receiver', () {
        expect(testMessage.isToUser('user2'), true);
      });

      test('isToUser returns false when user is not the receiver', () {
        expect(testMessage.isToUser('user1'), false);
      });

      test('timeAgo returns correct format for seconds', () {
        final recentMessage = testMessage.copyWith(
          createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
        );
        expect(recentMessage.timeAgo, 'Just now');
      });

      test('timeAgo returns correct format for minutes', () {
        final recentMessage = testMessage.copyWith(
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        );
        expect(recentMessage.timeAgo, '5m ago');
      });

      test('timeAgo returns correct format for hours', () {
        final recentMessage = testMessage.copyWith(
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        );
        expect(recentMessage.timeAgo, '3h ago');
      });

      test('timeAgo returns correct format for days', () {
        final recentMessage = testMessage.copyWith(
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        );
        expect(recentMessage.timeAgo, '2d ago');
      });

      test('formattedVoiceDuration returns correct format', () {
        final voiceMessage = testMessage.copyWith(
          voiceUrl: 'https://example.com/voice.m4a',
          voiceDuration: 83, // 1 minute 23 seconds
        );
        expect(voiceMessage.formattedVoiceDuration, '1:23');
      });

      test('formattedVoiceDuration returns 0:00 when no duration', () {
        expect(testMessage.formattedVoiceDuration, '0:00');
      });

      test('formattedVoiceDuration pads seconds with zero', () {
        final voiceMessage = testMessage.copyWith(
          voiceUrl: 'https://example.com/voice.m4a',
          voiceDuration: 65, // 1 minute 5 seconds
        );
        expect(voiceMessage.formattedVoiceDuration, '1:05');
      });
    });

    group('Equality', () {
      test('two messages with same id are equal', () {
        final message1 = testMessage;
        final message2 = testMessage.copyWith(content: 'Different content');
        expect(message1, equals(message2));
      });

      test('two messages with different ids are not equal', () {
        final message1 = testMessage;
        final message2 = testMessage.copyWith(id: 'message2');
        expect(message1, isNot(equals(message2)));
      });

      test('hashCode is based on id', () {
        final message1 = testMessage;
        final message2 = testMessage.copyWith(content: 'Different content');
        expect(message1.hashCode, equals(message2.hashCode));
      });
    });

    group('CopyWith', () {
      test('copyWith creates new instance with updated fields', () {
        final updatedMessage = testMessage.copyWith(
          content: 'Updated content',
          isRead: true,
          readAt: DateTime.now(),
        );

        expect(updatedMessage.id, testMessage.id);
        expect(updatedMessage.content, 'Updated content');
        expect(updatedMessage.isRead, true);
        expect(updatedMessage.readAt, isNotNull);
        expect(updatedMessage.senderName, testMessage.senderName);
      });

      test('copyWith preserves original when no fields provided', () {
        final copiedMessage = testMessage.copyWith();

        expect(copiedMessage.id, testMessage.id);
        expect(copiedMessage.content, testMessage.content);
        expect(copiedMessage.isRead, testMessage.isRead);
      });
    });

    group('ToString', () {
      test('toString returns correct format', () {
        final string = testMessage.toString();
        expect(string, contains('MessageEntity'));
        expect(string, contains('message1'));
        expect(string, contains('user1'));
        expect(string, contains('user2'));
      });
    });
  });
}

