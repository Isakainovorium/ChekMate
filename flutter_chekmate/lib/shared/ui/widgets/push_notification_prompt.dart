import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/services/push_notification_service.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';

/// Push notification permission prompt
class PushNotificationPrompt extends StatefulWidget {
  const PushNotificationPrompt({super.key});

  @override
  State<PushNotificationPrompt> createState() => _PushNotificationPromptState();
}

class _PushNotificationPromptState extends State<PushNotificationPrompt> {
  final _notificationService = PushNotificationService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.9),
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.notifications_active,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Stay Connected!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get notified about new likes, comments, and messages. Never miss a moment!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleDismiss,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Not Now'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleEnable,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        )
                      : const Text('Enable'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleEnable() async {
    setState(() => _isLoading = true);

    try {
      final success = await _notificationService.subscribe();

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔔 Notifications enabled!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Failed to enable notifications. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleDismiss() {
    Navigator.of(context).pop();
  }
}

/// Push notification settings widget
class PushNotificationSettings extends StatefulWidget {
  const PushNotificationSettings({super.key});

  @override
  State<PushNotificationSettings> createState() =>
      _PushNotificationSettingsState();
}

class _PushNotificationSettingsState extends State<PushNotificationSettings> {
  final _notificationService = PushNotificationService();
  bool _isSubscribed = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    await _notificationService.initialize();
    if (mounted) {
      setState(() {
        _isSubscribed = _notificationService.isSubscribed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.notifications,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Push Notifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Get notified about activity on your posts',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isSubscribed,
                  onChanged: _isLoading ? null : _handleToggle,
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
            if (_isSubscribed) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildNotificationOption(
                'Likes',
                'When someone likes your post',
                true,
              ),
              _buildNotificationOption(
                'Comments',
                'When someone comments on your post',
                true,
              ),
              _buildNotificationOption(
                'New Followers',
                'When someone follows you',
                true,
              ),
              _buildNotificationOption(
                'Messages',
                'When you receive a new message',
                true,
              ),
              _buildNotificationOption(
                'Streak Reminders',
                'Daily reminder to maintain your streak',
                false,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption(String title, String subtitle, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (value) {
              // Handle individual notification type toggle
            },
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _handleToggle(bool value) async {
    setState(() => _isLoading = true);

    try {
      bool success;
      if (value) {
        success = await _notificationService.subscribe();
      } else {
        success = await _notificationService.unsubscribe();
      }

      if (mounted) {
        if (success) {
          setState(() => _isSubscribed = value);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                value
                    ? '🔔 Notifications enabled!'
                    : '🔕 Notifications disabled',
              ),
              backgroundColor: value ? Colors.green : Colors.grey,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update notification settings'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
