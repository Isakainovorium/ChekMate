import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_breakpoints.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// Tablet-Optimized Messages Layout
///
/// Displays a master-detail layout on tablets with conversation list
/// on the left and chat view on the right. Falls back to single-pane
/// navigation on mobile.
///
/// Sprint 3 - Task 3.4.2
/// Date: November 28, 2025

class TabletMessagesLayout extends StatelessWidget {
  const TabletMessagesLayout({
    required this.conversationList,
    required this.chatView,
    super.key,
    this.selectedConversationId,
    this.emptyStateWidget,
    this.listWidth = 350,
  });

  /// Widget displaying the list of conversations
  final Widget conversationList;

  /// Widget displaying the current chat
  final Widget chatView;

  /// Currently selected conversation ID (for highlighting)
  final String? selectedConversationId;

  /// Widget to show when no conversation is selected
  final Widget? emptyStateWidget;

  /// Width of the conversation list panel on tablet
  final double listWidth;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: conversationList, // On mobile, just show the list
      tablet: _buildMasterDetailLayout(context),
      desktop: _buildMasterDetailLayout(context),
    );
  }

  Widget _buildMasterDetailLayout(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // Conversation list (master)
        SizedBox(
          width: listWidth,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                  width: 1,
                ),
              ),
            ),
            child: conversationList,
          ),
        ),

        // Chat view (detail)
        Expanded(
          child: selectedConversationId != null
              ? chatView
              : _buildEmptyState(context),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    if (emptyStateWidget != null) {
      return emptyStateWidget!;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Select a conversation',
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Choose a conversation from the list to start chatting',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Conversation list item with tablet-aware selection state
class TabletConversationTile extends StatelessWidget {
  const TabletConversationTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
    this.avatar,
    this.isSelected = false,
    this.unreadCount = 0,
    this.timestamp,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? avatar;
  final bool isSelected;
  final int unreadCount;
  final String? timestamp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTabletOrLarger = !AppBreakpoints.isMobile(context);

    return Material(
      color: isSelected && isTabletOrLarger
          ? (isDark
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.primary.withOpacity(0.1))
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isSelected && isTabletOrLarger
                    ? AppColors.primary
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              // Avatar
              if (avatar != null) ...[
                avatar!,
                const SizedBox(width: AppSpacing.md),
              ],

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (timestamp != null)
                          Text(
                            timestamp!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              fontWeight: unreadCount > 0
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
