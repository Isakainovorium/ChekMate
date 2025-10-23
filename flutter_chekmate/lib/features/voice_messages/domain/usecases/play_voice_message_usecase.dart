import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chekmate/core/error/failures.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/repositories/voice_recording_repository.dart';

/// Use case for playing a voice message
/// 
/// This use case encapsulates the business logic for playing a voice message.
/// It follows the Single Responsibility Principle by handling only one operation.
/// 
/// Usage:
/// ```dart
/// final useCase = PlayVoiceMessageUseCase(repository);
/// final params = PlayVoiceMessageParams(voiceMessage: message);
/// final result = await useCase(params);
/// 
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (voiceMessage) => print('Playing: ${voiceMessage.fileName}'),
/// );
/// ```
class PlayVoiceMessageUseCase {

  PlayVoiceMessageUseCase(this.repository);
  final VoiceRecordingRepository repository;

  /// Executes the use case
  /// 
  /// [params]: Parameters containing the voice message to play
  /// 
  /// Returns Either<Failure, VoiceMessageEntity>:
  /// - Left: Failure if playback fails to start
  /// - Right: Updated VoiceMessageEntity with isPlaying = true
  /// 
  /// Possible failures:
  /// - [PlaybackFailure]: Playback failed to start
  /// - [ValidationFailure]: Voice message has no file path or download URL
  Future<Either<Failure, VoiceMessageEntity>> call(
    PlayVoiceMessageParams params,
  ) async {
    // Validate that the voice message is ready to play
    if (!params.voiceMessage.isReadyToPlay) {
      return const Left(
        ValidationFailure(
          'Voice message is not ready to play. Missing file path or download URL.',
        ),
      );
    }

    return repository.playVoiceMessage(params.voiceMessage);
  }
}

/// Parameters for PlayVoiceMessageUseCase
class PlayVoiceMessageParams extends Equatable {

  const PlayVoiceMessageParams({
    required this.voiceMessage,
  });
  final VoiceMessageEntity voiceMessage;

  @override
  List<Object?> get props => [voiceMessage];
}

