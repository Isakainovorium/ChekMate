import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppCarousel - Image/content carousel with indicators and controls
class AppCarousel extends StatefulWidget {
  const AppCarousel({
    required this.items,
    super.key,
    this.height = 200,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.showIndicators = true,
    this.showControls = false,
    this.onPageChanged,
    this.initialPage = 0,
    this.viewportFraction = 1.0,
    this.enableInfiniteScroll = true,
  });

  final List<Widget> items;
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool showIndicators;
  final bool showControls;
  final ValueChanged<int>? onPageChanged;
  final int initialPage;
  final double viewportFraction;
  final bool enableInfiniteScroll;

  @override
  State<AppCarousel> createState() => _AppCarouselState();
}

class _AppCarouselState extends State<AppCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(
      initialPage: widget.initialPage,
      viewportFraction: widget.viewportFraction,
    );

    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (mounted) {
        _nextPage();
      }
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
  }

  void _nextPage() {
    if (widget.items.isEmpty) return;

    var nextPage = _currentPage + 1;
    if (widget.enableInfiniteScroll) {
      nextPage = nextPage % widget.items.length;
    } else if (nextPage >= widget.items.length) {
      nextPage = 0;
    }

    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    if (widget.items.isEmpty) return;

    var previousPage = _currentPage - 1;
    if (widget.enableInfiniteScroll) {
      previousPage = previousPage < 0 ? widget.items.length - 1 : previousPage;
    } else if (previousPage < 0) {
      previousPage = widget.items.length - 1;
    }

    _pageController.animateToPage(
      previousPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    widget.onPageChanged?.call(page);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return SizedBox(height: widget.height);
    }

    return GestureDetector(
      onPanStart: (_) => _stopAutoPlay(),
      onPanEnd: (_) {
        if (widget.autoPlay) {
          _startAutoPlay();
        }
      },
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            // Carousel content
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount:
                  widget.enableInfiniteScroll ? null : widget.items.length,
              itemBuilder: (context, index) {
                final itemIndex = index % widget.items.length;
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        widget.viewportFraction < 1.0 ? AppSpacing.xs : 0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.items[itemIndex],
                  ),
                );
              },
            ),

            // Navigation controls
            if (widget.showControls && widget.items.length > 1) ...[
              // Previous button
              Positioned(
                left: AppSpacing.sm,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _CarouselButton(
                    icon: Icons.chevron_left,
                    onPressed: _previousPage,
                  ),
                ),
              ),

              // Next button
              Positioned(
                right: AppSpacing.sm,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _CarouselButton(
                    icon: Icons.chevron_right,
                    onPressed: _nextPage,
                  ),
                ),
              ),
            ],

            // Page indicators
            if (widget.showIndicators && widget.items.length > 1)
              Positioned(
                bottom: AppSpacing.md,
                left: 0,
                right: 0,
                child: _CarouselIndicators(
                  itemCount: widget.items.length,
                  currentIndex: _currentPage % widget.items.length,
                  onTap: (index) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CarouselButton extends StatelessWidget {
  const _CarouselButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _CarouselIndicators extends StatelessWidget {
  const _CarouselIndicators({
    required this.itemCount,
    required this.currentIndex,
    this.onTap,
  });

  final int itemCount;
  final int currentIndex;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentIndex;

        return GestureDetector(
          onTap: onTap != null ? () => onTap!(index) : null,
          child: Container(
            width: isActive ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color:
                  isActive ? Colors.white : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

/// AppImageCarousel - Specialized carousel for images
class AppImageCarousel extends StatelessWidget {
  const AppImageCarousel({
    required this.imageUrls,
    super.key,
    this.height = 200,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.showIndicators = true,
    this.showControls = false,
    this.onPageChanged,
    this.fit = BoxFit.cover,
  });

  final List<String> imageUrls;
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool showIndicators;
  final bool showControls;
  final ValueChanged<int>? onPageChanged;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return AppCarousel(
      items: imageUrls
          .map(
            (url) => Image.network(
              url,
              fit: fit,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                final theme = Theme.of(context);
                return Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                final theme = Theme.of(context);
                return Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          )
          .toList(),
      height: height,
      autoPlay: autoPlay,
      autoPlayInterval: autoPlayInterval,
      showIndicators: showIndicators,
      showControls: showControls,
      onPageChanged: onPageChanged,
    );
  }
}
