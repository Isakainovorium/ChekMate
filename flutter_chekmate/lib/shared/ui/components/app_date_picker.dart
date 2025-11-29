import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppDatePicker - Standalone date picker (different from calendar)
class AppDatePicker extends StatefulWidget {
  const AppDatePicker({
    super.key,
    this.initialDate,
    this.onDateChanged,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.showYearPicker = true,
    this.showMonthPicker = true,
    this.label,
  });

  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDateChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final bool showYearPicker;
  final bool showMonthPicker;
  final String? label;

  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  late DateTime _selectedDate;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();

    _dayController = FixedExtentScrollController(
      initialItem: _selectedDate.day - 1,
    );
    _monthController = FixedExtentScrollController(
      initialItem: _selectedDate.month - 1,
    );
    _yearController = FixedExtentScrollController(
      initialItem: _selectedDate.year - _getFirstYear(),
    );
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  int _getFirstYear() {
    return widget.firstDate?.year ?? DateTime.now().year - 100;
  }

  int _getLastYear() {
    return widget.lastDate?.year ?? DateTime.now().year + 100;
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  void _onDateChanged() {
    widget.onDateChanged?.call(_selectedDate);
  }

  void _updateDay(int day) {
    setState(() {
      _selectedDate =
          DateTime(_selectedDate.year, _selectedDate.month, day + 1);
    });
    _onDateChanged();
  }

  void _updateMonth(int month) {
    final daysInNewMonth = _getDaysInMonth(_selectedDate.year, month + 1);
    final newDay =
        _selectedDate.day > daysInNewMonth ? daysInNewMonth : _selectedDate.day;

    setState(() {
      _selectedDate = DateTime(_selectedDate.year, month + 1, newDay);
    });

    // Update day controller if the day changed
    if (newDay != _selectedDate.day) {
      _dayController.animateToItem(
        newDay - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    _onDateChanged();
  }

  void _updateYear(int yearIndex) {
    final year = _getFirstYear() + yearIndex;
    final daysInMonth = _getDaysInMonth(year, _selectedDate.month);
    final newDay =
        _selectedDate.day > daysInMonth ? daysInMonth : _selectedDate.day;

    setState(() {
      _selectedDate = DateTime(year, _selectedDate.month, newDay);
    });

    // Update day controller if the day changed
    if (newDay != _selectedDate.day) {
      _dayController.animateToItem(
        newDay - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    _onDateChanged();
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
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Day
              Expanded(
                child: _DateColumn(
                  controller: _dayController,
                  itemCount:
                      _getDaysInMonth(_selectedDate.year, _selectedDate.month),
                  itemBuilder: (index) => (index + 1).toString(),
                  onSelectedItemChanged: _updateDay,
                  enabled: widget.enabled,
                  label: 'Day',
                ),
              ),

              // Month
              if (widget.showMonthPicker)
                Expanded(
                  flex: 2,
                  child: _DateColumn(
                    controller: _monthController,
                    itemCount: 12,
                    itemBuilder: (index) => _monthNames[index],
                    onSelectedItemChanged: _updateMonth,
                    enabled: widget.enabled,
                    label: 'Month',
                  ),
                ),

              // Year
              if (widget.showYearPicker)
                Expanded(
                  child: _DateColumn(
                    controller: _yearController,
                    itemCount: _getLastYear() - _getFirstYear() + 1,
                    itemBuilder: (index) =>
                        (_getFirstYear() + index).toString(),
                    onSelectedItemChanged: _updateYear,
                    enabled: widget.enabled,
                    label: 'Year',
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Selected date display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _formatDate(_selectedDate),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.enabled
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _DateColumn extends StatelessWidget {
  const _DateColumn({
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    required this.onSelectedItemChanged,
    required this.enabled,
    required this.label,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int) itemBuilder;
  final ValueChanged<int> onSelectedItemChanged;
  final bool enabled;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Column label
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Scroll wheel
        Expanded(
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 40,
            perspective: 0.005,
            diameterRatio: 1.2,
            physics: enabled
                ? const FixedExtentScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            onSelectedItemChanged: enabled ? onSelectedItemChanged : null,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: itemCount,
              builder: (context, index) {
                return Center(
                  child: Text(
                    itemBuilder(index),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: enabled
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// AppDatePickerDialog - Date picker in a dialog
class AppDatePickerDialog {
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String title = 'Select Date',
  }) {
    return showDialog<DateTime>(
      context: context,
      builder: (context) => _DatePickerDialog(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        title: title,
      ),
    );
  }
}

class _DatePickerDialog extends StatefulWidget {
  const _DatePickerDialog({
    required this.title,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String title;

  @override
  State<_DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 300,
        child: AppDatePicker(
          initialDate: widget.initialDate,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          onDateChanged: (date) => _selectedDate = date,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_selectedDate),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

/// AppDateInput - Text field with date picker
class AppDateInput extends StatefulWidget {
  const AppDateInput({
    super.key,
    this.initialDate,
    this.onDateChanged,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.label,
    this.hint = 'Select date',
    this.validator,
    this.dateFormat = 'MMM dd, yyyy',
  });

  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDateChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final String? label;
  final String hint;
  final String? Function(DateTime?)? validator;
  final String dateFormat;

  @override
  State<AppDateInput> createState() => _AppDateInputState();
}

class _AppDateInputState extends State<AppDateInput> {
  DateTime? _selectedDate;
  final TextEditingController _controller = TextEditingController();

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _updateController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateController() {
    if (_selectedDate != null) {
      _controller.text = _formatDate(_selectedDate!);
    } else {
      _controller.clear();
    }
  }

  String _formatDate(DateTime date) {
    // Simple date formatting - in a real app, you'd use intl package
    switch (widget.dateFormat) {
      case 'MMM dd, yyyy':
        return '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';
      case 'dd/MM/yyyy':
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case 'MM/dd/yyyy':
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      case 'yyyy-MM-dd':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      default:
        return '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  Future<void> _showDatePicker() async {
    final date = await AppDatePickerDialog.show(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
      _updateController();
      widget.onDateChanged?.call(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      readOnly: true,
      onTap: widget.enabled ? _showDatePicker : null,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        suffixIcon: const Icon(Icons.calendar_today),
        border: const OutlineInputBorder(),
      ),
      validator: widget.validator != null
          ? (value) => widget.validator!(_selectedDate)
          : null,
    );
  }
}

/// AppDateRangePicker - Date range selection
class AppDateRangePicker extends StatefulWidget {
  const AppDateRangePicker({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.onDateRangeChanged,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.label,
  });

  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final ValueChanged<DateTimeRange?>? onDateRangeChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final String? label;

  @override
  State<AppDateRangePicker> createState() => _AppDateRangePickerState();
}

class _AppDateRangePickerState extends State<AppDateRangePicker> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  void _onDateRangeChanged() {
    if (_startDate != null && _endDate != null) {
      widget.onDateRangeChanged
          ?.call(DateTimeRange(start: _startDate!, end: _endDate!));
    } else {
      widget.onDateRangeChanged?.call(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Row(
          children: [
            Expanded(
              child: AppDateInput(
                initialDate: _startDate,
                label: 'Start Date',
                firstDate: widget.firstDate,
                lastDate: _endDate ?? widget.lastDate,
                enabled: widget.enabled,
                onDateChanged: (date) {
                  setState(() {
                    _startDate = date;
                    if (_endDate != null && date.isAfter(_endDate!)) {
                      _endDate = null;
                    }
                  });
                  _onDateRangeChanged();
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppDateInput(
                initialDate: _endDate,
                label: 'End Date',
                firstDate: _startDate ?? widget.firstDate,
                lastDate: widget.lastDate,
                enabled: widget.enabled && _startDate != null,
                onDateChanged: (date) {
                  setState(() {
                    _endDate = date;
                  });
                  _onDateRangeChanged();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
