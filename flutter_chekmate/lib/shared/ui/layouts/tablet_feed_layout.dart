import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_breakpoints.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// Tablet-Optimized Feed Layout
///
/// Displays feed content in a 2-column grid on tablets and larger screens,
/// while maintaining single-column layout on mobile devices.
///
/// Sprint 3 - Task 3.4.1
/// Date: November 28, 2025

class TabletFeedLayout extends StatelessWidget {
  const TabletFeedLayout({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.controller,
    this.padding,
    this.onRefresh,
    this.emptyWidget,
    this.headerWidget,
  });

  /// Total number of items in the feed
  final int itemCount;

  /// Builder for each feed item
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Optional scroll controller
  final ScrollController? controller;

  /// Padding around the grid
  final EdgeInsets? padding;

  /// Pull-to-refresh callback
  final Future<void> Function()? onRefresh;

  /// Widget to show when feed is empty
  final Widget? emptyWidget;

  /// Optional header widget (shown above the grid)
  final Widget? headerWidget;

  @override
  Widget build(BuildContext context) {
    // Use responsive builder to switch between layouts
    return ResponsiveBuilder(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  /// Single-column layout for mobile
  Widget _buildMobileLayout(BuildContext context) {
    if (itemCount == 0 && emptyWidget != null) {
      return emptyWidget!;
    }

    Widget list = ListView.builder(
      controller: controller,
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      itemCount: itemCount + (headerWidget != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (headerWidget != null && index == 0) {
          return headerWidget!;
        }
        final itemIndex = headerWidget != null ? index - 1 : index;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: itemBuilder(context, itemIndex),
        );
      },
    );

    if (onRefresh != null) {
      list = RefreshIndicator(
        onRefresh: onRefresh!,
        child: list,
      );
    }

    return list;
  }

  /// 2-column grid layout for tablets
  Widget _buildTabletLayout(BuildContext context) {
    if (itemCount == 0 && emptyWidget != null) {
      return emptyWidget!;
    }

    Widget content = CustomScrollView(
      controller: controller,
      slivers: [
        // Optional header
        if (headerWidget != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: padding ?? const EdgeInsets.all(AppSpacing.md),
              child: headerWidget,
            ),
          ),

        // 2-column grid
        SliverPadding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.75, // Adjust based on post card design
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => itemBuilder(context, index),
              childCount: itemCount,
            ),
          ),
        ),
      ],
    );

    if (onRefresh != null) {
      content = RefreshIndicator(
        onRefresh: onRefresh!,
        child: content,
      );
    }

    return content;
  }

  /// 3-column grid layout for desktop
  Widget _buildDesktopLayout(BuildContext context) {
    if (itemCount == 0 && emptyWidget != null) {
      return Center(child: emptyWidget);
    }

    Widget content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: CustomScrollView(
          controller: controller,
          slivers: [
            // Optional header
            if (headerWidget != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
                  child: headerWidget,
                ),
              ),

            // 3-column grid
            SliverPadding(
              padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSpacing.lg,
                  crossAxisSpacing: AppSpacing.lg,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => itemBuilder(context, index),
                  childCount: itemCount,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (onRefresh != null) {
      content = RefreshIndicator(
        onRefresh: onRefresh!,
        child: content,
      );
    }

    return content;
  }
}

/// Tablet-optimized post card wrapper
/// Adjusts post card styling for grid layouts
class TabletPostCard extends StatelessWidget {
  const TabletPostCard({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isTabletOrLarger = !AppBreakpoints.isMobile(context);

    if (!isTabletOrLarger) {
      return child;
    }

    // Add card styling for tablet grid
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
