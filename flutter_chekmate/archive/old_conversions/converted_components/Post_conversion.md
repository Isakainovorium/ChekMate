# Post - Flutter Conversion

To convert the provided React/TypeScript component to a Flutter/Dart widget, I'll follow the conversion requirements and ensure the functionality and design are preserved. Here's the complete Dart code for the `Post` widget:

### Dart Code for the Post Widget

```dart
import 'package:flutter/material.dart';
import 'package:your_app_name/core/theme/app_colors.dart';
import 'package:your_app_name/widgets/image_with_fallback.dart';
import 'package:your_app_name/widgets/post_detail_modal.dart';
import 'package:your_app_name/widgets/share_modal.dart';

class Post extends StatefulWidget {
  final String id;
  final String username;
  final String avatar;
  final String content;
  final String? image;
  final int likes;
  final int comments;
  final int shares;
  final String timestamp;
  final String? caption;
  final VoidCallback? onShareModalOpen;
  final VoidCallback? onShareModalClose;

  const Post({
    Key? key,
    required this.id,
    required this.username,
    required this.avatar,
    required this.content,
    this.image,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.timestamp,
    this.caption,
    this.onShareModalOpen,
    this.onShareModalClose,
  }) : super(key: key);

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  bool isLiked = false;
  late int likeCount;
  bool showModal = false;
  bool showShareModal = false;

  @override
  void initState() {
    super.initState();
    likeCount = widget.likes;
  }

  void handleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount = isLiked ? likeCount + 1 : likeCount - 1;
    });
  }

  String formatNumber(int num) {
    if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}k';
    }
    return num.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PostDetailModal(
          isOpen: showModal,
          onClose: () => setState(() => showModal = false),
          post: {
            'id': widget.id,
            'username': widget.username,
            'avatar': widget.avatar,
            'content': widget.content,
            'image': widget.image,
            'caption': widget.caption,
          },
        ),
        ShareModal(
          isOpen: showShareModal,
          onClose: () {
            setState(() => showShareModal = false);
            widget.onShareModalClose?.call();
          },
          post: {
            'id': widget.id,
            'username': widget.username,
            'avatar': widget.avatar,
            'content': widget.content,
            'image': widget.image,
            'caption': widget.caption,
          },
        ),
        Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ImageWithFallback(
                          src: widget.avatar,
                          alt: widget.username,
                          width: 40.0,
                          height: 40.0,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        const SizedBox(width: 8.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.username,
                              style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              widget.timestamp,
                              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.grey),
                      onPressed: () => setState(() => showModal = true),
                    ),
                  ],
                ),
              ),
              // Post Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  widget.content,
                  style: const TextStyle(fontSize: 14.0),
                ),
              ),
              // Post Image
              if (widget.image != null)
                Stack(
                  children: [
                    ImageWithFallback(
                      src: widget.image!,
                      alt: 'Post content',
                      width: double.infinity,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                    if (widget.caption != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          child: Text(
                            widget.caption!,
                            style: const TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                  ],
                ),
              // Post Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: isLiked ? Colors.red : Colors.grey,
                          ),
                          onPressed: handleLike,
                        ),
                        Text(formatNumber(likeCount)),
                        const SizedBox(width: 16.0),
                        IconButton(
                          icon: const Icon(Icons.comment, color: Colors.grey),
                          onPressed: () {},
                        ),
                        Text(formatNumber(widget.comments)),
                        const SizedBox(width: 16.0),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.grey),
                          onPressed: () {
                            setState(() => showShareModal = true);
                            widget.onShareModalOpen?.call();
                          },
                        ),
                        Text(formatNumber(widget.shares)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.bookmark, color: Colors.grey),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              // Liked by text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Simone Gabrielle and ${formatNumber(likeCount - 1)} others liked this post',
                  style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
              ),
              // Caption preview
              if (widget.caption != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Text(
                    '${widget.username} ${widget.caption!.toLowerCase()}',
                    style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
```

### File Path
- Save this file as `lib/features/post/post.dart`.

### Dependencies
- Ensure you have the following dependencies in your `pubspec.yaml`:
  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    # Add any other dependencies you need, such as for image handling or modals
  ```

### Usage Example
To use the `Post` widget, you can include it in your widget tree like this:

```dart
Post(
  id: '1',
  username: 'johndoe',
  avatar: 'https://example.com/avatar.jpg',
  content: 'This is a sample post content.',
  image: 'https://example.com/image.jpg',
  likes: 120,
  comments: 34,
  shares: 12,
  timestamp: '2 hours ago',
  caption: 'Check out this amazing view!',
  onShareModalOpen: () {
    // Handle share modal open
  },
  onShareModalClose: () {
    // Handle share modal close
  },
)
```

### Additional Files Needed
- `image_with_fallback.dart`: A widget to handle image loading with a fallback.
- `post_detail_modal.dart`: A widget for displaying post details in a modal.
- `share_modal.dart`: A widget for displaying the share modal.

### Notes
- Ensure that the `ImageWithFallback`, `PostDetailModal`, and `ShareModal` widgets are implemented to match the functionality of their React counterparts.
- Adjust the styling and layout as needed to fit your app's design and theming.