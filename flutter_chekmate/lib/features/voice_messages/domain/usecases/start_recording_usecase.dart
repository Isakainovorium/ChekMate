import 'package:dartz/dartz.dart';
import 'package:flutter_chekmate/core/error/failures.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/repositories/voice_recording_repository.dart';

/// Use case for starting a voice message recording
/// 
/// This use case encapsulates the business logic for starting a voice recording.
/// It follows the Single Responsibility Principle by handling only one operation.
/// 
/// Usage:
/// ```dart
/// final useCase = StartRecordingUseCase(repository);
/// final result = await useCase();
/// 
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (filePath) => print('Recording started: $filePath'),
/// );
/// ```
class StartRecordingUseCase {

  StartRecordingUseCase(this.repository);
  final VoiceRecordingRepository repository;

  /// Executes the use case
  /// 
  /// Returns Either<Failure, String>:
  /// - Left: Failure if recording fails to start
  /// - Right: File path where recording is being saved
  /// 
  /// Possible failures:
  /// - [PermissionFailure]: Microphone permission not granted
  /// - [RecordingFailure]: Recording failed to start
  Future<Either<Failure, String>> call() async {
    return repository.startRecording();
  }
}

