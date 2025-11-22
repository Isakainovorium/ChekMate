import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/ui/components/app_accordion.dart';
import '../../../shared/ui/components/app_alert.dart';
import '../../../shared/ui/components/app_breadcrumb.dart';
import '../../../shared/ui/components/app_button.dart';
import '../../../shared/ui/components/app_radio_group.dart';
import '../../../shared/ui/components/app_switch.dart';
import '../../../shared/ui/components/app_time_picker.dart';

/// Notification Schedule Settings Page
///
/// Allows users to configure notification schedules including:
/// - Quiet hours (start/end time)
/// - Daily digest scheduling
/// - Weekly report scheduling
///
/// Date: 11/13/2025
class NotificationScheduleSettingsPage extends ConsumerStatefulWidget {
  const NotificationScheduleSettingsPage({super.key});

  @override
  ConsumerState<NotificationScheduleSettingsPage> createState() =>
      _NotificationScheduleSettingsPageState();
}

class _NotificationScheduleSettingsPageState
    extends ConsumerState<NotificationScheduleSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  // Quiet hours settings
  bool _quietHoursEnabled = false;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 8, minute: 0);

  // Daily digest settings
  bool _dailyDigestEnabled = false;
  TimeOfDay _dailyDigestTime = const TimeOfDay(hour: 9, minute: 0);

  // Weekly report settings
  bool _weeklyReportEnabled = false;
  int _weeklyReportDay = 1; // Monday = 1, Sunday = 7
  TimeOfDay _weeklyReportTime = const TimeOfDay(hour: 10, minute: 0);

  bool _isSaving = false;
  String? _errorMessage;
  bool _hasChanges = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Schedule'),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _handleCancel,
              child: const Text('Cancel'),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppBreadcrumb(
                  items: [
                    AppBreadcrumbItem(label: 'Profile'),
                    AppBreadcrumbItem(label: 'Notification Schedule'),
                  ],
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  AppAlert(
                    message: _errorMessage!,
                    variant: AppAlertVariant.error,
                  ),
                  const SizedBox(height: 16),
                ],
                AppAccordion(
                  allowMultiple: true,
                  items: [
                    AppAccordionItem(
                      title: 'Quiet Hours',
                      subtitle: _quietHoursEnabled
                          ? '${_formatTime(_quietHoursStart)} - ${_formatTime(_quietHoursEnd)}'
                          : 'Disabled',
                      content: _buildQuietHoursSection(),
                    ),
                    AppAccordionItem(
                      title: 'Daily Digest',
                      subtitle: _dailyDigestEnabled
                          ? 'Daily at ${_formatTime(_dailyDigestTime)}'
                          : 'Disabled',
                      content: _buildDailyDigestSection(),
                    ),
                    AppAccordionItem(
                      title: 'Weekly Report',
                      subtitle: _weeklyReportEnabled
                          ? '${_getDayName(_weeklyReportDay)} at ${_formatTime(_weeklyReportTime)}'
                          : 'Disabled',
                      content: _buildWeeklyReportSection(),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                AppButton(
                  onPressed: _isSaving ? null : _handleSave,
                  isLoading: _isSaving,
                  fullWidth: true,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuietHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSwitch(
          value: _quietHoursEnabled,
          onChanged: (value) {
            setState(() {
              _quietHoursEnabled = value;
              _hasChanges = true;
            });
          },
          label: 'Enable Quiet Hours',
          subtitle: 'Mute notifications during specified hours',
        ),
        if (_quietHoursEnabled) ...[
          const SizedBox(height: 24),
          AppTimePicker(
            label: 'Start Time',
            initialTime: _quietHoursStart,
            onTimeChanged: (time) {
              setState(() {
                _quietHoursStart = time;
                _hasChanges = true;
              });
            },
          ),
          const SizedBox(height: 16),
          AppTimePicker(
            label: 'End Time',
            initialTime: _quietHoursEnd,
            onTimeChanged: (time) {
              setState(() {
                _quietHoursEnd = time;
                _hasChanges = true;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDailyDigestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSwitch(
          value: _dailyDigestEnabled,
          onChanged: (value) {
            setState(() {
              _dailyDigestEnabled = value;
              _hasChanges = true;
            });
          },
          label: 'Enable Daily Digest',
          subtitle: 'Receive a summary of notifications once per day',
        ),
        if (_dailyDigestEnabled) ...[
          const SizedBox(height: 24),
          AppTimePicker(
            label: 'Digest Time',
            initialTime: _dailyDigestTime,
            onTimeChanged: (time) {
              setState(() {
                _dailyDigestTime = time;
                _hasChanges = true;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildWeeklyReportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSwitch(
          value: _weeklyReportEnabled,
          onChanged: (value) {
            setState(() {
              _weeklyReportEnabled = value;
              _hasChanges = true;
            });
          },
          label: 'Enable Weekly Report',
          subtitle: 'Receive a weekly summary of activity',
        ),
        if (_weeklyReportEnabled) ...[
          const SizedBox(height: 24),
          Text(
            'Day of Week',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          AppRadioGroup<int>(
            value: _weeklyReportDay,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _weeklyReportDay = value;
                  _hasChanges = true;
                });
              }
            },
            items: List.generate(7, (index) {
              final day = index + 1;
              return AppRadioItem<int>(
                value: day,
                label: _getDayName(day),
              );
            }),
          ),
          const SizedBox(height: 24),
          AppTimePicker(
            label: 'Report Time',
            initialTime: _weeklyReportTime,
            onTimeChanged: (time) {
              setState(() {
                _weeklyReportTime = time;
                _hasChanges = true;
              });
            },
          ),
        ],
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getDayName(int day) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[day - 1];
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // Save notification schedule settings to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notif_quiet_hours_enabled', _quietHoursEnabled);
      await prefs.setInt('notif_quiet_start_hour', _quietHoursStart.hour);
      await prefs.setInt('notif_quiet_start_minute', _quietHoursStart.minute);
      await prefs.setInt('notif_quiet_end_hour', _quietHoursEnd.hour);
      await prefs.setInt('notif_quiet_end_minute', _quietHoursEnd.minute);
      await prefs.setBool('notif_daily_digest_enabled', _dailyDigestEnabled);
      await prefs.setInt('notif_daily_digest_hour', _dailyDigestTime.hour);
      await prefs.setInt('notif_daily_digest_minute', _dailyDigestTime.minute);
      await prefs.setBool('notif_weekly_report_enabled', _weeklyReportEnabled);
      await prefs.setInt('notif_weekly_report_day', _weeklyReportDay);
      await prefs.setInt('notif_weekly_report_hour', _weeklyReportTime.hour);
      await prefs.setInt(
          'notif_weekly_report_minute', _weeklyReportTime.minute);

      if (mounted) {
        setState(() {
          _isSaving = false;
          _hasChanges = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification schedule saved successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save settings. Please try again.';
          _isSaving = false;
        });
      }
    }
  }

  void _handleCancel() {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Keep Editing'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              child: const Text('Discard'),
            ),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }
}
