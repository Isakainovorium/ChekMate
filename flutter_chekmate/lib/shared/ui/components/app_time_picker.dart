import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppTimePicker - Time selection with hours, minutes, AM/PM
class AppTimePicker extends StatefulWidget {
  const AppTimePicker({
    super.key,
    this.initialTime,
    this.onTimeChanged,
    this.use24HourFormat = false,
    this.minuteInterval = 1,
    this.showSeconds = false,
    this.enabled = true,
    this.label,
  });

  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay>? onTimeChanged;
  final bool use24HourFormat;
  final int minuteInterval;
  final bool showSeconds;
  final bool enabled;
  final String? label;

  @override
  State<AppTimePicker> createState() => _AppTimePickerState();
}

class _AppTimePickerState extends State<AppTimePicker> {
  late TimeOfDay _selectedTime;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _secondController;
  late FixedExtentScrollController _periodController;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime ?? TimeOfDay.now();
    
    _hourController = FixedExtentScrollController(
      initialItem: widget.use24HourFormat 
          ? _selectedTime.hour 
          : _selectedTime.hourOfPeriod,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedTime.minute ~/ widget.minuteInterval,
    );
    _secondController = FixedExtentScrollController();
    _periodController = FixedExtentScrollController(
      initialItem: _selectedTime.period == DayPeriod.am ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _onTimeChanged() {
    widget.onTimeChanged?.call(_selectedTime);
  }

  void _updateHour(int hour) {
    setState(() {
      if (widget.use24HourFormat) {
        _selectedTime = _selectedTime.replacing(hour: hour);
      } else {
        final period = _selectedTime.period;
        final adjustedHour = hour == 0 ? 12 : hour;
        final finalHour = period == DayPeriod.am 
            ? (adjustedHour == 12 ? 0 : adjustedHour)
            : (adjustedHour == 12 ? 12 : adjustedHour + 12);
        _selectedTime = _selectedTime.replacing(hour: finalHour);
      }
    });
    _onTimeChanged();
  }

  void _updateMinute(int minute) {
    setState(() {
      _selectedTime = _selectedTime.replacing(minute: minute * widget.minuteInterval);
    });
    _onTimeChanged();
  }

  void _updatePeriod(int periodIndex) {
    setState(() {
      final newPeriod = periodIndex == 0 ? DayPeriod.am : DayPeriod.pm;
      final currentHour = _selectedTime.hour;
      int newHour;
      
      if (newPeriod == DayPeriod.am) {
        newHour = currentHour >= 12 ? currentHour - 12 : currentHour;
      } else {
        newHour = currentHour < 12 ? currentHour + 12 : currentHour;
      }
      
      _selectedTime = _selectedTime.replacing(hour: newHour);
    });
    _onTimeChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: widget.enabled 
                  ? theme.colorScheme.onSurface 
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Hours
              Expanded(
                child: _TimeColumn(
                  controller: _hourController,
                  itemCount: widget.use24HourFormat ? 24 : 12,
                  itemBuilder: (index) => widget.use24HourFormat 
                      ? index.toString().padLeft(2, '0')
                      : (index == 0 ? 12 : index).toString().padLeft(2, '0'),
                  onSelectedItemChanged: _updateHour,
                  enabled: widget.enabled,
                ),
              ),
              
              _TimeSeparator(),
              
              // Minutes
              Expanded(
                child: _TimeColumn(
                  controller: _minuteController,
                  itemCount: 60 ~/ widget.minuteInterval,
                  itemBuilder: (index) => (index * widget.minuteInterval)
                      .toString().padLeft(2, '0'),
                  onSelectedItemChanged: _updateMinute,
                  enabled: widget.enabled,
                ),
              ),
              
              // Seconds (if enabled)
              if (widget.showSeconds) ...[
                _TimeSeparator(),
                Expanded(
                  child: _TimeColumn(
                    controller: _secondController,
                    itemCount: 60,
                    itemBuilder: (index) => index.toString().padLeft(2, '0'),
                    onSelectedItemChanged: (index) {
                      // Seconds handling would go here
                    },
                    enabled: widget.enabled,
                  ),
                ),
              ],
              
              // AM/PM (if 12-hour format)
              if (!widget.use24HourFormat) ...[
                _TimeSeparator(),
                Expanded(
                  child: _TimeColumn(
                    controller: _periodController,
                    itemCount: 2,
                    itemBuilder: (index) => index == 0 ? 'AM' : 'PM',
                    onSelectedItemChanged: _updatePeriod,
                    enabled: widget.enabled,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Selected time display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _formatTime(_selectedTime),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.enabled 
                  ? theme.colorScheme.onSurface 
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    if (widget.use24HourFormat) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    required this.onSelectedItemChanged,
    required this.enabled,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int) itemBuilder;
  final ValueChanged<int> onSelectedItemChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 40,
      perspective: 0.005,
      diameterRatio: 1.2,
      physics: enabled ? const FixedExtentScrollPhysics() : const NeverScrollableScrollPhysics(),
      onSelectedItemChanged: enabled ? onSelectedItemChanged : null,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          return Center(
            child: Text(
              itemBuilder(index),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: enabled 
                    ? theme.colorScheme.onSurface 
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimeSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: 20,
      child: Center(
        child: Text(
          ':',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// AppTimePickerDialog - Time picker in a dialog
class AppTimePickerDialog {
  static Future<TimeOfDay?> show({
    required BuildContext context,
    TimeOfDay? initialTime,
    bool use24HourFormat = false,
    int minuteInterval = 1,
    bool showSeconds = false,
    String title = 'Select Time',
  }) {
    return showDialog<TimeOfDay>(
      context: context,
      builder: (context) => _TimePickerDialog(
        initialTime: initialTime,
        use24HourFormat: use24HourFormat,
        minuteInterval: minuteInterval,
        showSeconds: showSeconds,
        title: title,
      ),
    );
  }
}

class _TimePickerDialog extends StatefulWidget {
  const _TimePickerDialog({
    required this.use24HourFormat, required this.minuteInterval, required this.showSeconds, required this.title, this.initialTime,
  });

  final TimeOfDay? initialTime;
  final bool use24HourFormat;
  final int minuteInterval;
  final bool showSeconds;
  final String title;

  @override
  State<_TimePickerDialog> createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<_TimePickerDialog> {
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 300,
        child: AppTimePicker(
          initialTime: widget.initialTime,
          use24HourFormat: widget.use24HourFormat,
          minuteInterval: widget.minuteInterval,
          showSeconds: widget.showSeconds,
          onTimeChanged: (time) => _selectedTime = time,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_selectedTime),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

/// AppTimeInput - Text field with time picker
class AppTimeInput extends StatefulWidget {
  const AppTimeInput({
    super.key,
    this.initialTime,
    this.onTimeChanged,
    this.use24HourFormat = false,
    this.enabled = true,
    this.label,
    this.hint = 'Select time',
    this.validator,
  });

  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay>? onTimeChanged;
  final bool use24HourFormat;
  final bool enabled;
  final String? label;
  final String hint;
  final String? Function(TimeOfDay?)? validator;

  @override
  State<AppTimeInput> createState() => _AppTimeInputState();
}

class _AppTimeInputState extends State<AppTimeInput> {
  TimeOfDay? _selectedTime;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _updateController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateController() {
    if (_selectedTime != null) {
      _controller.text = _formatTime(_selectedTime!);
    } else {
      _controller.clear();
    }
  }

  String _formatTime(TimeOfDay time) {
    if (widget.use24HourFormat) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }

  Future<void> _showTimePicker() async {
    final time = await AppTimePickerDialog.show(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      use24HourFormat: widget.use24HourFormat,
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
      _updateController();
      widget.onTimeChanged?.call(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      readOnly: true,
      onTap: widget.enabled ? _showTimePicker : null,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        suffixIcon: const Icon(Icons.access_time),
        border: const OutlineInputBorder(),
      ),
      validator: widget.validator != null 
          ? (value) => widget.validator!(_selectedTime)
          : null,
    );
  }
}
