import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/posts/presentation/widgets/multi_photo_carousel.dart';

/// Multi-Photo Post Example Widget
///
/// Demonstrates the usage of MultiPhotoCarousel with various configurations.
/// This widget shows different use cases:
/// - Single photo
/// - Multiple photos (2-10)
/// - Different aspect ratios
/// - With/without zoom
/// - Auto-play carousel
///
/// Usage:
/// ```dart
/// MultiPhotoPostExample()
/// ```
class MultiPhotoPostExample extends StatelessWidget {
  const MultiPhotoPostExample({super.key});

  // Sample image URLs from Unsplash
  static const List<String> sampleImages = [
    'https://images.unsplash.com/photo-1758874089739-da0739746ea4',
    'https://images.unsplash.com/photo-1618590067690-2db34a87750a',
    'https://images.unsplash.com/photo-1655249493799-9cee4fe983bb',
    'https://images.unsplash.com/photo-1672685667592-0392f458f46f',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Photo Carousel Examples'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildSection(
            title: '1. Single Photo',
            description: 'Displays a single photo with zoom capability',
            child: MultiPhotoCarousel(
              imageUrls: [sampleImages[0]],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            title: '2. Two Photos',
            description: 'Swipeable carousel with 2 photos',
            child: MultiPhotoCarousel(
              imageUrls: sampleImages.sublist(0, 2),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            title: '3. Multiple Photos (5)',
            description: 'Instagram-style carousel with page indicators',
            child: const MultiPhotoCarousel(
              imageUrls: sampleImages,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            title: '4. Auto-Play Carousel',
            description: 'Automatically advances every 3 seconds',
            child: MultiPhotoCarousel(
              imageUrls: sampleImages.sublist(0, 3),
              autoPlay: true,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            title: '5. Rounded Corners',
            description: 'Carousel with rounded corners',
            child: MultiPhotoCarousel(
              imageUrls: sampleImages.sublist(0, 3),
              borderRadius: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            title: '6. Portrait Aspect Ratio (4:5)',
            description: 'Vertical photos like Instagram',
            child: MultiPhotoCarousel(
              imageUrls: sampleImages.sublist(0, 3),
              aspectRatio: 4 / 5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            title: '7. Landscape Aspect Ratio (16:9)',
            description: 'Wide photos for landscape content',
            child: MultiPhotoCarousel(
              imageUrls: sampleImages.sublist(0, 3),
              aspectRatio: 16 / 9,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            title: '8. Zoom Disabled',
            description: 'Carousel without zoom functionality',
            child: MultiPhotoCarousel(
              imageUrls: sampleImages.sublist(0, 3),
              enableZoom: false,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            title: '9. With Page Change Callback',
            description: 'Tracks current page index',
            child: _PageChangeExample(
              imageUrls: sampleImages.sublist(0, 4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

/// Example widget that demonstrates page change callback
class _PageChangeExample extends StatefulWidget {
  const _PageChangeExample({
    required this.imageUrls,
  });

  final List<String> imageUrls;

  @override
  State<_PageChangeExample> createState() => _PageChangeExampleState();
}

class _PageChangeExampleState extends State<_PageChangeExample> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MultiPhotoCarousel(
          imageUrls: widget.imageUrls,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Current page: ${_currentPage + 1} of ${widget.imageUrls.length}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

