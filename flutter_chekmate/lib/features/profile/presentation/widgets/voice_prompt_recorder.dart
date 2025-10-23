import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/profile/domain/entities/voice_prompt_entity.dart';
import 'package:flutter_chekmate/features/voice_messages/presentation/providers/voice_recording_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Voice Prompt Recorder Widget
///
/// Allows users to record voice answers to profile prompts (Bumble-style).
/// Features:
/// - Select from predefined questions
/// - Record answer (max 30 seconds)
/// - Pause/resume recording
/// - Cancel recording
/// - Preview recording
///
/// Usage:
/// ```dart
/// VoicePromptRecorder(
///   question: "What's your ideal date?",
///   onRecordingComplete: (voicePrompt) {
///     // Handle completed voice prompt
///   },
///   onCancel: () {
///     // Handle cancel
///   },
/// )
/// ```
class VoicePromptRecorder extends ConsumerStatefulWidget {
  const VoicePromptRecorder({
    required this.question,
    super.key,
    this.onRecordingComplete,
    this.onCancel,
    this.maxDuration = 30,
  });

  /// The prompt question
  final String question;

  /// Callback when recording is complete
  final void Function(VoicePromptEntity voicePrompt)? onRecordingComplete;

  /// Callback when recording is cancelled
  final VoidCallback? onCancel;

  /// Maximum recording duration in seconds (default: 30)
  final int maxDuration;

  @override
  ConsumerState<VoicePromptRecorder> createState() =>
      _VoicePromptRecorderState();
}

class _VoicePromptRecorderState extends ConsumerState<VoicePromptRecorder> {
  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(voiceRecordingNotifierProvider);
    final recordingNotifier = ref.read(voiceRecordingNotifierProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Record Voice Prompt',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
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

          // Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'PROMPT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.question,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Recording Timer
          if (recordingState.isRecording || recordingState.isPaused)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
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
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Tap the mic to start recording (max ${widget.maxDuration}s)',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
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
                      senderId: 'profile',
                      receiverId: 'prompt',
                      maxDuration: widget.maxDuration,
                    );
                  } else if (recordingState.isRecording) {
                    // Pause recording
                    await recordingNotifier.pauseRecording();
                  } else if (recordingState.isPaused) {
                    // Resume recording
                    await recordingNotifier.resumeRecording();
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

                    // Get the voice message from state
                    final voiceMessage = recordingState.voiceMessage;

                    if (voiceMessage != null) {
                      // Convert to VoicePromptEntity
                      final voicePrompt = VoicePromptEntity(
                        id: voiceMessage.id,
                        question: widget.question,
                        audioUrl: voiceMessage.downloadUrl ?? '',
                        duration: voiceMessage.duration,
                        createdAt: voiceMessage.createdAt,
                      );
                      widget.onRecordingComplete?.call(voicePrompt);
                    } else {
                      // Show error if no voice message
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Failed to save prompt'),
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
              fontSize: 12,
              fontWeight: FontWeight.w500,
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
