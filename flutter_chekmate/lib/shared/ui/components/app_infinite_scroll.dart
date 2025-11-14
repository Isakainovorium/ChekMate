import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppInfiniteScroll - Infinite scrolling container with loading
class AppInfiniteScroll<T> extends StatefulWidget {
  const AppInfiniteScroll({
    required this.items, required this.itemBuilder, required this.onLoadMore, super.key,
    this.hasMore = true,
    this.isLoading = false,
    this.loadThreshold = 200.0,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.physics,
    this.padding,
    this.separatorBuilder,
    this.onItemTap,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.hasError = false,
    this.onRefresh,
    this.refreshIndicatorColor,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final double loadThreshold;
  final Axis scrollDirection;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final ValueChanged<T>? onItemTap;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final bool hasError;
  final Future<void> Function()? onRefresh;
  final Color? refreshIndicatorColor;

  @override
  State<AppInfiniteScroll<T>> createState() => _AppInfiniteScrollState<T>();
}

class _AppInfiniteScrollState<T> extends State<AppInfiniteScroll<T>> {
  late ScrollController _controller;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !widget.hasMore || widget.hasError) return;

    final maxScroll = _controller.position.maxScrollExtent;
    final currentScroll = _controller.position.pixels;
    
    if (maxScroll - currentScroll <= widget.loadThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      await widget.onLoadMore();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Widget _buildContent() {
    // Handle error state
    if (widget.hasError && widget.items.isEmpty) {
      return widget.errorBuilder?.call(context, 'Error loading data') ??
          _DefaultErrorWidget(
            onRetry: widget.onLoadMore,
          );
    }

    // Handle empty state
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyBuilder?.call(context) ??
          _DefaultEmptyWidget();
    }

    // Handle loading state for initial load
    if (widget.items.isEmpty && widget.isLoading) {
      return widget.loadingBuilder?.call(context) ??
          const Center(child: CircularProgressIndicator());
    }

    // Build list with infinite scroll
    return _buildList();
  }

  Widget _buildList() {
    final itemCount = widget.items.length + (widget.hasMore ? 1 : 0);

    if (widget.separatorBuilder != null) {
      return ListView.separated(
        controller: _controller,
        scrollDirection: widget.scrollDirection,
        physics: widget.physics,
        padding: widget.padding,
        itemCount: itemCount,
        separatorBuilder: (context, index) {
          if (index < widget.items.length - 1) {
            return widget.separatorBuilder!(context, index);
          }
          return const SizedBox.shrink();
        },
        itemBuilder: (context, index) => _buildItem(context, index),
      );
    } else {
      return ListView.builder(
        controller: _controller,
        scrollDirection: widget.scrollDirection,
        physics: widget.physics,
        padding: widget.padding,
        itemCount: itemCount,
        itemBuilder: (context, index) => _buildItem(context, index),
      );
    }
  }

  Widget _buildItem(BuildContext context, int index) {
    if (index < widget.items.length) {
      // Regular item
      final item = widget.items[index];
      return GestureDetector(
        onTap: widget.onItemTap != null ? () => widget.onItemTap!(item) : null,
        child: widget.itemBuilder(context, item, index),
      );
    } else {
      // Loading indicator at the end
      return _LoadingIndicator(
        isLoading: _isLoadingMore || widget.isLoading,
        hasError: widget.hasError,
        onRetry: widget.onLoadMore,
        loadingBuilder: widget.loadingBuilder,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        color: widget.refreshIndicatorColor,
        child: _buildContent(),
      );
    } else {
      return _buildContent();
    }
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
    this.loadingBuilder,
  });

  final bool isLoading;
  final bool hasError;
  final Future<void> Function() onRetry;
  final Widget Function(BuildContext context)? loadingBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (hasError) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Failed to load more',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        alignment: Alignment.center,
        child: loadingBuilder?.call(context) ??
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _DefaultEmptyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No items to display',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Pull down to refresh or check back later',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultErrorWidget extends StatelessWidget {
  const _DefaultErrorWidget({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Something went wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Unable to load content. Please check your connection and try again.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// AppInfiniteGrid - Infinite scrolling grid
class AppInfiniteGrid<T> extends StatefulWidget {
  const AppInfiniteGrid({
    required this.items, required this.itemBuilder, required this.onLoadMore, required this.crossAxisCount, super.key,
    this.hasMore = true,
    this.isLoading = false,
    this.loadThreshold = 200.0,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.controller,
    this.physics,
    this.padding,
    this.onItemTap,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.hasError = false,
    this.onRefresh,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onLoadMore;
  final int crossAxisCount;
  final bool hasMore;
  final bool isLoading;
  final double loadThreshold;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<T>? onItemTap;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final bool hasError;
  final Future<void> Function()? onRefresh;

  @override
  State<AppInfiniteGrid<T>> createState() => _AppInfiniteGridState<T>();
}

class _AppInfiniteGridState<T> extends State<AppInfiniteGrid<T>> {
  late ScrollController _controller;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !widget.hasMore || widget.hasError) return;

    final maxScroll = _controller.position.maxScrollExtent;
    final currentScroll = _controller.position.pixels;
    
    if (maxScroll - currentScroll <= widget.loadThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      await widget.onLoadMore();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Widget _buildContent() {
    // Handle error state
    if (widget.hasError && widget.items.isEmpty) {
      return widget.errorBuilder?.call(context, 'Error loading data') ??
          _DefaultErrorWidget(onRetry: widget.onLoadMore);
    }

    // Handle empty state
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyBuilder?.call(context) ??
          _DefaultEmptyWidget();
    }

    // Handle loading state for initial load
    if (widget.items.isEmpty && widget.isLoading) {
      return widget.loadingBuilder?.call(context) ??
          const Center(child: CircularProgressIndicator());
    }

    // Calculate items including loading indicator
    final totalItems = widget.items.length + (widget.hasMore ? widget.crossAxisCount : 0);

    return GridView.builder(
      controller: _controller,
      physics: widget.physics,
      padding: widget.padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        if (index < widget.items.length) {
          // Regular item
          final item = widget.items[index];
          return GestureDetector(
            onTap: widget.onItemTap != null ? () => widget.onItemTap!(item) : null,
            child: widget.itemBuilder(context, item, index),
          );
        } else {
          // Loading indicator (spans full width)
          if (index == widget.items.length) {
            return _LoadingIndicator(
              isLoading: _isLoadingMore || widget.isLoading,
              hasError: widget.hasError,
              onRetry: widget.onLoadMore,
              loadingBuilder: widget.loadingBuilder,
            );
          } else {
            // Empty cells to complete the row
            return const SizedBox.shrink();
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: _buildContent(),
      );
    } else {
      return _buildContent();
    }
  }
}

/// AppInfiniteSliver - Infinite scrolling as a sliver
class AppInfiniteSliver<T> extends StatefulWidget {
  const AppInfiniteSliver({
    required this.items, required this.itemBuilder, required this.onLoadMore, super.key,
    this.hasMore = true,
    this.isLoading = false,
    this.loadThreshold = 200.0,
    this.onItemTap,
    this.loadingBuilder,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final double loadThreshold;
  final ValueChanged<T>? onItemTap;
  final Widget Function(BuildContext context)? loadingBuilder;

  @override
  State<AppInfiniteSliver<T>> createState() => _AppInfiniteSliverState<T>();
}

class _AppInfiniteSliverState<T> extends State<AppInfiniteSliver<T>> {
  bool _isLoadingMore = false;

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      await widget.onLoadMore();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.items.length + (widget.hasMore ? 1 : 0);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < widget.items.length) {
            // Regular item
            final item = widget.items[index];
            
            // Check if we need to load more
            if (index >= widget.items.length - 3 && widget.hasMore && !_isLoadingMore) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
            }
            
            return GestureDetector(
              onTap: widget.onItemTap != null ? () => widget.onItemTap!(item) : null,
              child: widget.itemBuilder(context, item, index),
            );
          } else {
            // Loading indicator
            return _LoadingIndicator(
              isLoading: _isLoadingMore || widget.isLoading,
              hasError: false,
              onRetry: widget.onLoadMore,
              loadingBuilder: widget.loadingBuilder,
            );
          }
        },
        childCount: itemCount,
      ),
    );
  }
}
