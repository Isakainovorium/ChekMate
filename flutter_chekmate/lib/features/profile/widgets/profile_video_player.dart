import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Profile Video Player - Compact video player for profile video intros
///
/// Features:
/// - Compact video player for profile
/// - Auto-play on profile view (muted)
/// - Tap to unmute
/// - Loop video
/// - Thumbnail preview
///
/// Usage:
/// ```dart
/// ProfileVideoPlayer(
///   videoUrl: 'https://example.com/intro.mp4',
///   thumbnailUrl: 'https://example.com/thumb.jpg',
/// )
/// ```
class ProfileVideoPlayer extends StatefulWidget {
  const ProfileVideoPlayer({
    required this.videoUrl,
    super.key,
    this.thumbnailUrl,
    this.aspectRatio = 9 / 16,
    this.height = 400,
    this.onError,
  });

  final String videoUrl;
  final String? thumbnailUrl;
  final double aspectRatio;
  final double height;
  final ValueChanged<String>? onError;

  @override
  State<ProfileVideoPlayer> createState() => _ProfileVideoPlayerState();
}

class _ProfileVideoPlayerState extends State<ProfileVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isMuted = true; // Start muted

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
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true, // Allow background audio
        ),
      );

      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Set initial mute state (start muted)
        unawaited(_controller.setVolume(0.0));

        // Loop video
        unawaited(_controller.setLooping(true));

        // Auto-play (muted)
        unawaited(_controller.play());
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load video intro';
        });
        widget.onError?.call(_errorMessage);
      }
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
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

            // Tap detector for mute/unmute
            if (_isInitialized && !_hasError)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleMute,
                  child: Container(color: Colors.transparent),
                ),
              ),

            // Mute/Unmute indicator (shows when tapped)
            if (_isInitialized && !_hasError)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),

            // "Tap to unmute" hint (shows for first few seconds)
            if (_isInitialized && !_hasError && _isMuted)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Tap to unmute',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
