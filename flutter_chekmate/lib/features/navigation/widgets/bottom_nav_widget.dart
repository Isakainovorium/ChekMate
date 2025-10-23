import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/shared/ui/animations/micro_interactions.dart';
import 'package:flutter_chekmate/shared/ui/animations/tiktok_animations.dart';

/// Bottom navigation bar - converted from BottomNavigation.tsx
///
/// Features:
/// - 5 navigation items (Home, Messages, Create, Notifications, Profile)
/// - Active state highlighting
/// - Special styling for Create button (golden circle)
/// - Profile avatar in nav
/// - Pulsing badge on notification icon when unread
class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({
    required this.currentIndex,
    required this.onTap,
    super.key,
    this.profileAvatarUrl,
    this.unreadNotificationCount = 0,
  });

  final int currentIndex;
  final void Function(int) onTap;
  final String? profileAvatarUrl;
  final int unreadNotificationCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home,
                label: 'Home',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.chat_bubble_outline,
                label: 'Messages',
              ),
              _buildCreateButton(),
              _buildNotificationNavItem(),
              _buildProfileNavItem(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                size: 24,
                color: isActive ? AppColors.primary : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return InkWell(
      onTap: () => onTap(2),
      borderRadius: BorderRadius.circular(20),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.95, end: 1.0),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: scale > 0.97 ? 2 : 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
          );
        },
      ).scaleIn(),
    );
  }

  Widget _buildNotificationNavItem() {
    final isActive = currentIndex == 3;

    return InkWell(
      onTap: () => onTap(3),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Icon(
                Icons.notifications_outlined,
                size: 24,
                color: isActive ? AppColors.primary : Colors.grey.shade600,
              ),
            ),
            // Pulsing badge for unread notifications
            if (unreadNotificationCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: PulsingBadge(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      unreadNotificationCount > 9
                          ? '9+'
                          : '$unreadNotificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileNavItem() {
    final isActive = currentIndex == 4;

    return InkWell(
      onTap: () => onTap(4),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.primary : Colors.grey.shade600,
              width: 2,
            ),
          ),
          child: ClipOval(
            child: profileAvatarUrl != null
                ? Image.network(
                    profileAvatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: 16,
                        color:
                            isActive ? AppColors.primary : Colors.grey.shade600,
                      );
                    },
                  )
                : Icon(
                    Icons.person,
                    size: 16,
                    color: isActive ? AppColors.primary : Colors.grey.shade600,
                  ),
          ),
        ),
      ),
    );
  }
}
