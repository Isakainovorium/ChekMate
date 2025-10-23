import 'dart:async';

import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/usecases/play_voice_message_usecase.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/state/voice_playback_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Voice playback notifier
///
/// This notifier manages the state of voice message playback.
/// It handles play, pause, seek, and speed control operations.
///
/// Usage:
/// ```dart
/// final notifier = ref.read(voicePlaybackNotifierProvider.notifier);
/// await notifier.play(voiceMessage);
/// notifier.pause();
/// notifier.seek(30); // Seek to 30 seconds
/// notifier.setSpeed(1.5); // Set speed to 1.5x
/// ```
class VoicePlaybackNotifier extends StateNotifier<VoicePlaybackState> {

  VoicePlaybackNotifier({
    required PlayVoiceMessageUseCase playVoiceMessageUseCase,
  })  : _playVoiceMessageUseCase = playVoiceMessageUseCase,
        super(VoicePlaybackState.initial());
  final PlayVoiceMessageUseCase _playVoiceMessageUseCase;

  Timer? _progressTimer;
  String? _currentMessageId;

  // ============================================================================
  // PUBLIC METHODS
  // ============================================================================

  /// Play a voice message
  ///
  /// If a different message is currently playing, it will be stopped first.
  /// If the same message is paused, it will resume from the current position.
  Future<void> play(VoiceMessageEntity voiceMessage) async {
    // If a different message is playing, stop it first
    if (_currentMessageId != null && _currentMessageId != voiceMessage.id) {
      stop();
    }

    // If same message is paused, resume
    if (_currentMessageId == voiceMessage.id && state.isPaused) {
      resume();
      return;
    }

    // If same message is completed, restart from beginning
    if (_currentMessageId == voiceMessage.id && state.isCompleted) {
      state = VoicePlaybackState.playing(
        voiceMessage: voiceMessage,
        position: 0,
        duration: voiceMessage.duration,
        speed: state.speed,
      );
      _startProgressTimer();
      return;
    }

    // Start playing new message
    state = VoicePlaybackState.loading(voiceMessage: voiceMessage);
    _currentMessageId = voiceMessage.id;

    final result = await _playVoiceMessageUseCase(
      PlayVoiceMessageParams(voiceMessage: voiceMessage),
    );

    result.fold(
      (failure) {
        state = VoicePlaybackState.error(
          errorMessage: failure.message,
          voiceMessage: voiceMessage,
        );
        _currentMessageId = null;
      },
      (playingMessage) {
        state = VoicePlaybackState.playing(
          voiceMessage: playingMessage,
          position: 0,
          duration: playingMessage.duration,
          speed: state.speed,
        );
        _startProgressTimer();
      },
    );
  }

  /// Pause playback
  void pause() {
    if (!state.canPause) return;

    _stopProgressTimer();
    state = state.copyWith(status: VoicePlaybackStatus.paused);
  }

  /// Resume playback
  void resume() {
    if (!state.isPaused) return;

    state = state.copyWith(status: VoicePlaybackStatus.playing);
    _startProgressTimer();
  }

  /// Stop playback
  void stop() {
    _stopProgressTimer();
    _currentMessageId = null;
    state = VoicePlaybackState.initial();
  }

  /// Seek to a specific position (in seconds)
  void seek(int position) {
    if (state.voiceMessage == null) return;

    final clampedPosition = position.clamp(0, state.duration);
    state = state.copyWith(position: clampedPosition);

    // If at the end, mark as completed
    if (clampedPosition >= state.duration) {
      _onPlaybackCompleted();
    }
  }

  /// Set playback speed
  ///
  /// Common speeds: 1.0 (normal), 1.5 (1.5x), 2.0 (2x)
  void setSpeed(double speed) {
    if (state.voiceMessage == null) return;

    final clampedSpeed = speed.clamp(0.5, 2.0);
    state = state.copyWith(speed: clampedSpeed);
  }

  /// Toggle between common speeds (1.0x -> 1.5x -> 2.0x -> 1.0x)
  void toggleSpeed() {
    if (state.speed == 1.0) {
      setSpeed(1.5);
    } else if (state.speed == 1.5) {
      setSpeed(2.0);
    } else {
      setSpeed(1.0);
    }
  }

  /// Reset to initial state
  void reset() {
    stop();
  }

  // ============================================================================
  // PRIVATE METHODS
  // ============================================================================

  /// Start progress timer
  ///
  /// Updates position every second based on playback speed
  void _startProgressTimer() {
    _stopProgressTimer();

    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isPlaying) {
        timer.cancel();
        return;
      }

      // Increment position based on speed
      final increment = (1 * state.speed).round();
      final newPosition = state.position + increment;

      if (newPosition >= state.duration) {
        _onPlaybackCompleted();
      } else {
        state = state.copyWith(position: newPosition);
      }
    });
  }

  /// Stop progress timer
  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  /// Handle playback completion
  void _onPlaybackCompleted() {
    _stopProgressTimer();

    if (state.voiceMessage != null) {
      state = VoicePlaybackState.completed(
        voiceMessage: state.voiceMessage!,
        duration: state.duration,
      );
    }
  }

  // ============================================================================
  // LIFECYCLE
  // ============================================================================

  @override
  void dispose() {
    _stopProgressTimer();
    super.dispose();
  }
}

