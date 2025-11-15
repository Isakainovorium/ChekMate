import 'package:flutter/material.dart';
import 'package:flutter_chekmate/features/stories/models/story_model.dart';

/// Stories Widget
/// Displays a horizontal list of user stories
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
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: storyUser.hasUnviewedStories
                            ? [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ]
                            : [Colors.grey, Colors.grey],
                      ),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      backgroundImage: storyUser.avatar != null
                          ? NetworkImage(storyUser.avatar!)
                          : null,
                      child: storyUser.avatar == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 64,
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

