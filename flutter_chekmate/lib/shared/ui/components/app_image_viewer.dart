import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppImageViewer - Comprehensive image display and viewing
class AppImageViewer extends StatefulWidget {
  const AppImageViewer({
    required this.imageUrl, super.key,
    this.heroTag,
    this.title,
    this.description,
    this.allowZoom = true,
    this.allowDownload = true,
    this.allowShare = true,
    this.onClose,
    this.backgroundColor,
  });

  final String imageUrl;
  final String? heroTag;
  final String? title;
  final String? description;
  final bool allowZoom;
  final bool allowDownload;
  final bool allowShare;
  final VoidCallback? onClose;
  final Color? backgroundColor;

  static Future<void> show({
    required BuildContext context,
    required String imageUrl,
    String? heroTag,
    String? title,
    String? description,
    bool allowZoom = true,
    bool allowDownload = true,
    bool allowShare = true,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AppImageViewer(
          imageUrl: imageUrl,
          heroTag: heroTag,
          title: title,
          description: description,
          allowZoom: allowZoom,
          allowDownload: allowDownload,
          allowShare: allowShare,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        barrierDismissible: true,
        opaque: false,
      ),
    );
  }

  @override
  State<AppImageViewer> createState() => _AppImageViewerState();
}

class _AppImageViewerState extends State<AppImageViewer>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  bool _showControls = true;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
    _hideControlsAfterDelay();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _hideControlsAfterDelay();
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _close() {
    _animationController.reverse().then((_) {
      widget.onClose?.call();
      Navigator.of(context).pop();
    });
  }

  void _downloadImage() {
    // Implement image download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download started')),
    );
  }

  void _shareImage() {
    // Implement image sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: widget.backgroundColor ?? Colors.black,
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(
            opacity: _animation.value,
            child: Stack(
              children: [
                // Image viewer
                GestureDetector(
                  onTap: _toggleControls,
                  child: Center(
                    child: widget.allowZoom
                        ? InteractiveViewer(
                            transformationController: _transformationController,
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: _buildImage(),
                          )
                        : _buildImage(),
                  ),
                ),

                // Top controls
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  top: _showControls ? 0 : -100,
                  left: 0,
                  right: 0,
                  child: _buildTopControls(theme),
                ),

                // Bottom controls
                if (widget.title != null || widget.description != null)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    bottom: _showControls ? 0 : -200,
                    left: 0,
                    right: 0,
                    child: _buildBottomInfo(theme),
                  ),

                // Loading indicator
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),

                // Error state
                if (_hasError)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 64,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _hasError = false;
                              _isLoading = true;
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage() {
    Widget imageWidget = Image.network(
      widget.imageUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          });
          return child;
        }
        return const SizedBox.shrink();
      },
      errorBuilder: (context, error, stackTrace) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          }
        });
        return const SizedBox.shrink();
      },
    );

    if (widget.heroTag != null) {
      imageWidget = Hero(
        tag: widget.heroTag!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildTopControls(ThemeData theme) {
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
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              IconButton(
                onPressed: _close,
                icon: const Icon(Icons.close, color: Colors.white),
              ),
              const Spacer(),
              if (widget.allowZoom)
                IconButton(
                  onPressed: _resetZoom,
                  icon: const Icon(Icons.zoom_out_map, color: Colors.white),
                ),
              if (widget.allowShare)
                IconButton(
                  onPressed: _shareImage,
                  icon: const Icon(Icons.share, color: Colors.white),
                ),
              if (widget.allowDownload)
                IconButton(
                  onPressed: _downloadImage,
                  icon: const Icon(Icons.download, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInfo(ThemeData theme) {
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
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.title != null)
                Text(
                  widget.title!,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (widget.description != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// AppImageGallery - Gallery viewer for multiple images
class AppImageGallery extends StatefulWidget {
  const AppImageGallery({
    required this.images, super.key,
    this.initialIndex = 0,
    this.onPageChanged,
    this.allowZoom = true,
    this.allowDownload = true,
    this.allowShare = true,
  });

  final List<AppGalleryImage> images;
  final int initialIndex;
  final ValueChanged<int>? onPageChanged;
  final bool allowZoom;
  final bool allowDownload;
  final bool allowShare;

  static Future<void> show({
    required BuildContext context,
    required List<AppGalleryImage> images,
    int initialIndex = 0,
    ValueChanged<int>? onPageChanged,
    bool allowZoom = true,
    bool allowDownload = true,
    bool allowShare = true,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AppImageGallery(
          images: images,
          initialIndex: initialIndex,
          onPageChanged: onPageChanged,
          allowZoom: allowZoom,
          allowDownload: allowDownload,
          allowShare: allowShare,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        barrierDismissible: true,
        opaque: false,
      ),
    );
  }

  @override
  State<AppImageGallery> createState() => _AppImageGalleryState();
}

class _AppImageGalleryState extends State<AppImageGallery> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _hideControlsAfterDelay();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _hideControlsAfterDelay();
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    widget.onPageChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentImage = widget.images[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image gallery
          GestureDetector(
            onTap: _toggleControls,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                final image = widget.images[index];
                return Center(
                  child: widget.allowZoom
                      ? InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Image.network(
                            image.url,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Image.network(
                          image.url,
                          fit: BoxFit.contain,
                        ),
                );
              },
            ),
          ),

          // Top controls
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: _showControls ? 0 : -100,
            left: 0,
            right: 0,
            child: Container(
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
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                      const Spacer(),
                      Text(
                        '${_currentIndex + 1} of ${widget.images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (widget.allowShare)
                        IconButton(
                          onPressed: () {
                            // Share current image
                          },
                          icon: const Icon(Icons.share, color: Colors.white),
                        ),
                      if (widget.allowDownload)
                        IconButton(
                          onPressed: () {
                            // Download current image
                          },
                          icon: const Icon(Icons.download, color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom info
          if (currentImage.title != null || currentImage.description != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: _showControls ? 0 : -200,
              left: 0,
              right: 0,
              child: Container(
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
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (currentImage.title != null)
                          Text(
                            currentImage.title!,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (currentImage.description != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            currentImage.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Page indicators
          if (widget.images.length > 1)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: _showControls ? 80 : -50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      widget.images.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index == _currentIndex
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// AppImageThumbnail - Thumbnail image with tap to view
class AppImageThumbnail extends StatelessWidget {
  const AppImageThumbnail({
    required this.imageUrl, super.key,
    this.width = 100,
    this.height = 100,
    this.borderRadius = 8,
    this.heroTag,
    this.onTap,
    this.showZoomIcon = true,
  });

  final String imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final String? heroTag;
  final VoidCallback? onTap;
  final bool showZoomIcon;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            Image.network(
              imageUrl,
              width: width,
              height: height,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
            if (showZoomIcon)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (heroTag != null) {
      imageWidget = Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    return GestureDetector(
      onTap: onTap ??
          () => AppImageViewer.show(
                context: context,
                imageUrl: imageUrl,
                heroTag: heroTag,
              ),
      child: imageWidget,
    );
  }
}

/// Data class for gallery images
class AppGalleryImage {

  const AppGalleryImage({
    required this.url,
    this.title,
    this.description,
    this.heroTag,
  });
  final String url;
  final String? title;
  final String? description;
  final String? heroTag;
}
