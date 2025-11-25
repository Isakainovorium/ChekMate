import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/providers/voice_recording_providers.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/state/voice_recording_state.dart';

/// Voice Recording Button Widget
///
/// A floating action button that handles voice recording with visual feedback.
/// Integrates with Riverpod state management for recording state.
class VoiceRecordingButton extends ConsumerWidget {
  const VoiceRecordingButton({
    super.key,
    required this.senderId,
    required this.receiverId,
    this.size = 56.0,
    this.iconSize,
    this.maxDuration = 60,
    this.primaryColor,
    this.backgroundColor,
    this.onRecordingComplete,
    this.onRecordingCancelled,
    this.onError,
  });

  final String senderId;
  final String receiverId;
  final double size;
  final double? iconSize;
  final int maxDuration;
  final Color? primaryColor;
  final Color? backgroundColor;
  final void Function(VoiceMessageEntity voiceMessage)? onRecordingComplete;
  final void Function()? onRecordingCancelled;
  final void Function(String error)? onError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(voiceRecordingProvider);
    final recordingNotifier = ref.read(voiceRecordingProvider.notifier);

    return SizedBox(
      width: size,
      height: size,
      child: FloatingActionButton(
        onPressed: () => _handleRecording(recordingState, recordingNotifier),
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        foregroundColor: primaryColor ?? Theme.of(context).colorScheme.onPrimary,
        elevation: recordingState.isRecording ? 8.0 : 6.0,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildIcon(recordingState),
        ),
      ),
    );
  }

  void _handleRecording(VoiceRecordingState state, VoiceRecordingNotifier notifier) {
    if (state.isIdle) {
      // Start recording
      notifier.startRecording();
    } else if (state.isRecording) {
      // Stop recording
      notifier.stopRecording();
      // Mock completion callback
      if (onRecordingComplete != null) {
        // In real implementation, this would be called after processing/uploading
        // For now, create a mock VoiceMessageEntity
        final mockMessage = VoiceMessageEntity(
          id: 'mock-id',
          senderId: senderId,
          receiverId: receiverId,
          url: 'https://example.com/voice.mp3',
          duration: 5,
          createdAt: DateTime.now(),
        );
        onRecordingComplete!(mockMessage);
      }
    } else if (state.isPaused) {
      // Resume recording
      notifier.resumeRecording();
    }

    // Handle errors (mock implementation)
    if (state.hasError && onError != null) {
      onError!(state.errorMessage ?? 'Unknown error');
    }

    // Handle cancellation
    if (onRecordingCancelled != null) {
      // In real implementation, this would be called when recording is cancelled
    }
  }

  Widget _buildIcon(VoiceRecordingState state) {
    final iconSizeValue = iconSize ?? (size * 0.6);

    if (state.isRecording) {
      return Icon(
        Icons.stop,
        key: const ValueKey('stop'),
        size: iconSizeValue,
      );
    } else if (state.isPaused) {
      return Icon(
        Icons.play_arrow,
        key: const ValueKey('play'),
        size: iconSizeValue,
      );
    } else {
      return Icon(
        Icons.mic,
        key: const ValueKey('mic'),
        size: iconSizeValue,
      );
    }
  }
}
