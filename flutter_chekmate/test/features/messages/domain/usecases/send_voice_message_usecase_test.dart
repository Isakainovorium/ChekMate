import 'package:flutter_chekmate/features/messages/domain/repositories/messages_repository.dart';
import 'package:flutter_chekmate/features/messages/domain/usecases/send_voice_message_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMessagesRepository extends Mock implements MessagesRepository {}

void main() {
  group('SendVoiceMessageUseCase', () {
    late SendVoiceMessageUseCase useCase;
    late MockMessagesRepository mockRepository;

    setUp(() {
      mockRepository = MockMessagesRepository();
      useCase = SendVoiceMessageUseCase(mockRepository);
    });

    group('Validation', () {
      test('throws exception when conversationId is empty', () async {
        expect(
          () => useCase(
            conversationId: '',
            senderId: 'user1',
            senderName: 'Test User',
            senderAvatar: 'avatar.jpg',
            receiverId: 'user2',
            voiceUrl: 'voice.m4a',
            voiceDuration: 30,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when senderId is empty', () async {
        expect(
          () => useCase(
            conversationId: 'conv1',
            senderId: '',
            senderName: 'Test User',
            senderAvatar: 'avatar.jpg',
            receiverId: 'user2',
            voiceUrl: 'voice.m4a',
            voiceDuration: 30,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when receiverId is empty', () async {
        expect(
          () => useCase(
            conversationId: 'conv1',
            senderId: 'user1',
            senderName: 'Test User',
            senderAvatar: 'avatar.jpg',
            receiverId: '',
            voiceUrl: 'voice.m4a',
            voiceDuration: 30,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when voiceUrl is empty', () async {
        expect(
          () => useCase(
            conversationId: 'conv1',
            senderId: 'user1',
            senderName: 'Test User',
            senderAvatar: 'avatar.jpg',
            receiverId: 'user2',
            voiceUrl: '',
            voiceDuration: 30,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when voiceDuration is zero or negative', () async {
        expect(
          () => useCase(
            conversationId: 'conv1',
            senderId: 'user1',
            senderName: 'Test User',
            senderAvatar: 'avatar.jpg',
            receiverId: 'user2',
            voiceUrl: 'voice.m4a',
            voiceDuration: 0,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when voiceDuration exceeds 5 minutes', () async {
        expect(
          () => useCase(
            conversationId: 'conv1',
            senderId: 'user1',
            senderName: 'Test User',
            senderAvatar: 'avatar.jpg',
            receiverId: 'user2',
            voiceUrl: 'voice.m4a',
            voiceDuration: 301, // 5 minutes 1 second
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('accepts valid voice message', () async {
        when(() => mockRepository.sendVoiceMessage(
          conversationId: any(named: 'conversationId'),
          senderId: any(named: 'senderId'),
          senderName: any(named: 'senderName'),
          senderAvatar: any(named: 'senderAvatar'),
          receiverId: any(named: 'receiverId'),
          voiceUrl: any(named: 'voiceUrl'),
          voiceDuration: any(named: 'voiceDuration'),
        )).thenAnswer((_) async => 'message1');

        final result = await useCase(
          conversationId: 'conv1',
          senderId: 'user1',
          senderName: 'Test User',
          senderAvatar: 'avatar.jpg',
          receiverId: 'user2',
          voiceUrl: 'voice.m4a',
          voiceDuration: 30,
        );

        expect(result, 'message1');
        verify(() => mockRepository.sendVoiceMessage(
          conversationId: 'conv1',
          senderId: 'user1',
          senderName: 'Test User',
          senderAvatar: 'avatar.jpg',
          receiverId: 'user2',
          voiceUrl: 'voice.m4a',
          voiceDuration: 30,
        )).called(1);
      });
    });

    group('Error Handling', () {
      test('propagates repository errors', () async {
        when(() => mockRepository.sendVoiceMessage(
          conversationId: any(named: 'conversationId'),
          senderId: any(named: 'senderId'),
          senderName: any(named: 'senderName'),
          senderAvatar: any(named: 'senderAvatar'),
          receiverId: any(named: 'receiverId'),
          voiceUrl: any(named: 'voiceUrl'),
          voiceDuration: any(named: 'voiceDuration'),
        )).thenThrow(Exception('Failed to send voice message'));

        expect(
          () => useCase(
            conversationId: 'conv1',
            senderId: 'user1',
            senderName: 'Test User',
            senderAvatar: 'avatar.jpg',
            receiverId: 'user2',
            voiceUrl: 'voice.m4a',
            voiceDuration: 30,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

