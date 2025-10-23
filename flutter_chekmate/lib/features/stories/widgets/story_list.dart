import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// Story List Widget - Horizontal scrolling stories
/// Fixed: User icons overflow issue (P2)
class StoryList extends StatelessWidget {
  const StoryList({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for stories
    final stories = [
      {
        'name': 'Your Story',
        'avatar': 'https://i.pravatar.cc/100?img=1',
        'hasStory': false,
      },
      {
        'name': 'Sarah',
        'avatar': 'https://i.pravatar.cc/100?img=2',
        'hasStory': true,
      },
      {
        'name': 'Mike',
        'avatar': 'https://i.pravatar.cc/100?img=3',
        'hasStory': true,
      },
      {
        'name': 'Jessica',
        'avatar': 'https://i.pravatar.cc/100?img=4',
        'hasStory': true,
      },
      {
        'name': 'David',
        'avatar': 'https://i.pravatar.cc/100?img=5',
        'hasStory': true,
      },
      {
        'name': 'Emma',
        'avatar': 'https://i.pravatar.cc/100?img=6',
        'hasStory': true,
      },
      {
        'name': 'James',
        'avatar': 'https://i.pravatar.cc/100?img=7',
        'hasStory': true,
      },
      {
        'name': 'Olivia',
        'avatar': 'https://i.pravatar.cc/100?img=8',
        'hasStory': true,
      },
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        return _StoryItem(
          name: story['name'] as String,
          avatar: story['avatar'] as String,
          hasStory: story['hasStory'] as bool,
          isFirst: index == 0,
        );
      },
    );
  }
}

class _StoryItem extends StatelessWidget {
  const _StoryItem({
    required this.name,
    required this.avatar,
    required this.hasStory,
    required this.isFirst,
  });
  final String name;
  final String avatar;
  final bool hasStory;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md), // Increased spacing
      child: GestureDetector(
        onTap: () {
          // Open story viewer
        },
        child: SizedBox(
          width: 76, // Slightly wider for better spacing
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Story circle with gradient border
              Container(
                width: 64, // Fixed size
                height: 64, // Fixed size
                constraints: const BoxConstraints(
                  maxWidth: 64, // Prevent overflow
                  maxHeight: 64,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasStory
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.secondary,
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            Colors.grey.shade300,
                            Colors.grey.shade300,
                          ],
                        ),
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: AppAvatar(
                    imageUrl: avatar,
                    name: name,
                    size: AppAvatarSize.large,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Username - constrained to prevent overflow
              SizedBox(
                width: 76,
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
