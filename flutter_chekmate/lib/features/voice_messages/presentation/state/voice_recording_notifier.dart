import 'dart:async';

import 'package:flutter_chekmate/features/voice_messages/domain/usecases/start_recording_usecase.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/usecases/stop_recording_usecase.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/usecases/upload_voice_message_usecase.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/state/voice_recording_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// StateNotifier for managing voice recording state
///
/// This class handles all voice recording business logic including:
/// - Starting/stopping recording
/// - Pausing/resuming recording
/// - Timer management
/// - Upload progress tracking
/// - Error handling
class VoiceRecordingNotifier extends StateNotifier<VoiceRecordingState> {
  VoiceRecordingNotifier({
    required StartRecordingUseCase startRecordingUseCase,
    required StopRecordingUseCase stopRecordingUseCase,
    required UploadVoiceMessageUseCase uploadVoiceMessageUseCase,
  })  : _startRecordingUseCase = startRecordingUseCase,
        _stopRecordingUseCase = stopRecordingUseCase,
        _uploadVoiceMessageUseCase = uploadVoiceMessageUseCase,
        super(VoiceRecordingState.initial());
  final StartRecordingUseCase _startRecordingUseCase;
  final StopRecordingUseCase _stopRecordingUseCase;
  final UploadVoiceMessageUseCase _uploadVoiceMessageUseCase;

  Timer? _timer;
  String? _currentSenderId;
  String? _currentReceiverId;

  /// Start recording a voice message
  ///
  /// [senderId] - ID of the user sending the message
  /// [receiverId] - ID of the user receiving the message
  /// [maxDuration] - Maximum recording duration in seconds (default: 60)
  Future<void> startRecording({
    required String senderId,
    required String receiverId,
    int maxDuration = 60,
  }) async {
    if (!state.isIdle) {
      return;
    }

    _currentSenderId = senderId;
    _currentReceiverId = receiverId;

    // Start recording
    final result = await _startRecordingUseCase();

    result.fold(
      (failure) {
        state = VoiceRecordingState.error(
          errorMessage: failure.message,
        );
      },
      (filePath) {
        state = VoiceRecordingState.recording(
          duration: 0,
          maxDuration: maxDuration,
          filePath: filePath,
        );
        _startTimer();
      },
    );
  }

  /// Stop recording and process the voice message
  Future<void> stopRecording() async {
    if (!state.canStop) {
      return;
    }

    _stopTimer();

    // Update state to processing
    state = VoiceRecordingState.processing(
      duration: state.duration,
      filePath: state.filePath,
    );

    // Stop recording
    final result = await _stopRecordingUseCase();

    result.fold(
      (failure) {
        state = VoiceRecordingState.error(
          errorMessage: failure.message,
          duration: state.duration,
        );
      },
      (voiceMessage) {
        // Update voice message with sender and receiver IDs
        final updatedMessage = voiceMessage.copyWith(
          senderId: _currentSenderId,
          receiverId: _currentReceiverId,
        );

        state = state.copyWith(
          status: VoiceRecordingStatus.idle,
          voiceMessage: updatedMessage,
        );
      },
    );
  }

  /// Cancel recording and discard the audio
  Future<void> cancelRecording() async {
    if (!state.canStop) {
      return;
    }

    _stopTimer();

    // Reset to initial state
    state = VoiceRecordingState.initial();
  }

  /// Pause recording
  Future<void> pauseRecording() async {
    if (!state.canPause) {
      return;
    }

    _stopTimer();

    state = VoiceRecordingState.paused(
      duration: state.duration,
      maxDuration: state.maxDuration,
      filePath: state.filePath,
    );
  }

  /// Resume recording
  Future<void> resumeRecording() async {
    if (!state.canResume) {
      return;
    }

    state = VoiceRecordingState.recording(
      duration: state.duration,
      maxDuration: state.maxDuration,
      filePath: state.filePath,
    );

    _startTimer();
  }

  /// Upload voice message to Firebase Storage
  ///
  /// This should be called after stopRecording() completes successfully
  Future<void> uploadVoiceMessage() async {
    if (state.voiceMessage == null) {
      state = VoiceRecordingState.error(
        errorMessage: 'No voice message to upload',
      );
      return;
    }

    // Update state to uploading
    state = VoiceRecordingState.uploading(
      voiceMessage: state.voiceMessage!,
      uploadProgress: 0.0,
    );

    // Upload with progress callback
    final result = await _uploadVoiceMessageUseCase(
      UploadVoiceMessageParams(
        voiceMessage: state.voiceMessage!,
        onProgress: (double progress) {
          if (state.isUploading) {
            state = state.copyWith(uploadProgress: progress);
          }
        },
      ),
    );

    result.fold(
      (failure) {
        state = VoiceRecordingState.error(
          errorMessage: failure.message,
          duration: state.duration,
        );
      },
      (uploadedMessage) {
        state = VoiceRecordingState.completed(
          voiceMessage: uploadedMessage,
        );
      },
    );
  }

  /// Reset to initial state
  void reset() {
    _stopTimer();
    _currentSenderId = null;
    _currentReceiverId = null;
    state = VoiceRecordingState.initial();
  }

  /// Start the recording timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.hasReachedMaxDuration) {
        // Auto-stop when max duration reached
        stopRecording();
      } else {
        state = state.copyWith(duration: state.duration + 1);
      }
    });
  }

  /// Stop the recording timer
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
