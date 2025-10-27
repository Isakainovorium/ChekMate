import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppLoadingSpinner - Comprehensive loading states and spinners
class AppLoadingSpinner extends StatefulWidget {
  const AppLoadingSpinner({
    super.key,
    this.size = AppLoadingSize.medium,
    this.color,
    this.strokeWidth,
    this.message,
    this.showMessage = false,
    this.type = AppLoadingType.circular,
  });

  final AppLoadingSize size;
  final Color? color;
  final double? strokeWidth;
  final String? message;
  final bool showMessage;
  final AppLoadingType type;

  @override
  State<AppLoadingSpinner> createState() => _AppLoadingSpinnerState();
}

class _AppLoadingSpinnerState extends State<AppLoadingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.primary;
    final size = _getSizeValue(widget.size);

    Widget spinner;
    switch (widget.type) {
      case AppLoadingType.circular:
        spinner = _buildCircularSpinner(color, size);
        break;
      case AppLoadingType.linear:
        spinner = _buildLinearSpinner(color);
        break;
      case AppLoadingType.dots:
        spinner = _buildDotsSpinner(color, size);
        break;
      case AppLoadingType.pulse:
        spinner = _buildPulseSpinner(color, size);
        break;
      case AppLoadingType.wave:
        spinner = _buildWaveSpinner(color, size);
        break;
      case AppLoadingType.custom:
        spinner = _buildCustomSpinner(color, size);
        break;
    }

    if (widget.showMessage && widget.message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          spinner,
          const SizedBox(height: AppSpacing.md),
          Text(
            widget.message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return spinner;
  }

  Widget _buildCircularSpinner(Color color, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: widget.strokeWidth ?? (size / 10),
      ),
    );
  }

  Widget _buildLinearSpinner(Color color) {
    return LinearProgressIndicator(
      color: color,
      backgroundColor: color.withValues(alpha: 0.2),
    );
  }

  Widget _buildDotsSpinner(Color color, double size) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_controller.value - delay).clamp(0.0, 1.0);
            final scale = 0.5 +
                (0.5 * (1 - (animationValue - 0.5).abs() * 2).clamp(0.0, 1.0));

            return Container(
              margin: EdgeInsets.symmetric(horizontal: size / 8),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: size / 4,
                  height: size / 4,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildPulseSpinner(Color color, double size) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 0.8 + (0.4 * (1 - (_controller.value - 0.5).abs() * 2));
        final opacity = 0.3 + (0.7 * (1 - (_controller.value - 0.5).abs() * 2));

        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withValues(alpha: opacity),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveSpinner(Color color, double size) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final delay = index * 0.1;
            final animationValue = (_controller.value - delay) % 1.0;
            final height =
                size * (0.3 + 0.7 * (1 - (animationValue - 0.5).abs() * 2));

            return Container(
              margin: EdgeInsets.symmetric(horizontal: size / 20),
              width: size / 10,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(size / 20),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildCustomSpinner(Color color, double size) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Rotating gradient ring
            Transform.rotate(
              angle: _controller.value * 2 * 3.14159,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  gradient: SweepGradient(
                    colors: [
                      color,
                      color.withValues(alpha: 0.1),
                      color,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // ChekMate app icon in center
            Container(
              width: size * 0.6,
              height: size * 0.6,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to simple icon if image fails to load
                    return Icon(
                      Icons.favorite,
                      size: size * 0.4,
                      color: color,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double _getSizeValue(AppLoadingSize size) {
    switch (size) {
      case AppLoadingSize.small:
        return 16.0;
      case AppLoadingSize.medium:
        return 24.0;
      case AppLoadingSize.large:
        return 32.0;
      case AppLoadingSize.extraLarge:
        return 48.0;
    }
  }
}

/// AppLoadingOverlay - Full-screen loading overlay
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    required this.isLoading,
    required this.child,
    super.key,
    this.message,
    this.backgroundColor,
    this.spinnerColor,
    this.type = AppLoadingType.circular,
  });

  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;
  final Color? spinnerColor;
  final AppLoadingType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AppLoadingSpinner(
                  size: AppLoadingSize.large,
                  color: spinnerColor,
                  message: message,
                  showMessage: message != null,
                  type: type,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// AppLoadingButton - Button with loading state
class AppLoadingButton extends StatelessWidget {
  const AppLoadingButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.isLoading = false,
    this.loadingText,
    this.style,
    this.spinnerColor,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final String? loadingText;
  final ButtonStyle? style;
  final Color? spinnerColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppLoadingSpinner(
                  size: AppLoadingSize.small,
                  color: spinnerColor ?? theme.colorScheme.onPrimary,
                ),
                if (loadingText != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(loadingText!),
                ],
              ],
            )
          : child,
    );
  }
}

/// AppLoadingCard - Card with loading skeleton
class AppLoadingCard extends StatefulWidget {
  const AppLoadingCard({
    super.key,
    this.width,
    this.height = 200,
    this.borderRadius = 12,
    this.showAvatar = true,
    this.showTitle = true,
    this.showSubtitle = true,
    this.showContent = true,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final bool showAvatar;
  final bool showTitle;
  final bool showSubtitle;
  final bool showContent;

  @override
  State<AppLoadingCard> createState() => _AppLoadingCardState();
}

class _AppLoadingCardState extends State<AppLoadingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with avatar
                    if (widget.showAvatar ||
                        widget.showTitle ||
                        widget.showSubtitle)
                      Row(
                        children: [
                          if (widget.showAvatar)
                            const _SkeletonBox(
                              width: 40,
                              height: 40,
                              borderRadius: 20,
                            ),
                          if (widget.showAvatar)
                            const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.showTitle)
                                  const _SkeletonBox(
                                    width: 120,
                                    height: 16,
                                    borderRadius: 4,
                                  ),
                                if (widget.showTitle && widget.showSubtitle)
                                  const SizedBox(height: AppSpacing.xs),
                                if (widget.showSubtitle)
                                  const _SkeletonBox(
                                    width: 80,
                                    height: 12,
                                    borderRadius: 4,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    if (widget.showContent) ...[
                      const SizedBox(height: AppSpacing.md),
                      // Content lines
                      const _SkeletonBox(
                        width: double.infinity,
                        height: 14,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _SkeletonBox(
                        width: double.infinity,
                        height: 14,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _SkeletonBox(
                        width: 200,
                        height: 14,
                        borderRadius: 4,
                      ),
                    ],
                  ],
                ),
              ),

              // Shimmer effect
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: Transform.translate(
                    offset: Offset(_animation.value * widget.width!, 0),
                    child: Container(
                      width: widget.width! * 0.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// AppLoadingList - Loading skeleton for lists
class AppLoadingList extends StatelessWidget {
  const AppLoadingList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.showSeparator = true,
  });

  final int itemCount;
  final double itemHeight;
  final bool showSeparator;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: itemCount,
      separatorBuilder: (context, index) => showSeparator
          ? const Divider()
          : const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        return AppLoadingCard(
          height: itemHeight,
          showContent: false,
        );
      },
    );
  }
}

/// Enums for loading configurations
enum AppLoadingSize {
  small,
  medium,
  large,
  extraLarge,
}

enum AppLoadingType {
  circular,
  linear,
  dots,
  pulse,
  wave,
  custom,
}
