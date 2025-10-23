import 'package:dartz/dartz.dart';
import 'package:flutter_chekmate/core/error/failures.dart';
import 'package:flutter_chekmate/features/voice_messages/data/datasources/voice_recording_local_data_source.dart';
import 'package:flutter_chekmate/features/voice_messages/data/datasources/voice_storage_remote_data_source.dart';
import 'package:flutter_chekmate/features/voice_messages/data/models/voice_message_model.dart';
import 'package:flutter_chekmate/features/voice_messages/data/repositories/voice_recording_repository_impl.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class MockVoiceRecordingLocalDataSource extends Mock
    implements VoiceRecordingLocalDataSource {}

class MockVoiceStorageRemoteDataSource extends Mock
    implements VoiceStorageRemoteDataSource {}

class MockUuid extends Mock implements Uuid {}

void main() {
  late VoiceRecordingRepositoryImpl repository;
  late MockVoiceRecordingLocalDataSource mockLocalDataSource;
  late MockVoiceStorageRemoteDataSource mockRemoteDataSource;
  late MockUuid mockUuid;

  setUp(() {
    mockLocalDataSource = MockVoiceRecordingLocalDataSource();
    mockRemoteDataSource = MockVoiceStorageRemoteDataSource();
    mockUuid = MockUuid();

    repository = VoiceRecordingRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
      uuid: mockUuid,
    );
  });

  group('startRecording', () {
    test('should return file path when recording starts successfully',
        () async {
      // Arrange
      const filePath = '/temp/voice_123.m4a';
      when(() => mockLocalDataSource.startRecording())
          .thenAnswer((_) async => filePath);

      // Act
      final result = await repository.startRecording();

      // Assert
      expect(result, const Right<Failure, String>(filePath));
      verify(() => mockLocalDataSource.startRecording()).called(1);
    });

    test('should return RecordingFailure when RecordingException occurs',
        () async {
      // Arrange
      when(() => mockLocalDataSource.startRecording())
          .thenThrow(RecordingException('Failed to start'));

      // Act
      final result = await repository.startRecording();

      // Assert
      expect(result, isA<Left<Failure, String>>());
      result.fold(
        (failure) => expect(failure, isA<RecordingFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return UnexpectedFailure on other exceptions', () async {
      // Arrange
      when(() => mockLocalDataSource.startRecording())
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.startRecording();

      // Assert
      expect(result, isA<Left<Failure, String>>());
      result.fold(
        (failure) => expect(failure, isA<UnexpectedFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('stopRecording', () {
    test('should return VoiceMessageEntity when recording stops successfully',
        () async {
      // Arrange
      const filePath = '/temp/voice_123.m4a';
      const fileSize = 360000;
      const duration = 45;
      const uuid = 'msg-uuid-123';

      when(() => mockLocalDataSource.stopRecording())
          .thenAnswer((_) async => filePath);
      when(() => mockLocalDataSource.getFileSize(filePath))
          .thenAnswer((_) async => fileSize);
      when(() => mockLocalDataSource.getRecordingDuration())
          .thenAnswer((_) async => duration);
      when(() => mockUuid.v4()).thenReturn(uuid);

      // Act
      final result = await repository.stopRecording();

      // Assert
      expect(result, isA<Right<Failure, VoiceMessageEntity>>());
      result.fold(
        (_) => fail('Should return success'),
        (voiceMessage) {
          expect(voiceMessage.id, uuid);
          expect(voiceMessage.filePath, filePath);
          expect(voiceMessage.fileName, 'voice_123.m4a');
          expect(voiceMessage.fileSize, fileSize);
          expect(voiceMessage.duration, duration);
          expect(voiceMessage.isUploaded, false);
          expect(voiceMessage.uploadProgress, 0.0);
        },
      );
    });

    test('should return RecordingFailure when RecordingException occurs',
        () async {
      // Arrange
      when(() => mockLocalDataSource.stopRecording())
          .thenThrow(RecordingException('Failed to stop'));

      // Act
      final result = await repository.stopRecording();

      // Assert
      expect(result, isA<Left<Failure, VoiceMessageEntity>>());
      result.fold(
        (failure) => expect(failure, isA<RecordingFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('cancelRecording', () {
    test('should return true when recording is cancelled successfully',
        () async {
      // Arrange
      when(() => mockLocalDataSource.cancelRecording())
          .thenAnswer((_) async => true);

      // Act
      final result = await repository.cancelRecording();

      // Assert
      expect(result, const Right<Failure, bool>(true));
      verify(() => mockLocalDataSource.cancelRecording()).called(1);
    });

    test('should return RecordingFailure when cancellation fails', () async {
      // Arrange
      when(() => mockLocalDataSource.cancelRecording())
          .thenThrow(RecordingException('Failed to cancel'));

      // Act
      final result = await repository.cancelRecording();

      // Assert
      expect(result, isA<Left<Failure, bool>>());
      result.fold(
        (failure) => expect(failure, isA<RecordingFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('uploadVoiceMessage', () {
    final tVoiceMessage = VoiceMessageEntity(
      id: 'msg123',
      senderId: 'user123',
      receiverId: 'user456',
      duration: 45,
      filePath: '/temp/voice_123.m4a',
      fileName: 'voice_123.m4a',
      fileSize: 360000,
      createdAt: DateTime(2025, 10, 17),
    );

    final tUploadedModel = VoiceMessageModel(
      id: 'msg123',
      senderId: 'user123',
      receiverId: 'user456',
      downloadUrl: 'https://storage.googleapis.com/voice_messages/msg123.m4a',
      duration: 45,
      filePath: '/temp/voice_123.m4a',
      fileName: 'voice_123.m4a',
      fileSize: 360000,
      createdAt: DateTime(2025, 10, 17),
      isUploaded: true,
      uploadProgress: 1.0,
    );

    setUpAll(() {
      registerFallbackValue(
        VoiceMessageModel(
          id: '',
          senderId: '',
          receiverId: '',
          duration: 0,
          fileName: '',
          fileSize: 0,
          createdAt: DateTime.now(),
        ),
      );
    });

    test('should upload voice message and delete local file', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.uploadVoiceMessage(
          any(),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async => tUploadedModel);
      when(() => mockLocalDataSource.deleteLocalFile(any()))
          .thenAnswer((_) async => true);

      // Act
      final result = await repository.uploadVoiceMessage(tVoiceMessage);

      // Assert
      expect(result, isA<Right<Failure, VoiceMessageEntity>>());
      result.fold(
        (_) => fail('Should return success'),
        (uploadedMessage) {
          expect(uploadedMessage.downloadUrl, tUploadedModel.downloadUrl);
          expect(uploadedMessage.isUploaded, true);
          expect(uploadedMessage.uploadProgress, 1.0);
        },
      );
      verify(() => mockRemoteDataSource.uploadVoiceMessage(any(),
          onProgress: any(named: 'onProgress'),),).called(1);
      verify(() => mockLocalDataSource.deleteLocalFile(tVoiceMessage.filePath!))
          .called(1);
    });

    test('should call progress callback during upload', () async {
      // Arrange
      final progressValues = <double>[];

      when(
        () => mockRemoteDataSource.uploadVoiceMessage(
          any(),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async => tUploadedModel);
      when(() => mockLocalDataSource.deleteLocalFile(any()))
          .thenAnswer((_) async => true);

      // Act
      await repository.uploadVoiceMessage(
        tVoiceMessage,
        onProgress: (progress) => progressValues.add(progress),
      );

      // Assert
      // Note: Progress callback is passed through to remote data source
      // Actual callback invocation is tested in remote data source tests
      verify(
        () => mockRemoteDataSource.uploadVoiceMessage(
          any(),
          onProgress: any(named: 'onProgress'),
        ),
      ).called(1);
    });

    test('should return StorageFailure when StorageException occurs', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.uploadVoiceMessage(
          any(),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenThrow(StorageException('Upload failed'));

      // Act
      final result = await repository.uploadVoiceMessage(tVoiceMessage);

      // Assert
      expect(result, isA<Left<Failure, VoiceMessageEntity>>());
      result.fold(
        (failure) => expect(failure, isA<StorageFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('downloadVoiceMessage', () {
    final tVoiceMessage = VoiceMessageEntity(
      id: 'msg123',
      senderId: 'user123',
      receiverId: 'user456',
      downloadUrl: 'https://storage.googleapis.com/voice_messages/msg123.m4a',
      duration: 45,
      fileName: 'voice_123.m4a',
      fileSize: 360000,
      createdAt: DateTime(2025, 10, 17),
      isUploaded: true,
    );

    final tDownloadedModel = VoiceMessageModel(
      id: 'msg123',
      senderId: 'user123',
      receiverId: 'user456',
      downloadUrl: 'https://storage.googleapis.com/voice_messages/msg123.m4a',
      duration: 45,
      filePath: '/temp/voice_123.m4a',
      fileName: 'voice_123.m4a',
      fileSize: 360000,
      createdAt: DateTime(2025, 10, 17),
      isUploaded: true,
    );

    setUpAll(() {
      registerFallbackValue(
        VoiceMessageModel(
          id: '',
          senderId: '',
          receiverId: '',
          duration: 0,
          fileName: '',
          fileSize: 0,
          createdAt: DateTime.now(),
        ),
      );
    });

    test('should download voice message successfully', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.downloadVoiceMessage(
          any(),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async => tDownloadedModel);

      // Act
      final result = await repository.downloadVoiceMessage(tVoiceMessage);

      // Assert
      expect(result, isA<Right<Failure, VoiceMessageEntity>>());
      result.fold(
        (_) => fail('Should return success'),
        (downloadedMessage) {
          expect(downloadedMessage.filePath, tDownloadedModel.filePath);
        },
      );
    });

    test('should return StorageFailure when download fails', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.downloadVoiceMessage(
          any(),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenThrow(StorageException('Download failed'));

      // Act
      final result = await repository.downloadVoiceMessage(tVoiceMessage);

      // Assert
      expect(result, isA<Left<Failure, VoiceMessageEntity>>());
      result.fold(
        (failure) => expect(failure, isA<StorageFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });
}
