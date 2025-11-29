import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/features/stories/models/story_model.dart';

/// Stories Widget
/// Displays a horizontal list of user stories with Instagram-style gradient rings
class StoriesWidget extends StatelessWidget {
  const StoriesWidget({
    super.key,
    required this.stories,
    this.onStoryTap,
  });

  final List<StoryUser> stories;
  final ValueChanged<StoryUser>? onStoryTap;

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final storyUser = stories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onStoryTap?.call(storyUser),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StoryRing(
                    hasUnviewedStories: storyUser.hasUnviewedStories,
                    avatarUrl: storyUser.avatar,
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 68,
                    child: Text(
                      storyUser.username,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Instagram-style story ring with animated gradient
class _StoryRing extends StatefulWidget {
  const _StoryRing({
    required this.hasUnviewedStories,
    this.avatarUrl,
  });

  final bool hasUnviewedStories;
  final String? avatarUrl;

  @override
  State<_StoryRing> createState() => _StoryRingState();
}

class _StoryRingState extends State<_StoryRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // Only animate if there are unviewed stories
    if (widget.hasUnviewedStories) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(_StoryRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasUnviewedStories && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.hasUnviewedStories && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: widget.hasUnviewedStories
                ? SweepGradient(
                    startAngle: _controller.value * 2 * math.pi,
                    colors: AppColors.storyGradient,
                    stops: const [0.0, 0.33, 0.66, 1.0],
                  )
                : null,
            color: widget.hasUnviewedStories ? null : Colors.grey.shade300,
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: widget.avatarUrl != null
                  ? NetworkImage(widget.avatarUrl!)
                  : null,
              child: widget.avatarUrl == null
                  ? Icon(Icons.person, color: Colors.grey.shade400, size: 28)
                  : null,
            ),
          ),
        );
      },
    );
  }
}

