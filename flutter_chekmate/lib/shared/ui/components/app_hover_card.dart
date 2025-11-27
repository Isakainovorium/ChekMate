import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppHoverCard - Hover-triggered content card
class AppHoverCard extends StatefulWidget {
  const AppHoverCard({
    required this.child, required this.hoverContent, super.key,
    this.hoverDelay = const Duration(milliseconds: 500),
    this.hideDelay = const Duration(milliseconds: 100),
    this.offset = const Offset(0, 8),
    this.preferredDirection = AxisDirection.down,
  });

  final Widget child;
  final Widget hoverContent;
  final Duration hoverDelay;
  final Duration hideDelay;
  final Offset offset;
  final AxisDirection preferredDirection;

  @override
  State<AppHoverCard> createState() => _AppHoverCardState();
}

class _AppHoverCardState extends State<AppHoverCard> {
  OverlayEntry? _overlayEntry;
  bool _isHovering = false;
  bool _isHoveringOverlay = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _onEnter() {
    _isHovering = true;
    Future.delayed(widget.hoverDelay, () {
      if (_isHovering && mounted) {
        _showOverlay();
      }
    });
  }

  void _onExit() {
    _isHovering = false;
    Future.delayed(widget.hideDelay, () {
      if (!_isHovering && !_isHoveringOverlay && mounted) {
        _removeOverlay();
      }
    });
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx + widget.offset.dx,
        top: position.dy + size.height + widget.offset.dy,
        child: Material(
          color: Colors.transparent,
          child: MouseRegion(
            onEnter: (_) => _isHoveringOverlay = true,
            onExit: (_) {
              _isHoveringOverlay = false;
              _onExit();
            },
            child: _HoverCardContent(content: widget.hoverContent),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: widget.child,
    );
  }
}

class _HoverCardContent extends StatelessWidget {
  const _HoverCardContent({required this.content});

  final Widget content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: content,
    );
  }
}

/// AppTooltipCard - Enhanced tooltip with rich content
class AppTooltipCard extends StatelessWidget {
  const AppTooltipCard({
    required this.child, super.key,
    this.title,
    this.description,
    this.footer,
    this.showArrow = true,
  });

  final Widget child;
  final String? title;
  final String? description;
  final Widget? footer;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppHoverCard(
      hoverContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (description != null) const SizedBox(height: AppSpacing.xs),
          ],
          if (description != null) ...[
            Text(
              description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.sm),
            footer!,
          ],
        ],
      ),
      child: child,
    );
  }
}

/// AppUserCard - User profile hover card
class AppUserCard extends StatelessWidget {
  const AppUserCard({
    required this.child, required this.user, super.key,
  });

  final Widget child;
  final AppUserCardData user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppHoverCard(
      hoverContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: user.avatarUrl != null 
                    ? NetworkImage(user.avatarUrl!) 
                    : null,
                child: user.avatarUrl == null 
                    ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?')
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (user.title != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        user.title!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          if (user.bio != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              user.bio!,
              style: theme.textTheme.bodySmall,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          if (user.stats != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _StatItem(
                  label: 'Followers',
                  value: user.stats!.followers.toString(),
                ),
                const SizedBox(width: AppSpacing.lg),
                _StatItem(
                  label: 'Following',
                  value: user.stats!.following.toString(),
                ),
              ],
            ),
          ],
          
          if (user.actions != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: user.actions!.map((action) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: action,
              ),).toList(),
            ),
          ],
        ],
      ),
      child: child,
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Data classes for user card
class AppUserCardData {
  const AppUserCardData({
    required this.name,
    this.title,
    this.bio,
    this.avatarUrl,
    this.stats,
    this.actions,
  });

  final String name;
  final String? title;
  final String? bio;
  final String? avatarUrl;
  final AppUserStats? stats;
  final List<Widget>? actions;
}

class AppUserStats {
  const AppUserStats({
    required this.followers,
    required this.following,
  });

  final int followers;
  final int following;
}
