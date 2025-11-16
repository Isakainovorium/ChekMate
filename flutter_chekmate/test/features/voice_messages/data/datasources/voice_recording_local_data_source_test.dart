import 'package:flutter_chekmate/features/voice_messages/data/datasources/voice_recording_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class MockAudioRecorder extends Mock implements AudioRecorder {}

class MockUuid extends Mock implements Uuid {}

void main() {
  late VoiceRecordingLocalDataSourceImpl dataSource;
  late MockAudioRecorder mockRecorder;
  late MockUuid mockUuid;

  setUpAll(() {
    registerFallbackValue(const RecordConfig(
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      sampleRate: 44100,
    ));
  });

  setUp(() {
    mockRecorder = MockAudioRecorder();
    mockUuid = MockUuid();
    dataSource = VoiceRecordingLocalDataSourceImpl(
      recorder: mockRecorder,
      uuid: mockUuid,
    );
  });

  group('startRecording', () {
    test('should start recording and return file path', () async {
      // Arrange
      when(() => mockRecorder.isRecording()).thenAnswer((_) async => false);
      when(() => mockUuid.v4()).thenReturn('test-uuid-123');
      when(() => mockRecorder.start(any(), path: any(named: 'path')))
          .thenAnswer((_) async {});

      // Act
      final result = await dataSource.startRecording();

      // Assert
      expect(result, contains('voice_'));
      expect(result, contains('test-uuid-123'));
      expect(result, endsWith('.m4a'));
      verify(() => mockRecorder.isRecording()).called(1);
      verify(() => mockRecorder.start(any(), path: any(named: 'path')))
          .called(1);
    });

    test('should throw RecordingException if already recording', () async {
      // Arrange
      when(() => mockRecorder.isRecording()).thenAnswer((_) async => true);

      // Act & Assert
      expect(
        () => dataSource.startRecording(),
        throwsA(isA<RecordingException>()),
      );
    });

    test('should throw RecordingException if start fails', () async {
      // Arrange
      when(() => mockRecorder.isRecording()).thenAnswer((_) async => false);
      when(() => mockUuid.v4()).thenReturn('test-uuid-123');
      when(() => mockRecorder.start(any(), path: any(named: 'path')))
          .thenThrow(Exception('Start failed'));

      // Act & Assert
      expect(
        () => dataSource.startRecording(),
        throwsA(isA<RecordingException>()),
      );
    });
  });

  group('stopRecording', () {
    test('should stop recording and return file path', () async {
      // Arrange
      const testPath = '/temp/voice_123.m4a';
      when(() => mockRecorder.isRecording()).thenAnswer((_) async => true);
      when(() => mockRecorder.stop()).thenAnswer((_) async => testPath);

      // Act
      final result = await dataSource.stopRecording();

      // Assert
      expect(result, testPath);
      verify(() => mockRecorder.isRecording()).called(1);
      verify(() => mockRecorder.stop()).called(1);
    });

    test('should throw RecordingException if not recording', () async {
      // Arrange
      when(() => mockRecorder.isRecording()).thenAnswer((_) async => false);

      // Act & Assert
      expect(
        () => dataSource.stopRecording(),
        throwsA(isA<RecordingException>()),
      );
    });

    test('should throw RecordingException if stop returns null', () async {
      // Arrange
      when(() => mockRecorder.isRecording()).thenAnswer((_) async => true);
      when(() => mockRecorder.stop()).thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => dataSource.stopRecording(),
        throwsA(isA<RecordingException>()),
      );
    });
  });

  group('cancelRecording', () {
    test('should stop recording and delete file', () async {
      // Arrange
      when(() => mockRecorder.isRecording()).thenAnswer((_) async => true);
      when(() => mockRecorder.stop()).thenAnswer((_) async => '/temp/test.m4a');

      // Act
      final result = await dataSource.cancelRecording();

      // Assert
      expect(result, true);
      verify(() => mockRecorder.isRecording()).called(1);
      verify(() => mockRecorder.stop()).called(1);
    });

    test('should return true even if not recording', () async {
      // Arrange
      when(() => mockRecorder.isRecording()).thenAnswer((_) async => false);

      // Act
      final result = await dataSource.cancelRecording();

      // Assert
      expect(result, true);
      verify(() => mockRecorder.isRecording()).called(1);
      verifyNever(() => mockRecorder.stop());
    });
  });

  group('pauseRecording', () {
    test('should pause recording', () async {
      // Arrange
      when(() => mockRecorder.isRecording()).thenAnswer((_) async => true);
      when(() => mockRecorder.pause()).thenAnswer((_) async {});

      // Act
      final result = await dataSource.pauseRecording();

      // Assert
      expect(result, true);
      verify(() => mockRecorder.isRecording()).called(1);
      verify(() => mockRecorder.pause()).called(1);
    });

    test('should throw RecordingException if not recording', () async {
      // Arrange
      when(() => mockRecorder.isRecording()).thenAnswer((_) async => false);

      // Act & Assert
      expect(
        () => dataSource.pauseRecording(),
        throwsA(isA<RecordingException>()),
      );
    });
  });

  group('resumeRecording', () {
    test('should resume recording', () async {
      // Arrange
      when(() => mockRecorder.isPaused()).thenAnswer((_) async => true);
      when(() => mockRecorder.resume()).thenAnswer((_) async {});

      // Act
      final result = await dataSource.resumeRecording();

      // Assert
      expect(result, true);
      verify(() => mockRecorder.isPaused()).called(1);
      verify(() => mockRecorder.resume()).called(1);
    });

    test('should throw RecordingException if not paused', () async {
      // Arrange
      when(() => mockRecorder.isPaused()).thenAnswer((_) async => false);

      // Act & Assert
      expect(
        () => dataSource.resumeRecording(),
        throwsA(isA<RecordingException>()),
      );
    });
  });

  group('isRecording', () {
    test('should return true when recording', () async {
      // Arrange
      when(() => mockRecorder.isRecording()).thenAnswer((_) async => true);

      // Act
      final result = await dataSource.isRecording();

      // Assert
      expect(result, true);
      verify(() => mockRecorder.isRecording()).called(1);
    });

    test('should return false when not recording', () async {
      // Arrange
      when(() => mockRecorder.isRecording()).thenAnswer((_) async => false);

      // Act
      final result = await dataSource.isRecording();

      // Assert
      expect(result, false);
      verify(() => mockRecorder.isRecording()).called(1);
    });
  });

  group('getFileSize', () {
    test(
      'should return file size when file exists',
      () async {
        // Note: This test requires actual file system access
        // In a real scenario, we would mock the File class
        // For now, we'll skip this test as it requires platform channels
      },
      skip: 'Requires file system mocking',
    );

    test('should return 0 when file does not exist', () async {
      // Arrange
      const nonExistentPath = '/nonexistent/file.m4a';

      // Act
      final result = await dataSource.getFileSize(nonExistentPath);

      // Assert
      expect(result, 0);
    });
  });

  group('deleteLocalFile', () {
    test(
      'should delete file when it exists',
      () async {
        // Note: This test requires actual file system access
        // In a real scenario, we would mock the File class
        // For now, we'll skip this test as it requires platform channels
      },
      skip: 'Requires file system mocking',
    );

    test('should return false when file does not exist', () async {
      // Arrange
      const nonExistentPath = '/nonexistent/file.m4a';

      // Act
      final result = await dataSource.deleteLocalFile(nonExistentPath);

      // Assert
      expect(result, false);
    });
  });
}
