import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:go_router/go_router.dart';

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

  void _saveSettings() {
    // TODO: Implement save logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification schedule saved!'),
        backgroundColor: AppColors.primary,
      ),
    );
    setState(() {
      _hasChanges = false;
    });
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
                      color: Colors.black.withOpacity(0.05),
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

