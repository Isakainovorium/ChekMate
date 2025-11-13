import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppVirtualizedList - Performance-optimized large lists
class AppVirtualizedList<T> extends StatefulWidget {
  const AppVirtualizedList({
    required this.items, required this.itemBuilder, super.key,
    this.itemExtent,
    this.estimatedItemExtent = 50.0,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.physics,
    this.padding,
    this.cacheExtent,
    this.separatorBuilder,
    this.onItemTap,
    this.emptyBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.isLoading = false,
    this.hasError = false,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final double? itemExtent;
  final double estimatedItemExtent;
  final Axis scrollDirection;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final double? cacheExtent;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final ValueChanged<T>? onItemTap;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final bool isLoading;
  final bool hasError;

  @override
  State<AppVirtualizedList<T>> createState() => _AppVirtualizedListState<T>();
}

class _AppVirtualizedListState<T> extends State<AppVirtualizedList<T>> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Handle loading state
    if (widget.isLoading && widget.items.isEmpty) {
      return widget.loadingBuilder?.call(context) ?? 
          const Center(child: CircularProgressIndicator());
    }

    // Handle error state
    if (widget.hasError) {
      return widget.errorBuilder?.call(context, 'Error loading data') ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Error loading data',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          );
    }

    // Handle empty state
    if (widget.items.isEmpty) {
      return widget.emptyBuilder?.call(context) ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No items to display',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
    }

    // Build virtualized list
    if (widget.separatorBuilder != null) {
      return ListView.separated(
        controller: _controller,
        scrollDirection: widget.scrollDirection,
        physics: widget.physics,
        padding: widget.padding,
        cacheExtent: widget.cacheExtent,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return GestureDetector(
            onTap: widget.onItemTap != null ? () => widget.onItemTap!(item) : null,
            child: widget.itemBuilder(context, item, index),
          );
        },
        separatorBuilder: widget.separatorBuilder!,
      );
    } else if (widget.itemExtent != null) {
      return ListView.builder(
        controller: _controller,
        scrollDirection: widget.scrollDirection,
        physics: widget.physics,
        padding: widget.padding,
        cacheExtent: widget.cacheExtent,
        itemCount: widget.items.length,
        itemExtent: widget.itemExtent,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return GestureDetector(
            onTap: widget.onItemTap != null ? () => widget.onItemTap!(item) : null,
            child: widget.itemBuilder(context, item, index),
          );
        },
      );
    } else {
      return ListView.builder(
        controller: _controller,
        scrollDirection: widget.scrollDirection,
        physics: widget.physics,
        padding: widget.padding,
        cacheExtent: widget.cacheExtent,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return GestureDetector(
            onTap: widget.onItemTap != null ? () => widget.onItemTap!(item) : null,
            child: widget.itemBuilder(context, item, index),
          );
        },
      );
    }
  }
}

/// AppGridVirtualizedList - Virtualized grid list
class AppGridVirtualizedList<T> extends StatefulWidget {
  const AppGridVirtualizedList({
    required this.items, required this.itemBuilder, required this.crossAxisCount, super.key,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.physics,
    this.padding,
    this.cacheExtent,
    this.onItemTap,
    this.emptyBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.isLoading = false,
    this.hasError = false,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final Axis scrollDirection;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final double? cacheExtent;
  final ValueChanged<T>? onItemTap;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final bool isLoading;
  final bool hasError;

  @override
  State<AppGridVirtualizedList<T>> createState() => _AppGridVirtualizedListState<T>();
}

class _AppGridVirtualizedListState<T> extends State<AppGridVirtualizedList<T>> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Handle loading state
    if (widget.isLoading && widget.items.isEmpty) {
      return widget.loadingBuilder?.call(context) ?? 
          const Center(child: CircularProgressIndicator());
    }

    // Handle error state
    if (widget.hasError) {
      return widget.errorBuilder?.call(context, 'Error loading data') ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Error loading data',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          );
    }

    // Handle empty state
    if (widget.items.isEmpty) {
      return widget.emptyBuilder?.call(context) ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.grid_view_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No items to display',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
    }

    return GridView.builder(
      controller: _controller,
      scrollDirection: widget.scrollDirection,
      physics: widget.physics,
      padding: widget.padding,
      cacheExtent: widget.cacheExtent,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        return GestureDetector(
          onTap: widget.onItemTap != null ? () => widget.onItemTap!(item) : null,
          child: widget.itemBuilder(context, item, index),
        );
      },
    );
  }
}

/// AppSliverVirtualizedList - Virtualized list as a sliver
class AppSliverVirtualizedList<T> extends StatelessWidget {
  const AppSliverVirtualizedList({
    required this.items, required this.itemBuilder, super.key,
    this.itemExtent,
    this.separatorBuilder,
    this.onItemTap,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final double? itemExtent;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final ValueChanged<T>? onItemTap;

  @override
  Widget build(BuildContext context) {
    if (separatorBuilder != null) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final itemIndex = index ~/ 2;
            if (index.isEven) {
              // Item
              final item = items[itemIndex];
              return GestureDetector(
                onTap: onItemTap != null ? () => onItemTap!(item) : null,
                child: itemBuilder(context, item, itemIndex),
              );
            } else {
              // Separator
              return separatorBuilder!(context, itemIndex);
            }
          },
          childCount: items.length * 2 - 1,
        ),
      );
    } else if (itemExtent != null) {
      return SliverFixedExtentList(
        itemExtent: itemExtent!,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: onItemTap != null ? () => onItemTap!(item) : null,
              child: itemBuilder(context, item, index),
            );
          },
          childCount: items.length,
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: onItemTap != null ? () => onItemTap!(item) : null,
              child: itemBuilder(context, item, index),
            );
          },
          childCount: items.length,
        ),
      );
    }
  }
}

/// AppPagedVirtualizedList - Virtualized list with pagination
class AppPagedVirtualizedList<T> extends StatefulWidget {
  const AppPagedVirtualizedList({
    required this.items, required this.itemBuilder, required this.onLoadMore, super.key,
    this.hasMore = true,
    this.isLoading = false,
    this.loadThreshold = 3,
    this.itemExtent,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.physics,
    this.padding,
    this.separatorBuilder,
    this.onItemTap,
    this.loadingBuilder,
    this.emptyBuilder,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final int loadThreshold;
  final double? itemExtent;
  final Axis scrollDirection;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final ValueChanged<T>? onItemTap;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;

  @override
  State<AppPagedVirtualizedList<T>> createState() => _AppPagedVirtualizedListState<T>();
}

class _AppPagedVirtualizedListState<T> extends State<AppPagedVirtualizedList<T>> {
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
    if (_isLoadingMore || !widget.hasMore) return;

    final itemsFromEnd = widget.items.length - 
        (_controller.position.maxScrollExtent > 0 
            ? (_controller.offset / _controller.position.maxScrollExtent * widget.items.length).floor()
            : 0);

    if (itemsFromEnd <= widget.loadThreshold) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyBuilder?.call(context) ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No items to display',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
    }

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
        itemBuilder: (context, index) {
          if (index < widget.items.length) {
            final item = widget.items[index];
            return GestureDetector(
              onTap: widget.onItemTap != null ? () => widget.onItemTap!(item) : null,
              child: widget.itemBuilder(context, item, index),
            );
          } else {
            // Loading indicator
            return Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              alignment: Alignment.center,
              child: widget.loadingBuilder?.call(context) ??
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
            );
          }
        },
      );
    } else {
      return ListView.builder(
        controller: _controller,
        scrollDirection: widget.scrollDirection,
        physics: widget.physics,
        padding: widget.padding,
        itemCount: itemCount,
        itemExtent: widget.itemExtent,
        itemBuilder: (context, index) {
          if (index < widget.items.length) {
            final item = widget.items[index];
            return GestureDetector(
              onTap: widget.onItemTap != null ? () => widget.onItemTap!(item) : null,
              child: widget.itemBuilder(context, item, index),
            );
          } else {
            // Loading indicator
            return Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              alignment: Alignment.center,
              child: widget.loadingBuilder?.call(context) ??
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
            );
          }
        },
      );
    }
  }
}
