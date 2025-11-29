import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/state/voice_recording_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

// Voice recording state provider
final voiceRecordingProvider = StateNotifierProvider<VoiceRecordingNotifier, VoiceRecordingState>((ref) {
  return VoiceRecordingNotifier();
});

class VoiceRecordingNotifier extends StateNotifier<VoiceRecordingState> {
  VoiceRecordingNotifier() : super(VoiceRecordingState.initial());

  final AudioRecorder _recorder = AudioRecorder();
  Timer? _durationTimer;
  String? _currentFilePath;
  int _recordingDuration = 0;

  /// Start recording audio
  Future<void> startRecording() async {
    try {
      // Check microphone permission
      if (!await _recorder.hasPermission()) {
        state = VoiceRecordingState.error(errorMessage: 'Microphone permission denied');
        return;
      }

      // Generate unique filename
      final tempDir = await getTemporaryDirectory();
      final fileName = 'voice_${const Uuid().v4()}.m4a';
      _currentFilePath = '${tempDir.path}/$fileName';

      // Configure and start recording
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentFilePath!,
      );

      _recordingDuration = 0;
      state = VoiceRecordingState.recording(
        duration: 0,
        filePath: _currentFilePath,
      );

      // Start duration timer
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration++;
        state = VoiceRecordingState.recording(
          duration: _recordingDuration,
          filePath: _currentFilePath,
        );

        // Auto-stop at 60 seconds
        if (_recordingDuration >= 60) {
          stopRecording();
        }
      });
    } catch (e) {
      debugPrint('Error starting recording: $e');
      state = VoiceRecordingState.error(errorMessage: 'Failed to start recording: $e');
    }
  }

  /// Stop recording and return the file path
  Future<String?> stopRecording() async {
    _durationTimer?.cancel();
    _durationTimer = null;

    if (!state.isRecording && !state.isPaused) {
      return null;
    }

    try {
      state = VoiceRecordingState.processing(
        duration: _recordingDuration,
        filePath: _currentFilePath!,
      );

      final filePath = await _recorder.stop();

      if (filePath != null && await File(filePath).exists()) {
        state = VoiceRecordingState.completed(
          duration: _recordingDuration,
          filePath: filePath,
        );
        return filePath;
      } else {
        state = VoiceRecordingState.error(errorMessage: 'Recording file not found');
        return null;
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      state = VoiceRecordingState.error(errorMessage: 'Failed to stop recording: $e');
      return null;
    }
  }

  /// Pause recording
  Future<void> pauseRecording() async {
    if (!state.isRecording) return;

    try {
      _durationTimer?.cancel();
      await _recorder.pause();
      state = VoiceRecordingState.paused(
        duration: _recordingDuration,
        filePath: _currentFilePath,
      );
    } catch (e) {
      debugPrint('Error pausing recording: $e');
      state = VoiceRecordingState.error(errorMessage: 'Failed to pause recording');
    }
  }

  /// Resume recording
  Future<void> resumeRecording() async {
    if (!state.isPaused) return;

    try {
      await _recorder.resume();
      state = VoiceRecordingState.recording(
        duration: _recordingDuration,
        filePath: _currentFilePath,
      );

      // Restart duration timer
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration++;
        state = VoiceRecordingState.recording(
          duration: _recordingDuration,
          filePath: _currentFilePath,
        );

        if (_recordingDuration >= 60) {
          stopRecording();
        }
      });
    } catch (e) {
      debugPrint('Error resuming recording: $e');
      state = VoiceRecordingState.error(errorMessage: 'Failed to resume recording');
    }
  }

  /// Cancel recording and delete file
  Future<void> cancelRecording() async {
    _durationTimer?.cancel();
    _durationTimer = null;

    try {
      if (await _recorder.isRecording() || await _recorder.isPaused()) {
        await _recorder.stop();
      }

      // Delete the file if it exists
      if (_currentFilePath != null) {
        final file = File(_currentFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error cancelling recording: $e');
    }

    _currentFilePath = null;
    _recordingDuration = 0;
    state = VoiceRecordingState.initial();
  }

  void completeRecording() {
    state = VoiceRecordingState.initial();
    _currentFilePath = null;
    _recordingDuration = 0;
  }

  void setError(String error) {
    state = VoiceRecordingState.error(errorMessage: error);
  }

  void reset() {
    _durationTimer?.cancel();
    _durationTimer = null;
    _currentFilePath = null;
    _recordingDuration = 0;
    state = VoiceRecordingState.initial();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}
