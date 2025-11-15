import 'package:flutter/material.dart';

/// Voiceover Recorder Widget
/// Allows users to record voiceover audio for videos
class VoiceoverRecorder extends StatefulWidget {
  const VoiceoverRecorder({
    super.key,
    required this.videoPath,
    required this.videoDuration,
    this.onRecordingComplete,
    this.onCancel,
  });

  final String videoPath;
  final Duration videoDuration;
  final ValueChanged<String>? onRecordingComplete;
  final VoidCallback? onCancel;

  @override
  State<VoiceoverRecorder> createState() => _VoiceoverRecorderState();
}

class _VoiceoverRecorderState extends State<VoiceoverRecorder> {
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (!_isRecording) {
        // Recording stopped
        widget.onRecordingComplete?.call('path/to/recording.mp3');
        _recordingDuration = Duration.zero;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Voiceover Recorder',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          if (_isRecording)
            Text(
              _formatDuration(_recordingDuration),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          const SizedBox(height: 16),
          IconButton(
            onPressed: _toggleRecording,
            icon: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              size: 48,
            ),
            color: _isRecording
                ? Colors.red
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            _isRecording ? 'Tap to stop recording' : 'Tap to start recording',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
