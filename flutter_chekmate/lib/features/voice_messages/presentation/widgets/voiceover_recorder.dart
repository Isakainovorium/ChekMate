import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/voice_messages/domain/entities/voice_message_entity.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/providers/voice_recording_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Voiceover Recorder Widget
///
/// Allows users to record audio narration over video posts (TikTok-style).
/// Features:
/// - Record voiceover while video plays
/// - Pause/resume recording
/// - Cancel recording
/// - Preview combined audio
/// - Max 60 seconds (matches video duration)
///
/// Usage:
/// ```dart
/// VoiceoverRecorder(
///   videoPath: '/path/to/video.mp4',
///   videoDuration: 30, // seconds
///   onRecordingComplete: (voiceMessage) {
///     // Handle completed voiceover
///   },
///   onCancel: () {
///     // Handle cancel
///   },
/// )
/// ```
class VoiceoverRecorder extends ConsumerStatefulWidget {
  const VoiceoverRecorder({
    required this.videoPath,
    required this.videoDuration,
    super.key,
    this.onRecordingComplete,
    this.onCancel,
    this.maxDuration = 60,
  });

  /// Path to the video file
  final String videoPath;

  /// Duration of the video in seconds
  final int videoDuration;

  /// Callback when recording is complete
  final void Function(VoiceMessageEntity voiceMessage)? onRecordingComplete;

  /// Callback when recording is cancelled
  final VoidCallback? onCancel;

  /// Maximum recording duration in seconds (default: 60)
  final int maxDuration;

  @override
  ConsumerState<VoiceoverRecorder> createState() => _VoiceoverRecorderState();
}

class _VoiceoverRecorderState extends ConsumerState<VoiceoverRecorder> {
  bool _isVideoPlaying = false;

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(voiceRecordingNotifierProvider);
    final recordingNotifier = ref.read(voiceRecordingNotifierProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Record Voiceover',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  if (recordingState.isRecording) {
                    recordingNotifier.cancelRecording();
                  }
                  widget.onCancel?.call();
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Instructions
          if (!recordingState.isRecording && !recordingState.isPaused)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Tap record to start. The video will play while you narrate.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.lg),

          // Recording Timer
          if (recordingState.isRecording || recordingState.isPaused)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (recordingState.isRecording)
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        recordingState.formattedDuration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '/ ${_formatDuration(widget.maxDuration)}',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.xl),

          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Cancel Button
              if (recordingState.isRecording || recordingState.isPaused)
                _buildControlButton(
                  icon: Icons.close,
                  label: 'Cancel',
                  color: Colors.red,
                  onTap: () {
                    recordingNotifier.cancelRecording();
                    widget.onCancel?.call();
                  },
                ),

              // Record/Pause Button
              _buildControlButton(
                icon: recordingState.isRecording
                    ? Icons.pause
                    : recordingState.isPaused
                        ? Icons.play_arrow
                        : Icons.mic,
                label: recordingState.isRecording
                    ? 'Pause'
                    : recordingState.isPaused
                        ? 'Resume'
                        : 'Record',
                color: AppColors.primary,
                onTap: () async {
                  if (!recordingState.isRecording && !recordingState.isPaused) {
                    // Start recording
                    await recordingNotifier.startRecording(
                      senderId: 'voiceover',
                      receiverId: 'video',
                      maxDuration: widget.maxDuration,
                    );
                    setState(() {
                      _isVideoPlaying = true;
                    });
                  } else if (recordingState.isRecording) {
                    // Pause recording
                    await recordingNotifier.pauseRecording();
                    setState(() {
                      _isVideoPlaying = false;
                    });
                  } else if (recordingState.isPaused) {
                    // Resume recording
                    await recordingNotifier.resumeRecording();
                    setState(() {
                      _isVideoPlaying = true;
                    });
                  }
                },
                size: 80,
              ),

              // Done Button
              if (recordingState.isRecording || recordingState.isPaused)
                _buildControlButton(
                  icon: Icons.check,
                  label: 'Done',
                  color: Colors.green,
                  onTap: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    await recordingNotifier.stopRecording();
                    // Access voice message from state after stopping
                    final voiceMessage = recordingState.voiceMessage;
                    if (voiceMessage != null) {
                      widget.onRecordingComplete?.call(voiceMessage);
                    } else {
                      // Show error if no voice message
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Failed to save voiceover'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Video Status
          if (_isVideoPlaying)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    color: Colors.green,
                    size: 16,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Video playing...',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    double size = 60,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: size * 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
