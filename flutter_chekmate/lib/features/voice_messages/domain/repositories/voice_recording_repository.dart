import 'package:dartz/dartz.dart';
import 'package:flutter_chekmate/core/error/failures.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';

/// Repository interface for voice recording operations
///
/// This interface defines the contract for voice recording operations.
/// It follows the Repository Pattern from Clean Architecture, where the
/// domain layer defines the interface and the data layer provides the
/// implementation.
///
/// All methods return Either<Failure, T> to handle errors functionally.
/// - Left: Failure (error case)
/// - Right: Success value
abstract class VoiceRecordingRepository {
  /// Starts recording a voice message
  ///
  /// Returns the file path where the recording is being saved.
  ///
  /// Throws:
  /// - [PermissionFailure] if microphone permission is not granted
  /// - [RecordingFailure] if recording fails to start
  Future<Either<Failure, String>> startRecording();

  /// Stops the current recording
  ///
  /// Returns a [VoiceMessageEntity] with the recorded audio file information.
  ///
  /// Throws:
  /// - [RecordingFailure] if no recording is in progress
  /// - [RecordingFailure] if stopping the recording fails
  Future<Either<Failure, VoiceMessageEntity>> stopRecording();

  /// Cancels the current recording and deletes the file
  ///
  /// Returns true if cancellation was successful.
  ///
  /// Throws:
  /// - [RecordingFailure] if no recording is in progress
  /// - [RecordingFailure] if cancellation fails
  Future<Either<Failure, bool>> cancelRecording();

  /// Pauses the current recording
  ///
  /// Returns true if pause was successful.
  ///
  /// Throws:
  /// - [RecordingFailure] if no recording is in progress
  /// - [RecordingFailure] if pause fails
  Future<Either<Failure, bool>> pauseRecording();

  /// Resumes a paused recording
  ///
  /// Returns true if resume was successful.
  ///
  /// Throws:
  /// - [RecordingFailure] if no recording is paused
  /// - [RecordingFailure] if resume fails
  Future<Either<Failure, bool>> resumeRecording();

  /// Checks if a recording is currently in progress
  ///
  /// Returns true if recording is active.
  Future<Either<Failure, bool>> isRecording();

  /// Gets the current recording duration in seconds
  ///
  /// Returns the duration of the current recording.
  /// Returns 0 if no recording is in progress.
  Future<Either<Failure, int>> getRecordingDuration();

  /// Uploads a voice message to Firebase Storage
  ///
  /// [voiceMessage]: The voice message entity to upload
  /// [onProgress]: Optional callback for upload progress (0.0 to 1.0)
  ///
  /// Returns the updated [VoiceMessageEntity] with download URL.
  ///
  /// Throws:
  /// - [NetworkFailure] if network is unavailable
  /// - [StorageFailure] if upload to Firebase Storage fails
  /// - [ValidationFailure] if voice message validation fails
  Future<Either<Failure, VoiceMessageEntity>> uploadVoiceMessage(
    VoiceMessageEntity voiceMessage, {
    void Function(double)? onProgress,
  });

  /// Downloads a voice message from Firebase Storage
  ///
  /// [voiceMessage]: The voice message entity to download
  /// [onProgress]: Optional callback for download progress (0.0 to 1.0)
  ///
  /// Returns the updated [VoiceMessageEntity] with local file path.
  ///
  /// Throws:
  /// - [NetworkFailure] if network is unavailable
  /// - [StorageFailure] if download from Firebase Storage fails
  Future<Either<Failure, VoiceMessageEntity>> downloadVoiceMessage(
    VoiceMessageEntity voiceMessage, {
    void Function(double)? onProgress,
  });

  /// Deletes a voice message from Firebase Storage
  ///
  /// [voiceMessage]: The voice message entity to delete
  ///
  /// Returns true if deletion was successful.
  ///
  /// Throws:
  /// - [NetworkFailure] if network is unavailable
  /// - [StorageFailure] if deletion from Firebase Storage fails
  Future<Either<Failure, bool>> deleteVoiceMessage(
    VoiceMessageEntity voiceMessage,
  );

  /// Plays a voice message
  ///
  /// [voiceMessage]: The voice message entity to play
  ///
  /// Returns the updated [VoiceMessageEntity] with isPlaying = true.
  ///
  /// Throws:
  /// - [PlaybackFailure] if playback fails to start
  /// - [ValidationFailure] if voice message has no file path or download URL
  Future<Either<Failure, VoiceMessageEntity>> playVoiceMessage(
    VoiceMessageEntity voiceMessage,
  );

  /// Pauses playback of a voice message
  ///
  /// [voiceMessage]: The voice message entity to pause
  ///
  /// Returns the updated [VoiceMessageEntity] with isPlaying = false.
  ///
  /// Throws:
  /// - [PlaybackFailure] if pause fails
  Future<Either<Failure, VoiceMessageEntity>> pausePlayback(
    VoiceMessageEntity voiceMessage,
  );

  /// Resumes playback of a voice message
  ///
  /// [voiceMessage]: The voice message entity to resume
  ///
  /// Returns the updated [VoiceMessageEntity] with isPlaying = true.
  ///
  /// Throws:
  /// - [PlaybackFailure] if resume fails
  Future<Either<Failure, VoiceMessageEntity>> resumePlayback(
    VoiceMessageEntity voiceMessage,
  );

  /// Stops playback of a voice message
  ///
  /// [voiceMessage]: The voice message entity to stop
  ///
  /// Returns the updated [VoiceMessageEntity] with isPlaying = false and playbackPosition = 0.
  ///
  /// Throws:
  /// - [PlaybackFailure] if stop fails
  Future<Either<Failure, VoiceMessageEntity>> stopPlayback(
    VoiceMessageEntity voiceMessage,
  );

  /// Seeks to a specific position in a voice message
  ///
  /// [voiceMessage]: The voice message entity
  /// [position]: The position to seek to in seconds
  ///
  /// Returns the updated [VoiceMessageEntity] with new playbackPosition.
  ///
  /// Throws:
  /// - [PlaybackFailure] if seek fails
  /// - [ValidationFailure] if position is invalid
  Future<Either<Failure, VoiceMessageEntity>> seekTo(
    VoiceMessageEntity voiceMessage,
    double position,
  );

  /// Gets the current playback position of a voice message
  ///
  /// [voiceMessage]: The voice message entity
  ///
  /// Returns the current playback position in seconds.
  Future<Either<Failure, double>> getPlaybackPosition(
    VoiceMessageEntity voiceMessage,
  );

  /// Checks if a voice message is currently playing
  ///
  /// [voiceMessage]: The voice message entity
  ///
  /// Returns true if the voice message is playing.
  Future<Either<Failure, bool>> isPlaying(
    VoiceMessageEntity voiceMessage,
  );

  /// Disposes of all resources (audio players, recorders, etc.)
  ///
  /// Should be called when the repository is no longer needed.
  Future<Either<Failure, void>> dispose();
}
