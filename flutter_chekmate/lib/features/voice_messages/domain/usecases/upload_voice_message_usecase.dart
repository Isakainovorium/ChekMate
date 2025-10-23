import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chekmate/core/error/failures.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/repositories/voice_recording_repository.dart';

/// Use case for uploading a voice message to Firebase Storage
///
/// This use case encapsulates the business logic for uploading a voice message.
/// It follows the Single Responsibility Principle by handling only one operation.
///
/// Usage:
/// ```dart
/// final useCase = UploadVoiceMessageUseCase(repository);
/// final params = UploadVoiceMessageParams(
///   voiceMessage: message,
///   onProgress: (progress) => print('Upload: ${(progress * 100).toInt()}%'),
/// );
/// final result = await useCase(params);
///
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (voiceMessage) => print('Uploaded: ${voiceMessage.downloadUrl}'),
/// );
/// ```
class UploadVoiceMessageUseCase {
  UploadVoiceMessageUseCase(this.repository);
  final VoiceRecordingRepository repository;

  /// Executes the use case
  ///
  /// [params]: Parameters containing the voice message to upload and optional progress callback
  ///
  /// Returns Either<Failure, VoiceMessageEntity>:
  /// - Left: Failure if upload fails
  /// - Right: Updated VoiceMessageEntity with download URL
  ///
  /// Possible failures:
  /// - [NetworkFailure]: Network is unavailable
  /// - [StorageFailure]: Upload to Firebase Storage failed
  /// - [ValidationFailure]: Voice message validation failed
  Future<Either<Failure, VoiceMessageEntity>> call(
    UploadVoiceMessageParams params,
  ) async {
    // Validate the voice message before uploading
    if (!params.voiceMessage.validate()) {
      return const Left(
        ValidationFailure(
          'Voice message validation failed. Check duration (max 60s) and file size (max 5MB).',
        ),
      );
    }

    // Check if voice message has a local file path
    if (params.voiceMessage.filePath == null ||
        params.voiceMessage.filePath!.isEmpty) {
      return const Left(
        ValidationFailure(
          'Voice message has no local file path to upload.',
        ),
      );
    }

    return repository.uploadVoiceMessage(
      params.voiceMessage,
      onProgress: params.onProgress,
    );
  }
}

/// Parameters for UploadVoiceMessageUseCase
class UploadVoiceMessageParams extends Equatable {
  const UploadVoiceMessageParams({
    required this.voiceMessage,
    this.onProgress,
  });
  final VoiceMessageEntity voiceMessage;
  final void Function(double)? onProgress;

  @override
  List<Object?> get props => [voiceMessage, onProgress];
}
