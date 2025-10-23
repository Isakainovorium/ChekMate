import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/domain/entities/location_entity.dart';
import 'package:flutter_chekmate/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_chekmate/features/posts/presentation/providers/posts_providers.dart';
import 'package:flutter_chekmate/shared/ui/location/location_picker_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Create Post page - Full-screen post creation experience
/// Converted from PostCreationModal.tsx
///
/// Features:
/// - Text input for post content
/// - Image/video upload
/// - Privacy settings
/// - Location tagging
/// - Full-screen experience (no bottom navigation)
class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedImagePath;
  String _privacy = 'public';
  LocationEntity? _location;
  String? _feeling;
  bool _isPosting = false;

  // Predefined feelings/activities
  static const List<Map<String, dynamic>> _feelings = [
    {'id': 'happy', 'label': '😊 Happy', 'emoji': '😊'},
    {'id': 'excited', 'label': '🎉 Excited', 'emoji': '🎉'},
    {'id': 'blessed', 'label': '🙏 Blessed', 'emoji': '🙏'},
    {'id': 'loved', 'label': '❤️ Loved', 'emoji': '❤️'},
    {'id': 'grateful', 'label': '🙌 Grateful', 'emoji': '🙌'},
    {'id': 'motivated', 'label': '💪 Motivated', 'emoji': '💪'},
    {'id': 'relaxed', 'label': '😌 Relaxed', 'emoji': '😌'},
    {'id': 'thoughtful', 'label': '🤔 Thoughtful', 'emoji': '🤔'},
    {'id': 'celebrating', 'label': '🥳 Celebrating', 'emoji': '🥳'},
    {'id': 'adventurous', 'label': '🌍 Adventurous', 'emoji': '🌍'},
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => _handleCancel(),
        ),
        title: const Text(
          'Create Post',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _handlePost,
            child: _isPosting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Post',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info
              _buildUserInfo(theme),
              const SizedBox(height: 16),

              // Content input
              TextField(
                controller: _contentController,
                maxLines: null,
                minLines: 5,
                decoration: const InputDecoration(
                  hintText: 'What\'s on your mind?',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),

              // Image preview
              if (_selectedImagePath != null) _buildImagePreview(),

              const SizedBox(height: 24),

              // Options
              _buildOptions(theme),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildUserInfo(ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: theme.colorScheme.primary,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            _buildPrivacySelector(theme),
          ],
        ),
      ],
    );
  }

  Widget _buildPrivacySelector(ThemeData theme) {
    return GestureDetector(
      onTap: _showPrivacyOptions,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _privacy == 'public' ? Icons.public : Icons.lock,
              size: 14,
              color: Colors.grey.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              _privacy == 'public' ? 'Public' : 'Private',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade200,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _selectedImagePath!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
            ),
            onPressed: () {
              setState(() {
                _selectedImagePath = null;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add to your post',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        _buildOptionButton(
          icon: Icons.photo_library,
          label: 'Photo/Video',
          color: Colors.green,
          onTap: _handleImagePick,
        ),
        _buildOptionButton(
          icon: Icons.location_on,
          label: _location?.displayName ?? 'Add Location',
          color: Colors.red,
          onTap: _handleLocationPick,
        ),
        _buildOptionButton(
          icon: Icons.emoji_emotions,
          label: _feeling ?? 'Feeling/Activity',
          color: Colors.orange,
          onTap: _showFeelingPicker,
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Your post will be visible to your selected audience',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCancel() {
    if (_contentController.text.isNotEmpty || _selectedImagePath != null) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard post?'),
          content: const Text('Are you sure you want to discard this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              child: const Text('Discard'),
            ),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }

  Future<void> _handlePost() async {
    if (_contentController.text.isEmpty && _selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some content or an image'),
        ),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      // Get current user from auth provider
      final user = ref.read(authStateProvider).value;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Convert image to bytes if selected
      Uint8List? imageBytes;
      if (_selectedImagePath != null) {
        final file = File(_selectedImagePath!);
        final bytes = await file.readAsBytes();
        imageBytes = Uint8List.fromList(bytes);
      }

      // Build post content with feeling if selected
      var content = _contentController.text.trim();
      if (_feeling != null) {
        content = '$content\n\nFeeling: $_feeling';
      }

      // Get current user's coordinates for location-based discovery
      GeoPoint? coordinates;
      if (user.locationEnabled && user.coordinates != null) {
        coordinates = user.coordinates;
      }

      // Get posts controller
      final postsController = ref.read(postsControllerProvider.notifier);

      // Create post
      await postsController.createPost(
        content: content,
        images: imageBytes != null ? [imageBytes] : null,
        location: _location?.displayName,
        coordinates: coordinates,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  Future<void> _handleImagePick() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
    }
  }

  Future<void> _handleLocationPick() async {
    final result = await showDialog<LocationEntity>(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          child: LocationPickerWidget(
            selectedLocation: _location,
            onLocationSelected: (location) {
              Navigator.pop(context, location);
            },
            onLocationRemoved: () {
              Navigator.pop(context);
              setState(() => _location = null);
            },
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() => _location = result);
    }
  }

  void _showFeelingPicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'How are you feeling?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _feelings.length,
                itemBuilder: (context, index) {
                  final feeling = _feelings[index];
                  final isSelected = _feeling == feeling['label'];
                  return ListTile(
                    leading: Text(
                      feeling['emoji'] as String,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      feeling['label'] as String,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected ? Theme.of(context).primaryColor : null,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                    onTap: () {
                      setState(() => _feeling = feeling['label'] as String);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPrivacyOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Public'),
              subtitle: const Text('Anyone can see this post'),
              onTap: () {
                setState(() {
                  _privacy = 'public';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Private'),
              subtitle: const Text('Only you can see this post'),
              onTap: () {
                setState(() {
                  _privacy = 'private';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
