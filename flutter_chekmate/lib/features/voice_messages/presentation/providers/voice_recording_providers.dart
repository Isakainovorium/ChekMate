import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/state/voice_recording_state.dart';

// Voice recording state provider
final voiceRecordingProvider = StateNotifierProvider<VoiceRecordingNotifier, VoiceRecordingState>((ref) {
  return VoiceRecordingNotifier();
});

class VoiceRecordingNotifier extends StateNotifier<VoiceRecordingState> {
  VoiceRecordingNotifier() : super(VoiceRecordingState.initial());

  void startRecording() {
    // Mock implementation - in real app would start actual recording
    state = VoiceRecordingState.recording(duration: 0, filePath: '/mock/path/audio.m4a');
  }

  void stopRecording() {
    if (state.isRecording) {
      // Mock implementation - in real app would stop recording and process file
      state = VoiceRecordingState.processing(
        duration: state.duration + 1,
        filePath: state.filePath!,
      );
    }
  }

  void pauseRecording() {
    if (state.isRecording) {
      state = VoiceRecordingState.paused(
        duration: state.duration,
        filePath: state.filePath,
      );
    }
  }

  void resumeRecording() {
    if (state.isPaused) {
      state = VoiceRecordingState.recording(
        duration: state.duration,
        filePath: state.filePath,
      );
    }
  }

  void cancelRecording() {
    state = VoiceRecordingState.initial();
  }

  void completeRecording() {
    // Mock completion - in real app would create VoiceMessageEntity
    state = VoiceRecordingState.initial();
  }

  void setError(String error) {
    state = VoiceRecordingState.error(errorMessage: error);
  }

  void reset() {
    state = VoiceRecordingState.initial();
  }
}
