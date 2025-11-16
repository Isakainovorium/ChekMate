import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/features/voice_messages/data/models/voice_message_model.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VoiceMessageModel', () {
    final tDateTime = DateTime(2025, 10, 17, 10, 30);
    
    final tVoiceMessageModel = VoiceMessageModel(
      id: 'msg123',
      senderId: 'user123',
      receiverId: 'user456',
      url: 'https://example.com/voice.mp3',
      downloadUrl: 'https://storage.googleapis.com/voice_messages/msg123.m4a',
      duration: 45,
      filePath: '/path/to/local/file.m4a',
      fileName: 'voice_1697558400000_msg123.m4a',
      fileSize: 360000,
      createdAt: tDateTime,
      isUploaded: true,
      uploadProgress: 1.0,
    );

    test('should be a subclass of VoiceMessageEntity', () {
      expect(tVoiceMessageModel, isA<VoiceMessageEntity>());
    });

    group('fromEntity', () {
      test('should create VoiceMessageModel from VoiceMessageEntity', () {
        // Arrange
        final entity = VoiceMessageEntity(
          id: 'msg123',
          senderId: 'user123',
          receiverId: 'user456',
          url: 'https://example.com/voice.mp3',
          downloadUrl: 'https://storage.googleapis.com/voice_messages/msg123.m4a',
          duration: 45,
          filePath: '/path/to/local/file.m4a',
          fileName: 'voice_1697558400000_msg123.m4a',
          fileSize: 360000,
          createdAt: tDateTime,
        );

        // Act
        final model = VoiceMessageModel.fromEntity(entity);

        // Assert
        expect(model.id, entity.id);
        expect(model.senderId, entity.senderId);
        expect(model.receiverId, entity.receiverId);
        expect(model.downloadUrl, entity.downloadUrl);
        expect(model.duration, entity.duration);
        expect(model.filePath, entity.filePath);
        expect(model.fileName, entity.fileName);
        expect(model.fileSize, entity.fileSize);
        expect(model.createdAt, entity.createdAt);
      });
    });

    group('fromJson', () {
      test('should create VoiceMessageModel from JSON map', () {
        // Arrange
        final json = {
          'id': 'msg123',
          'senderId': 'user123',
          'receiverId': 'user456',
          'downloadUrl': 'https://storage.googleapis.com/voice_messages/msg123.m4a',
          'duration': 45,
          'filePath': '/path/to/local/file.m4a',
          'fileName': 'voice_1697558400000_msg123.m4a',
          'fileSize': 360000,
          'createdAt': tDateTime.toIso8601String(),
          'isPlaying': false,
          'playbackPosition': 0.0,
          'isUploaded': true,
          'uploadProgress': 1.0,
        };

        // Act
        final model = VoiceMessageModel.fromJson(json);

        // Assert
        expect(model.id, 'msg123');
        expect(model.senderId, 'user123');
        expect(model.receiverId, 'user456');
        expect(model.downloadUrl, 'https://storage.googleapis.com/voice_messages/msg123.m4a');
        expect(model.duration, 45);
        expect(model.filePath, '/path/to/local/file.m4a');
        expect(model.fileName, 'voice_1697558400000_msg123.m4a');
        expect(model.fileSize, 360000);
        expect(model.createdAt, tDateTime);
        expect(model.isPlaying, false);
        expect(model.playbackPosition, 0.0);
        expect(model.isUploaded, true);
        expect(model.uploadProgress, 1.0);
      });

      test('should handle null optional fields in JSON', () {
        // Arrange
        final json = {
          'id': 'msg123',
          'senderId': 'user123',
          'receiverId': 'user456',
          'duration': 45,
          'fileName': 'voice_1697558400000_msg123.m4a',
          'fileSize': 360000,
          'createdAt': tDateTime.toIso8601String(),
        };

        // Act
        final model = VoiceMessageModel.fromJson(json);

        // Assert
        expect(model.downloadUrl, null);
        expect(model.filePath, null);
        expect(model.isPlaying, false);
        expect(model.playbackPosition, 0.0);
        expect(model.isUploaded, false);
        expect(model.uploadProgress, 0.0);
      });
    });

    group('toJson', () {
      test('should convert VoiceMessageModel to JSON map', () {
        // Act
        final json = tVoiceMessageModel.toJson();

        // Assert
        expect(json['id'], 'msg123');
        expect(json['senderId'], 'user123');
        expect(json['receiverId'], 'user456');
        expect(json['downloadUrl'], 'https://storage.googleapis.com/voice_messages/msg123.m4a');
        expect(json['duration'], 45);
        expect(json['filePath'], '/path/to/local/file.m4a');
        expect(json['fileName'], 'voice_1697558400000_msg123.m4a');
        expect(json['fileSize'], 360000);
        expect(json['createdAt'], tDateTime.toIso8601String());
        expect(json['isPlaying'], false);
        expect(json['playbackPosition'], 0.0);
        expect(json['isUploaded'], true);
        expect(json['uploadProgress'], 1.0);
      });
    });

    group('toFirestore', () {
      test('should convert VoiceMessageModel to Firestore map', () {
        // Act
        final firestoreMap = tVoiceMessageModel.toFirestore();

        // Assert
        expect(firestoreMap['senderId'], 'user123');
        expect(firestoreMap['receiverId'], 'user456');
        expect(firestoreMap['downloadUrl'], 'https://storage.googleapis.com/voice_messages/msg123.m4a');
        expect(firestoreMap['duration'], 45);
        expect(firestoreMap['fileName'], 'voice_1697558400000_msg123.m4a');
        expect(firestoreMap['fileSize'], 360000);
        expect(firestoreMap['createdAt'], isA<Timestamp>());
        expect(firestoreMap['isUploaded'], true);
        
        // Verify fields not included in Firestore
        expect(firestoreMap.containsKey('id'), false);
        expect(firestoreMap.containsKey('filePath'), false);
        expect(firestoreMap.containsKey('isPlaying'), false);
        expect(firestoreMap.containsKey('playbackPosition'), false);
        expect(firestoreMap.containsKey('uploadProgress'), false);
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        // Act
        final updated = tVoiceMessageModel.copyWith(
          isPlaying: true,
          playbackPosition: 15.5,
        );

        // Assert
        expect(updated.id, tVoiceMessageModel.id);
        expect(updated.isPlaying, true);
        expect(updated.playbackPosition, 15.5);
        expect(updated.duration, tVoiceMessageModel.duration);
      });

      test('should handle explicit null values', () {
        // Act
        final updated = tVoiceMessageModel.copyWith(
          downloadUrl: null,
          filePath: null,
        );

        // Assert
        expect(updated.downloadUrl, null);
        expect(updated.filePath, null);
        expect(updated.id, tVoiceMessageModel.id);
      });
    });
  });
}

