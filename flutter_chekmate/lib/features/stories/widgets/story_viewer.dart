import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/stories/widgets/video_story_player.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// Story Viewer - converted from StoryViewer.tsx
/// Full-screen story viewer with progress bars
class StoryViewer extends StatefulWidget {
  const StoryViewer({
    required this.stories,
    super.key,
    this.initialUserIndex = 0,
  });
  final List<StoryUser> stories;
  final int initialUserIndex;

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  int _currentUserIndex = 0;
  int _currentStoryIndex = 0;
  double _progress = 0;
  bool _isPaused = false;
  bool _isMuted = false;
  String _replyText = '';
  Timer? _progressTimer;
  double _dragOffset = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentUserIndex = widget.initialUserIndex;
    _startProgress();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startProgress() {
    _progressTimer?.cancel();
    _progress = 0;

    if (_isPaused) return;

    final currentStory = _getCurrentStory();
    if (currentStory == null) return;

    const updateInterval = Duration(milliseconds: 100);
    final totalDuration = Duration(seconds: currentStory.duration);
    final increment =
        100 / (totalDuration.inMilliseconds / updateInterval.inMilliseconds);

    _progressTimer = Timer.periodic(updateInterval, (timer) {
      if (!mounted || _isPaused) return;

      setState(() {
        _progress += increment;
        if (_progress >= 100) {
          _nextStory();
        }
      });
    });
  }

  StoryContent? _getCurrentStory() {
    if (_currentUserIndex >= widget.stories.length) return null;
    final user = widget.stories[_currentUserIndex];
    if (_currentStoryIndex >= user.stories.length) return null;
    return user.stories[_currentStoryIndex];
  }

  void _nextStory() {
    final user = widget.stories[_currentUserIndex];
    if (_currentStoryIndex < user.stories.length - 1) {
      setState(() {
        _currentStoryIndex++;
        _progress = 0;
      });
      _startProgress();
    } else if (_currentUserIndex < widget.stories.length - 1) {
      setState(() {
        _currentUserIndex++;
        _currentStoryIndex = 0;
        _progress = 0;
      });
      _startProgress();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
        _progress = 0;
      });
      _startProgress();
    } else if (_currentUserIndex > 0) {
      setState(() {
        _currentUserIndex--;
        final prevUser = widget.stories[_currentUserIndex];
        _currentStoryIndex = prevUser.stories.length - 1;
        _progress = 0;
      });
      _startProgress();
    }
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    if (_isPaused) {
      _progressTimer?.cancel();
    } else {
      _startProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.stories[_currentUserIndex];
    final story = _getCurrentStory();

    if (story == null) {
      return const SizedBox();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          if (_isDragging) return;
          final width = MediaQuery.of(context).size.width;
          final tapX = details.globalPosition.dx;

          if (tapX < width / 3) {
            _previousStory();
          } else if (tapX > width * 2 / 3) {
            _nextStory();
          } else {
            _togglePause();
          }
        },
        onVerticalDragStart: (details) {
          setState(() {
            _isDragging = true;
            _isPaused = true;
          });
          _progressTimer?.cancel();
        },
        onVerticalDragUpdate: (details) {
          setState(() {
            _dragOffset += details.delta.dy;
            // Only allow downward drag
            if (_dragOffset < 0) _dragOffset = 0;
          });
        },
        onVerticalDragEnd: (details) {
          if (_dragOffset > 100) {
            // Dismiss story viewer
            Navigator.of(context).pop();
          } else {
            // Snap back to original position
            setState(() {
              _dragOffset = 0.0;
              _isDragging = false;
              _isPaused = false;
            });
            _startProgress();
          }
        },
        child: Transform.translate(
          offset: Offset(0, _dragOffset),
          child: Opacity(
            opacity: 1.0 - (_dragOffset / 500).clamp(0.0, 0.5),
            child: Stack(
              children: [
                _buildStoryContent(story),
                _buildProgressBars(user),
                _buildHeader(user, story),
                _buildBottomActions(user),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryContent(StoryContent story) {
    return Positioned.fill(
      child: story.type == 'image'
          ? Image.network(story.url, fit: BoxFit.cover)
          : story.type == 'video'
              ? VideoStoryPlayer(
                  videoUrl: story.url,
                  thumbnailUrl: story.thumbnailUrl,
                  onVideoEnd: _nextStory,
                  onPause: () => setState(() => _isPaused = true),
                  onResume: () => setState(() => _isPaused = false),
                )
              : Container(
                  color: Colors.grey.shade900,
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
    );
  }

  Widget _buildProgressBars(StoryUser user) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Row(
        children: List.generate(user.stories.length, (index) {
          final progress = index < _currentStoryIndex
              ? 1.0
              : index == _currentStoryIndex
                  ? _progress / 100
                  : 0.0;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: AppProgress(
                value: progress,
                height: 4,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: Colors.white,
                borderRadius: 2,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(StoryUser user, StoryContent story) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 32,
      left: 16,
      right: 16,
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(user.avatar),
          ),
          const SizedBox(width: AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                story.timestamp,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (_isPaused)
            IconButton(
              onPressed: _togglePause,
              icon: const Icon(Icons.play_arrow, color: Colors.white),
            )
          else
            IconButton(
              onPressed: _togglePause,
              icon: const Icon(Icons.pause, color: Colors.white),
            ),
          IconButton(
            onPressed: () => setState(() => _isMuted = !_isMuted),
            icon: Icon(
              _isMuted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(StoryUser user) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 24,
      left: 16,
      right: 16,
      child: Row(
        children: [
          Expanded(
            child: AppInput(
              hint: 'Reply to ${user.username}...',
              onChanged: (value) => setState(() => _replyText = value),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            onPressed: () => debugPrint('Like story'),
            icon: const Icon(Icons.favorite_border, color: Colors.white),
          ),
          if (_replyText.isNotEmpty)
            IconButton(
              onPressed: () {
                debugPrint('Send reply: $_replyText');
                setState(() => _replyText = '');
              },
              icon: const Icon(Icons.send, color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}

/// Story models
class StoryUser {
  StoryUser({
    required this.id,
    required this.username,
    required this.avatar,
    required this.stories,
  });
  final String id;
  final String username;
  final String avatar;
  final List<StoryContent> stories;
}

class StoryContent {
  StoryContent({
    required this.id,
    required this.type,
    required this.url,
    required this.duration,
    required this.timestamp,
    this.thumbnailUrl,
    this.text,
  });
  final String id;
  final String type; // 'image' or 'video'
  final String url;
  final String? thumbnailUrl; // Thumbnail for video stories
  final int duration; // in seconds
  final String timestamp;
  final String? text;
}
