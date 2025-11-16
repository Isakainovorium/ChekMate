import 'package:equatable/equatable.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';

/// Enum representing the different states of voice recording
enum VoiceRecordingStatus {
  idle,
  recording,
  paused,
  processing,
  uploading,
  completed,
  error,
}

/// State class for voice recording functionality
class VoiceRecordingState extends Equatable {
  const VoiceRecordingState({
    required this.status,
    this.duration = 0,
    this.maxDuration = 60,
    this.filePath,
    this.voiceMessage,
    this.uploadProgress = 0.0,
    this.errorMessage,
  });

  /// Factory constructor for initial idle state
  factory VoiceRecordingState.initial() {
    return const VoiceRecordingState(
      status: VoiceRecordingStatus.idle,
    );
  }

  /// Factory constructor for recording state
  factory VoiceRecordingState.recording({
    required int duration,
    String? filePath,
  }) {
    return VoiceRecordingState(
      status: VoiceRecordingStatus.recording,
      duration: duration,
      filePath: filePath,
    );
  }

  /// Factory constructor for paused state
  factory VoiceRecordingState.paused({
    required int duration,
    String? filePath,
  }) {
    return VoiceRecordingState(
      status: VoiceRecordingStatus.paused,
      duration: duration,
      filePath: filePath,
    );
  }

  /// Factory constructor for processing state
  factory VoiceRecordingState.processing({
    required int duration,
    required String filePath,
  }) {
    return VoiceRecordingState(
      status: VoiceRecordingStatus.processing,
      duration: duration,
      filePath: filePath,
    );
  }

  /// Factory constructor for uploading state
  factory VoiceRecordingState.uploading({
    required int duration,
    required String filePath,
    required VoiceMessageEntity voiceMessage,
    double uploadProgress = 0.0,
  }) {
    return VoiceRecordingState(
      status: VoiceRecordingStatus.uploading,
      duration: duration,
      filePath: filePath,
      voiceMessage: voiceMessage,
      uploadProgress: uploadProgress,
    );
  }

  /// Factory constructor for completed state
  factory VoiceRecordingState.completed({
    required int duration,
    required String filePath,
    required VoiceMessageEntity voiceMessage,
  }) {
    return VoiceRecordingState(
      status: VoiceRecordingStatus.completed,
      duration: duration,
      filePath: filePath,
      voiceMessage: voiceMessage,
    );
  }

  /// Factory constructor for error state
  factory VoiceRecordingState.error({
    String? errorMessage,
    String? filePath,
    int duration = 0,
  }) {
    return VoiceRecordingState(
      status: VoiceRecordingStatus.error,
      duration: duration,
      filePath: filePath,
      errorMessage: errorMessage,
    );
  }

  final VoiceRecordingStatus status;
  final int duration;
  final int maxDuration;
  final String? filePath;
  final VoiceMessageEntity? voiceMessage;
  final double uploadProgress;
  final String? errorMessage;

  /// Check if the recording is in idle state
  bool get isIdle => status == VoiceRecordingStatus.idle;

  /// Check if the recording is currently recording
  bool get isRecording => status == VoiceRecordingStatus.recording;

  /// Check if the recording is paused
  bool get isPaused => status == VoiceRecordingStatus.paused;

  /// Check if the recording is being processed
  bool get isProcessing => status == VoiceRecordingStatus.processing;

  /// Check if the recording is uploading
  bool get isUploading => status == VoiceRecordingStatus.uploading;

  /// Check if the recording is completed
  bool get isCompleted => status == VoiceRecordingStatus.completed;

  /// Check if there's an error
  bool get hasError => status == VoiceRecordingStatus.error;

  /// Get formatted duration in MM:SS format
  String get formattedDuration {
    final minutes = (duration ~/ 60).toString().padLeft(2, '0');
    final seconds = (duration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Get formatted remaining time in MM:SS format
  String get formattedRemainingTime {
    final remaining = maxDuration - duration;
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Get recording progress as a value between 0.0 and 1.0
  double get progress {
    if (maxDuration <= 0) return 0.0;
    return (duration / maxDuration).clamp(0.0, 1.0);
  }

  /// Check if the recording has reached the maximum duration
  bool get hasReachedMaxDuration => duration >= maxDuration;

  /// Check if the recording can be resumed (only when paused)
  bool get canResume => status == VoiceRecordingStatus.paused;

  /// Check if the recording can be stopped (when recording or paused)
  bool get canStop => status == VoiceRecordingStatus.recording || status == VoiceRecordingStatus.paused;

  /// Check if the recording can be paused (only when recording)
  bool get canPause => status == VoiceRecordingStatus.recording;

  /// Create a copy with updated fields
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
}
