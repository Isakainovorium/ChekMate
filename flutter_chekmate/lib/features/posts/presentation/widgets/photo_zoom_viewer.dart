import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

/// Photo Zoom Viewer Widget
///
/// A full-screen image viewer with zoom capabilities.
/// Supports single images and image galleries with swipe navigation.
class PhotoZoomViewer extends StatefulWidget {
  const PhotoZoomViewer({
    required this.imageUrls,
    this.initialIndex = 0,
    this.heroTag,
    super.key,
  });

  final List<String> imageUrls;
  final int initialIndex;
  final Object? heroTag;

  @override
  State<PhotoZoomViewer> createState() => _PhotoZoomViewerState();
}

class _PhotoZoomViewerState extends State<PhotoZoomViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.imageUrls.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No images to display',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main image/gallery view
          widget.imageUrls.length == 1
              ? _buildSingleImageView()
              : _buildGalleryView(),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Page indicator for multiple images
          if (widget.imageUrls.length > 1) _buildPageIndicator(),
        ],
      ),
    );
  }

  Widget _buildSingleImageView() {
    final imageUrl = widget.imageUrls.first;

    if (widget.heroTag != null) {
      return Hero(
        tag: widget.heroTag!,
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        ),
      );
    }

    return PhotoView(
      imageProvider: NetworkImage(imageUrl),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 2,
      backgroundDecoration: const BoxDecoration(color: Colors.black),
    );
  }

  Widget _buildGalleryView() {
    return PhotoViewGallery.builder(
      pageController: _pageController,
      itemCount: widget.imageUrls.length,
      builder: (context, index) {
        final imageUrl = widget.imageUrls[index];

        if (widget.heroTag != null && index == widget.initialIndex) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(tag: widget.heroTag!),
          );
        }

        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        );
      },
      onPageChanged: _onPageChanged,
      backgroundDecoration: const BoxDecoration(color: Colors.black),
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
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
        ),
      ),
    );
  }
}
