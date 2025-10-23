import 'package:dartz/dartz.dart';
import 'package:flutter_chekmate/core/error/failures.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/repositories/voice_recording_repository.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/usecases/start_recording_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockVoiceRecordingRepository extends Mock
    implements VoiceRecordingRepository {}

void main() {
  late StartRecordingUseCase useCase;
  late MockVoiceRecordingRepository mockRepository;

  setUp(() {
    mockRepository = MockVoiceRecordingRepository();
    useCase = StartRecordingUseCase(mockRepository);
  });

  group('StartRecordingUseCase', () {
    const tFilePath = '/path/to/recording.m4a';

    test('should return file path when recording starts successfully',
        () async {
      // Arrange
      when(() => mockRepository.startRecording())
          .thenAnswer((_) async => const Right(tFilePath));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Right<Failure, String>(tFilePath));
      verify(() => mockRepository.startRecording()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return PermissionFailure when microphone permission is denied',
        () async {
      // Arrange
      const tFailure = PermissionFailure('Microphone permission denied');
      when(() => mockRepository.startRecording())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left<Failure, String>(tFailure));
      verify(() => mockRepository.startRecording()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return RecordingFailure when recording fails to start',
        () async {
      // Arrange
      const tFailure = RecordingFailure('Failed to start recording');
      when(() => mockRepository.startRecording())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left<Failure, String>(tFailure));
      verify(() => mockRepository.startRecording()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
