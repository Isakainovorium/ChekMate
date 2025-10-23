# Stories - Flutter Conversion

To convert the provided React/TypeScript component to a Flutter/Dart widget, I'll ensure that the functionality and design are preserved while adhering to the conversion requirements.

### Dart Code for the Stories Widget

```dart
import 'package:flutter/material.dart';
import 'package:your_app_name/core/theme/app_colors.dart';
import 'package:your_app_name/widgets/image_with_fallback.dart';
import 'package:your_app_name/widgets/story_viewer.dart';

class Stories extends StatefulWidget {
  final VoidCallback? onStoryOpen;
  final VoidCallback? onStoryClose;

  const Stories({
    Key? key,
    this.onStoryOpen,
    this.onStoryClose,
  }) : super(key: key);

  @override
  _StoriesState createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {
  bool showStoryViewer = false;
  String selectedStoryUserId = '';

  final List<Map<String, dynamic>> storyUsers = [
    {
      'id': '1',
      'username': 'Your story',
      'avatar': 'https://images.unsplash.com/photo-1618590067690-2db34a87750a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcG9ydHJhaXQlMjBzZWxmaWV8ZW58MXx8fHwxNzU5NzU0Mjc1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      'isFollowing': true,
      'stories': [
        {
          'id': 's1-1',
          'type': 'image',
          'url': 'https://images.unsplash.com/photo-1516975080664-ed2fc6a32937?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb3VwbGUlMjBoYXBweSUyMHBvcnRyYWl0fGVufDF8fHx8MTc1OTc1Nzk5N3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
          'duration': 5,
          'text': 'Perfect date night! 💕',
          'textColor': 'white',
          'textPosition': 'bottom',
          'timestamp': '2h ago'
        }
      ]
    },
    // Add other users similarly
  ];

  final List<String> currentUserFollowing = ['2', '3', '4', '5', '6'];

  void handleStoryClick(String storyId) {
    final userIndex = storyUsers.indexWhere((user) => user['id'] == storyId);
    if (userIndex != -1) {
      setState(() {
        selectedStoryUserId = storyId;
        widget.onStoryOpen?.call();
        Future.delayed(const Duration(milliseconds: 50), () {
          setState(() {
            showStoryViewer = true;
          });
        });
      });
    }
  }

  void handleCloseViewer() {
    setState(() {
      showStoryViewer = false;
      selectedStoryUserId = '';
      widget.onStoryClose?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showStoryViewer)
          StoryViewer(
            isOpen: showStoryViewer,
            onClose: handleCloseViewer,
            stories: storyUsers,
            currentUserId: selectedStoryUserId,
            currentUserFollowing: currentUserFollowing,
          ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: storyUsers.map((story) {
                final hasStory = story['stories'].isNotEmpty;
                final isViewed = false; // Implement logic to track viewed stories
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => handleStoryClick(story['id']),
                        child: Container(
                          width: 64.0,
                          height: 64.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: hasStory && !isViewed
                                ? LinearGradient(
                                    colors: [AppColors.golden, AppColors.navyBlue],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    colors: [Colors.grey.shade300, Colors.grey.shade400],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                          ),
                          padding: const EdgeInsets.all(2.0),
                          child: ImageWithFallback(
                            src: story['avatar'],
                            alt: story['username'],
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      SizedBox(
                        width: 64.0,
                        child: Text(
                          story['id'] == '1' ? 'Your story' : story['username'],
                          style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
```

### File Path
- Save this file as `lib/features/stories/stories.dart`.

### Dependencies
- Ensure you have the following dependencies in your `pubspec.yaml`:
  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    # Add any other dependencies you need, such as for image handling or modals
  ```

### Usage Example
To use the `Stories` widget, you can include it in your widget tree like this:

```dart
Stories(
  onStoryOpen: () {
    // Handle story open
  },
  onStoryClose: () {
    // Handle story close
  },
)
```

### Additional Files Needed
- `image_with_fallback.dart`: A widget to handle image loading with a fallback.
- `story_viewer.dart`: A widget for displaying the story viewer.

### Notes
- Ensure that the `ImageWithFallback` and `StoryViewer` widgets are implemented to match the functionality of their React counterparts.
- Adjust the styling and layout as needed to fit your app's design and theming.