import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/navigation/nav_state.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/features/navigation/widgets/bottom_nav_widget.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Main navigation scaffold with shared BottomNavWidget
class MainNavigation extends ConsumerWidget {
  const MainNavigation({
    required this.child,
    required this.currentIndex,
    super.key,
    this.hideNavigation = false,
  });
  final Widget child;
  final int currentIndex;
  final bool hideNavigation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(navStateProvider);
    final shouldHideNav =
        hideNavigation || nav.isInConversation || nav.isViewingStories;
    return Scaffold(
      body: child,
      bottomNavigationBar: shouldHideNav
          ? null
          : BottomNavWidget(
              currentIndex: currentIndex,
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go('/');
                    break;
                  case 1:
                    context.go('/messages');
                    break;
                  case 2:
                    _showCreateModal(context);
                    break;
                  case 3:
                    context.go('/notifications');
                    break;
                  case 4:
                    context.go('/profile');
                    break;
                }
              },
            ),
    );
  }

  void _showCreateModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Create Post',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const Divider(),
            // Post creation form
            const Expanded(
              child: PostCreationForm(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Post Creation Form Widget
class PostCreationForm extends StatefulWidget {
  const PostCreationForm({super.key});

  @override
  State<PostCreationForm> createState() => _PostCreationFormState();
}

class _PostCreationFormState extends State<PostCreationForm> {
  final TextEditingController _textController = TextEditingController();
  bool _isPosting = false;
  String _selectedPostType = 'text';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post type selector
          Row(
            children: [
              _buildPostTypeButton('text', 'Text', Icons.text_fields),
              const SizedBox(width: 8),
              _buildPostTypeButton('photo', 'Photo', Icons.photo_camera),
              const SizedBox(width: 8),
              _buildPostTypeButton('video', 'Video', Icons.videocam),
            ],
          ),

          const SizedBox(height: 16),

          // Text input
          Expanded(
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: _getHintText(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              // Media buttons
              IconButton(
                onPressed: () => _handleMediaAction('camera'),
                icon: const Icon(Icons.camera_alt),
                tooltip: 'Take Photo',
              ),
              IconButton(
                onPressed: () => _handleMediaAction('gallery'),
                icon: const Icon(Icons.photo_library),
                tooltip: 'Choose from Gallery',
              ),
              IconButton(
                onPressed: () => _handleMediaAction('location'),
                icon: const Icon(Icons.location_on),
                tooltip: 'Add Location',
              ),

              const Spacer(),

              // Post button
              ElevatedButton(
                onPressed: _isPosting ? null : _handlePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isPosting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Post'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostTypeButton(String type, String label, IconData icon) {
    final isSelected = _selectedPostType == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedPostType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHintText() {
    switch (_selectedPostType) {
      case 'photo':
        return "What's happening? Add a photo to share...";
      case 'video':
        return "What's happening? Share a video...";
      default:
        return "What's on your mind?";
    }
  }

  void _handleMediaAction(String action) {
    // Simulate media actions
    AppSnackBarNotification.show(
      context,
      message: '$action feature coming soon!',
    );
  }

  Future<void> _handlePost() async {
    if (_textController.text.trim().isEmpty) {
      AppSnackBarNotification.show(
        context,
        message: 'Please enter some content to post',
        type: AppNotificationBannerType.warning,
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      // Simulate posting
      await Future<void>.delayed(const Duration(seconds: 2));

      if (mounted) {
        _textController.clear();
        Navigator.of(context).pop(); // Close the modal

        AppSnackBarNotification.show(
          context,
          message: 'Post created successfully!',
          type: AppNotificationBannerType.success,
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        AppSnackBarNotification.show(
          context,
          message: 'Failed to create post: $e',
          type: AppNotificationBannerType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }
}
