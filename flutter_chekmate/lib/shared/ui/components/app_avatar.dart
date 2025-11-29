import 'package:flutter/material.dart';

/// AppAvatar - User avatar with consistent styling and fallbacks
///
/// Sprint 1 - Task 1.1.4: Added semantic accessibility support
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppAvatarSize.medium,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2.0,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  });

  final String? imageUrl;
  final String? name;
  final AppAvatarSize size;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  
  /// Custom semantic label for screen readers (defaults to name)
  final String? semanticLabel;
  
  /// Whether to exclude this avatar from the accessibility tree (decorative)
  final bool excludeFromSemantics;

  double get _radius => switch (size) {
        AppAvatarSize.small => 16,
        AppAvatarSize.medium => 24,
        AppAvatarSize.large => 32,
        AppAvatarSize.extraLarge => 48,
      };

  double get _fontSize => switch (size) {
        AppAvatarSize.small => 12,
        AppAvatarSize.medium => 16,
        AppAvatarSize.large => 20,
        AppAvatarSize.extraLarge => 28,
      };

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name![0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValidImageUrl = imageUrl != null && imageUrl!.isNotEmpty;

    Widget avatar = CircleAvatar(
      radius: _radius,
      backgroundColor: backgroundColor ?? theme.colorScheme.primaryContainer,
      backgroundImage: hasValidImageUrl ? NetworkImage(imageUrl!) : null,
      child: !hasValidImageUrl
          ? Text(
              _initials,
              style: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.w600,
                color: textColor ?? theme.colorScheme.onPrimaryContainer,
              ),
            )
          : null,
    );

    if (showBorder) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? theme.colorScheme.outline,
            width: borderWidth,
          ),
        ),
        child: avatar,
      );
    }

    if (onTap != null) {
      avatar = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius + borderWidth),
        child: avatar,
      );
    }

    // Apply semantics
    if (excludeFromSemantics) {
      return ExcludeSemantics(child: avatar);
    }

    final label = semanticLabel ?? (name != null ? '$name avatar' : 'User avatar');
    return Semantics(
      label: label,
      image: true,
      button: onTap != null,
      child: avatar,
    );
  }
}

/// AppAvatarGroup - Stack of overlapping avatars
class AppAvatarGroup extends StatelessWidget {
  const AppAvatarGroup({
    required this.avatars,
    super.key,
    this.maxVisible = 3,
    this.size = AppAvatarSize.medium,
    this.spacing = 16.0,
    this.onMoreTap,
  });

  final List<AppAvatarData> avatars;
  final int maxVisible;
  final AppAvatarSize size;
  final double spacing;
  final VoidCallback? onMoreTap;

  double get _radius => switch (size) {
        AppAvatarSize.small => 16,
        AppAvatarSize.medium => 24,
        AppAvatarSize.large => 32,
        AppAvatarSize.extraLarge => 48,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleAvatars = avatars.take(maxVisible).toList();
    final remainingCount = avatars.length - maxVisible;

    return SizedBox(
      height: _radius * 2,
      child: Stack(
        children: [
          ...visibleAvatars.asMap().entries.map((entry) {
            final index = entry.key;
            final avatar = entry.value;

            return Positioned(
              left: index * spacing,
              child: AppAvatar(
                imageUrl: avatar.imageUrl,
                name: avatar.name,
                size: size,
                showBorder: true,
                borderColor: theme.colorScheme.surface,
                onTap: avatar.onTap,
              ),
            );
          }),
          if (remainingCount > 0)
            Positioned(
              left: maxVisible * spacing,
              child: GestureDetector(
                onTap: onMoreTap,
                child: CircleAvatar(
                  radius: _radius,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  child: Text(
                    '+$remainingCount',
                    style: TextStyle(
                      fontSize: _radius * 0.6,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum AppAvatarSize { small, medium, large, extraLarge }

/// Data class for avatar information
class AppAvatarData {
  const AppAvatarData({
    this.imageUrl,
    this.name,
    this.onTap,
  });

  final String? imageUrl;
  final String? name;
  final VoidCallback? onTap;
}
