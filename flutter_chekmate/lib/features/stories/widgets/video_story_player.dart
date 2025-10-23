import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Video Story Player - Full-screen video player for stories
///
/// Features:
/// - Full-screen video playback
/// - Auto-play on story open
/// - Pause on tap (center)
/// - Progress bar synced with video duration
/// - Auto-advance to next story on video end
/// - Mute/unmute toggle
///
/// Usage:
/// ```dart
/// VideoStoryPlayer(
///   videoUrl: 'https://example.com/story.mp4',
///   onVideoEnd: () => _nextStory(),
///   onPause: () => _pauseStory(),
///   onResume: () => _resumeStory(),
/// )
/// ```
class VideoStoryPlayer extends StatefulWidget {
  const VideoStoryPlayer({
    required this.videoUrl,
    super.key,
    this.thumbnailUrl,
    this.onVideoEnd,
    this.onPause,
    this.onResume,
    this.onError,
  });

  final String videoUrl;
  final String? thumbnailUrl;
  final VoidCallback? onVideoEnd;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final ValueChanged<String>? onError;

  @override
  State<VideoStoryPlayer> createState() => _VideoStoryPlayerState();
}

class _VideoStoryPlayerState extends State<VideoStoryPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(),
      );

      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Set initial mute state
        unawaited(_controller.setVolume(_isMuted ? 0.0 : 1.0));

        // Don't loop - advance to next story on end
        unawaited(_controller.setLooping(false));

        // Add listener for video end
        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration) {
            widget.onVideoEnd?.call();
          }
        });

        // Auto-play
        unawaited(_controller.play());
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load video';
        });
        widget.onError?.call(_errorMessage);
      }
    }
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      widget.onPause?.call();
    } else {
      _controller.play();
      widget.onResume?.call();
    }
    setState(() {});
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  /// Get progress as a value between 0.0 and 1.0
  double get _progress {
    if (!_isInitialized || _controller.value.duration.inMilliseconds == 0) {
      return 0.0;
    }
    return _controller.value.position.inMilliseconds /
        _controller.value.duration.inMilliseconds;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video player or thumbnail
        if (_isInitialized && !_hasError)
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          )
        else if (widget.thumbnailUrl != null)
          Image.network(
            widget.thumbnailUrl!,
            fit: BoxFit.cover,
          )
        else
          Container(color: Colors.black),

        // Loading indicator
        if (!_isInitialized && !_hasError)
          const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),

        // Error message
        if (_hasError)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

        // Play/Pause overlay (when paused)
        if (_isInitialized && !_hasError && !_controller.value.isPlaying)
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),

        // Tap detector for play/pause
        Positioned.fill(
          child: GestureDetector(
            onTap: _isInitialized && !_hasError ? _togglePlayPause : null,
            child: Container(color: Colors.transparent),
          ),
        ),

        // Mute/Unmute button (top right)
        if (_isInitialized && !_hasError)
          Positioned(
            top: 60,
            right: 16,
            child: IconButton(
              onPressed: _toggleMute,
              icon: Icon(
                _isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

        // Progress bar (synced with video duration)
        if (_isInitialized && !_hasError)
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 2,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
