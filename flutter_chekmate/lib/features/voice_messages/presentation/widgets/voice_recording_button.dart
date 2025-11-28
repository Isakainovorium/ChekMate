import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/providers/voice_recording_providers.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/state/voice_recording_state.dart';

/// Voice Recording Button Widget
///
/// A floating action button that handles voice recording with visual feedback.
/// Integrates with Riverpod state management for recording state.
class VoiceRecordingButton extends ConsumerStatefulWidget {
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
  ConsumerState<VoiceRecordingButton> createState() => _VoiceRecordingButtonState();
}

class _VoiceRecordingButtonState extends ConsumerState<VoiceRecordingButton> {
  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(voiceRecordingProvider);

    // Listen for state changes
    ref.listen<VoiceRecordingState>(voiceRecordingProvider, (previous, next) {
      // Handle completion
      if (next.isCompleted && next.filePath != null) {
        _handleRecordingComplete(next);
      }
      
      // Handle errors
      if (next.hasError && widget.onError != null) {
        widget.onError!(next.errorMessage ?? 'Unknown error');
      }
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Duration indicator when recording
        if (recordingState.isRecording || recordingState.isPaused)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: recordingState.isRecording ? Colors.red : Colors.orange,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _formatDuration(recordingState.duration),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        
        // Recording button
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: GestureDetector(
            onLongPress: () => _startRecording(),
            onLongPressEnd: (_) => _stopRecording(),
            child: FloatingActionButton(
              onPressed: () => _handleTap(recordingState),
              backgroundColor: recordingState.isRecording
                  ? Colors.red
                  : (widget.backgroundColor ?? AppColors.primary),
              foregroundColor: widget.primaryColor ?? Colors.white,
              elevation: recordingState.isRecording ? 8.0 : 6.0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildIcon(recordingState),
              ),
            ),
          ),
        ),
        
        // Cancel button when recording
        if (recordingState.isRecording || recordingState.isPaused)
          TextButton(
            onPressed: _cancelRecording,
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _handleTap(VoiceRecordingState state) {
    if (state.isIdle || state.isCompleted) {
      _startRecording();
    } else if (state.isRecording) {
      _stopRecording();
    } else if (state.isPaused) {
      ref.read(voiceRecordingProvider.notifier).resumeRecording();
    }
    HapticFeedback.mediumImpact();
  }

  void _startRecording() {
    ref.read(voiceRecordingProvider.notifier).startRecording();
    HapticFeedback.heavyImpact();
  }

  Future<void> _stopRecording() async {
    await ref.read(voiceRecordingProvider.notifier).stopRecording();
    HapticFeedback.lightImpact();
  }

  void _cancelRecording() {
    ref.read(voiceRecordingProvider.notifier).cancelRecording();
    widget.onRecordingCancelled?.call();
    HapticFeedback.lightImpact();
  }

  void _handleRecordingComplete(VoiceRecordingState state) {
    if (widget.onRecordingComplete != null && state.filePath != null) {
      final voiceMessage = VoiceMessageEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: widget.senderId,
        receiverId: widget.receiverId,
        url: state.filePath!, // Local file path, will be uploaded by caller
        duration: state.duration,
        createdAt: DateTime.now(),
        filePath: state.filePath,
      );
      widget.onRecordingComplete!(voiceMessage);
    }
    
    // Reset state after completion callback
    ref.read(voiceRecordingProvider.notifier).completeRecording();
  }

  Widget _buildIcon(VoiceRecordingState state) {
    final iconSizeValue = widget.iconSize ?? (widget.size * 0.5);

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
    } else if (state.isProcessing) {
      return SizedBox(
        width: iconSizeValue,
        height: iconSizeValue,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
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
