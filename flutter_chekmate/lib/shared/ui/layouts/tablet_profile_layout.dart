import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_breakpoints.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// Tablet-Optimized Profile Layout
///
/// Displays profile content with a wider content area on tablets,
/// with stats in a sidebar. Falls back to standard vertical layout
/// on mobile devices.
///
/// Sprint 3 - Task 3.4.3
/// Date: November 28, 2025

class TabletProfileLayout extends StatelessWidget {
  const TabletProfileLayout({
    required this.header,
    required this.content,
    super.key,
    this.sidebar,
    this.sidebarWidth = 300,
    this.maxContentWidth = 800,
  });

  /// Profile header (cover photo, avatar, name, bio)
  final Widget header;

  /// Main content area (posts, media, etc.)
  final Widget content;

  /// Optional sidebar widget (stats, quick actions)
  final Widget? sidebar;

  /// Width of the sidebar on tablet/desktop
  final double sidebarWidth;

  /// Maximum width of the content area
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  /// Standard vertical layout for mobile
  Widget _buildMobileLayout(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: header),
        SliverFillRemaining(child: content),
      ],
    );
  }

  /// Two-column layout for tablets
  Widget _buildTabletLayout(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main content
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: header),
              SliverFillRemaining(child: content),
            ],
          ),
        ),

        // Sidebar (if provided)
        if (sidebar != null)
          Container(
            width: sidebarWidth,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                  width: 1,
                ),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: sidebar,
            ),
          ),
      ],
    );
  }

  /// Centered layout with max width for desktop
  Widget _buildDesktopLayout(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxContentWidth + (sidebar != null ? sidebarWidth : 0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: header),
                  SliverFillRemaining(child: content),
                ],
              ),
            ),

            // Sidebar (if provided)
            if (sidebar != null)
              Container(
                width: sidebarWidth,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: isDark ? AppColors.dividerDark : AppColors.divider,
                      width: 1,
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: sidebar,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Profile sidebar widget with stats and quick actions
class ProfileSidebar extends StatelessWidget {
  const ProfileSidebar({
    super.key,
    this.stats,
    this.quickActions,
    this.additionalContent,
  });

  /// Stats to display (posts, followers, following)
  final List<ProfileStat>? stats;

  /// Quick action buttons
  final List<Widget>? quickActions;

  /// Additional content widgets
  final List<Widget>? additionalContent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // isDark available for future theme-specific styling in sidebar

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats section
        if (stats != null && stats!.isNotEmpty) ...[
          Text(
            'Stats',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...stats!.map((stat) => _buildStatRow(context, stat)),
          const SizedBox(height: AppSpacing.xl),
        ],

        // Quick actions section
        if (quickActions != null && quickActions!.isNotEmpty) ...[
          Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...quickActions!.map((action) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: action,
              )),
          const SizedBox(height: AppSpacing.xl),
        ],

        // Additional content
        if (additionalContent != null) ...additionalContent!,
      ],
    );
  }

  Widget _buildStatRow(BuildContext context, ProfileStat stat) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                stat.icon,
                size: 20,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                stat.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            stat.value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile stat data class
class ProfileStat {
  const ProfileStat({
    required this.label,
    required this.value,
    this.icon = Icons.analytics_outlined,
  });

  final String label;
  final String value;
  final IconData icon;
}
