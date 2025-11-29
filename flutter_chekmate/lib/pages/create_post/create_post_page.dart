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
import '../../core/theme/app_colors.dart';
import '../../features/posts/presentation/providers/posts_providers.dart';
import '../../features/rate_date/presentation/providers/rate_date_providers.dart';
import '../../features/stories/presentation/providers/stories_providers.dart';
import '../../features/templates/models/story_template_model.dart';
import '../../features/templates/presentation/widgets/template_selector_sheet.dart';
import '../../features/templates/presentation/widgets/template_guided_form.dart';

/// Post Type - Different types of content users can create
enum CreatePostType {
  post,     // Regular feed post
  story,    // 24-hour story
  rateDate, // Rate Your Date post
  goLive,   // Live streaming
}

/// Create Post Page - Unified content creation interface
///
/// Allows users to create:
/// - Regular posts (text, images, videos)
/// - Stories (24-hour ephemeral content)
/// - Rate Date posts (dating experience ratings)
/// - Go Live (start a live stream)
class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({
    super.key,
    this.initialPostType = CreatePostType.post,
  });

  final CreatePostType initialPostType;

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
  
  // Post type selection
  late CreatePostType _selectedPostType;
  
  // Rate Date specific fields
  final TextEditingController _partnerNameController = TextEditingController();
  final TextEditingController _partnerAgeController = TextEditingController();
  final TextEditingController _dateLocationController = TextEditingController();
  final TextEditingController _dateActivityController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  String? _selectedRating; // WOW, GTFOH, ChekMate

  @override
  void initState() {
    super.initState();
    _selectedPostType = widget.initialPostType;
  }

  @override
  void dispose() {
    _textController.dispose();
    _partnerNameController.dispose();
    _partnerAgeController.dispose();
    _dateLocationController.dispose();
    _dateActivityController.dispose();
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
        title: Text(_getAppBarTitle()),
        actions: [
          TextButton(
            onPressed: _canSubmit() && !_isCreatingPost
                ? _handleSubmit
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
                : Text(
                    _getSubmitButtonText(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Post Type Selector
          _buildPostTypeSelector(),
          // Content based on selected type
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: switch (_selectedPostType) {
                CreatePostType.post => _buildRegularPostForm(),
                CreatePostType.story => _buildStoryForm(),
                CreatePostType.rateDate => _buildRateDateForm(),
                CreatePostType.goLive => _buildGoLiveForm(),
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build regular post form
  Widget _buildRegularPostForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User info
        _buildUserHeader(),
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
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
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
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
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
                          backgroundColor: Colors.green.withOpacity(0.1),
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
        );
  }

  /// Build user header (shared across forms)
  Widget _buildUserHeader() {
    final currentUserAsync = ref.watch(currentUserProvider);
    return currentUserAsync.when(
      data: (user) => Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: user?.avatar.isNotEmpty == true
                ? NetworkImage(user!.avatar)
                : null,
            child: user?.avatar.isEmpty != false ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.displayName ?? 'Your Name',
                style: const TextStyle(
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
      loading: () => const Row(
        children: [
          CircleAvatar(radius: 20, child: Icon(Icons.person)),
          SizedBox(width: 12),
          Text('Loading...'),
        ],
      ),
      error: (_, __) => const Row(
        children: [
          CircleAvatar(radius: 20, child: Icon(Icons.person)),
          SizedBox(width: 12),
          Text('Your Name'),
        ],
      ),
    );
  }

  /// Build Rate Date form
  Widget _buildRateDateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserHeader(),
        const SizedBox(height: 24),
        
        // Partner Name
        TextField(
          controller: _partnerNameController,
          decoration: InputDecoration(
            labelText: 'Who did you go on a date with? *',
            hintText: 'Enter their name',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        
        // Partner Age (optional)
        TextField(
          controller: _partnerAgeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Their age (optional)',
            prefixIcon: const Icon(Icons.cake_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        
        // Date Location
        TextField(
          controller: _dateLocationController,
          decoration: InputDecoration(
            labelText: 'Where was the date? *',
            hintText: 'Restaurant, park, etc.',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        
        // Date Activity
        TextField(
          controller: _dateActivityController,
          decoration: InputDecoration(
            labelText: 'What did you do? *',
            hintText: 'Dinner, coffee, movie, etc.',
            prefixIcon: const Icon(Icons.restaurant_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        
        // Date picker
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDateTime,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _selectedDateTime = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'When was the date?',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    Text(
                      '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Rating Selection
        const Text(
          'How was the date? *',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildRatingOption('WOW', '⭐', 'Amazing!', Colors.green),
            const SizedBox(width: 8),
            _buildRatingOption('GTFOH', '🚫', 'Bad', Colors.red),
            const SizedBox(width: 8),
            _buildRatingOption('ChekMate', '♟️', 'Smart', AppColors.primary),
          ],
        ),
        const SizedBox(height: 24),
        
        // Optional review text
        TextField(
          controller: _textController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Tell us more (optional)',
            hintText: 'Share your experience...',
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        
        // Media buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library),
                label: const Text('Add Photo'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.videocam),
                label: const Text('Add Video'),
              ),
            ),
          ],
        ),
        
        // Show selected media
        if (_selectedImages.isNotEmpty || _selectedVideo != null) ...[
          const SizedBox(height: 16),
          _buildMediaPreview(),
        ],
      ],
    );
  }

  Widget _buildRatingOption(String rating, String emoji, String label, Color color) {
    final isSelected = _selectedRating == rating;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRating = rating;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Story form - 24-hour ephemeral content
  Widget _buildStoryForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserHeader(),
        const SizedBox(height: 16),
        
        // Story info banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Stories disappear after 24 hours',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Story preview area
        Container(
          width: double.infinity,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: _selectedImages.isNotEmpty || _selectedVideo != null
              ? _buildStoryPreview()
              : _buildStoryPlaceholder(),
        ),
        const SizedBox(height: 16),
        
        // Media selection buttons
        Row(
          children: [
            Expanded(
              child: _buildStoryMediaButton(
                icon: Icons.photo_library,
                label: 'Photo',
                onTap: _pickImages,
                isSelected: _selectedImages.isNotEmpty,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStoryMediaButton(
                icon: Icons.videocam,
                label: 'Video',
                onTap: _pickVideo,
                isSelected: _selectedVideo != null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStoryMediaButton(
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: _openCamera,
                isSelected: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Optional caption
        TextField(
          controller: _textController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Add a caption (optional)',
            hintText: 'Say something about your story...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        
        // Story options
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Story Settings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              _buildStoryOption(
                icon: Icons.public,
                title: 'Everyone',
                subtitle: 'All followers can see',
                isSelected: true,
              ),
              _buildStoryOption(
                icon: Icons.group,
                title: 'Close Friends',
                subtitle: 'Only close friends can see',
                isSelected: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStoryPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_photo_alternate,
              size: 48,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Add a photo or video',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share a moment with your followers',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryPreview() {
    if (_selectedVideo != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_outline, size: 64, color: Colors.white54),
                  SizedBox(height: 8),
                  Text('Video Selected', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
              onPressed: () => setState(() => _selectedVideo = null),
            ),
          ),
        ],
      );
    }
    
    if (_selectedImages.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              _selectedImages.first,
              fit: BoxFit.cover,
            ),
          ),
          // Multiple images indicator
          if (_selectedImages.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '1/${_selectedImages.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          Positioned(
            top: 12,
            left: 12,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
              onPressed: () => setState(() => _selectedImages.clear()),
            ),
          ),
        ],
      );
    }
    
    return _buildStoryPlaceholder();
  }

  Widget _buildStoryMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey.shade600,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isSelected ? AppColors.primary : Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          if (isSelected)
            Icon(Icons.check_circle, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }

  /// Open camera for story capture
  Future<void> _openCamera() async {
    try {
      final image = await FilePickerService.pickImageFromCamera();
      if (image != null) {
        setState(() {
          _selectedImages.clear();
          _selectedVideo = null;
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Create a story
  Future<void> _createStory() async {
    if (_isCreatingPost) return;
    if (_selectedImages.isEmpty && _selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a photo or video to your story'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCreatingPost = true;
    });

    try {
      // Upload media first
      String mediaUrl = '';
      String mediaType = 'image';

      if (_selectedVideo != null) {
        // Upload video
        final videoBytes = await _selectedVideo!.readAsBytes();
        final storageRef = ref.read(storageProvider);
        final fileName = 'stories/${DateTime.now().millisecondsSinceEpoch}_video.mp4';
        final uploadTask = await storageRef.ref(fileName).putData(videoBytes);
        mediaUrl = await uploadTask.ref.getDownloadURL();
        mediaType = 'video';
      } else if (_selectedImages.isNotEmpty) {
        // Upload first image
        final imageBytes = await _selectedImages.first.readAsBytes();
        final storageRef = ref.read(storageProvider);
        final fileName = 'stories/${DateTime.now().millisecondsSinceEpoch}_image.jpg';
        final uploadTask = await storageRef.ref(fileName).putData(imageBytes);
        mediaUrl = await uploadTask.ref.getDownloadURL();
        mediaType = 'image';
      }

      // Create story in Firebase
      await ref.read(createStoryProvider).call(
        mediaUrl: mediaUrl,
        mediaType: mediaType,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Story shared!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create story: $e'),
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

  /// Build Go Live form
  Widget _buildGoLiveForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserHeader(),
        const SizedBox(height: 24),
        
        // Live stream title
        TextField(
          controller: _textController,
          decoration: InputDecoration(
            labelText: 'What\'s your live about? *',
            hintText: 'Dating advice, Q&A, Story time...',
            prefixIcon: const Icon(Icons.title),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 24),
        
        // Live preview card
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.8),
                AppColors.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Camera preview placeholder
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam, size: 64, color: Colors.white54),
                    SizedBox(height: 16),
                    Text(
                      'Camera Preview',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your live will appear here',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Live badge
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Tips
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Tips for a great live',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('• Find good lighting'),
              const Text('• Use a stable connection'),
              const Text('• Engage with your audience'),
              const Text('• Have fun and be yourself!'),
            ],
          ),
        ),
      ],
    );
  }

  /// Build media preview for selected images/video
  Widget _buildMediaPreview() {
    if (_selectedVideo != null) {
      return Stack(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.video_file, size: 48, color: Colors.grey),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
              onPressed: () => setState(() => _selectedVideo = null),
            ),
          ),
        ],
      );
    }
    
    if (_selectedImages.isNotEmpty) {
      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _selectedImages.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImages[index],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImages.removeAt(index)),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  /// Build the post type selector tabs
  Widget _buildPostTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          _buildPostTypeTab(
            type: CreatePostType.post,
            icon: Icons.edit_note,
            label: 'Post',
          ),
          const SizedBox(width: 6),
          _buildPostTypeTab(
            type: CreatePostType.story,
            icon: Icons.auto_awesome,
            label: 'Story',
          ),
          const SizedBox(width: 6),
          _buildPostTypeTab(
            type: CreatePostType.rateDate,
            icon: Icons.favorite,
            label: 'Rate',
          ),
          const SizedBox(width: 6),
          _buildPostTypeTab(
            type: CreatePostType.goLive,
            icon: Icons.live_tv,
            label: 'Live',
          ),
        ],
      ),
    );
  }

  Widget _buildPostTypeTab({
    required CreatePostType type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedPostType == type;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPostType = type;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get app bar title based on selected post type
  String _getAppBarTitle() {
    return switch (_selectedPostType) {
      CreatePostType.post => 'Create Post',
      CreatePostType.story => 'Create Story',
      CreatePostType.rateDate => 'Rate Your Date',
      CreatePostType.goLive => 'Go Live',
    };
  }

  /// Get submit button text based on selected post type
  String _getSubmitButtonText() {
    return switch (_selectedPostType) {
      CreatePostType.post => 'Post',
      CreatePostType.story => 'Share',
      CreatePostType.rateDate => 'Rate',
      CreatePostType.goLive => 'Start',
    };
  }

  /// Check if form can be submitted
  bool _canSubmit() {
    return switch (_selectedPostType) {
      CreatePostType.post => _textController.text.trim().isNotEmpty ||
          _selectedImages.isNotEmpty ||
          _selectedVideo != null,
      CreatePostType.story => _selectedImages.isNotEmpty || _selectedVideo != null,
      CreatePostType.rateDate => _partnerNameController.text.trim().isNotEmpty &&
          _dateLocationController.text.trim().isNotEmpty &&
          _dateActivityController.text.trim().isNotEmpty &&
          _selectedRating != null,
      CreatePostType.goLive => _textController.text.trim().isNotEmpty,
    };
  }

  /// Handle form submission based on post type
  Future<void> _handleSubmit() async {
    switch (_selectedPostType) {
      case CreatePostType.post:
        await _createPost();
        break;
      case CreatePostType.story:
        await _createStory();
        break;
      case CreatePostType.rateDate:
        await _createRateDatePost();
        break;
      case CreatePostType.goLive:
        _startLiveStream();
        break;
    }
  }

  /// Create a Rate Date post
  Future<void> _createRateDatePost() async {
    if (_isCreatingPost) return;

    setState(() {
      _isCreatingPost = true;
    });

    try {
      // Create the date experience
      final dateId = await ref.read(createDateExperienceProvider).call(
        partnerName: _partnerNameController.text.trim(),
        partnerAge: int.tryParse(_partnerAgeController.text),
        location: _dateLocationController.text.trim(),
        dateDetails: _dateActivityController.text.trim(),
        dateTime: _selectedDateTime,
      );

      // Rate it immediately if rating selected
      if (_selectedRating != null) {
        await ref.read(rateDateExperienceProvider).call(
          dateExperienceId: dateId,
          rating: _selectedRating!,
          review: _textController.text.trim().isNotEmpty 
              ? _textController.text.trim() 
              : null,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Date rated as $_selectedRating!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create rating: $e'),
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

  /// Start a live stream
  void _startLiveStream() {
    // Navigate to live streaming page
    context.push('/live/create', extra: {
      'title': _textController.text.trim(),
    });
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
