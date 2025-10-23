import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// Video Player Widget - converted from VideoPlayer.tsx
/// Full-screen video player with controls
class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    required this.video,
    required this.userName,
    required this.userAvatar,
    super.key,
  });
  final VideoData video;
  final String userName;
  final String userAvatar;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  bool _isPlaying = false;
  // ignore: unused_field
  final bool _isMuted = false;
  double _currentTime = 0;
  final double _duration = 100; // Mock duration
  bool _isLiked = false;
  bool _showControls = true;
  Timer? _controlsTimer;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _startPlaying();
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startPlaying() {
    setState(() => _isPlaying = true);
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isPlaying && mounted) {
        setState(() {
          _currentTime += 0.1;
          if (_currentTime >= _duration) {
            _currentTime = 0; // Loop
          }
        });
      }
    });
    _hideControlsAfterDelay();
  }

  void _hideControlsAfterDelay() {
    _controlsTimer?.cancel();
    if (_isPlaying) {
      _controlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showControls = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: AppVideoPlayer(
              videoUrl:
                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', // Mock video URL
              thumbnailUrl: widget.video.thumbnail,
              title: widget.video.title,
              description: '${widget.video.views} views',
              autoPlay: _isPlaying,
              showControls: _showControls,
              onPlay: () => setState(() => _isPlaying = true),
              onPause: () => setState(() => _isPlaying = false),
              onEnd: () => setState(() => _isPlaying = false),
              onError: (error) => debugPrint('Video error: $error'),
            ),
          ),
          _buildVideoInfo(),
        ],
      ),
    );
  }

  Widget _buildVideoInfo() {
    return AppCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(
                imageUrl: widget.userAvatar,
                name: widget.userName,
                size: AppAvatarSize.large,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.video.title,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildActionButton(
                    icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                    label: 'Like',
                    color: _isLiked ? Colors.red : Colors.grey.shade600,
                    onTap: () => setState(() => _isLiked = !_isLiked),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _buildActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Comment',
                    color: Colors.grey.shade600,
                    onTap: () {},
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _buildActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    color: Colors.grey.shade600,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.video.views} views',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              if (widget.video.isChecked)
                const AppBadge(
                  label: 'Cheked',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

/// Video data model
class VideoData {
  VideoData({
    required this.id,
    required this.thumbnail,
    required this.title,
    required this.views,
    this.isChecked = false,
  });
  final String id;
  final String thumbnail;
  final String title;
  final String views;
  final bool isChecked;
}
