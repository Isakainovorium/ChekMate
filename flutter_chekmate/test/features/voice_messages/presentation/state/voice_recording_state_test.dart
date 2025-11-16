import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/state/voice_recording_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VoiceRecordingState', () {
    group('initial state', () {
      test('should have idle status', () {
        final state = VoiceRecordingState.initial();

        expect(state.status, VoiceRecordingStatus.idle);
        expect(state.duration, 0);
        expect(state.maxDuration, 60);
        expect(state.filePath, null);
        expect(state.voiceMessage, null);
        expect(state.uploadProgress, 0.0);
        expect(state.errorMessage, null);
      });

      test('should have correct boolean getters', () {
        final state = VoiceRecordingState.initial();

        expect(state.isIdle, true);
        expect(state.isRecording, false);
        expect(state.isPaused, false);
        expect(state.isProcessing, false);
        expect(state.isUploading, false);
        expect(state.isCompleted, false);
        expect(state.hasError, false);
      });
    });

    group('recording state', () {
      test('should create recording state correctly', () {
        final state = VoiceRecordingState.recording(
          duration: 10,
          filePath: '/path/to/file.m4a',
        );

        expect(state.status, VoiceRecordingStatus.recording);
        expect(state.duration, 10);
        expect(state.maxDuration, 60);
        expect(state.filePath, '/path/to/file.m4a');
        expect(state.isRecording, true);
      });

      test('should format duration correctly', () {
        final state = VoiceRecordingState.recording(duration: 125);

        expect(state.formattedDuration, '02:05');
      });

      test('should format remaining time correctly', () {
        final state = VoiceRecordingState.recording(
          duration: 25,
        );

        expect(state.formattedRemainingTime, '00:35');
      });

      test('should calculate progress correctly', () {
        final state = VoiceRecordingState.recording(
          duration: 30,
        );

        expect(state.progress, 0.5);
      });

      test('should detect max duration reached', () {
        final state = VoiceRecordingState.recording(
          duration: 60,
        );

        expect(state.hasReachedMaxDuration, true);
      });
    });

    group('paused state', () {
      test('should create paused state correctly', () {
        final state = VoiceRecordingState.paused(
          duration: 15,
          filePath: '/path/to/file.m4a',
        );

        expect(state.status, VoiceRecordingStatus.paused);
        expect(state.duration, 15);
        expect(state.isPaused, true);
        expect(state.canResume, true);
      });
    });

    group('processing state', () {
      test('should create processing state correctly', () {
        final state = VoiceRecordingState.processing(
          duration: 30,
          filePath: '/path/to/file.m4a',
        );

        expect(state.status, VoiceRecordingStatus.processing);
        expect(state.duration, 30);
        expect(state.isProcessing, true);
      });
    });

    group('uploading state', () {
      test('should create uploading state correctly', () {
        final voiceMessage = VoiceMessageEntity(
          id: 'msg123',
          senderId: 'user1',
          receiverId: 'user2',
          url: 'https://example.com/voice.mp3',
          duration: 30,
          fileName: 'voice.m4a',
          fileSize: 1024,
          createdAt: DateTime.now(),
        );

        final state = VoiceRecordingState.uploading(
          duration: 30,
          filePath: '/path/to/file.m4a',
          voiceMessage: voiceMessage,
          uploadProgress: 0.5,
        );

        expect(state.status, VoiceRecordingStatus.uploading);
        expect(state.voiceMessage, voiceMessage);
        expect(state.uploadProgress, 0.5);
        expect(state.isUploading, true);
      });
    });

    group('completed state', () {
      test('should create completed state correctly', () {
        final voiceMessage = VoiceMessageEntity(
          id: 'msg123',
          senderId: 'user1',
          receiverId: 'user2',
          url: 'https://example.com/voice.mp3',
          duration: 30,
          fileName: 'voice.m4a',
          fileSize: 1024,
          createdAt: DateTime.now(),
        );

        final state = VoiceRecordingState.completed(
          duration: 30,
          filePath: '/path/to/file.m4a',
          voiceMessage: voiceMessage,
        );

        expect(state.status, VoiceRecordingStatus.completed);
        expect(state.voiceMessage, voiceMessage);
        expect(state.uploadProgress, 1.0);
        expect(state.isCompleted, true);
      });
    });

    group('error state', () {
      test('should create error state correctly', () {
        final state = VoiceRecordingState.error(
          errorMessage: 'Recording failed',
          duration: 10,
        );

        expect(state.status, VoiceRecordingStatus.error);
        expect(state.errorMessage, 'Recording failed');
        expect(state.duration, 10);
        expect(state.hasError, true);
      });
    });

    group('copyWith', () {
      test('should copy with new values', () {
        final original = VoiceRecordingState.initial();
        final copied = original.copyWith(
          status: VoiceRecordingStatus.recording,
          duration: 10,
        );

        expect(copied.status, VoiceRecordingStatus.recording);
        expect(copied.duration, 10);
        expect(copied.maxDuration, original.maxDuration);
      });

      test('should keep original values when not specified', () {
        final original = VoiceRecordingState.recording(
          duration: 10,
          filePath: '/path/to/file.m4a',
        );
        final copied = original.copyWith(duration: 20);

        expect(copied.duration, 20);
        expect(copied.maxDuration, 60);
        expect(copied.filePath, '/path/to/file.m4a');
        expect(copied.status, VoiceRecordingStatus.recording);
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        final state1 = VoiceRecordingState.recording(
          duration: 10,
        );
        final state2 = VoiceRecordingState.recording(
          duration: 10,
        );

        expect(state1, state2);
      });

      test('should not be equal when properties differ', () {
        final state1 = VoiceRecordingState.recording(duration: 10);
        final state2 = VoiceRecordingState.recording(duration: 20);

        expect(state1, isNot(state2));
      });
    });

    group('boolean getters', () {
      test('canStop should be true when recording or paused', () {
        final recordingState = VoiceRecordingState.recording(duration: 10);
        final pausedState = VoiceRecordingState.paused(duration: 10);
        final idleState = VoiceRecordingState.initial();

        expect(recordingState.canStop, true);
        expect(pausedState.canStop, true);
        expect(idleState.canStop, false);
      });

      test('canPause should be true only when recording', () {
        final recordingState = VoiceRecordingState.recording(duration: 10);
        final pausedState = VoiceRecordingState.paused(duration: 10);
        final idleState = VoiceRecordingState.initial();

        expect(recordingState.canPause, true);
        expect(pausedState.canPause, false);
        expect(idleState.canPause, false);
      });

      test('canResume should be true only when paused', () {
        final recordingState = VoiceRecordingState.recording(duration: 10);
        final pausedState = VoiceRecordingState.paused(duration: 10);
        final idleState = VoiceRecordingState.initial();

        expect(recordingState.canResume, false);
        expect(pausedState.canResume, true);
        expect(idleState.canResume, false);
      });
    });

    group('toString', () {
      test('should return string representation', () {
        final state = VoiceRecordingState.recording(duration: 10);
        final string = state.toString();

        expect(string, contains('VoiceRecordingState'));
        expect(string, contains('recording'));
        expect(string, contains('10'));
      });
    });
  });
}

