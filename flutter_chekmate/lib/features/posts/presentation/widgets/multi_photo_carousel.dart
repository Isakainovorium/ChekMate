import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_chekmate/features/posts/presentation/widgets/photo_zoom_viewer.dart';
import 'package:flutter_chekmate/shared/ui/loading/shimmer_loading.dart';

/// Multi-Photo Carousel Widget
///
/// Instagram-style carousel for displaying multiple photos in a post.
/// Features:
/// - Swipeable carousel with smooth transitions
/// - Page indicators (dots)
/// - Tap to view full-screen with zoom
/// - Supports 1-10 photos
/// - Aspect ratio preservation
/// - Loading states
/// - Error handling
///
/// Usage:
/// ```dart
/// MultiPhotoCarousel(
///   imageUrls: ['url1', 'url2', 'url3'],
///   aspectRatio: 1.0, // Square by default
///   enableZoom: true,
/// )
/// ```
class MultiPhotoCarousel extends StatefulWidget {
  const MultiPhotoCarousel({
    required this.imageUrls,
    super.key,
    this.aspectRatio = 1.0,
    this.enableZoom = true,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.enableInfiniteScroll = true,
    this.viewportFraction = 1.0,
    this.onPageChanged,
    this.borderRadius = 0.0,
  });

  final List<String> imageUrls;
  final double aspectRatio;
  final bool enableZoom;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool enableInfiniteScroll;
  final double viewportFraction;
  final ValueChanged<int>? onPageChanged;
  final double borderRadius;

  @override
  State<MultiPhotoCarousel> createState() => _MultiPhotoCarouselState();
}

class _MultiPhotoCarouselState extends State<MultiPhotoCarousel> {
  int _currentPage = 0;
  final carousel.CarouselSliderController _carouselController =
      carousel.CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    // Handle empty or single image cases
    if (widget.imageUrls.isEmpty) {
      return _buildEmptyState();
    }

    if (widget.imageUrls.length == 1) {
      return _buildSingleImage(widget.imageUrls.first);
    }

    return Stack(
      children: [
        // Carousel
        carousel.CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: widget.imageUrls.length,
          itemBuilder: (context, index, realIndex) {
            return _buildCarouselItem(widget.imageUrls[index], index);
          },
          options: carousel.CarouselOptions(
            aspectRatio: widget.aspectRatio,
            viewportFraction: widget.viewportFraction,
            enableInfiniteScroll: widget.enableInfiniteScroll,
            autoPlay: widget.autoPlay,
            autoPlayInterval: widget.autoPlayInterval,
            onPageChanged: (index, reason) {
              setState(() {
                _currentPage = index;
              });
              widget.onPageChanged?.call(index);
            },
          ),
        ),

        // Page indicators (dots)
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: _buildPageIndicators(),
          ),

        // Navigation arrows (optional, for desktop/web)
        if (widget.imageUrls.length > 1 &&
            MediaQuery.of(context).size.width > 600)
          _buildNavigationArrows(),
      ],
    );
  }

  Widget _buildCarouselItem(String imageUrl, int index) {
    return GestureDetector(
      onTap: widget.enableZoom ? () => _openPhotoZoomViewer(index) : null,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingState(loadingProgress);
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorState();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSingleImage(String imageUrl) {
    return GestureDetector(
      onTap: widget.enableZoom ? () => _openPhotoZoomViewer(0) : null,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingState(loadingProgress);
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorState();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.imageUrls.length,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationArrows() {
    return Positioned.fill(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          if (_currentPage > 0 || widget.enableInfiniteScroll)
            _buildArrowButton(
              icon: Icons.chevron_left,
              onPressed: () => _carouselController.previousPage(),
            ),
          const Spacer(),
          // Next button
          if (_currentPage < widget.imageUrls.length - 1 ||
              widget.enableInfiniteScroll)
            _buildArrowButton(
              icon: Icons.chevron_right,
              onPressed: () => _carouselController.nextPage(),
            ),
        ],
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildLoadingState(ImageChunkEvent loadingProgress) {
    return const ShimmerImage(
      borderRadius: 0,
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Failed to load image',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
        ),
      ),
    );
  }

  void _openPhotoZoomViewer(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PhotoZoomViewer(
          imageUrls: widget.imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}
