import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/entities/location_entity.dart';
import '../../core/providers/providers.dart';
import '../../core/services/file_picker_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/content_generation_service.dart';
import '../../features/posts/presentation/providers/posts_providers.dart';
import '../../features/templates/models/story_template_model.dart';
import '../../features/templates/presentation/providers/template_providers.dart';
import '../../features/templates/presentation/widgets/template_selector_sheet.dart';
import '../../features/templates/presentation/widgets/template_guided_form.dart';

/// Create Post Page - Full screen post creation interface
///
/// Allows users to create new posts with text, images, and videos.
class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final TextEditingController _textController = TextEditingController();
  final List<File> _selectedImages = [];
  File? _selectedVideo;
  LocationEntity? _selectedLocation;
  final List<String> _selectedTags = [];
  bool _isCreatingPost = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Pick images from gallery
  Future<void> _pickImages() async {
    try {
      final images = await FilePickerService.pickImages(
          maxFiles: 9); // Allow up to 9 images
      if (images.isNotEmpty) {
        setState(() {
          // Add new images, but limit total to 9
          final availableSlots = 9 - _selectedImages.length;
          final imagesToAdd = images.take(availableSlots);
          _selectedImages.addAll(imagesToAdd);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Pick video from gallery
  Future<void> _pickVideo() async {
    try {
      final video = await FilePickerService.pickVideo();
      if (video != null) {
        setState(() {
          _selectedVideo = video;
          // Clear images if video is selected (can only have one or the other)
          _selectedImages.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Pick current location
  Future<void> _pickLocation() async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Getting your location...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Get current location
      final location = await LocationService.getCurrentLocation();

      // Try to get address for the location
      LocationEntity locationWithAddress;
      try {
        locationWithAddress = await LocationService.getAddressFromCoordinates(
          latitude: location.latitude,
          longitude: location.longitude,
        );
      } catch (e) {
        // If address lookup fails, use location without address
        locationWithAddress = location;
      }

      if (mounted) {
        setState(() {
          _selectedLocation = locationWithAddress;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Location set to: ${locationWithAddress.displayName}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on LocationServiceException catch (e) {
      if (mounted) {
        // Show appropriate error message based on the error
        String message = 'Failed to get location';
        String actionText = 'Retry';
        VoidCallback? action;

        switch (e.code) {
          case 'SERVICE_DISABLED':
            message = 'Location services are disabled. Please enable them.';
            actionText = 'Settings';
            action = () => LocationService.openLocationSettings();
            break;
          case 'PERMISSION_DENIED':
            message =
                'Location permission is required to add location to posts.';
            actionText = 'Grant Permission';
            action = () async {
              try {
                await LocationService.requestPermission();
                // Try again after permission is granted
                await _pickLocation();
              } catch (_) {}
            };
            break;
          case 'PERMISSION_DENIED_FOREVER':
            message =
                'Location permission is permanently denied. Please enable it in settings.';
            actionText = 'Settings';
            action = () => LocationService.openAppSettings();
            break;
          default:
            message = e.message;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: actionText,
              onPressed: action ?? () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Pick tags for the post
  Future<void> _pickTags() async {
    final TextEditingController tagController = TextEditingController();

    if (mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Tags'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tagController,
                decoration: const InputDecoration(
                  hintText: 'Enter a tag (without #)',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _addTag(value.trim());
                    tagController.clear();
                  }
                },
              ),
              const SizedBox(height: 16),
              // Display current tags
              if (_selectedTags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _selectedTags.map((tag) {
                    return Chip(
                      label: Text('#$tag'),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _removeTag(tag),
                    );
                  }).toList(),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
            TextButton(
              onPressed: () {
                if (tagController.text.trim().isNotEmpty) {
                  _addTag(tagController.text.trim());
                  tagController.clear();
                }
              },
              child: const Text('Add Tag'),
            ),
          ],
        ),
      );
    }
  }

  /// Add a tag to the selected tags list
  void _addTag(String tag) {
    final cleanTag = tag.toLowerCase().replaceAll('#', '');
    if (cleanTag.isNotEmpty && !_selectedTags.contains(cleanTag)) {
      setState(() {
        _selectedTags.add(cleanTag);
      });
    }
  }

  /// Remove a tag from the selected tags list
  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

  /// Open template selector sheet
  Future<void> _openTemplateSelector() async {
    if (!mounted) return;

    final template = await showModalBottomSheet<StoryTemplate?>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const TemplateSelectorSheet(),
    );

    if (template == null) return;

    try {
      // Show the template guided form to get user responses
      final responses =
          await Navigator.of(context).push<List<TemplateResponse>?>(
        MaterialPageRoute(
          builder: (context) => TemplateGuidedForm(
            template: template,
            onComplete: (responses) => Navigator.of(context).pop(responses),
            onCancel: () => Navigator.of(context).pop(),
          ),
        ),
      );

      if (responses == null || !mounted) return;

      // Generate content from the template and responses
      final generatedContent =
          await ContentGenerationService.instance.generatePostContent(
        template: template,
        responses: responses,
        includeMetadata: true,
      );

      final generatedTags = await ContentGenerationService.instance
          .generateTags(template: template, responses: responses);

      setState(() {
        _textController.text = generatedContent;
        for (final tag in generatedTags) {
          if (!_selectedTags.contains(tag)) {
            _selectedTags.add(tag);
          }
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Story created! Review and post when ready.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating content: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Create a new post
  Future<void> _createPost() async {
    if (_isCreatingPost) return;

    setState(() {
      _isCreatingPost = true;
    });

    try {
      // Get current user information
      final currentUserAsync = ref.watch(currentUserProvider);
      final currentUser = currentUserAsync.when(
        data: (user) => user,
        loading: () => null,
        error: (_, __) => null,
      );

      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You must be logged in to create a post'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Get post creation notifier
      final postsNotifier = ref.read(postsNotifierProvider.notifier);

      // Prepare post data
      final content = _textController.text.trim();

      // Convert selected media files to Uint8List for upload
      List<Uint8List>? imageData;
      Uint8List? videoData;

      if (_selectedImages.isNotEmpty) {
        try {
          imageData = [];
          for (final imageFile in _selectedImages) {
            final bytes = await imageFile.readAsBytes();
            imageData.add(bytes);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to process selected images'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          imageData = null;
        }
      } else if (_selectedVideo != null) {
        try {
          videoData = await _selectedVideo!.readAsBytes();
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to process selected video'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          videoData = null;
        }
      }

      // Create the post
      await postsNotifier.createPost(
        userId: currentUser.uid,
        username: currentUser.username,
        userAvatar: currentUser.avatar,
        content: content,
        images: imageData,
        video: videoData,
        location: _selectedLocation?.formattedLocation,
        tags: _selectedTags, // Use selected tags
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        context.pop();
      }
    } catch (e) {
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
          _isCreatingPost = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: (_textController.text.trim().isNotEmpty ||
                        _selectedImages.isNotEmpty ||
                        _selectedVideo != null) &&
                    !_isCreatingPost
                ? _createPost
                : null,
            child: _isCreatingPost
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Post',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Public',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Text input
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: InputBorder.none,
              ),
              maxLines: null,
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            // Media display (images or video)
            if (_selectedImages.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(_selectedImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close,
                                size: 16, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
            else if (_selectedVideo != null)
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black12,
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.video_file,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Video Selected',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            size: 16, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _selectedVideo = null;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            // Location display
            if (_selectedLocation != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedLocation!.displayName,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.close, size: 16, color: Colors.blue),
                      onPressed: () {
                        setState(() {
                          _selectedLocation = null;
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            if (_selectedLocation != null) const SizedBox(height: 16),
            // Tags display
            if (_selectedTags.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.tag,
                          color: Colors.green,
                          size: 20.0,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Tags',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _selectedTags.map((tag) {
                        return Chip(
                          label: Text(
                            '#$tag',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: Colors.green.withValues(alpha: 0.1),
                          deleteIcon: const Icon(Icons.close,
                              size: 14, color: Colors.green),
                          onDeleted: () => _removeTag(tag),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            if (_selectedTags.isNotEmpty) const SizedBox(height: 16),
            // Action buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    icon: Icons.description,
                    label: 'Template',
                    onPressed: _openTemplateSelector,
                  ),
                  _buildActionButton(
                    icon: Icons.photo_library,
                    label: 'Photo',
                    onPressed: _pickImages,
                  ),
                  _buildActionButton(
                    icon: Icons.videocam,
                    label: 'Video',
                    onPressed: _pickVideo,
                  ),
                  _buildActionButton(
                    icon: Icons.location_on,
                    label: 'Location',
                    onPressed: _pickLocation,
                  ),
                  _buildActionButton(
                    icon: Icons.tag,
                    label: 'Tag',
                    onPressed: _pickTags,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, color: Colors.grey[700]),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
