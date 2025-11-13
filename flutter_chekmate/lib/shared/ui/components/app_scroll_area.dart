import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppScrollArea - Custom scroll behavior with styling and performance
class AppScrollArea extends StatefulWidget {
  const AppScrollArea({
    required this.child,
    super.key,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.physics,
    this.padding,
    this.showScrollbar = true,
    this.scrollbarThickness = 6.0,
    this.scrollbarRadius = 3.0,
    this.scrollbarMargin = 2.0,
    this.fadeScrollbars = true,
    this.onScrollStart,
    this.onScrollUpdate,
    this.onScrollEnd,
    this.enableOverscroll = true,
    this.overscrollColor,
  });

  final Widget child;
  final Axis scrollDirection;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool showScrollbar;
  final double scrollbarThickness;
  final double scrollbarRadius;
  final double scrollbarMargin;
  final bool fadeScrollbars;
  final VoidCallback? onScrollStart;
  final VoidCallback? onScrollUpdate;
  final VoidCallback? onScrollEnd;
  final bool enableOverscroll;
  final Color? overscrollColor;

  @override
  State<AppScrollArea> createState() => _AppScrollAreaState();
}

class _AppScrollAreaState extends State<AppScrollArea> {
  late ScrollController _controller;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (!_isScrolling) {
      _isScrolling = true;
      widget.onScrollStart?.call();
    }
    widget.onScrollUpdate?.call();

    // Debounce scroll end detection
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_controller.hasClients &&
          !_controller.position.isScrollingNotifier.value) {
        if (_isScrolling) {
          _isScrolling = false;
          widget.onScrollEnd?.call();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget scrollView = SingleChildScrollView(
      scrollDirection: widget.scrollDirection,
      controller: _controller,
      physics: widget.physics ?? const BouncingScrollPhysics(),
      padding: widget.padding,
      child: widget.child,
    );

    // Add overscroll indicator if enabled
    if (widget.enableOverscroll) {
      scrollView = GlowingOverscrollIndicator(
        axisDirection: widget.scrollDirection == Axis.vertical
            ? AxisDirection.down
            : AxisDirection.right,
        color: widget.overscrollColor ??
            theme.colorScheme.primary.withValues(alpha: 0.3),
        child: scrollView,
      );
    } else {
      scrollView = ScrollConfiguration(
        behavior: const _NoOverscrollBehavior(),
        child: scrollView,
      );
    }

    // Add scrollbar if enabled
    if (widget.showScrollbar) {
      if (widget.scrollDirection == Axis.vertical) {
        scrollView = Scrollbar(
          controller: _controller,
          thickness: widget.scrollbarThickness,
          radius: Radius.circular(widget.scrollbarRadius),
          thumbVisibility: !widget.fadeScrollbars,
          trackVisibility: false,
          child: scrollView,
        );
      } else {
        scrollView = Scrollbar(
          controller: _controller,
          thickness: widget.scrollbarThickness,
          radius: Radius.circular(widget.scrollbarRadius),
          thumbVisibility: !widget.fadeScrollbars,
          trackVisibility: false,
          notificationPredicate: (notification) => notification.depth == 0,
          child: scrollView,
        );
      }
    }

    return scrollView;
  }
}

/// AppInfiniteScrollArea - Scroll area with infinite loading capability
class AppInfiniteScrollArea extends StatefulWidget {
  const AppInfiniteScrollArea({
    required this.itemBuilder,
    required this.itemCount,
    super.key,
    this.onLoadMore,
    this.hasMore = true,
    this.loadingWidget,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.physics,
    this.padding,
    this.loadThreshold = 200.0,
    this.separatorBuilder,
  });

  final Widget Function(BuildContext context, int index) itemBuilder;
  final int itemCount;
  final Future<void> Function()? onLoadMore;
  final bool hasMore;
  final Widget? loadingWidget;
  final Axis scrollDirection;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final double loadThreshold;
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  @override
  State<AppInfiniteScrollArea> createState() => _AppInfiniteScrollAreaState();
}

class _AppInfiniteScrollAreaState extends State<AppInfiniteScrollArea> {
  late ScrollController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (_isLoading || !widget.hasMore || widget.onLoadMore == null) return;

    final maxScroll = _controller.position.maxScrollExtent;
    final currentScroll = _controller.position.pixels;

    if (maxScroll - currentScroll <= widget.loadThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onLoadMore?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      scrollDirection: widget.scrollDirection,
      controller: _controller,
      physics: widget.physics,
      padding: widget.padding,
      itemCount: widget.itemCount + (widget.hasMore ? 1 : 0),
      separatorBuilder: widget.separatorBuilder ??
          (context, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        if (index < widget.itemCount) {
          return widget.itemBuilder(context, index);
        } else {
          // Loading indicator
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            alignment: Alignment.center,
            child: widget.loadingWidget ??
                CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
          );
        }
      },
    );
  }
}

/// AppVirtualScrollArea - Virtualized scroll area for large datasets
class AppVirtualScrollArea extends StatelessWidget {
  const AppVirtualScrollArea({
    required this.itemBuilder,
    required this.itemCount,
    super.key,
    this.itemExtent,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.physics,
    this.padding,
    this.cacheExtent,
  });

  final Widget Function(BuildContext context, int index) itemBuilder;
  final int itemCount;
  final double? itemExtent;
  final Axis scrollDirection;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final double? cacheExtent;

  @override
  Widget build(BuildContext context) {
    if (itemExtent != null) {
      return ListView.builder(
        scrollDirection: scrollDirection,
        controller: controller,
        physics: physics,
        padding: padding,
        itemCount: itemCount,
        itemExtent: itemExtent,
        cacheExtent: cacheExtent,
        itemBuilder: itemBuilder,
      );
    } else {
      return ListView.builder(
        scrollDirection: scrollDirection,
        controller: controller,
        physics: physics,
        padding: padding,
        itemCount: itemCount,
        cacheExtent: cacheExtent,
        itemBuilder: itemBuilder,
      );
    }
  }
}

/// AppStickyScrollArea - Scroll area with sticky headers
class AppStickyScrollArea extends StatelessWidget {
  const AppStickyScrollArea({
    required this.slivers,
    super.key,
    this.controller,
    this.physics,
  });

  final List<Widget> slivers;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      physics: physics,
      slivers: slivers,
    );
  }
}

/// AppNestedScrollArea - Scroll area that handles nested scrolling
class AppNestedScrollArea extends StatelessWidget {
  const AppNestedScrollArea({
    required this.headerSliverBuilder,
    required this.body,
    super.key,
    this.controller,
    this.physics,
  });

  final List<Widget> Function(BuildContext context, bool innerBoxIsScrolled)
      headerSliverBuilder;
  final Widget body;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      controller: controller,
      physics: physics,
      headerSliverBuilder: headerSliverBuilder,
      body: body,
    );
  }
}

/// Custom scroll behavior that removes overscroll glow
class _NoOverscrollBehavior extends ScrollBehavior {
  const _NoOverscrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

/// Scroll physics that provides custom bounce behavior
class AppBouncyScrollPhysics extends BouncingScrollPhysics {
  const AppBouncyScrollPhysics({
    super.parent,
    this.bounciness = 0.5,
  });

  final double bounciness;

  @override
  AppBouncyScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return AppBouncyScrollPhysics(
      parent: buildParent(ancestor),
      bounciness: bounciness,
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    }
    if (position.maxScrollExtent <= position.pixels &&
        position.pixels < value) {
      return value - position.pixels;
    }
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) {
      return (value - position.minScrollExtent) * bounciness;
    }
    if (position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent < value) {
      return (value - position.maxScrollExtent) * bounciness;
    }
    return 0.0;
  }
}

/// Scroll physics that snaps to specific positions
class AppSnapScrollPhysics extends ScrollPhysics {
  const AppSnapScrollPhysics({
    required this.snapPositions,
    super.parent,
  });

  final List<double> snapPositions;

  @override
  AppSnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return AppSnapScrollPhysics(
      parent: buildParent(ancestor),
      snapPositions: snapPositions,
    );
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Find the closest snap position
    var targetPosition = position.pixels;
    var minDistance = double.infinity;

    for (final snapPos in snapPositions) {
      final distance = (snapPos - position.pixels).abs();
      if (distance < minDistance) {
        minDistance = distance;
        targetPosition = snapPos;
      }
    }

    // Clamp to scroll bounds
    targetPosition = targetPosition.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    if (targetPosition != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        targetPosition,
        velocity,
        tolerance: toleranceFor(position),
      );
    }

    return super.createBallisticSimulation(position, velocity);
  }
}
