import 'package:dartz/dartz.dart';
import 'package:flutter_chekmate/core/error/failures.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/repositories/voice_recording_repository.dart';

/// Use case for stopping a voice message recording
/// 
/// This use case encapsulates the business logic for stopping a voice recording.
/// It follows the Single Responsibility Principle by handling only one operation.
/// 
/// Usage:
/// ```dart
/// final useCase = StopRecordingUseCase(repository);
/// final result = await useCase();
/// 
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (voiceMessage) => print('Recording stopped: ${voiceMessage.fileName}'),
/// );
/// ```
class StopRecordingUseCase {

  StopRecordingUseCase(this.repository);
  final VoiceRecordingRepository repository;

  /// Executes the use case
  /// 
  /// Returns Either<Failure, VoiceMessageEntity>:
  /// - Left: Failure if recording fails to stop
  /// - Right: VoiceMessageEntity with recorded audio file information
  /// 
  /// Possible failures:
  /// - [RecordingFailure]: No recording in progress or stop failed
  Future<Either<Failure, VoiceMessageEntity>> call() async {
    return repository.stopRecording();
  }
}

