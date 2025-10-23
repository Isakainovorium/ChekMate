import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/stories/models/story_model.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// Horizontal scrolling stories row - converted from Stories.tsx
///
/// Features:
/// - Story circles with gradient borders
/// - "Your story" vs other users
/// - Viewed/unviewed states
/// - Story viewer modal
/// - Following filter
class StoriesWidget extends StatelessWidget {
  const StoriesWidget({
    required this.stories,
    super.key,
    this.onStoryTap,
  });
  final List<StoryUser> stories;
  final void Function(String userId)? onStoryTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: SizedBox(
        height: 90,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: stories.length,
          itemBuilder: (context, index) {
            final story = stories[index];
            return AnimatedStoryCircle(
              index: index,
              child: _StoryCircle(
                story: story,
                onTap: () => onStoryTap?.call(story.id),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StoryCircle extends StatelessWidget {
  const _StoryCircle({
    required this.story,
    this.onTap,
  });
  final StoryUser story;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            // Story circle with gradient border
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _getGradient(),
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(2),
                child: AppAvatar(
                  imageUrl: story.avatar,
                  name: story.username,
                  size: AppAvatarSize.large,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            // Username
            SizedBox(
              width: 64,
              child: Text(
                story.isOwn ? 'Your story' : story.username,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Gradient _getGradient() {
    if (!story.hasStory) {
      return LinearGradient(
        colors: [Colors.grey.shade300, Colors.grey.shade300],
      );
    }

    if (story.isViewed) {
      return LinearGradient(
        colors: [Colors.grey.shade400, Colors.grey.shade500],
      );
    }

    // Unviewed story - golden gradient
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.primary, // Golden
        AppColors.secondary, // Darker gold
      ],
    );
  }
}
