import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chekmate/features/voice_messages/data/datasources/voice_storage_remote_data_source.dart';
import 'package:flutter_chekmate/features/voice_messages/data/models/voice_message_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockReference extends Mock implements Reference {}

class MockUploadTask extends Mock implements UploadTask {}

class MockDownloadTask extends Mock implements DownloadTask {}

class MockTaskSnapshot extends Mock implements TaskSnapshot {}

class MockFile extends Mock implements File {}

void main() {
  late VoiceStorageRemoteDataSourceImpl dataSource;
  late MockFirebaseStorage mockStorage;
  late MockReference mockRef;
  late MockUploadTask mockUploadTask;
  late MockDownloadTask mockDownloadTask;
  late MockTaskSnapshot mockSnapshot;

  setUpAll(() {
    registerFallbackValue(SettableMetadata());
    registerFallbackValue(File(''));
  });

  setUp(() {
    mockStorage = MockFirebaseStorage();
    mockRef = MockReference();
    mockUploadTask = MockUploadTask();
    mockDownloadTask = MockDownloadTask();
    mockSnapshot = MockTaskSnapshot();

    dataSource = VoiceStorageRemoteDataSourceImpl(storage: mockStorage);
  });

  group('uploadVoiceMessage', () {
    final tModel = VoiceMessageModel(
      id: 'msg123',
      senderId: 'user123',
      receiverId: 'user456',
      url: 'https://example.com/voice.mp3',
      duration: 45,
      filePath: '/temp/voice_123.m4a',
      fileName: 'voice_123.m4a',
      fileSize: 360000,
      createdAt: DateTime(2025, 10, 17),
    );

    test('should upload file and return model with download URL', () async {
      // Arrange
      const downloadUrl =
          'https://storage.googleapis.com/voice_messages/user123/voice_123.m4a';

      when(() => mockStorage.ref()).thenReturn(mockRef);
      when(() => mockRef.child(any())).thenReturn(mockRef);
      when(() => mockRef.putFile(any(), any())).thenReturn(mockUploadTask);
      when(() => mockUploadTask.snapshotEvents).thenAnswer(
        (_) => Stream.value(mockSnapshot),
      );
      when(() => mockSnapshot.bytesTransferred).thenReturn(360000);
      when(() => mockSnapshot.totalBytes).thenReturn(360000);
      when(() => mockSnapshot.ref).thenReturn(mockRef);
      when(() => mockRef.getDownloadURL()).thenAnswer((_) async => downloadUrl);

      // Act
      final result = await dataSource.uploadVoiceMessage(tModel);

      // Assert
      expect(result.downloadUrl, downloadUrl);
      expect(result.isUploaded, true);
      expect(result.uploadProgress, 1.0);
      verify(() => mockStorage.ref()).called(1);
      verify(() => mockRef.child('voice_messages/user123/voice_123.m4a'))
          .called(1);
    });

    test('should call progress callback during upload', () async {
      // Arrange
      const downloadUrl =
          'https://storage.googleapis.com/voice_messages/user123/voice_123.m4a';
      final progressValues = <double>[];

      when(() => mockStorage.ref()).thenReturn(mockRef);
      when(() => mockRef.child(any())).thenReturn(mockRef);
      when(() => mockRef.putFile(any(), any())).thenReturn(mockUploadTask);
      when(() => mockUploadTask.snapshotEvents).thenAnswer(
        (_) => Stream.fromIterable([
          mockSnapshot,
          mockSnapshot,
        ]),
      );
      when(() => mockSnapshot.bytesTransferred).thenReturn(180000);
      when(() => mockSnapshot.totalBytes).thenReturn(360000);
      when(() => mockSnapshot.ref).thenReturn(mockRef);
      when(() => mockRef.getDownloadURL()).thenAnswer((_) async => downloadUrl);

      // Act
      await dataSource.uploadVoiceMessage(
        tModel,
        onProgress: (progress) => progressValues.add(progress),
      );

      // Assert
      expect(progressValues.length, greaterThan(0));
      expect(progressValues.first, 0.5);
    });

    test('should throw StorageException if file path is null', () async {
      // Arrange
      final modelWithoutPath = tModel.copyWith(filePath: null);

      // Act & Assert
      expect(
        () => dataSource.uploadVoiceMessage(modelWithoutPath),
        throwsA(isA<StorageException>()),
      );
    });

    test('should throw StorageException if file path is empty', () async {
      // Arrange
      final modelWithEmptyPath = tModel.copyWith(filePath: '');

      // Act & Assert
      expect(
        () => dataSource.uploadVoiceMessage(modelWithEmptyPath),
        throwsA(isA<StorageException>()),
      );
    });
  });

  group('downloadVoiceMessage', () {
    final tModel = VoiceMessageModel(
      id: 'msg123',
      senderId: 'user123',
      receiverId: 'user456',
      url: 'https://example.com/voice.mp3',
      downloadUrl:
          'https://storage.googleapis.com/voice_messages/user123/voice_123.m4a',
      duration: 45,
      fileName: 'voice_123.m4a',
      fileSize: 360000,
      createdAt: DateTime(2025, 10, 17),
      isUploaded: true,
    );

    test('should download file and return model with local path', () async {
      // Arrange
      when(() => mockStorage.refFromURL(any())).thenReturn(mockRef);
      when(() => mockRef.writeToFile(any())).thenReturn(mockDownloadTask);
      when(() => mockDownloadTask.snapshotEvents).thenAnswer(
        (_) => Stream.value(mockSnapshot),
      );
      when(() => mockSnapshot.bytesTransferred).thenReturn(360000);
      when(() => mockSnapshot.totalBytes).thenReturn(360000);

      // Act
      final result = await dataSource.downloadVoiceMessage(tModel);

      // Assert
      expect(result.filePath, isNotNull);
      expect(result.filePath, contains('voice_123.m4a'));
      verify(() => mockStorage.refFromURL(tModel.downloadUrl!)).called(1);
    });

    test('should call progress callback during download', () async {
      // Arrange
      final progressValues = <double>[];

      when(() => mockStorage.refFromURL(any())).thenReturn(mockRef);
      when(() => mockRef.writeToFile(any())).thenReturn(mockDownloadTask);
      when(() => mockDownloadTask.snapshotEvents).thenAnswer(
        (_) => Stream.fromIterable([
          mockSnapshot,
          mockSnapshot,
        ]),
      );
      when(() => mockSnapshot.bytesTransferred).thenReturn(180000);
      when(() => mockSnapshot.totalBytes).thenReturn(360000);

      // Act
      await dataSource.downloadVoiceMessage(
        tModel,
        onProgress: (progress) => progressValues.add(progress),
      );

      // Assert
      expect(progressValues.length, greaterThan(0));
      expect(progressValues.first, 0.5);
    });

    test('should throw StorageException if download URL is null', () async {
      // Arrange
      final modelWithoutUrl = tModel.copyWith(downloadUrl: null);

      // Act & Assert
      expect(
        () => dataSource.downloadVoiceMessage(modelWithoutUrl),
        throwsA(isA<StorageException>()),
      );
    });

    test('should throw StorageException if download URL is empty', () async {
      // Arrange
      final modelWithEmptyUrl = tModel.copyWith(downloadUrl: '');

      // Act & Assert
      expect(
        () => dataSource.downloadVoiceMessage(modelWithEmptyUrl),
        throwsA(isA<StorageException>()),
      );
    });
  });

  group('deleteVoiceMessage', () {
    const downloadUrl =
        'https://storage.googleapis.com/voice_messages/user123/voice_123.m4a';

    test('should delete file from storage', () async {
      // Arrange
      when(() => mockStorage.refFromURL(any())).thenReturn(mockRef);
      when(() => mockRef.delete()).thenAnswer((_) async {});

      // Act
      final result = await dataSource.deleteVoiceMessage(downloadUrl);

      // Assert
      expect(result, true);
      verify(() => mockStorage.refFromURL(downloadUrl)).called(1);
      verify(() => mockRef.delete()).called(1);
    });

    test('should return true if file already deleted', () async {
      // Arrange
      when(() => mockStorage.refFromURL(any())).thenReturn(mockRef);
      when(() => mockRef.delete()).thenThrow(
        FirebaseException(
          plugin: 'firebase_storage',
          code: 'object-not-found',
        ),
      );

      // Act
      final result = await dataSource.deleteVoiceMessage(downloadUrl);

      // Assert
      expect(result, true);
    });

    test('should throw StorageException on other Firebase errors', () async {
      // Arrange
      when(() => mockStorage.refFromURL(any())).thenReturn(mockRef);
      when(() => mockRef.delete()).thenThrow(
        FirebaseException(
          plugin: 'firebase_storage',
          code: 'unauthorized',
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.deleteVoiceMessage(downloadUrl),
        throwsA(isA<StorageException>()),
      );
    });
  });

  group('getDownloadUrl', () {
    const userId = 'user123';
    const fileName = 'voice_123.m4a';
    const downloadUrl =
        'https://storage.googleapis.com/voice_messages/user123/voice_123.m4a';

    test('should return download URL for existing file', () async {
      // Arrange
      when(() => mockStorage.ref()).thenReturn(mockRef);
      when(() => mockRef.child(any())).thenReturn(mockRef);
      when(() => mockRef.getDownloadURL()).thenAnswer((_) async => downloadUrl);

      // Act
      final result = await dataSource.getDownloadUrl(userId, fileName);

      // Assert
      expect(result, downloadUrl);
      verify(() => mockStorage.ref()).called(1);
      verify(() => mockRef.child('voice_messages/$userId/$fileName')).called(1);
    });

    test('should throw StorageException if file not found', () async {
      // Arrange
      when(() => mockStorage.ref()).thenReturn(mockRef);
      when(() => mockRef.child(any())).thenReturn(mockRef);
      when(() => mockRef.getDownloadURL()).thenThrow(
        FirebaseException(
          plugin: 'firebase_storage',
          code: 'object-not-found',
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.getDownloadUrl(userId, fileName),
        throwsA(isA<StorageException>()),
      );
    });
  });
}
