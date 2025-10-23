import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/shared/widgets/cached_image.dart';

enum AvatarSize { small, medium, large, extraLarge }

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    this.imageUrl,
    this.name,
    this.size = AvatarSize.medium,
    this.showBadge = false,
    this.badgeColor,
    this.onTap,
    super.key,
  });
  final String? imageUrl;
  final String? name;
  final AvatarSize size;
  final bool showBadge;
  final Color? badgeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatarSize = _getSize();
    final badgeSize = avatarSize * 0.25;

    Widget avatar = imageUrl != null
        ? CircularCachedImage(
            imageUrl: imageUrl!,
            size: avatarSize,
          )
        : CircleAvatar(
            radius: avatarSize / 2,
            backgroundColor: AppColors.surfaceVariant,
            child: Text(
              _getInitials(),
              style: TextStyle(
                fontSize: avatarSize * 0.4,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          );

    if (showBadge) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: badgeColor ?? AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surface,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      avatar = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(avatarSize / 2),
        child: avatar,
      );
    }

    return SizedBox(
      width: avatarSize,
      height: avatarSize,
      child: avatar,
    );
  }

  double _getSize() {
    switch (size) {
      case AvatarSize.small:
        return 32;
      case AvatarSize.medium:
        return 40;
      case AvatarSize.large:
        return 56;
      case AvatarSize.extraLarge:
        return 80;
    }
  }

  String _getInitials() {
    if (name == null || name!.isEmpty) return '?';

    final parts = name!.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name![0].toUpperCase();
  }
}

class StoryAvatar extends StatelessWidget {
  const StoryAvatar({
    required this.imageUrl,
    required this.name,
    this.hasStory = false,
    this.isViewed = false,
    this.onTap,
    super.key,
  });
  final String imageUrl;
  final String name;
  final bool hasStory;
  final bool isViewed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasStory && !isViewed
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    )
                  : null,
              border: hasStory && isViewed
                  ? Border.all(color: AppColors.border, width: 2)
                  : null,
            ),
            child: CircularCachedImage(
              imageUrl: imageUrl,
              size: 56,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 64,
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.icon,
    super.key,
  });
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: textColor ?? AppColors.primary,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
