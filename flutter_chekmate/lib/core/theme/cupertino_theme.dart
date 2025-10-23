import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';

/// Cupertino Theme Configuration
///
/// Provides iOS-native styling using Cupertino widgets and design patterns.
/// Automatically applies iOS-specific styling when running on iOS devices.
class AppCupertinoTheme {
  /// Check if the current platform is iOS
  static bool get isIOS =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  /// Cupertino Theme Data
  static CupertinoThemeData get theme => CupertinoThemeData(
        primaryColor: AppColors.primary,
        primaryContrastingColor: CupertinoColors.white,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
        barBackgroundColor: CupertinoColors.systemBackground,
        textTheme: cupertinoTextTheme,
      );

  /// Cupertino Text Theme
  static CupertinoTextThemeData get cupertinoTextTheme =>
      const CupertinoTextThemeData(
        primaryColor: CupertinoColors.label,
        textStyle: TextStyle(
          fontFamily: '.SF UI Text',
          fontSize: 17,
          letterSpacing: -0.41,
          color: CupertinoColors.label,
        ),
        actionTextStyle: TextStyle(
          fontFamily: '.SF UI Text',
          fontSize: 17,
          letterSpacing: -0.41,
          color: CupertinoColors.activeBlue,
        ),
        tabLabelTextStyle: TextStyle(
          fontFamily: '.SF UI Text',
          fontSize: 10,
          letterSpacing: -0.24,
          color: CupertinoColors.inactiveGray,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: '.SF UI Display',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
          color: CupertinoColors.label,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: '.SF UI Display',
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.41,
          color: CupertinoColors.label,
        ),
        navActionTextStyle: TextStyle(
          fontFamily: '.SF UI Text',
          fontSize: 17,
          letterSpacing: -0.41,
          color: CupertinoColors.activeBlue,
        ),
        pickerTextStyle: TextStyle(
          fontFamily: '.SF UI Text',
          fontSize: 21,
          letterSpacing: -0.6,
          color: CupertinoColors.label,
        ),
        dateTimePickerTextStyle: TextStyle(
          fontFamily: '.SF UI Text',
          fontSize: 21,
          letterSpacing: -0.6,
          color: CupertinoColors.label,
        ),
      );

  /// iOS System Colors
  static const systemRed = CupertinoColors.systemRed;
  static const systemGreen = CupertinoColors.systemGreen;
  static const systemBlue = CupertinoColors.systemBlue;
  static const systemOrange = CupertinoColors.systemOrange;
  static const systemYellow = CupertinoColors.systemYellow;
  static const systemPink = CupertinoColors.systemPink;
  static const systemPurple = CupertinoColors.systemPurple;
  static const systemTeal = CupertinoColors.systemTeal;
  static const systemIndigo = CupertinoColors.systemIndigo;
  static const systemGray = CupertinoColors.systemGrey;

  /// iOS System Grays
  static const systemGray2 = CupertinoColors.systemGrey2;
  static const systemGray3 = CupertinoColors.systemGrey3;
  static const systemGray4 = CupertinoColors.systemGrey4;
  static const systemGray5 = CupertinoColors.systemGrey5;
  static const systemGray6 = CupertinoColors.systemGrey6;

  /// iOS Label Colors
  static const label = CupertinoColors.label;
  static const secondaryLabel = CupertinoColors.secondaryLabel;
  static const tertiaryLabel = CupertinoColors.tertiaryLabel;
  static const quaternaryLabel = CupertinoColors.quaternaryLabel;

  /// iOS Background Colors
  static const systemBackground = CupertinoColors.systemBackground;
  static const secondarySystemBackground =
      CupertinoColors.secondarySystemBackground;
  static const tertiarySystemBackground =
      CupertinoColors.tertiarySystemBackground;
  static const systemGroupedBackground =
      CupertinoColors.systemGroupedBackground;
  static const secondarySystemGroupedBackground =
      CupertinoColors.secondarySystemGroupedBackground;
  static const tertiarySystemGroupedBackground =
      CupertinoColors.tertiarySystemGroupedBackground;

  /// iOS Fill Colors
  static const systemFill = CupertinoColors.systemFill;
  static const secondarySystemFill = CupertinoColors.secondarySystemFill;
  static const tertiarySystemFill = CupertinoColors.tertiarySystemFill;
  static const quaternarySystemFill = CupertinoColors.quaternarySystemFill;

  /// iOS Separator Colors
  static const separator = CupertinoColors.separator;
  static const opaqueSeparator = CupertinoColors.opaqueSeparator;

  /// iOS Link Color
  static const link = CupertinoColors.link;

  /// iOS Placeholder Text Color
  static const placeholderText = CupertinoColors.placeholderText;

  /// iOS Active Colors
  static const activeBlue = CupertinoColors.activeBlue;
  static const activeGreen = CupertinoColors.activeGreen;
  static const activeOrange = CupertinoColors.activeOrange;

  /// iOS Inactive Gray
  static const inactiveGray = CupertinoColors.inactiveGray;

  /// iOS Destructive Red
  static const destructiveRed = CupertinoColors.destructiveRed;

  /// iOS White
  static const white = CupertinoColors.white;

  /// iOS Black
  static const black = CupertinoColors.black;
}

/// Cupertino Helper Widgets
class CupertinoHelpers {
  /// Show iOS-style action sheet
  static Future<T?> showActionSheet<T>({
    required BuildContext context,
    required String title,
    required List<CupertinoActionSheetAction> actions,
    String? message,
    CupertinoActionSheetAction? cancelAction,
  }) {
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(title),
        message: message != null ? Text(message) : null,
        actions: actions,
        cancelButton: cancelAction ??
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
      ),
    );
  }

  /// Show iOS-style alert dialog
  static Future<T?> showAlertDialog<T>({
    required BuildContext context,
    required String title,
    required List<CupertinoDialogAction> actions,
    String? message,
  }) {
    return showCupertinoDialog<T>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: message != null ? Text(message) : null,
        actions: actions,
      ),
    );
  }

  /// Show iOS-style date picker
  static Future<DateTime?> showDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? minimumDate,
    DateTime? maximumDate,
    CupertinoDatePickerMode mode = CupertinoDatePickerMode.date,
  }) {
    DateTime? selectedDate = initialDate;

    return showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            // Header with Done button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context, selectedDate),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            // Date Picker
            Expanded(
              child: CupertinoDatePicker(
                mode: mode,
                initialDateTime: initialDate,
                minimumDate: minimumDate,
                maximumDate: maximumDate,
                onDateTimeChanged: (date) {
                  selectedDate = date;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show iOS-style picker
  static Future<T?> showPicker<T>({
    required BuildContext context,
    required List<T> items,
    required String Function(T) itemBuilder,
    T? initialItem,
  }) {
    T? selectedItem = initialItem ?? items.first;

    return showCupertinoModalPopup<T>(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            // Header with Done button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context, selectedItem),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            // Picker
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  selectedItem = items[index];
                },
                children: items.map((item) => Text(itemBuilder(item))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
