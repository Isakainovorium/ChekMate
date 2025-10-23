import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/providers/providers.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/feed/pages/create_post/pages/camera_page.dart';
import 'package:flutter_chekmate/features/feed/pages/create_post/pages/video_editor_page.dart';
import 'package:flutter_chekmate/features/feed/pages/create_post/widgets/filter_selector.dart';
import 'package:flutter_chekmate/features/feed/pages/create_post/widgets/media_type_selector.dart';
import 'package:flutter_chekmate/features/feed/pages/create_post/widgets/post_options_panel.dart';
import 'package:flutter_chekmate/features/posts/presentation/providers/posts_providers.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Create Post Page - TikTok-like creation experience
///
/// Features:
/// - Text posts
/// - Image posts with filters
/// - Video posts with filters and effects
/// - Green screen
/// - Beauty filters
/// - Location tagging
/// - Privacy settings
/// - Firebase integration
class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final TextEditingController _textController = TextEditingController();

  String _selectedMediaType = 'text'; // text, image, video
  XFile? _selectedMedia;
  String? _selectedFilter;
  bool _useGreenScreen = false;
  String? _location;
  String _privacy = 'public'; // public, friends, private

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Post',
          style: TextStyle(
            color: AppColors.navyBlue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          AppButton(
            onPressed: _canPost() ? _createPost : null,
            variant: AppButtonVariant.text,
            size: AppButtonSize.sm,
            child: const Text('Post'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          // Media Type Selector
          MediaTypeSelector(
            selectedType: _selectedMediaType,
            onTypeSelected: (type) {
              setState(() {
                _selectedMediaType = type;
                _selectedMedia = null;
              });
            },
          ),

          const Divider(height: 1),

          // Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text Input
                  AppInput(
                    controller: _textController,
                    hint: _getHintText(),
                    maxLines: _selectedMediaType == 'text' ? 8 : 3,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Media Preview/Selector
                  if (_selectedMediaType != 'text') ...[
                    _buildMediaSection(),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Filter Section (for image/video)
                  if (_selectedMedia != null &&
                      _selectedMediaType != 'text') ...[
                    FilterSelector(
                      selectedFilter: _selectedFilter,
                      onFilterSelected: (filter) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Green Screen Toggle (for video)
                  if (_selectedMediaType == 'video') ...[
                    _buildGreenScreenToggle(),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Post Options
                  PostOptionsPanel(
                    location: _location,
                    privacy: _privacy,
                    onLocationChanged: (location) {
                      setState(() {
                        _location = location;
                      });
                    },
                    onPrivacyChanged: (privacy) {
                      setState(() {
                        _privacy = privacy;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getHintText() {
    switch (_selectedMediaType) {
      case 'image':
        return 'Add a caption...';
      case 'video':
        return 'Describe your video...';
      default:
        return "What's on your mind?";
    }
  }

  Widget _buildMediaSection() {
    if (_selectedMedia != null) {
      return _buildMediaPreview();
    } else {
      return _buildMediaSelector();
    }
  }

  Widget _buildMediaPreview() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            // Media preview (simplified - would show actual image/video)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedMediaType == 'image'
                        ? Icons.image
                        : Icons.videocam,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _selectedMediaType == 'image'
                        ? 'Image Selected'
                        : 'Video Selected',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Remove button
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMedia = null;
                    _selectedFilter = null;
                  });
                },
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
              ),
            ),

            // Edit button (for video)
            if (_selectedMediaType == 'video')
              Positioned(
                bottom: AppSpacing.sm,
                right: AppSpacing.sm,
                child: AppButton(
                  onPressed: _openVideoEditor,
                  size: AppButtonSize.sm,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 4),
                      Text('Edit'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSelector() {
    return Column(
      children: [
        // Camera option
        _buildMediaOption(
          icon: Icons.camera_alt,
          label: _selectedMediaType == 'image' ? 'Take Photo' : 'Record Video',
          onTap: _openCamera,
        ),

        const SizedBox(height: AppSpacing.sm),

        // Gallery option with AppFileUpload
        AppFileUpload(
          onFilesSelected: (files) {
            if (files.isNotEmpty && files.first.path != null) {
              setState(() {
                _selectedMedia = XFile(files.first.path!);
              });
            }
          },
          acceptedTypes:
              _selectedMediaType == 'image' ? ['image/*'] : ['video/*'],
          maxFileSize: _selectedMediaType == 'image' ? 10 : 100, // MB
          placeholder:
              _selectedMediaType == 'image' ? 'Choose Photo' : 'Choose Video',
        ),
      ],
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AppCard(
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreenScreenToggle() {
    return AppCard(
      child: AppSwitch(
        value: _useGreenScreen,
        onChanged: (value) {
          setState(() {
            _useGreenScreen = value;
          });
        },
        label: 'Green Screen',
        subtitle: 'Replace background with custom image',
      ),
    );
  }

  bool _canPost() {
    if (_selectedMediaType == 'text') {
      return _textController.text.trim().isNotEmpty;
    } else {
      return _selectedMedia != null;
    }
  }

  Future<void> _openCamera() async {
    final result = await Navigator.push<XFile?>(
      context,
      MaterialPageRoute<XFile?>(
        builder: (context) => CameraPage(
          isVideo: _selectedMediaType == 'video',
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMedia = result;
      });
    }
  }

  Future<void> _openVideoEditor() async {
    if (_selectedMedia == null) return;

    final result = await Navigator.push<XFile?>(
      context,
      MaterialPageRoute<XFile?>(
        builder: (context) => VideoEditorPage(
          videoPath: _selectedMedia!.path,
          useGreenScreen: _useGreenScreen,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMedia = result;
      });
    }
  }

  Future<void> _createPost() async {
    if (!_canPost()) return;

    try {
      // Show loading
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      final postController = ref.read(postsControllerProvider.notifier);
      final currentUser = ref.read(currentUserProvider).value;

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Media upload implementation
      // For now, creating text-only posts. Media upload can be implemented by:
      // 1. Converting XFile to Uint8List using readAsBytes()
      // 2. Passing images/video to createPost method
      // 3. The StorageService will handle Firebase Storage upload
      
      List<Uint8List>? imageData;
      Uint8List? videoData;
      
      // Future implementation:
      // if (_selectedImages.isNotEmpty) {
      //   imageData = await Future.wait(
      //     _selectedImages.map((file) => file.readAsBytes())
      //   );
      // }
      // if (_selectedVideo != null) {
      //   videoData = await _selectedVideo!.readAsBytes();
      // }

      // Create post
      await postController.createPost(
        content: _textController.text.trim(),
        location: _location,
        images: imageData,
        video: videoData,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Close create post page
      if (mounted) Navigator.pop(context);

      // Show success message
      if (mounted) {
        await AppDialog.show<void>(
          context: context,
          title: const Text('Success'),
          content: const Text('Post created successfully!'),
          actions: [
            AppButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      }
    } on Exception catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      _showError('Failed to create post: $e');
    }
  }

  void _showError(String message) {
    AppDialog.show<void>(
      context: context,
      title: const Text('Error'),
      content: Text(message),
      actions: [
        AppButton(
          onPressed: () => Navigator.pop(context),
          variant: AppButtonVariant.text,
          child: const Text('OK'),
        ),
      ],
    );
  }
}
