import 'package:dartz/dartz.dart';
import 'package:flutter_chekmate/core/error/failures.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/repositories/voice_recording_repository.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/usecases/upload_voice_message_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockVoiceRecordingRepository extends Mock
    implements VoiceRecordingRepository {}

void main() {
  late UploadVoiceMessageUseCase useCase;
  late MockVoiceRecordingRepository mockRepository;

  setUp(() {
    mockRepository = MockVoiceRecordingRepository();
    useCase = UploadVoiceMessageUseCase(mockRepository);
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

  group('UploadVoiceMessageUseCase', () {
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

    final tUploadedMessage = tVoiceMessage.copyWith(
      downloadUrl: 'https://storage.googleapis.com/voice_messages/msg123.m4a',
      isUploaded: true,
      uploadProgress: 1.0,
    );

    test(
        'should return VoiceMessageEntity with downloadUrl when upload succeeds',
        () async {
      // Arrange
      when(() => mockRepository.uploadVoiceMessage(any(),
              onProgress: any(named: 'onProgress'),),)
          .thenAnswer((_) async => Right(tUploadedMessage));

      // Act
      final result =
          await useCase(UploadVoiceMessageParams(voiceMessage: tVoiceMessage));

      // Assert
      expect(result, Right<Failure, VoiceMessageEntity>(tUploadedMessage));
      verify(() => mockRepository.uploadVoiceMessage(tVoiceMessage)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should call onProgress callback during upload', () async {
      // Arrange
      final progressValues = <double>[];
      when(() => mockRepository.uploadVoiceMessage(any(),
          onProgress: any(named: 'onProgress'),),).thenAnswer((invocation) async {
        final onProgress =
            invocation.namedArguments[#onProgress] as void Function(double)?;
        onProgress?.call(0.5);
        onProgress?.call(1.0);
        return Right(tUploadedMessage);
      });

      // Act
      final result = await useCase(
        UploadVoiceMessageParams(
          voiceMessage: tVoiceMessage,
          onProgress: (progress) => progressValues.add(progress),
        ),
      );

      // Assert
      expect(result, Right<Failure, VoiceMessageEntity>(tUploadedMessage));
      expect(progressValues, [0.5, 1.0]);
    });

    test('should return ValidationFailure when voice message validation fails',
        () async {
      // Arrange
      final invalidMessage =
          tVoiceMessage.copyWith(duration: 0); // Invalid duration

      // Act
      final result =
          await useCase(UploadVoiceMessageParams(voiceMessage: invalidMessage));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('validation failed'));
        },
        (_) => fail('Should return failure'),
      );
      verifyNever(() => mockRepository.uploadVoiceMessage(any(),
          onProgress: any(named: 'onProgress'),),);
    });

    test('should return ValidationFailure when filePath is null', () async {
      // Arrange
      final noFilePathMessage = tVoiceMessage.copyWith(filePath: null);

      // Act
      final result = await useCase(
          UploadVoiceMessageParams(voiceMessage: noFilePathMessage),);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('no local file path'));
        },
        (_) => fail('Should return failure'),
      );
      verifyNever(() => mockRepository.uploadVoiceMessage(any(),
          onProgress: any(named: 'onProgress'),),);
    });

    test('should return NetworkFailure when network is unavailable', () async {
      // Arrange
      const tFailure = NetworkFailure('Network unavailable');
      when(() => mockRepository.uploadVoiceMessage(any(),
              onProgress: any(named: 'onProgress'),),)
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result =
          await useCase(UploadVoiceMessageParams(voiceMessage: tVoiceMessage));

      // Assert
      expect(result, const Left<Failure, VoiceMessageEntity>(tFailure));
      verify(() => mockRepository.uploadVoiceMessage(tVoiceMessage)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return StorageFailure when upload to Firebase fails',
        () async {
      // Arrange
      const tFailure = StorageFailure('Upload failed');
      when(() => mockRepository.uploadVoiceMessage(any(),
              onProgress: any(named: 'onProgress'),),)
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result =
          await useCase(UploadVoiceMessageParams(voiceMessage: tVoiceMessage));

      // Assert
      expect(result, const Left<Failure, VoiceMessageEntity>(tFailure));
      verify(() => mockRepository.uploadVoiceMessage(tVoiceMessage)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
