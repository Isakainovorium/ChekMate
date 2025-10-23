import 'package:equatable/equatable.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';

/// Voice playback status enum
enum VoicePlaybackStatus {
  /// Not playing
  idle,

  /// Loading audio file
  loading,

  /// Currently playing
  playing,

  /// Paused
  paused,

  /// Playback completed
  completed,

  /// Error occurred
  error,
}

/// Voice playback state
///
/// This class represents the state of voice message playback.
/// It is immutable and uses Equatable for value equality.
///
/// Properties:
/// - [status]: Current playback status
/// - [voiceMessage]: The voice message being played
/// - [position]: Current playback position in seconds
/// - [duration]: Total duration in seconds
/// - [speed]: Playback speed (1.0 = normal, 1.5 = 1.5x, 2.0 = 2x)
/// - [errorMessage]: Error message if status is error
///
/// Computed properties:
/// - [isPlaying]: Whether audio is currently playing
/// - [isPaused]: Whether audio is paused
/// - [isLoading]: Whether audio is loading
/// - [isCompleted]: Whether playback is completed
/// - [hasError]: Whether an error occurred
/// - [progress]: Playback progress (0.0 to 1.0)
/// - [formattedPosition]: Formatted current position (MM:SS)
/// - [formattedDuration]: Formatted total duration (MM:SS)
/// - [formattedRemaining]: Formatted remaining time (MM:SS)
class VoicePlaybackState extends Equatable {

  const VoicePlaybackState({
    this.status = VoicePlaybackStatus.idle,
    this.voiceMessage,
    this.position = 0,
    this.duration = 0,
    this.speed = 1.0,
    this.errorMessage,
  });

  // ============================================================================
  // FACTORY CONSTRUCTORS
  // ============================================================================

  /// Create initial state
  factory VoicePlaybackState.initial() => const VoicePlaybackState();

  /// Create loading state
  factory VoicePlaybackState.loading({
    required VoiceMessageEntity voiceMessage,
  }) =>
      VoicePlaybackState(
        status: VoicePlaybackStatus.loading,
        voiceMessage: voiceMessage,
        duration: voiceMessage.duration,
      );

  /// Create playing state
  factory VoicePlaybackState.playing({
    required VoiceMessageEntity voiceMessage,
    required int position,
    required int duration,
    double speed = 1.0,
  }) =>
      VoicePlaybackState(
        status: VoicePlaybackStatus.playing,
        voiceMessage: voiceMessage,
        position: position,
        duration: duration,
        speed: speed,
      );

  /// Create paused state
  factory VoicePlaybackState.paused({
    required VoiceMessageEntity voiceMessage,
    required int position,
    required int duration,
    double speed = 1.0,
  }) =>
      VoicePlaybackState(
        status: VoicePlaybackStatus.paused,
        voiceMessage: voiceMessage,
        position: position,
        duration: duration,
        speed: speed,
      );

  /// Create completed state
  factory VoicePlaybackState.completed({
    required VoiceMessageEntity voiceMessage,
    required int duration,
  }) =>
      VoicePlaybackState(
        status: VoicePlaybackStatus.completed,
        voiceMessage: voiceMessage,
        position: duration,
        duration: duration,
      );

  /// Create error state
  factory VoicePlaybackState.error({
    required String errorMessage,
    VoiceMessageEntity? voiceMessage,
  }) =>
      VoicePlaybackState(
        status: VoicePlaybackStatus.error,
        voiceMessage: voiceMessage,
        errorMessage: errorMessage,
      );
  final VoicePlaybackStatus status;
  final VoiceMessageEntity? voiceMessage;
  final int position;
  final int duration;
  final double speed;
  final String? errorMessage;

  // ============================================================================
  // COMPUTED PROPERTIES
  // ============================================================================

  /// Whether audio is currently playing
  bool get isPlaying => status == VoicePlaybackStatus.playing;

  /// Whether audio is paused
  bool get isPaused => status == VoicePlaybackStatus.paused;

  /// Whether audio is loading
  bool get isLoading => status == VoicePlaybackStatus.loading;

  /// Whether audio is idle (not started)
  bool get isIdle => status == VoicePlaybackStatus.idle;

  /// Whether playback is completed
  bool get isCompleted => status == VoicePlaybackStatus.completed;

  /// Whether an error occurred
  bool get hasError => status == VoicePlaybackStatus.error;

  /// Whether playback can be started
  bool get canPlay => isIdle || isPaused || isCompleted;

  /// Whether playback can be paused
  bool get canPause => isPlaying;

  /// Playback progress (0.0 to 1.0)
  double get progress {
    if (duration == 0) return 0.0;
    return (position / duration).clamp(0.0, 1.0);
  }

  /// Remaining time in seconds
  int get remaining => (duration - position).clamp(0, duration);

  /// Formatted current position (MM:SS)
  String get formattedPosition {
    final minutes = position ~/ 60;
    final seconds = position % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formatted total duration (MM:SS)
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formatted remaining time (MM:SS)
  String get formattedRemaining {
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Speed label (1.0x, 1.5x, 2.0x)
  String get speedLabel {
    if (speed == 1.0) return '1.0x';
    if (speed == 1.5) return '1.5x';
    if (speed == 2.0) return '2.0x';
    return '${speed.toStringAsFixed(1)}x';
  }

  // ============================================================================
  // COPY WITH
  // ============================================================================

  VoicePlaybackState copyWith({
    VoicePlaybackStatus? status,
    VoiceMessageEntity? voiceMessage,
    int? position,
    int? duration,
    double? speed,
    String? errorMessage,
  }) {
    return VoicePlaybackState(
      status: status ?? this.status,
      voiceMessage: voiceMessage ?? this.voiceMessage,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // ============================================================================
  // EQUATABLE
  // ============================================================================

  @override
  List<Object?> get props => [
        status,
        voiceMessage,
        position,
        duration,
        speed,
        errorMessage,
      ];

  @override
  String toString() {
    return 'VoicePlaybackState(status: $status, position: $position, duration: $duration, speed: $speed)';
  }
}

