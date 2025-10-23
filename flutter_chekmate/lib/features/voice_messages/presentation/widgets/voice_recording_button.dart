import 'package:flutter/material.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/providers/voice_recording_providers.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/state/voice_recording_notifier.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/state/voice_recording_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Voice recording button widget
///
/// This widget displays a microphone button that:
/// - Shows different states (idle, recording, paused, uploading)
/// - Handles tap to start/stop recording
/// - Shows visual feedback for recording state
/// - Integrates with VoiceRecordingNotifier
///
/// Usage:
/// ```dart
/// VoiceRecordingButton(
///   senderId: 'user123',
///   receiverId: 'user456',
///   onRecordingComplete: (voiceMessage) {
///     // Handle completed recording
///   },
/// )
/// ```
class VoiceRecordingButton extends ConsumerWidget {
  const VoiceRecordingButton({
    required this.senderId,
    required this.receiverId,
    super.key,
    this.onRecordingComplete,
    this.onRecordingCancelled,
    this.onError,
    this.maxDuration = 60,
    this.size = 56.0,
    this.iconSize = 28.0,
    this.primaryColor,
    this.backgroundColor,
  });

  /// ID of the user sending the voice message
  final String senderId;

  /// ID of the user receiving the voice message
  final String receiverId;

  /// Callback when recording is complete and uploaded
  final void Function(dynamic voiceMessage)? onRecordingComplete;

  /// Callback when recording is cancelled
  final VoidCallback? onRecordingCancelled;

  /// Callback when an error occurs
  final void Function(String error)? onError;

  /// Maximum recording duration in seconds (default: 60)
  final int maxDuration;

  /// Button size (default: 56.0)
  final double size;

  /// Icon size (default: 28.0)
  final double iconSize;

  /// Primary color (default: Theme primary color)
  final Color? primaryColor;

  /// Background color (default: Theme surface color)
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(voiceRecordingNotifierProvider);
    final recordingNotifier = ref.read(voiceRecordingNotifierProvider.notifier);

    // Listen for state changes
    ref.listen<VoiceRecordingState>(
      voiceRecordingNotifierProvider,
      (previous, next) {
        if (next.isCompleted && next.voiceMessage != null) {
          onRecordingComplete?.call(next.voiceMessage);
          recordingNotifier.reset();
        } else if (next.hasError && next.errorMessage != null) {
          onError?.call(next.errorMessage!);
          recordingNotifier.reset();
        }
      },
    );

    final theme = Theme.of(context);
    final effectivePrimaryColor = primaryColor ?? theme.colorScheme.primary;
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.surface;

    return GestureDetector(
      onTap: () => _handleTap(context, recordingState, recordingNotifier),
      onLongPress: () =>
          _handleLongPress(context, recordingState, recordingNotifier),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _getBackgroundColor(
            recordingState,
            effectivePrimaryColor,
            effectiveBackgroundColor,
          ),
          shape: BoxShape.circle,
          boxShadow: recordingState.isRecording
              ? [
                  BoxShadow(
                    color: effectivePrimaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: _buildIcon(
            context,
            recordingState,
            effectivePrimaryColor,
          ),
        ),
      ),
    );
  }

  /// Build the appropriate icon based on recording state
  Widget _buildIcon(
    BuildContext context,
    VoiceRecordingState state,
    Color primaryColor,
  ) {
    if (state.isUploading) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          value: state.uploadProgress,
        ),
      );
    }

    if (state.isProcessing) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      );
    }

    IconData iconData;
    Color iconColor;

    if (state.isRecording) {
      iconData = Icons.stop;
      iconColor = Colors.white;
    } else if (state.isPaused) {
      iconData = Icons.play_arrow;
      iconColor = primaryColor;
    } else {
      iconData = Icons.mic;
      iconColor = primaryColor;
    }

    return Icon(
      iconData,
      size: iconSize,
      color: iconColor,
    );
  }

  /// Get background color based on recording state
  Color _getBackgroundColor(
    VoiceRecordingState state,
    Color primaryColor,
    Color backgroundColor,
  ) {
    if (state.isRecording) {
      return primaryColor;
    } else if (state.isPaused) {
      return backgroundColor;
    } else {
      return backgroundColor;
    }
  }

  /// Handle tap event
  void _handleTap(
    BuildContext context,
    VoiceRecordingState state,
    VoiceRecordingNotifier notifier,
  ) {
    if (state.isIdle) {
      // Start recording
      notifier.startRecording(
        senderId: senderId,
        receiverId: receiverId,
        maxDuration: maxDuration,
      );
    } else if (state.isRecording) {
      // Stop recording
      notifier.stopRecording().then((_) {
        // Auto-upload after stopping
        if (state.voiceMessage != null) {
          notifier.uploadVoiceMessage();
        }
      });
    } else if (state.isPaused) {
      // Resume recording
      notifier.resumeRecording();
    }
  }

  /// Handle long press event (cancel recording)
  void _handleLongPress(
    BuildContext context,
    VoiceRecordingState state,
    VoiceRecordingNotifier notifier,
  ) {
    if (state.canStop) {
      notifier.cancelRecording();
      onRecordingCancelled?.call();
    }
  }
}
