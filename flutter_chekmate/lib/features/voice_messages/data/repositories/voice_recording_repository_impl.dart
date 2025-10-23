import 'package:dartz/dartz.dart';
import 'package:flutter_chekmate/core/error/failures.dart';
import 'package:flutter_chekmate/features/voice_messages/data/datasources/voice_recording_local_data_source.dart';
import 'package:flutter_chekmate/features/voice_messages/data/datasources/voice_storage_remote_data_source.dart';
import 'package:flutter_chekmate/features/voice_messages/data/models/voice_message_model.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/repositories/voice_recording_repository.dart';
import 'package:uuid/uuid.dart';

/// Implementation of VoiceRecordingRepository
///
/// Coordinates between local recording data source and remote storage data source
/// to provide voice recording functionality following Clean Architecture.
class VoiceRecordingRepositoryImpl implements VoiceRecordingRepository {
  VoiceRecordingRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();
  final VoiceRecordingLocalDataSource localDataSource;
  final VoiceStorageRemoteDataSource remoteDataSource;
  final Uuid uuid;

  @override
  Future<Either<Failure, String>> startRecording() async {
    try {
      final filePath = await localDataSource.startRecording();
      return Right(filePath);
    } on RecordingException catch (e) {
      return Left(RecordingFailure(e.message));
    } on Exception catch (e) {
      return Left(UnexpectedFailure('Failed to start recording: $e'));
    }
  }

  @override
  Future<Either<Failure, VoiceMessageEntity>> stopRecording() async {
    try {
      // Stop recording and get file path
      final filePath = await localDataSource.stopRecording();

      // Get file size
      final fileSize = await localDataSource.getFileSize(filePath);

      // Get recording duration
      final duration = await localDataSource.getRecordingDuration();

      // Extract file name from path
      final fileName = filePath.split('/').last;

      // Create voice message entity
      final voiceMessage = VoiceMessageModel(
        id: uuid.v4(),
        senderId: '', // Will be set by presentation layer
        receiverId: '', // Will be set by presentation layer
        duration: duration,
        filePath: filePath,
        fileName: fileName,
        fileSize: fileSize,
        createdAt: DateTime.now(),
      );

      return Right(voiceMessage);
    } on RecordingException catch (e) {
      return Left(RecordingFailure(e.message));
    } on Exception catch (e) {
      return Left(UnexpectedFailure('Failed to stop recording: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelRecording() async {
    try {
      final result = await localDataSource.cancelRecording();
      return Right(result);
    } on RecordingException catch (e) {
      return Left(RecordingFailure(e.message));
    } on Exception catch (e) {
      return Left(UnexpectedFailure('Failed to cancel recording: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> pauseRecording() async {
    try {
      final result = await localDataSource.pauseRecording();
      return Right(result);
    } on RecordingException catch (e) {
      return Left(RecordingFailure(e.message));
    } on Exception catch (e) {
      return Left(UnexpectedFailure('Failed to pause recording: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> resumeRecording() async {
    try {
      final result = await localDataSource.resumeRecording();
      return Right(result);
    } on RecordingException catch (e) {
      return Left(RecordingFailure(e.message));
    } on Exception catch (e) {
      return Left(UnexpectedFailure('Failed to resume recording: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isRecording() async {
    try {
      final result = await localDataSource.isRecording();
      return Right(result);
    } on Exception catch (e) {
      return Left(UnexpectedFailure('Failed to check recording status: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getRecordingDuration() async {
    try {
      final duration = await localDataSource.getRecordingDuration();
      return Right(duration);
    } on Exception catch (e) {
      return Left(UnexpectedFailure('Failed to get recording duration: $e'));
    }
  }

  @override
  Future<Either<Failure, VoiceMessageEntity>> uploadVoiceMessage(
    VoiceMessageEntity voiceMessage, {
    void Function(double)? onProgress,
  }) async {
    try {
      // Convert entity to model
      final model = VoiceMessageModel.fromEntity(voiceMessage);

      // Upload to Firebase Storage
      final uploadedModel = await remoteDataSource.uploadVoiceMessage(
        model,
        onProgress: onProgress,
      );

      // Delete local file after successful upload
      if (voiceMessage.filePath != null) {
        await localDataSource.deleteLocalFile(voiceMessage.filePath!);
      }

      return Right(uploadedModel);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on Exception catch (e) {
      return Left(UnexpectedFailure('Failed to upload voice message: $e'));
    }
  }

  @override
  Future<Either<Failure, VoiceMessageEntity>> downloadVoiceMessage(
    VoiceMessageEntity voiceMessage, {
    void Function(double)? onProgress,
  }) async {
    try {
      // Convert entity to model
      final model = VoiceMessageModel.fromEntity(voiceMessage);

      // Download from Firebase Storage
      final downloadedModel = await remoteDataSource.downloadVoiceMessage(
        model,
        onProgress: onProgress,
      );

      return Right(downloadedModel);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on Exception catch (e) {
      return Left(UnexpectedFailure('Failed to download voice message: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteVoiceMessage(
    VoiceMessageEntity voiceMessage,
  ) async {
    try {
      // Delete from Firebase Storage if uploaded
      if (voiceMessage.downloadUrl != null &&
          voiceMessage.downloadUrl!.isNotEmpty) {
        await remoteDataSource.deleteVoiceMessage(voiceMessage.downloadUrl!);
      }

      // Delete local file if exists
      if (voiceMessage.filePath != null && voiceMessage.filePath!.isNotEmpty) {
        await localDataSource.deleteLocalFile(voiceMessage.filePath!);
      }

      return const Right(true);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on RecordingException catch (e) {
      return Left(StorageFailure(e.message));
    } on Exception catch (e) {
      return Left(UnexpectedFailure('Failed to delete voice message: $e'));
    }
  }

  @override
  Future<Either<Failure, VoiceMessageEntity>> playVoiceMessage(
    VoiceMessageEntity voiceMessage,
  ) async {
    // Playback will be handled by a separate audio player service
    // For now, just return the voice message with isPlaying = true
    return Right(voiceMessage.copyWith(isPlaying: true));
  }

  @override
  Future<Either<Failure, VoiceMessageEntity>> pausePlayback(
    VoiceMessageEntity voiceMessage,
  ) async {
    // Playback will be handled by a separate audio player service
    // For now, just return the voice message with isPlaying = false
    return Right(voiceMessage.copyWith(isPlaying: false));
  }

  @override
  Future<Either<Failure, VoiceMessageEntity>> resumePlayback(
    VoiceMessageEntity voiceMessage,
  ) async {
    // Playback will be handled by a separate audio player service
    // For now, just return the voice message with isPlaying = true
    return Right(voiceMessage.copyWith(isPlaying: true));
  }

  @override
  Future<Either<Failure, VoiceMessageEntity>> stopPlayback(
    VoiceMessageEntity voiceMessage,
  ) async {
    // Playback will be handled by a separate audio player service
    // For now, just return the voice message with isPlaying = false, playbackPosition = 0
    return Right(
      voiceMessage.copyWith(
        isPlaying: false,
        playbackPosition: 0.0,
      ),
    );
  }

  @override
  Future<Either<Failure, VoiceMessageEntity>> seekTo(
    VoiceMessageEntity voiceMessage,
    double position,
  ) async {
    // Playback will be handled by a separate audio player service
    // For now, just return the voice message with updated playbackPosition
    return Right(voiceMessage.copyWith(playbackPosition: position));
  }

  @override
  Future<Either<Failure, double>> getPlaybackPosition(
    VoiceMessageEntity voiceMessage,
  ) async {
    // Playback will be handled by a separate audio player service
    // For now, just return the current playback position
    return Right(voiceMessage.playbackPosition);
  }

  @override
  Future<Either<Failure, bool>> isPlaying(
    VoiceMessageEntity voiceMessage,
  ) async {
    // Playback will be handled by a separate audio player service
    // For now, just return the current playing state
    return Right(voiceMessage.isPlaying);
  }

  @override
  Future<Either<Failure, void>> dispose() async {
    try {
      // Cleanup resources if needed
      // For now, nothing to dispose
      return const Right(null);
    } on Exception catch (e) {
      return Left(UnexpectedFailure('Failed to dispose: $e'));
    }
  }
}
