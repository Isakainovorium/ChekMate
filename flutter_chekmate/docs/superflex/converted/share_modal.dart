import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// ShareModal - Modal for sharing content with various options
class ShareModal extends StatelessWidget {
  const ShareModal({
    required this.shareUrl,
    super.key,
    this.title,
    this.description,
    this.imageUrl,
    this.onSharePlatform,
    this.onCopyLink,
    this.onClose,
  });

  final String shareUrl;
  final String? title;
  final String? description;
  final String? imageUrl;
  final void Function(SharePlatform)? onSharePlatform;
  final VoidCallback? onCopyLink;
  final VoidCallback? onClose;

  static Future<void> show({
    required BuildContext context,
    required String shareUrl,
    String? title,
    String? description,
    String? imageUrl,
    void Function(SharePlatform)? onSharePlatform,
    VoidCallback? onCopyLink,
  }) {
    return AppSheet.show(
      context: context,
      title: const Text('Share'),
      content: ShareModal(
        shareUrl: shareUrl,
        title: title,
        description: description,
        imageUrl: imageUrl,
        onSharePlatform: onSharePlatform,
        onCopyLink: onCopyLink,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Content preview
        if (title != null || description != null || imageUrl != null) ...[
          AppCard(
            child: Row(
              children: [
                if (imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null) ...[
                        Text(
                          title!,
                          style: theme.textTheme.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      if (description != null)
                        Text(
                          description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Share platforms
        Text(
          'Share to',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),

        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: SharePlatform.values.map((platform) {
            return _SharePlatformButton(
              platform: platform,
              onTap: () {
                onSharePlatform?.call(platform);
                onClose?.call();
              },
            );
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Copy link section
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Copy Link',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      shareUrl,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              AppButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: shareUrl));
                  onCopyLink?.call();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                variant: AppButtonVariant.outline,
                size: AppButtonSize.sm,
                child: const Text('Copy'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SharePlatformButton extends StatelessWidget {
  const _SharePlatformButton({
    required this.platform,
    required this.onTap,
  });

  final SharePlatform platform;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final platformInfo = _getPlatformInfo(platform);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              platformInfo.icon,
              size: 32,
              color: platformInfo.color ?? theme.colorScheme.onSurface,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              platformInfo.name,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  _PlatformInfo _getPlatformInfo(SharePlatform platform) {
    switch (platform) {
      case SharePlatform.instagram:
        return const _PlatformInfo(
          name: 'Instagram',
          icon: Icons.camera_alt,
          color: Color(0xFFE4405F),
        );
      case SharePlatform.twitter:
        return const _PlatformInfo(
          name: 'Twitter',
          icon: Icons.alternate_email,
          color: Color(0xFF1DA1F2),
        );
      case SharePlatform.facebook:
        return const _PlatformInfo(
          name: 'Facebook',
          icon: Icons.facebook,
          color: Color(0xFF1877F2),
        );
      case SharePlatform.whatsapp:
        return const _PlatformInfo(
          name: 'WhatsApp',
          icon: Icons.message,
          color: Color(0xFF25D366),
        );
      case SharePlatform.telegram:
        return const _PlatformInfo(
          name: 'Telegram',
          icon: Icons.send,
          color: Color(0xFF0088CC),
        );
      case SharePlatform.sms:
        return const _PlatformInfo(
          name: 'SMS',
          icon: Icons.sms,
        );
      case SharePlatform.email:
        return const _PlatformInfo(
          name: 'Email',
          icon: Icons.email,
        );
      case SharePlatform.more:
        return const _PlatformInfo(
          name: 'More',
          icon: Icons.more_horiz,
        );
    }
  }
}

class _PlatformInfo {
  const _PlatformInfo({
    required this.name,
    required this.icon,
    this.color,
  });

  final String name;
  final IconData icon;
  final Color? color;
}

enum SharePlatform {
  instagram,
  twitter,
  facebook,
  whatsapp,
  telegram,
  sms,
  email,
  more,
}
