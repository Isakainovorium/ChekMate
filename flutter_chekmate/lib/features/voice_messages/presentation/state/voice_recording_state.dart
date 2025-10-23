import 'package:equatable/equatable.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';

/// Enum representing the current state of voice recording
enum VoiceRecordingStatus {
  /// Not recording, ready to start
  idle,

  /// Recording in progress
  recording,

  /// Recording paused
  paused,

  /// Recording stopped, processing
  processing,

  /// Uploading to Firebase Storage
  uploading,

  /// Upload complete
  completed,

  /// Error occurred
  error,
}

/// State class for voice recording feature
///
/// This class holds all the state needed for the voice recording UI.
/// It follows the immutable state pattern with copyWith for updates.
class VoiceRecordingState extends Equatable {

  const VoiceRecordingState({
    this.status = VoiceRecordingStatus.idle,
    this.duration = 0,
    this.maxDuration = 60,
    this.filePath,
    this.voiceMessage,
    this.uploadProgress = 0.0,
    this.errorMessage,
  });

  /// Initial state factory
  factory VoiceRecordingState.initial() {
    return const VoiceRecordingState();
  }

  /// Recording state factory
  factory VoiceRecordingState.recording({
    required int duration,
    int maxDuration = 60,
    String? filePath,
  }) {
    return VoiceRecordingState(
      status: VoiceRecordingStatus.recording,
      duration: duration,
      maxDuration: maxDuration,
      filePath: filePath,
    );
  }

  /// Paused state factory
  factory VoiceRecordingState.paused({
    required int duration,
    int maxDuration = 60,
    String? filePath,
  }) {
    return VoiceRecordingState(
      status: VoiceRecordingStatus.paused,
      duration: duration,
      maxDuration: maxDuration,
      filePath: filePath,
    );
  }

  /// Processing state factory
  factory VoiceRecordingState.processing({
    required int duration,
    String? filePath,
  }) {
    return VoiceRecordingState(
      status: VoiceRecordingStatus.processing,
      duration: duration,
      filePath: filePath,
    );
  }

  /// Uploading state factory
  factory VoiceRecordingState.uploading({
    required VoiceMessageEntity voiceMessage,
    required double uploadProgress,
  }) {
    return VoiceRecordingState(
      status: VoiceRecordingStatus.uploading,
      voiceMessage: voiceMessage,
      uploadProgress: uploadProgress,
      duration: voiceMessage.duration,
    );
  }

  /// Completed state factory
  factory VoiceRecordingState.completed({
    required VoiceMessageEntity voiceMessage,
  }) {
    return VoiceRecordingState(
      status: VoiceRecordingStatus.completed,
      voiceMessage: voiceMessage,
      uploadProgress: 1.0,
      duration: voiceMessage.duration,
    );
  }

  /// Error state factory
  factory VoiceRecordingState.error({
    required String errorMessage,
    int duration = 0,
  }) {
    return VoiceRecordingState(
      status: VoiceRecordingStatus.error,
      errorMessage: errorMessage,
      duration: duration,
    );
  }
  /// Current recording status
  final VoiceRecordingStatus status;

  /// Current recording duration in seconds
  final int duration;

  /// Maximum recording duration in seconds (default: 60)
  final int maxDuration;

  /// Local file path of the recording
  final String? filePath;

  /// Voice message entity (after recording stops)
  final VoiceMessageEntity? voiceMessage;

  /// Upload progress (0.0 to 1.0)
  final double uploadProgress;

  /// Error message if status is error
  final String? errorMessage;

  /// Whether the recording has reached max duration
  bool get hasReachedMaxDuration => duration >= maxDuration;

  /// Whether recording is in progress
  bool get isRecording => status == VoiceRecordingStatus.recording;

  /// Whether recording is paused
  bool get isPaused => status == VoiceRecordingStatus.paused;

  /// Whether recording is idle
  bool get isIdle => status == VoiceRecordingStatus.idle;

  /// Whether recording is processing
  bool get isProcessing => status == VoiceRecordingStatus.processing;

  /// Whether recording is uploading
  bool get isUploading => status == VoiceRecordingStatus.uploading;

  /// Whether recording is completed
  bool get isCompleted => status == VoiceRecordingStatus.completed;

  /// Whether recording has an error
  bool get hasError => status == VoiceRecordingStatus.error;

  /// Whether the recording can be stopped (recording or paused)
  bool get canStop => isRecording || isPaused;

  /// Whether the recording can be paused (currently recording)
  bool get canPause => isRecording;

  /// Whether the recording can be resumed (currently paused)
  bool get canResume => isPaused;

  /// Formatted duration string (MM:SS)
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formatted remaining time string (MM:SS)
  String get formattedRemainingTime {
    final remaining = maxDuration - duration;
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Progress percentage (0.0 to 1.0)
  double get progress => duration / maxDuration;

  /// Copy with method for immutable updates
  VoiceRecordingState copyWith({
    VoiceRecordingStatus? status,
    int? duration,
    int? maxDuration,
    String? filePath,
    VoiceMessageEntity? voiceMessage,
    double? uploadProgress,
    String? errorMessage,
  }) {
    return VoiceRecordingState(
      status: status ?? this.status,
      duration: duration ?? this.duration,
      maxDuration: maxDuration ?? this.maxDuration,
      filePath: filePath ?? this.filePath,
      voiceMessage: voiceMessage ?? this.voiceMessage,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        duration,
        maxDuration,
        filePath,
        voiceMessage,
        uploadProgress,
        errorMessage,
      ];

  @override
  String toString() {
    return 'VoiceRecordingState('
        'status: $status, '
        'duration: $duration, '
        'maxDuration: $maxDuration, '
        'filePath: $filePath, '
        'voiceMessage: $voiceMessage, '
        'uploadProgress: $uploadProgress, '
        'errorMessage: $errorMessage'
        ')';
  }
}

