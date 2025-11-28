import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notification settings state provider
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});

/// Notification settings model
class NotificationSettings {
  const NotificationSettings({
    this.pushEnabled = true,
    this.likesEnabled = true,
    this.commentsEnabled = true,
    this.followsEnabled = true,
    this.mentionsEnabled = true,
    this.messagesEnabled = true,
    this.liveEnabled = true,
    this.emailDigest = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = const TimeOfDay(hour: 22, minute: 0),
    this.quietHoursEnd = const TimeOfDay(hour: 7, minute: 0),
  });

  final bool pushEnabled;
  final bool likesEnabled;
  final bool commentsEnabled;
  final bool followsEnabled;
  final bool mentionsEnabled;
  final bool messagesEnabled;
  final bool liveEnabled;
  final bool emailDigest;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool quietHoursEnabled;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? likesEnabled,
    bool? commentsEnabled,
    bool? followsEnabled,
    bool? mentionsEnabled,
    bool? messagesEnabled,
    bool? liveEnabled,
    bool? emailDigest,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? quietHoursEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      likesEnabled: likesEnabled ?? this.likesEnabled,
      commentsEnabled: commentsEnabled ?? this.commentsEnabled,
      followsEnabled: followsEnabled ?? this.followsEnabled,
      mentionsEnabled: mentionsEnabled ?? this.mentionsEnabled,
      messagesEnabled: messagesEnabled ?? this.messagesEnabled,
      liveEnabled: liveEnabled ?? this.liveEnabled,
      emailDigest: emailDigest ?? this.emailDigest,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}

/// Notification settings state notifier
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(const NotificationSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = NotificationSettings(
      pushEnabled: prefs.getBool('notif_push') ?? true,
      likesEnabled: prefs.getBool('notif_likes') ?? true,
      commentsEnabled: prefs.getBool('notif_comments') ?? true,
      followsEnabled: prefs.getBool('notif_follows') ?? true,
      mentionsEnabled: prefs.getBool('notif_mentions') ?? true,
      messagesEnabled: prefs.getBool('notif_messages') ?? true,
      liveEnabled: prefs.getBool('notif_live') ?? true,
      emailDigest: prefs.getBool('notif_email') ?? false,
      soundEnabled: prefs.getBool('notif_sound') ?? true,
      vibrationEnabled: prefs.getBool('notif_vibration') ?? true,
      quietHoursEnabled: prefs.getBool('notif_quiet') ?? false,
    );
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_push', state.pushEnabled);
    await prefs.setBool('notif_likes', state.likesEnabled);
    await prefs.setBool('notif_comments', state.commentsEnabled);
    await prefs.setBool('notif_follows', state.followsEnabled);
    await prefs.setBool('notif_mentions', state.mentionsEnabled);
    await prefs.setBool('notif_messages', state.messagesEnabled);
    await prefs.setBool('notif_live', state.liveEnabled);
    await prefs.setBool('notif_email', state.emailDigest);
    await prefs.setBool('notif_sound', state.soundEnabled);
    await prefs.setBool('notif_vibration', state.vibrationEnabled);
    await prefs.setBool('notif_quiet', state.quietHoursEnabled);
  }

  void updatePushEnabled(bool value) {
    state = state.copyWith(pushEnabled: value);
    _saveSettings();
  }

  void updateLikesEnabled(bool value) {
    state = state.copyWith(likesEnabled: value);
    _saveSettings();
  }

  void updateCommentsEnabled(bool value) {
    state = state.copyWith(commentsEnabled: value);
    _saveSettings();
  }

  void updateFollowsEnabled(bool value) {
    state = state.copyWith(followsEnabled: value);
    _saveSettings();
  }

  void updateMentionsEnabled(bool value) {
    state = state.copyWith(mentionsEnabled: value);
    _saveSettings();
  }

  void updateMessagesEnabled(bool value) {
    state = state.copyWith(messagesEnabled: value);
    _saveSettings();
  }

  void updateLiveEnabled(bool value) {
    state = state.copyWith(liveEnabled: value);
    _saveSettings();
  }

  void updateEmailDigest(bool value) {
    state = state.copyWith(emailDigest: value);
    _saveSettings();
  }

  void updateSoundEnabled(bool value) {
    state = state.copyWith(soundEnabled: value);
    _saveSettings();
  }

  void updateVibrationEnabled(bool value) {
    state = state.copyWith(vibrationEnabled: value);
    _saveSettings();
  }

  void updateQuietHoursEnabled(bool value) {
    state = state.copyWith(quietHoursEnabled: value);
    _saveSettings();
  }

  void updateQuietHoursStart(TimeOfDay time) {
    state = state.copyWith(quietHoursStart: time);
    _saveSettings();
  }

  void updateQuietHoursEnd(TimeOfDay time) {
    state = state.copyWith(quietHoursEnd: time);
    _saveSettings();
  }
}

/// Notification Settings Page
class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.navyBlue,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Push Notifications Master Toggle
          _buildSection(
            title: 'Push Notifications',
            children: [
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'Enable Push Notifications',
                subtitle: 'Receive notifications on your device',
                value: settings.pushEnabled,
                onChanged: notifier.updatePushEnabled,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Notification Types
          _buildSection(
            title: 'Notification Types',
            enabled: settings.pushEnabled,
            children: [
              _buildSwitchTile(
                icon: Icons.favorite,
                title: 'Likes',
                subtitle: 'When someone likes your post',
                value: settings.likesEnabled,
                onChanged: settings.pushEnabled ? notifier.updateLikesEnabled : null,
              ),
              _buildSwitchTile(
                icon: Icons.comment,
                title: 'Comments',
                subtitle: 'When someone comments on your post',
                value: settings.commentsEnabled,
                onChanged: settings.pushEnabled ? notifier.updateCommentsEnabled : null,
              ),
              _buildSwitchTile(
                icon: Icons.person_add,
                title: 'New Followers',
                subtitle: 'When someone follows you',
                value: settings.followsEnabled,
                onChanged: settings.pushEnabled ? notifier.updateFollowsEnabled : null,
              ),
              _buildSwitchTile(
                icon: Icons.alternate_email,
                title: 'Mentions',
                subtitle: 'When someone mentions you',
                value: settings.mentionsEnabled,
                onChanged: settings.pushEnabled ? notifier.updateMentionsEnabled : null,
              ),
              _buildSwitchTile(
                icon: Icons.message,
                title: 'Messages',
                subtitle: 'When you receive a new message',
                value: settings.messagesEnabled,
                onChanged: settings.pushEnabled ? notifier.updateMessagesEnabled : null,
              ),
              _buildSwitchTile(
                icon: Icons.live_tv,
                title: 'Live Streams',
                subtitle: 'When someone you follow goes live',
                value: settings.liveEnabled,
                onChanged: settings.pushEnabled ? notifier.updateLiveEnabled : null,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Sound & Vibration
          _buildSection(
            title: 'Sound & Vibration',
            enabled: settings.pushEnabled,
            children: [
              _buildSwitchTile(
                icon: Icons.volume_up,
                title: 'Sound',
                subtitle: 'Play sound for notifications',
                value: settings.soundEnabled,
                onChanged: settings.pushEnabled ? notifier.updateSoundEnabled : null,
              ),
              _buildSwitchTile(
                icon: Icons.vibration,
                title: 'Vibration',
                subtitle: 'Vibrate for notifications',
                value: settings.vibrationEnabled,
                onChanged: settings.pushEnabled ? notifier.updateVibrationEnabled : null,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Quiet Hours
          _buildSection(
            title: 'Quiet Hours',
            enabled: settings.pushEnabled,
            children: [
              _buildSwitchTile(
                icon: Icons.bedtime,
                title: 'Enable Quiet Hours',
                subtitle: 'Pause notifications during set hours',
                value: settings.quietHoursEnabled,
                onChanged: settings.pushEnabled ? notifier.updateQuietHoursEnabled : null,
              ),
              if (settings.quietHoursEnabled && settings.pushEnabled) ...[
                _buildTimeTile(
                  context: context,
                  icon: Icons.nightlight,
                  title: 'Start Time',
                  time: settings.quietHoursStart,
                  onTap: () => _selectTime(
                    context,
                    settings.quietHoursStart,
                    notifier.updateQuietHoursStart,
                  ),
                ),
                _buildTimeTile(
                  context: context,
                  icon: Icons.wb_sunny,
                  title: 'End Time',
                  time: settings.quietHoursEnd,
                  onTap: () => _selectTime(
                    context,
                    settings.quietHoursEnd,
                    notifier.updateQuietHoursEnd,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Email Notifications
          _buildSection(
            title: 'Email Notifications',
            children: [
              _buildSwitchTile(
                icon: Icons.email,
                title: 'Email Digest',
                subtitle: 'Receive weekly email summary',
                value: settings.emailDigest,
                onChanged: notifier.updateEmailDigest,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool)? onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildTimeTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: TextButton(
        onPressed: onTap,
        child: Text(
          time.format(context),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    TimeOfDay initialTime,
    void Function(TimeOfDay) onTimeSelected,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      onTimeSelected(time);
    }
  }
}
