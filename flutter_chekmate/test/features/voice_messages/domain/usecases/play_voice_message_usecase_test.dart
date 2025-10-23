import 'package:dartz/dartz.dart';
import 'package:flutter_chekmate/core/error/failures.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/repositories/voice_recording_repository.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/usecases/play_voice_message_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockVoiceRecordingRepository extends Mock
    implements VoiceRecordingRepository {}

void main() {
  late PlayVoiceMessageUseCase useCase;
  late MockVoiceRecordingRepository mockRepository;

  setUp(() {
    mockRepository = MockVoiceRecordingRepository();
    useCase = PlayVoiceMessageUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      VoiceMessageEntity(
        id: 'fallback',
        senderId: 'fallback',
        receiverId: 'fallback',
        duration: 1,
        fileName: 'fallback.m4a',
        fileSize: 1,
        createdAt: DateTime.now(),
      ),
    );
  });

  group('PlayVoiceMessageUseCase', () {
    final tVoiceMessage = VoiceMessageEntity(
      id: 'msg123',
      senderId: 'user123',
      receiverId: 'user456',
      downloadUrl: 'https://storage.googleapis.com/voice_messages/msg123.m4a',
      duration: 45,
      filePath: '/path/to/recording.m4a',
      fileName: 'voice_1697558400000_msg123.m4a',
      fileSize: 360000,
      createdAt: DateTime(2025, 10, 17, 10, 30),
    );

    final tPlayingMessage = tVoiceMessage.copyWith(isPlaying: true);

    test(
        'should return VoiceMessageEntity with isPlaying=true when playback starts successfully',
        () async {
      // Arrange
      when(() => mockRepository.playVoiceMessage(any()))
          .thenAnswer((_) async => Right(tPlayingMessage));

      // Act
      final result =
          await useCase(PlayVoiceMessageParams(voiceMessage: tVoiceMessage));

      // Assert
      expect(result, Right<Failure, VoiceMessageEntity>(tPlayingMessage));
      verify(() => mockRepository.playVoiceMessage(tVoiceMessage)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
        'should return ValidationFailure when voice message is not ready to play',
        () async {
      // Arrange
      final notReadyMessage = tVoiceMessage.copyWith(
        downloadUrl: null,
        filePath: null,
      );

      // Act
      final result =
          await useCase(PlayVoiceMessageParams(voiceMessage: notReadyMessage));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('not ready to play'));
        },
        (_) => fail('Should return failure'),
      );
      verifyNever(() => mockRepository.playVoiceMessage(any()));
    });

    test('should return PlaybackFailure when playback fails to start',
        () async {
      // Arrange
      const tFailure = PlaybackFailure('Failed to start playback');
      when(() => mockRepository.playVoiceMessage(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result =
          await useCase(PlayVoiceMessageParams(voiceMessage: tVoiceMessage));

      // Assert
      expect(result, const Left<Failure, VoiceMessageEntity>(tFailure));
      verify(() => mockRepository.playVoiceMessage(tVoiceMessage)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
