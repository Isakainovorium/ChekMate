import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VoiceMessageEntity', () {
    late VoiceMessageEntity voiceMessage;

    setUp(() {
      voiceMessage = VoiceMessageEntity(
        id: 'msg123',
        senderId: 'user123',
        receiverId: 'user456',
        downloadUrl: 'https://storage.googleapis.com/voice_messages/msg123.m4a',
        duration: 45, // 45 seconds
        filePath: '/path/to/local/file.m4a',
        fileName: 'voice_1697558400000_msg123.m4a',
        fileSize: 360000, // 360 KB
        createdAt: DateTime(2025, 10, 17, 10, 30),
        isUploaded: true,
        uploadProgress: 1.0,
      );
    });

    test('should create a valid VoiceMessageEntity', () {
      expect(voiceMessage.id, 'msg123');
      expect(voiceMessage.senderId, 'user123');
      expect(voiceMessage.receiverId, 'user456');
      expect(voiceMessage.duration, 45);
      expect(voiceMessage.fileName, 'voice_1697558400000_msg123.m4a');
      expect(voiceMessage.fileSize, 360000);
      expect(voiceMessage.isPlaying, false);
      expect(voiceMessage.isUploaded, true);
    });

    test('copyWith should create a new instance with updated fields', () {
      final updated = voiceMessage.copyWith(
        isPlaying: true,
        playbackPosition: 15.5,
      );

      expect(updated.id, voiceMessage.id);
      expect(updated.isPlaying, true);
      expect(updated.playbackPosition, 15.5);
      expect(updated.duration, voiceMessage.duration);
    });

    test('formattedDuration should return MM:SS format', () {
      expect(voiceMessage.formattedDuration, '00:45');

      final longMessage = voiceMessage.copyWith(duration: 125); // 2:05
      expect(longMessage.formattedDuration, '02:05');
    });

    test('formattedPlaybackPosition should return MM:SS format', () {
      final playing = voiceMessage.copyWith(playbackPosition: 30.5);
      expect(playing.formattedPlaybackPosition, '00:30');

      final longPlayback = voiceMessage.copyWith(playbackPosition: 125.7);
      expect(longPlayback.formattedPlaybackPosition, '02:05');
    });

    test('formattedFileSize should return human-readable size', () {
      // 360 KB
      expect(voiceMessage.formattedFileSize, '351.6 KB');

      // 500 bytes
      final small = voiceMessage.copyWith(fileSize: 500);
      expect(small.formattedFileSize, '500 B');

      // 2 MB
      final large = voiceMessage.copyWith(fileSize: 2 * 1024 * 1024);
      expect(large.formattedFileSize, '2.0 MB');
    });

    test('uploadProgressPercentage should return 0-100', () {
      expect(voiceMessage.uploadProgressPercentage, 100);

      final uploading = voiceMessage.copyWith(uploadProgress: 0.5);
      expect(uploading.uploadProgressPercentage, 50);

      final notStarted = voiceMessage.copyWith(uploadProgress: 0.0);
      expect(notStarted.uploadProgressPercentage, 0);
    });

    test('playbackProgressPercentage should return 0-100', () {
      expect(voiceMessage.playbackProgressPercentage, 0);

      final halfway = voiceMessage.copyWith(playbackPosition: 22.5);
      expect(halfway.playbackProgressPercentage, 50);

      final complete = voiceMessage.copyWith(playbackPosition: 45.0);
      expect(complete.playbackProgressPercentage, 100);
    });

    test('playbackProgressPercentage should handle zero duration', () {
      final zeroDuration = voiceMessage.copyWith(duration: 0);
      expect(zeroDuration.playbackProgressPercentage, 0);
    });

    test('isReadyToPlay should return true when downloadUrl exists', () {
      expect(voiceMessage.isReadyToPlay, true);
    });

    test('isReadyToPlay should return true when filePath exists', () {
      final localOnly = voiceMessage.copyWith(downloadUrl: null);
      expect(localOnly.isReadyToPlay, true);
    });

    test('isReadyToPlay should return false when neither exists', () {
      final notReady = voiceMessage.copyWith(
        downloadUrl: null,
        filePath: null,
      );
      expect(notReady.isReadyToPlay, false);
    });

    test('isUploading should return true when upload is in progress', () {
      final uploading = voiceMessage.copyWith(
        isUploaded: false,
        uploadProgress: 0.5,
      );
      expect(uploading.isUploading, true);
    });

    test('isUploading should return false when upload is complete', () {
      expect(voiceMessage.isUploading, false);
    });

    test('isUploading should return false when upload not started', () {
      final notStarted = voiceMessage.copyWith(
        isUploaded: false,
        uploadProgress: 0.0,
      );
      expect(notStarted.isUploading, false);
    });

    test('uploadFailed should return true when upload failed', () {
      final failed = voiceMessage.copyWith(
        isUploaded: false,
        uploadProgress: 0.0,
        downloadUrl: null,
      );
      expect(failed.uploadFailed, true);
    });

    test('uploadFailed should return false when upload succeeded', () {
      expect(voiceMessage.uploadFailed, false);
    });

    test('isDownloaded should return true when filePath exists', () {
      expect(voiceMessage.isDownloaded, true);
    });

    test('isDownloaded should return false when filePath is null', () {
      final notDownloaded = voiceMessage.copyWith(filePath: null);
      expect(notDownloaded.isDownloaded, false);
    });

    test('validate should return true for valid voice message', () {
      expect(voiceMessage.validate(), true);
    });

    test('validate should return false when id is empty', () {
      final invalid = voiceMessage.copyWith(id: '');
      expect(invalid.validate(), false);
    });

    test('validate should return false when senderId is empty', () {
      final invalid = voiceMessage.copyWith(senderId: '');
      expect(invalid.validate(), false);
    });

    test('validate should return false when receiverId is empty', () {
      final invalid = voiceMessage.copyWith(receiverId: '');
      expect(invalid.validate(), false);
    });

    test('validate should return false when fileName is empty', () {
      final invalid = voiceMessage.copyWith(fileName: '');
      expect(invalid.validate(), false);
    });

    test('validate should return false when duration is 0', () {
      final invalid = voiceMessage.copyWith(duration: 0);
      expect(invalid.validate(), false);
    });

    test('validate should return false when duration exceeds 60 seconds', () {
      final invalid = voiceMessage.copyWith(duration: 61);
      expect(invalid.validate(), false);
    });

    test('validate should return false when fileSize is 0', () {
      final invalid = voiceMessage.copyWith(fileSize: 0);
      expect(invalid.validate(), false);
    });

    test('validate should return false when fileSize exceeds 5 MB', () {
      final invalid = voiceMessage.copyWith(fileSize: 6 * 1024 * 1024);
      expect(invalid.validate(), false);
    });

    test('should support equality comparison', () {
      final voiceMessage2 = VoiceMessageEntity(
        id: 'msg123',
        senderId: 'user123',
        receiverId: 'user456',
        downloadUrl: 'https://storage.googleapis.com/voice_messages/msg123.m4a',
        duration: 45,
        filePath: '/path/to/local/file.m4a',
        fileName: 'voice_1697558400000_msg123.m4a',
        fileSize: 360000,
        createdAt: DateTime(2025, 10, 17, 10, 30),
        isUploaded: true,
        uploadProgress: 1.0,
      );

      expect(voiceMessage, equals(voiceMessage2));
    });

    test('should have different hash codes for different instances', () {
      final different = voiceMessage.copyWith(id: 'msg456');
      expect(voiceMessage.hashCode, isNot(equals(different.hashCode)));
    });

    test('toString should return formatted string', () {
      final string = voiceMessage.toString();
      expect(string, contains('VoiceMessageEntity'));
      expect(string, contains('id: msg123'));
      expect(string, contains('senderId: user123'));
      expect(string, contains('duration: 45'));
    });
  });
}

