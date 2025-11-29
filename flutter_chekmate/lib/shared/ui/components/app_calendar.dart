import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppCalendar - Date picker calendar with consistent styling
class AppCalendar extends StatefulWidget {
  const AppCalendar({
    super.key,
    this.selectedDate,
    this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.enabledDates,
    this.disabledDates,
    this.showHeader = true,
    this.showWeekdays = true,
    this.compactMode = false,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Set<DateTime>? enabledDates;
  final Set<DateTime>? disabledDates;
  final bool showHeader;
  final bool showWeekdays;
  final bool compactMode;

  @override
  State<AppCalendar> createState() => _AppCalendarState();
}

class _AppCalendarState extends State<AppCalendar> {
  late DateTime _displayedMonth;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _displayedMonth = DateTime(
      widget.selectedDate?.year ?? _today.year,
      widget.selectedDate?.month ?? _today.month,
    );
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  bool _isDateEnabled(DateTime date) {
    if (widget.firstDate != null && date.isBefore(widget.firstDate!)) {
      return false;
    }
    if (widget.lastDate != null && date.isAfter(widget.lastDate!)) {
      return false;
    }
    if (widget.enabledDates != null) {
      return widget.enabledDates!.contains(date);
    }
    if (widget.disabledDates != null) {
      return !widget.disabledDates!.contains(date);
    }
    return true;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          if (widget.showHeader)
            _CalendarHeader(
              displayedMonth: _displayedMonth,
              onPreviousMonth: _previousMonth,
              onNextMonth: _nextMonth,
              compactMode: widget.compactMode,
            ),
          
          // Weekdays
          if (widget.showWeekdays)
            _CalendarWeekdays(compactMode: widget.compactMode),
          
          // Calendar grid
          _CalendarGrid(
            displayedMonth: _displayedMonth,
            selectedDate: widget.selectedDate,
            today: _today,
            onDateSelected: widget.onDateSelected,
            isDateEnabled: _isDateEnabled,
            isSameDay: _isSameDay,
            compactMode: widget.compactMode,
          ),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.displayedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.compactMode,
  });

  final DateTime displayedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final bool compactMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    
    return Container(
      padding: EdgeInsets.all(compactMode ? AppSpacing.sm : AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPreviousMonth,
            icon: const Icon(Icons.chevron_left),
            iconSize: compactMode ? 20 : 24,
          ),
          Text(
            '${monthNames[displayedMonth.month - 1]} ${displayedMonth.year}',
            style: (compactMode ? theme.textTheme.titleMedium : theme.textTheme.titleLarge)?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: onNextMonth,
            icon: const Icon(Icons.chevron_right),
            iconSize: compactMode ? 20 : 24,
          ),
        ],
      ),
    );
  }
}

class _CalendarWeekdays extends StatelessWidget {
  const _CalendarWeekdays({required this.compactMode});

  final bool compactMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compactMode ? AppSpacing.sm : AppSpacing.md,
        vertical: compactMode ? AppSpacing.xs : AppSpacing.sm,
      ),
      child: Row(
        children: weekdays.map((day) => Expanded(
          child: Center(
            child: Text(
              day,
              style: (compactMode ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),).toList(),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.displayedMonth,
    required this.selectedDate,
    required this.today,
    required this.onDateSelected,
    required this.isDateEnabled,
    required this.isSameDay,
    required this.compactMode,
  });

  final DateTime displayedMonth;
  final DateTime? selectedDate;
  final DateTime today;
  final ValueChanged<DateTime>? onDateSelected;
  final bool Function(DateTime) isDateEnabled;
  final bool Function(DateTime, DateTime) isSameDay;
  final bool compactMode;

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(displayedMonth.year, displayedMonth.month);
    final lastDayOfMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0);
    final firstDayOfWeek = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;
    
    final dayWidgets = <Widget>[];
    
    // Empty cells for days before the first day of the month
    for (var i = 0; i < firstDayOfWeek; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }
    
    // Days of the month
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(displayedMonth.year, displayedMonth.month, day);
      dayWidgets.add(
        _CalendarDay(
          date: date,
          isSelected: selectedDate != null && isSameDay(date, selectedDate!),
          isToday: isSameDay(date, today),
          isEnabled: isDateEnabled(date),
          onTap: onDateSelected != null ? () => onDateSelected!(date) : null,
          compactMode: compactMode,
        ),
      );
    }
    
    return Padding(
      padding: EdgeInsets.all(compactMode ? AppSpacing.sm : AppSpacing.md),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 7,
        mainAxisSpacing: compactMode ? 2 : 4,
        crossAxisSpacing: compactMode ? 2 : 4,
        children: dayWidgets,
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.isEnabled,
    required this.onTap,
    required this.compactMode,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isEnabled;
  final VoidCallback? onTap;
  final bool compactMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(compactMode ? 4 : 8),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary
              : isToday 
                  ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                  : null,
          borderRadius: BorderRadius.circular(compactMode ? 4 : 8),
          border: isToday && !isSelected
              ? Border.all(color: theme.colorScheme.primary)
              : null,
        ),
        child: Center(
          child: Text(
            date.day.toString(),
            style: (compactMode ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : isEnabled
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.4),
              fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

/// AppDatePicker - Simple date picker dialog
class AppDatePicker {
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return showDialog<DateTime>(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppCalendar(
                selectedDate: initialDate,
                firstDate: firstDate,
                lastDate: lastDate,
                onDateSelected: (date) => Navigator.of(context).pop(date),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
