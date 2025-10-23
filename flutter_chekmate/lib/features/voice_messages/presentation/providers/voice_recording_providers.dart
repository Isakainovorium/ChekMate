import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chekmate/features/voice_messages/data/datasources/voice_recording_local_data_source.dart';
import 'package:flutter_chekmate/features/voice_messages/data/datasources/voice_storage_remote_data_source.dart';
import 'package:flutter_chekmate/features/voice_messages/data/repositories/voice_recording_repository_impl.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/repositories/voice_recording_repository.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/usecases/play_voice_message_usecase.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/usecases/start_recording_usecase.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/usecases/stop_recording_usecase.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/usecases/upload_voice_message_usecase.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/state/voice_playback_notifier.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/state/voice_playback_state.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/state/voice_recording_notifier.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/state/voice_recording_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

// ============================================================================
// DATA SOURCE PROVIDERS
// ============================================================================

/// Provider for AudioRecorder instance
final audioRecorderProvider = Provider<AudioRecorder>((ref) {
  return AudioRecorder();
});

/// Provider for Firebase Storage instance
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

/// Provider for UUID generator
final uuidProvider = Provider<Uuid>((ref) {
  return const Uuid();
});

/// Provider for local voice recording data source
final voiceRecordingLocalDataSourceProvider =
    Provider<VoiceRecordingLocalDataSource>((ref) {
  final audioRecorder = ref.watch(audioRecorderProvider);
  final uuid = ref.watch(uuidProvider);
  return VoiceRecordingLocalDataSourceImpl(
    recorder: audioRecorder,
    uuid: uuid,
  );
});

/// Provider for remote voice storage data source
final voiceStorageRemoteDataSourceProvider =
    Provider<VoiceStorageRemoteDataSource>((ref) {
  final firebaseStorage = ref.watch(firebaseStorageProvider);
  return VoiceStorageRemoteDataSourceImpl(
    storage: firebaseStorage,
  );
});

// ============================================================================
// REPOSITORY PROVIDERS
// ============================================================================

/// Provider for voice recording repository
final voiceRecordingRepositoryProvider =
    Provider<VoiceRecordingRepository>((ref) {
  final localDataSource = ref.watch(voiceRecordingLocalDataSourceProvider);
  final remoteDataSource = ref.watch(voiceStorageRemoteDataSourceProvider);
  final uuid = ref.watch(uuidProvider);
  return VoiceRecordingRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    uuid: uuid,
  );
});

// ============================================================================
// USE CASE PROVIDERS
// ============================================================================

/// Provider for start recording use case
final startRecordingUseCaseProvider = Provider<StartRecordingUseCase>((ref) {
  final repository = ref.watch(voiceRecordingRepositoryProvider);
  return StartRecordingUseCase(repository);
});

/// Provider for stop recording use case
final stopRecordingUseCaseProvider = Provider<StopRecordingUseCase>((ref) {
  final repository = ref.watch(voiceRecordingRepositoryProvider);
  return StopRecordingUseCase(repository);
});

/// Provider for upload voice message use case
final uploadVoiceMessageUseCaseProvider =
    Provider<UploadVoiceMessageUseCase>((ref) {
  final repository = ref.watch(voiceRecordingRepositoryProvider);
  return UploadVoiceMessageUseCase(repository);
});

/// Provider for play voice message use case
final playVoiceMessageUseCaseProvider =
    Provider<PlayVoiceMessageUseCase>((ref) {
  final repository = ref.watch(voiceRecordingRepositoryProvider);
  return PlayVoiceMessageUseCase(repository);
});

// ============================================================================
// STATE NOTIFIER PROVIDERS
// ============================================================================

/// Provider for voice recording state notifier
///
/// This is the main provider for managing voice recording state.
/// Use this provider to:
/// - Start/stop recording
/// - Pause/resume recording
/// - Upload voice messages
/// - Track recording progress
///
/// Example usage:
/// ```dart
/// class VoiceRecordingButton extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final recordingState = ref.watch(voiceRecordingNotifierProvider);
///     final recordingNotifier = ref.read(voiceRecordingNotifierProvider.notifier);
///
///     return IconButton(
///       icon: Icon(recordingState.isRecording ? Icons.stop : Icons.mic),
///       onPressed: () {
///         if (recordingState.isRecording) {
///           recordingNotifier.stopRecording();
///         } else {
///           recordingNotifier.startRecording(
///             senderId: 'user123',
///             receiverId: 'user456',
///           );
///         }
///       },
///     );
///   }
/// }
/// ```
final voiceRecordingNotifierProvider =
    StateNotifierProvider<VoiceRecordingNotifier, VoiceRecordingState>((ref) {
  final startRecordingUseCase = ref.watch(startRecordingUseCaseProvider);
  final stopRecordingUseCase = ref.watch(stopRecordingUseCaseProvider);
  final uploadVoiceMessageUseCase =
      ref.watch(uploadVoiceMessageUseCaseProvider);

  return VoiceRecordingNotifier(
    startRecordingUseCase: startRecordingUseCase,
    stopRecordingUseCase: stopRecordingUseCase,
    uploadVoiceMessageUseCase: uploadVoiceMessageUseCase,
  );
});

// ============================================================================
// COMPUTED STATE PROVIDERS
// ============================================================================

/// Provider for checking if recording is in progress
final isRecordingProvider = Provider<bool>((ref) {
  final state = ref.watch(voiceRecordingNotifierProvider);
  return state.isRecording;
});

/// Provider for checking if recording is paused
final isPausedProvider = Provider<bool>((ref) {
  final state = ref.watch(voiceRecordingNotifierProvider);
  return state.isPaused;
});

/// Provider for checking if recording is uploading
final isUploadingProvider = Provider<bool>((ref) {
  final state = ref.watch(voiceRecordingNotifierProvider);
  return state.isUploading;
});

/// Provider for current recording duration
final recordingDurationProvider = Provider<int>((ref) {
  final state = ref.watch(voiceRecordingNotifierProvider);
  return state.duration;
});

/// Provider for formatted recording duration (MM:SS)
final formattedDurationProvider = Provider<String>((ref) {
  final state = ref.watch(voiceRecordingNotifierProvider);
  return state.formattedDuration;
});

/// Provider for recording progress (0.0 to 1.0)
final recordingProgressProvider = Provider<double>((ref) {
  final state = ref.watch(voiceRecordingNotifierProvider);
  return state.progress;
});

/// Provider for upload progress (0.0 to 1.0)
final uploadProgressProvider = Provider<double>((ref) {
  final state = ref.watch(voiceRecordingNotifierProvider);
  return state.uploadProgress;
});

/// Provider for checking if max duration reached
final hasReachedMaxDurationProvider = Provider<bool>((ref) {
  final state = ref.watch(voiceRecordingNotifierProvider);
  return state.hasReachedMaxDuration;
});

// ============================================================================
// VOICE PLAYBACK PROVIDERS
// ============================================================================

/// Provider for voice playback state notifier
///
/// This is the main provider for managing voice message playback.
/// Use this provider to:
/// - Play/pause voice messages
/// - Seek to specific positions
/// - Control playback speed
/// - Track playback progress
///
/// Example usage:
/// ```dart
/// class VoiceMessageBubble extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final playbackState = ref.watch(voicePlaybackNotifierProvider);
///     final playbackNotifier = ref.read(voicePlaybackNotifierProvider.notifier);
///
///     return IconButton(
///       icon: Icon(playbackState.isPlaying ? Icons.pause : Icons.play_arrow),
///       onPressed: () {
///         if (playbackState.isPlaying) {
///           playbackNotifier.pause();
///         } else {
///           playbackNotifier.play(voiceMessage);
///         }
///       },
///     );
///   }
/// }
/// ```
final voicePlaybackNotifierProvider =
    StateNotifierProvider<VoicePlaybackNotifier, VoicePlaybackState>((ref) {
  final playVoiceMessageUseCase = ref.watch(playVoiceMessageUseCaseProvider);

  return VoicePlaybackNotifier(
    playVoiceMessageUseCase: playVoiceMessageUseCase,
  );
});

/// Provider for checking if voice is playing
final isPlayingVoiceProvider = Provider<bool>((ref) {
  final state = ref.watch(voicePlaybackNotifierProvider);
  return state.isPlaying;
});

/// Provider for checking if voice is paused
final isPausedVoiceProvider = Provider<bool>((ref) {
  final state = ref.watch(voicePlaybackNotifierProvider);
  return state.isPaused;
});

/// Provider for checking if voice is loading
final isLoadingVoiceProvider = Provider<bool>((ref) {
  final state = ref.watch(voicePlaybackNotifierProvider);
  return state.isLoading;
});

/// Provider for current playback position
final playbackPositionProvider = Provider<int>((ref) {
  final state = ref.watch(voicePlaybackNotifierProvider);
  return state.position;
});

/// Provider for formatted playback position (MM:SS)
final formattedPlaybackPositionProvider = Provider<String>((ref) {
  final state = ref.watch(voicePlaybackNotifierProvider);
  return state.formattedPosition;
});

/// Provider for playback progress (0.0 to 1.0)
final playbackProgressProvider = Provider<double>((ref) {
  final state = ref.watch(voicePlaybackNotifierProvider);
  return state.progress;
});

/// Provider for playback speed
final playbackSpeedProvider = Provider<double>((ref) {
  final state = ref.watch(voicePlaybackNotifierProvider);
  return state.speed;
});
