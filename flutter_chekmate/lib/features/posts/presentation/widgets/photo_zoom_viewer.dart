import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

/// Photo Zoom Viewer Widget
///
/// Full-screen photo viewer with pinch-to-zoom functionality.
/// Features:
/// - Pinch-to-zoom with smooth animations
/// - Swipe between photos in gallery
/// - Double-tap to zoom
/// - Page indicators
/// - Close button
/// - Immersive full-screen mode
/// - Loading states
/// - Error handling
///
/// Usage:
/// ```dart
/// PhotoZoomViewer(
///   imageUrls: ['url1', 'url2', 'url3'],
///   initialIndex: 0,
/// )
/// ```
class PhotoZoomViewer extends StatefulWidget {
  const PhotoZoomViewer({
    required this.imageUrls,
    super.key,
    this.initialIndex = 0,
    this.minScale,
    this.maxScale,
    this.backgroundDecoration = const BoxDecoration(
      color: Colors.black,
    ),
    this.enableRotation = false,
    this.heroTag,
  });

  final List<String> imageUrls;
  final int initialIndex;
  final dynamic minScale;
  final dynamic maxScale;
  final BoxDecoration backgroundDecoration;
  final bool enableRotation;
  final String? heroTag;

  @override
  State<PhotoZoomViewer> createState() => _PhotoZoomViewerState();
}

class _PhotoZoomViewerState extends State<PhotoZoomViewer> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Set immersive mode (hide status bar and navigation bar)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Photo gallery
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: _buildPhotoViewItem,
            itemCount: widget.imageUrls.length,
            loadingBuilder: _buildLoadingIndicator,
            backgroundDecoration: widget.backgroundDecoration,
            pageController: _pageController,
            onPageChanged: _onPageChanged,
            enableRotation: widget.enableRotation,
          ),

          // Top bar with close button and counter
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),

          // Bottom bar with page indicators
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(),
            ),
        ],
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildPhotoViewItem(
    BuildContext context,
    int index,
  ) {
    final imageUrl = widget.imageUrls[index];

    return PhotoViewGalleryPageOptions(
      imageProvider: NetworkImage(imageUrl),
      initialScale: PhotoViewComputedScale.contained,
      minScale: widget.minScale ?? PhotoViewComputedScale.contained * 0.8,
      maxScale: widget.maxScale ?? PhotoViewComputedScale.covered * 2.0,
      heroAttributes: widget.heroTag != null
          ? PhotoViewHeroAttributes(tag: '${widget.heroTag}_$index')
          : null,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorState();
      },
    );
  }

  Widget _buildLoadingIndicator(BuildContext context, ImageChunkEvent? event) {
    return Center(
      child: CircularProgressIndicator(
        value: event == null || event.expectedTotalBytes == null
            ? null
            : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 8,
        bottom: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),

          // Counter
          if (widget.imageUrls.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.imageUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            const SizedBox.shrink(),

          // Placeholder for symmetry
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.imageUrls.length,
          (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == index
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'Failed to load image',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
