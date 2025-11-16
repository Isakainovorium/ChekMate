import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notification scheduling settings page
class NotificationScheduleSettingsPage extends StatefulWidget {
  const NotificationScheduleSettingsPage({super.key});

  @override
  State<NotificationScheduleSettingsPage> createState() =>
      _NotificationScheduleSettingsPageState();
}

class _NotificationScheduleSettingsPageState
    extends State<NotificationScheduleSettingsPage> {
  // Quiet Hours
  bool _quietHoursEnabled = false;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 8, minute: 0);

  // Daily Digest
  bool _dailyDigestEnabled = true;
  TimeOfDay _dailyDigestTime = const TimeOfDay(hour: 9, minute: 0);

  // Weekly Report
  bool _weeklyReportEnabled = true;
  String _weeklyReportDay = 'Monday';
  TimeOfDay _weeklyReportTime = const TimeOfDay(hour: 10, minute: 0);

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Load notification settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        // Quiet Hours
        _quietHoursEnabled = prefs.getBool('notification_quiet_hours_enabled') ?? false;
        _quietHoursStart = _timeOfDayFromString(
          prefs.getString('notification_quiet_hours_start') ?? '22:00',
        );
        _quietHoursEnd = _timeOfDayFromString(
          prefs.getString('notification_quiet_hours_end') ?? '08:00',
        );

        // Daily Digest
        _dailyDigestEnabled = prefs.getBool('notification_daily_digest_enabled') ?? true;
        _dailyDigestTime = _timeOfDayFromString(
          prefs.getString('notification_daily_digest_time') ?? '09:00',
        );

        // Weekly Report
        _weeklyReportEnabled = prefs.getBool('notification_weekly_report_enabled') ?? true;
        _weeklyReportDay = prefs.getString('notification_weekly_report_day') ?? 'Monday';
        _weeklyReportTime = _timeOfDayFromString(
          prefs.getString('notification_weekly_report_time') ?? '10:00',
        );
      });
    } catch (e) {
      // Silently fail if loading fails - use default values
      debugPrint('Failed to load notification settings: $e');
    }
  }

  /// Save notification settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Quiet Hours
      await prefs.setBool('notification_quiet_hours_enabled', _quietHoursEnabled);
      await prefs.setString('notification_quiet_hours_start', _timeOfDayToString(_quietHoursStart));
      await prefs.setString('notification_quiet_hours_end', _timeOfDayToString(_quietHoursEnd));

      // Daily Digest
      await prefs.setBool('notification_daily_digest_enabled', _dailyDigestEnabled);
      await prefs.setString('notification_daily_digest_time', _timeOfDayToString(_dailyDigestTime));

      // Weekly Report
      await prefs.setBool('notification_weekly_report_enabled', _weeklyReportEnabled);
      await prefs.setString('notification_weekly_report_day', _weeklyReportDay);
      await prefs.setString('notification_weekly_report_time', _timeOfDayToString(_weeklyReportTime));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification schedule saved!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }

      setState(() {
        _hasChanges = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save settings. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Convert TimeOfDay to string format (HH:MM)
  String _timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Convert string format (HH:MM) to TimeOfDay
  TimeOfDay _timeOfDayFromString(String timeString) {
    final parts = timeString.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]) ?? 9;
      final minute = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return const TimeOfDay(hour: 9, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navyBlue),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Notification Schedule',
          style: TextStyle(
            color: AppColors.navyBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Breadcrumb
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: const AppBreadcrumb(
                items: [
                  AppBreadcrumbItem(label: 'Profile'),
                  AppBreadcrumbItem(label: 'Settings'),
                  AppBreadcrumbItem(label: 'Notifications'),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info alert
                    const AppAlert(
                      message:
                          'Customize when you receive notifications to match your schedule.',
                      variant: AppAlertVariant.info,
                      showIcon: true,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Accordion sections
                    AppAccordion(
                      items: [
                        // Quiet Hours
                        AppAccordionItem(
                          title: 'Quiet Hours',
                          subtitle: _quietHoursEnabled
                              ? 'Enabled: ${_quietHoursStart.format(context)} - ${_quietHoursEnd.format(context)}'
                              : 'Disabled',
                          leading: const Icon(
                            Icons.nightlight_round,
                            color: AppColors.primary,
                          ),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Enable Quiet Hours',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                  AppSwitch(
                                    value: _quietHoursEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        _quietHoursEnabled = value;
                                        _hasChanges = true;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              if (_quietHoursEnabled) ...[
                                const SizedBox(height: AppSpacing.lg),
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
                                const SizedBox(height: AppSpacing.md),
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
                          ),
                        ),

                        // Daily Digest
                        AppAccordionItem(
                          title: 'Daily Digest',
                          subtitle: _dailyDigestEnabled
                              ? 'Enabled: ${_dailyDigestTime.format(context)}'
                              : 'Disabled',
                          leading: const Icon(
                            Icons.today,
                            color: AppColors.primary,
                          ),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Enable Daily Digest',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                  AppSwitch(
                                    value: _dailyDigestEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        _dailyDigestEnabled = value;
                                        _hasChanges = true;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              if (_dailyDigestEnabled) ...[
                                const SizedBox(height: AppSpacing.lg),
                                AppTimePicker(
                                  label: 'Delivery Time',
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
                          ),
                        ),

                        // Weekly Report
                        AppAccordionItem(
                          title: 'Weekly Report',
                          subtitle: _weeklyReportEnabled
                              ? 'Enabled: $_weeklyReportDay at ${_weeklyReportTime.format(context)}'
                              : 'Disabled',
                          leading: const Icon(
                            Icons.calendar_today,
                            color: AppColors.primary,
                          ),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Enable Weekly Report',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                  AppSwitch(
                                    value: _weeklyReportEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        _weeklyReportEnabled = value;
                                        _hasChanges = true;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              if (_weeklyReportEnabled) ...[
                                const SizedBox(height: AppSpacing.lg),
                                AppRadioGroup<String>(
                                  value: _weeklyReportDay,
                                  items: const [
                                    AppRadioItem(
                                      value: 'Monday',
                                      label: 'Monday',
                                    ),
                                    AppRadioItem(
                                      value: 'Tuesday',
                                      label: 'Tuesday',
                                    ),
                                    AppRadioItem(
                                      value: 'Wednesday',
                                      label: 'Wednesday',
                                    ),
                                    AppRadioItem(
                                      value: 'Thursday',
                                      label: 'Thursday',
                                    ),
                                    AppRadioItem(
                                      value: 'Friday',
                                      label: 'Friday',
                                    ),
                                    AppRadioItem(
                                      value: 'Saturday',
                                      label: 'Saturday',
                                    ),
                                    AppRadioItem(
                                      value: 'Sunday',
                                      label: 'Sunday',
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _weeklyReportDay = value;
                                        _hasChanges = true;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                AppTimePicker(
                                  label: 'Delivery Time',
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
                          ),
                        ),
                      ],
                      initialExpandedIndexes: const {0},
                    ),
                  ],
                ),
              ),
            ),

            // Save button
            if (_hasChanges)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: AppButton(
                  onPressed: _saveSettings,
                  child: const Text('Save Changes'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

