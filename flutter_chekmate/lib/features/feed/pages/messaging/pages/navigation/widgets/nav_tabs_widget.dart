import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// Horizontal tab navigation - converted from NavigationTabs.tsx
///
/// Features:
/// - Tabs: For you, Following, Explore, Live, Rate Date, Subscribe
/// - Active tab highlighting
/// - Horizontal scrolling
class NavTabsWidget extends StatelessWidget {
  const NavTabsWidget({
    required this.activeTab,
    required this.onTabChanged,
    super.key,
  });
  final String activeTab;
  final void Function(String) onTabChanged;

  static const List<String> tabs = [
    'For you',
    'Following',
    'Explore',
    'Live',
    'Rate Date',
    'Subscribe',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: tabs.map((tab) => _buildTab(tab)).toList(),
        ),
      ),
    );
  }

  Widget _buildTab(String tab) {
    final isActive = activeTab == tab;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: GestureDetector(
        onTap: () => onTabChanged(tab),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tab,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? Colors.black : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 3,
              width: tab.length * 8.0,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
