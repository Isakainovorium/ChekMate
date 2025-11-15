import 'package:flutter/material.dart';

/// Stories Widget
/// Displays a horizontal list of stories
class StoriesWidget extends StatelessWidget {
  const StoriesWidget({
    super.key,
    this.stories = const [],
    this.onStoryTap,
  });

  final List<StoryItem> stories;
  final ValueChanged<StoryItem>? onStoryTap;

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
          final story = stories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onStoryTap?.call(story),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: story.hasViewed
                            ? [Colors.grey, Colors.grey]
                            : [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                      ),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      backgroundImage: story.avatarUrl != null
                          ? NetworkImage(story.avatarUrl!)
                          : null,
                      child: story.avatarUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 64,
                    child: Text(
                      story.username,
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

/// Story Item
class StoryItem {
  const StoryItem({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.hasViewed = false,
  });

  final String id;
  final String username;
  final String? avatarUrl;
  final bool hasViewed;
}

