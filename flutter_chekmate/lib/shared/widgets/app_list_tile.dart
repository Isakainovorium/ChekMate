import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({
    required this.title, this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    super.key,
  });
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

class MessageListTile extends StatelessWidget {
  const MessageListTile({
    required this.avatarUrl,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    this.onTap,
    super.key,
  });
  final String avatarUrl;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        name,
        style: TextStyle(
          fontSize: 14,
          fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color:
              unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color:
                  unreadCount > 0 ? AppColors.primary : AppColors.textTertiary,
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}

class NotificationListTile extends StatelessWidget {
  const NotificationListTile({
    required this.avatarUrl,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isRead = false,
    this.onTap,
    super.key,
  });
  final String avatarUrl;
  final String title;
  final String subtitle;
  final String time;
  final bool isRead;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isRead ? null : AppColors.primary.withValues(alpha: 0.05),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(avatarUrl),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        trailing: !isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
