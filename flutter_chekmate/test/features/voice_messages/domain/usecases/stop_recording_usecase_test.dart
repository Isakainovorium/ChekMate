import 'package:dartz/dartz.dart';
import 'package:flutter_chekmate/core/error/failures.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/repositories/voice_recording_repository.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/usecases/stop_recording_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockVoiceRecordingRepository extends Mock
    implements VoiceRecordingRepository {}

void main() {
  late StopRecordingUseCase useCase;
  late MockVoiceRecordingRepository mockRepository;

  setUp(() {
    mockRepository = MockVoiceRecordingRepository();
    useCase = StopRecordingUseCase(mockRepository);
  });

  group('StopRecordingUseCase', () {
    final tVoiceMessage = VoiceMessageEntity(
      id: 'msg123',
      senderId: 'user123',
      receiverId: 'user456',
      duration: 45,
      filePath: '/path/to/recording.m4a',
      fileName: 'voice_1697558400000_msg123.m4a',
      fileSize: 360000,
      createdAt: DateTime(2025, 10, 17, 10, 30),
    );

    test('should return VoiceMessageEntity when recording stops successfully',
        () async {
      // Arrange
      when(() => mockRepository.stopRecording())
          .thenAnswer((_) async => Right(tVoiceMessage));

      // Act
      final result = await useCase();

      // Assert
      expect(result, Right<Failure, VoiceMessageEntity>(tVoiceMessage));
      verify(() => mockRepository.stopRecording()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return RecordingFailure when no recording is in progress',
        () async {
      // Arrange
      const tFailure = RecordingFailure('No recording in progress');
      when(() => mockRepository.stopRecording())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left<Failure, VoiceMessageEntity>(tFailure));
      verify(() => mockRepository.stopRecording()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return RecordingFailure when stop fails', () async {
      // Arrange
      const tFailure = RecordingFailure('Failed to stop recording');
      when(() => mockRepository.stopRecording())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left<Failure, VoiceMessageEntity>(tFailure));
      verify(() => mockRepository.stopRecording()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
