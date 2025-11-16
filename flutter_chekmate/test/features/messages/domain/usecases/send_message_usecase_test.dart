import 'package:flutter_chekmate/features/messages/domain/repositories/messages_repository.dart';
import 'package:flutter_chekmate/features/messages/domain/usecases/send_message_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMessagesRepository extends Mock implements MessagesRepository {}

void main() {
  group('SendMessageUseCase', () {
    late SendMessageUseCase useCase;
    late MockMessagesRepository mockRepository;

    setUp(() {
      mockRepository = MockMessagesRepository();
      useCase = SendMessageUseCase(mockRepository);
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
            content: 'Test message',
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
            content: 'Test message',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when senderName is empty', () async {
        expect(
          () => useCase(
            conversationId: 'conv1',
            senderId: 'user1',
            senderName: '',
            senderAvatar: 'avatar.jpg',
            receiverId: 'user2',
            content: 'Test message',
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
            content: 'Test message',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when content is empty', () async {
        expect(
          () => useCase(
            conversationId: 'conv1',
            senderId: 'user1',
            senderName: 'Test User',
            senderAvatar: 'avatar.jpg',
            receiverId: 'user2',
            content: '',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('throws exception when content exceeds 5000 characters', () async {
        final longContent = 'a' * 5001;
        expect(
          () => useCase(
            conversationId: 'conv1',
            senderId: 'user1',
            senderName: 'Test User',
            senderAvatar: 'avatar.jpg',
            receiverId: 'user2',
            content: longContent,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('trims whitespace from content', () async {
        when(() => mockRepository.sendMessage(
          conversationId: any(named: 'conversationId'),
          senderId: any(named: 'senderId'),
          senderName: any(named: 'senderName'),
          senderAvatar: any(named: 'senderAvatar'),
          receiverId: any(named: 'receiverId'),
          content: any(named: 'content'),
        )).thenAnswer((_) async => 'message1');

        await useCase(
          conversationId: 'conv1',
          senderId: 'user1',
          senderName: 'Test User',
          senderAvatar: 'avatar.jpg',
          receiverId: 'user2',
          content: '  Test message  ',
        );

        verify(() => mockRepository.sendMessage(
          conversationId: 'conv1',
          senderId: 'user1',
          senderName: 'Test User',
          senderAvatar: 'avatar.jpg',
          receiverId: 'user2',
          content: 'Test message',
        )).called(1);
      });

      test('accepts valid message', () async {
        when(() => mockRepository.sendMessage(
          conversationId: any(named: 'conversationId'),
          senderId: any(named: 'senderId'),
          senderName: any(named: 'senderName'),
          senderAvatar: any(named: 'senderAvatar'),
          receiverId: any(named: 'receiverId'),
          content: any(named: 'content'),
        )).thenAnswer((_) async => 'message1');

        final result = await useCase(
          conversationId: 'conv1',
          senderId: 'user1',
          senderName: 'Test User',
          senderAvatar: 'avatar.jpg',
          receiverId: 'user2',
          content: 'Test message',
        );

        expect(result, 'message1');
        verify(() => mockRepository.sendMessage(
          conversationId: 'conv1',
          senderId: 'user1',
          senderName: 'Test User',
          senderAvatar: 'avatar.jpg',
          receiverId: 'user2',
          content: 'Test message',
        )).called(1);
      });
    });

    group('Error Handling', () {
      test('propagates repository errors', () async {
        when(() => mockRepository.sendMessage(
          conversationId: any(named: 'conversationId'),
          senderId: any(named: 'senderId'),
          senderName: any(named: 'senderName'),
          senderAvatar: any(named: 'senderAvatar'),
          receiverId: any(named: 'receiverId'),
          content: any(named: 'content'),
        )).thenThrow(Exception('Failed to send message'));

        expect(
          () => useCase(
            conversationId: 'conv1',
            senderId: 'user1',
            senderName: 'Test User',
            senderAvatar: 'avatar.jpg',
            receiverId: 'user2',
            content: 'Test message',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

