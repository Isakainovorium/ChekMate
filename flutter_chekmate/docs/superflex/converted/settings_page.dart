import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// SettingsPage - User settings and preferences
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: AppButton(
          onPressed: () => context.pop(),
          variant: AppButtonVariant.text,
          size: AppButtonSize.sm,
          child: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account section
            _SettingsSection(
              title: 'Account',
              children: [
                _SettingsTile(
                  leading: const Icon(Icons.person_outline),
                  title: 'Edit Profile',
                  subtitle: 'Update your profile information',
                  onTap: () => context.push('/profile/edit'),
                ),
                _SettingsTile(
                  leading: const Icon(Icons.lock_outline),
                  title: 'Privacy & Security',
                  subtitle: 'Manage your privacy settings',
                  onTap: () => _showComingSoon(context),
                ),
                _SettingsTile(
                  leading: const Icon(Icons.verified_user_outlined),
                  title: 'Account Verification',
                  subtitle: 'Verify your account',
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Notifications section
            _SettingsSection(
              title: 'Notifications',
              children: [
                _SettingsTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: 'Push Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () => _showComingSoon(context),
                ),
                _SettingsTile(
                  leading: const Icon(Icons.email_outlined),
                  title: 'Email Notifications',
                  subtitle: 'Configure email alerts',
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Preferences section
            _SettingsSection(
              title: 'Preferences',
              children: [
                _SettingsTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: 'Theme',
                  subtitle: 'Choose your app theme',
                  onTap: () => _showThemeSelector(context),
                ),
                _SettingsTile(
                  leading: const Icon(Icons.language_outlined),
                  title: 'Language',
                  subtitle: 'Select your language',
                  onTap: () => _showComingSoon(context),
                ),
                _SettingsTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: 'Location Services',
                  subtitle: 'Manage location permissions',
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Support section
            _SettingsSection(
              title: 'Support',
              children: [
                _SettingsTile(
                  leading: const Icon(Icons.help_outline),
                  title: 'Help Center',
                  subtitle: 'Get help and support',
                  onTap: () => _showComingSoon(context),
                ),
                _SettingsTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: 'Send Feedback',
                  subtitle: 'Share your thoughts with us',
                  onTap: () => _showComingSoon(context),
                ),
                _SettingsTile(
                  leading: const Icon(Icons.info_outline),
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () => _showAbout(context),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // Danger zone
            _SettingsSection(
              title: 'Account Actions',
              children: [
                _SettingsTile(
                  leading: Icon(
                    Icons.logout,
                    color: theme.colorScheme.error,
                  ),
                  title: 'Sign Out',
                  titleColor: theme.colorScheme.error,
                  onTap: () => _showSignOutDialog(context),
                ),
                _SettingsTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: theme.colorScheme.error,
                  ),
                  title: 'Delete Account',
                  titleColor: theme.colorScheme.error,
                  subtitle: 'Permanently delete your account',
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    AppDialog.show<void>(
      context: context,
      title: const Text('Coming Soon'),
      content: const Text('This feature is coming soon!'),
      actions: [
        AppButton(
          onPressed: () => Navigator.of(context).pop(),
          variant: AppButtonVariant.text,
          child: const Text('OK'),
        ),
      ],
    );
  }

  void _showThemeSelector(BuildContext context) {
    AppDialog.show<void>(
      context: context,
      title: const Text('Choose Theme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_auto),
            title: const Text('System'),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.light_mode),
            title: const Text('Light'),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark'),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    AppDialog.show<void>(
      context: context,
      title: const Text('About ChekMate'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ChekMate v1.0.0'),
          SizedBox(height: AppSpacing.sm),
          Text('The ultimate dating app for meaningful connections.'),
        ],
      ),
      actions: [
        AppButton(
          onPressed: () => Navigator.of(context).pop(),
          variant: AppButtonVariant.text,
          child: const Text('OK'),
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context) {
    AppDialog.show<void>(
      context: context,
      title: const Text('Sign Out'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        AppButton(
          onPressed: () => Navigator.of(context).pop(),
          variant: AppButtonVariant.text,
          child: const Text('Cancel'),
        ),
        AppButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Sign out implementation ready for AuthService integration
            // await AuthService.instance.signOut();
            context.go('/auth/login');
          },
          child: const Text('Sign Out'),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final theme = Theme.of(context);
    AppDialog.show<void>(
      context: context,
      title: Text(
        'Delete Account',
        style: TextStyle(color: theme.colorScheme.error),
      ),
      content: const Text(
        'This action cannot be undone. All your data will be permanently deleted.',
      ),
      actions: [
        AppButton(
          onPressed: () => Navigator.of(context).pop(),
          variant: AppButtonVariant.text,
          child: const Text('Cancel'),
        ),
        AppButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Delete account implementation ready for AuthService integration
            // await AuthService.instance.deleteAccount();
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.onTap,
    this.titleColor,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final VoidCallback? onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: leading,
      title: Text(
        title,
        style: titleColor != null
            ? theme.textTheme.bodyLarge?.copyWith(color: titleColor)
            : null,
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
