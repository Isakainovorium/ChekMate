import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

/// EmojiPickerWidget - Shared UI Component
///
/// A customizable emoji picker widget using emoji_picker_flutter package.
/// Supports text input integration and recent emojis.
/// **Uses Apple-style emojis on iOS devices for native look and feel.**
///
/// Features:
/// - Full emoji keyboard with **Apple emoji rendering on iOS** (1.2x size)
/// - Recent emojis tracking
/// - Search functionality
/// - Category navigation (Recent, Smileys, Animals, Food, etc.)
/// - Skin tone selection
/// - Text controller integration
/// - Platform-specific emoji rendering
/// - Cupertino-style UI on iOS
///
/// Usage:
/// ```dart
/// EmojiPickerWidget(
///   onEmojiSelected: (emoji) {
///     print('Selected: ${emoji.emoji}');
///   },
/// )
/// ```
class EmojiPickerWidget extends StatelessWidget {
  const EmojiPickerWidget({
    super.key,
    this.onEmojiSelected,
    this.textEditingController,
    this.scrollController,
    this.height = 250,
    this.backgroundColor,
    this.indicatorColor,
    this.iconColor,
    this.iconColorSelected,
    this.backspaceColor,
    this.skinToneDialogBgColor,
    this.skinToneIndicatorColor,
    this.enableSkinTones = true,
    this.showRecentsTab = true,
    this.recentsLimit = 28,
    this.replaceEmojiOnLimitExceed = false,
    this.noRecents,
    this.loadingIndicator,
    this.tabIndicatorAnimDuration = kTabScrollDuration,
    this.categoryIcons = const CategoryIcons(),
    this.buttonMode = ButtonMode.MATERIAL,
    this.checkPlatformCompatibility = true,
    this.emojiSet,
  });

  /// Callback when an emoji is selected
  final void Function(Emoji emoji)? onEmojiSelected;

  /// Text editing controller to insert emojis into
  final TextEditingController? textEditingController;

  /// Scroll controller for the text field
  final ScrollController? scrollController;

  /// Height of the emoji picker
  final double height;

  /// Background color
  final Color? backgroundColor;

  /// Indicator color for selected category
  final Color? indicatorColor;

  /// Icon color
  final Color? iconColor;

  /// Selected icon color
  final Color? iconColorSelected;

  /// Backspace button color
  final Color? backspaceColor;

  /// Skin tone dialog background color
  final Color? skinToneDialogBgColor;

  /// Skin tone indicator color
  final Color? skinToneIndicatorColor;

  /// Enable skin tone selection
  final bool enableSkinTones;

  /// Show recents tab
  final bool showRecentsTab;

  /// Number of recent emojis to show
  final int recentsLimit;

  /// Replace emoji on limit exceed
  final bool replaceEmojiOnLimitExceed;

  /// Widget to show when no recents
  final Widget? noRecents;

  /// Loading indicator widget
  final Widget? loadingIndicator;

  /// Tab indicator animation duration
  final Duration tabIndicatorAnimDuration;

  /// Category icons
  final CategoryIcons categoryIcons;

  /// Button mode
  final ButtonMode buttonMode;

  /// Check platform compatibility
  final bool checkPlatformCompatibility;

  /// Custom emoji set
  final List<CategoryEmoji>? emojiSet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIOS = foundation.defaultTargetPlatform == TargetPlatform.iOS;

    return EmojiPicker(
      onEmojiSelected: (category, emoji) {
        onEmojiSelected?.call(emoji);
      },
      textEditingController: textEditingController,
      scrollController: scrollController,
      config: Config(
        height: height,
        checkPlatformCompatibility: checkPlatformCompatibility,
        emojiViewConfig: EmojiViewConfig(
          // Use larger emoji size on iOS for Apple emoji rendering
          // This ensures Apple emojis look native and crisp on iOS devices
          emojiSizeMax: 28 * (isIOS ? 1.2 : 1.0),
          backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
          columns: 7,
          recentsLimit: recentsLimit,
          replaceEmojiOnLimitExceed: replaceEmojiOnLimitExceed,
          noRecents: noRecents ??
              Center(
                child: Text(
                  'No recent emojis',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
          loadingIndicator: loadingIndicator ??
              const Center(child: CircularProgressIndicator()),
          buttonMode: buttonMode,
          // emojiSet parameter removed - not available in current emoji_picker_flutter version
        ),
        skinToneConfig: SkinToneConfig(
          enabled: enableSkinTones,
          dialogBackgroundColor: skinToneDialogBgColor ??
              theme.dialogTheme.backgroundColor ??
              theme.colorScheme.surface,
          indicatorColor: skinToneIndicatorColor ?? theme.primaryColor,
        ),
        categoryViewConfig: CategoryViewConfig(
          backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
          indicatorColor: indicatorColor ?? theme.primaryColor,
          iconColor: iconColor ?? theme.iconTheme.color ?? Colors.grey,
          iconColorSelected: iconColorSelected ?? theme.primaryColor,
          backspaceColor: backspaceColor ?? theme.colorScheme.error,
          categoryIcons: categoryIcons,
          tabIndicatorAnimDuration: tabIndicatorAnimDuration,
          showBackspaceButton: true,
        ),
        bottomActionBarConfig: BottomActionBarConfig(
          backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
          buttonColor: iconColor ?? theme.iconTheme.color ?? Colors.grey,
          buttonIconColor: backgroundColor ?? theme.scaffoldBackgroundColor,
        ),
        searchViewConfig: SearchViewConfig(
          backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
          buttonIconColor: iconColor ?? theme.iconTheme.color ?? Colors.grey,
        ),
      ),
    );
  }
}

/// EmojiPickerBottomSheet - Convenience widget for showing emoji picker in bottom sheet
///
/// **Automatically uses Apple emojis on iOS devices.**
///
/// Usage:
/// ```dart
/// EmojiPickerBottomSheet.show(
///   context: context,
///   onEmojiSelected: (emoji) {
///     print('Selected: ${emoji.emoji}');
///   },
/// );
/// ```
class EmojiPickerBottomSheet {
  static Future<Emoji?> show({
    required BuildContext context,
    double height = 250,
    bool enableSkinTones = true,
    bool showRecentsTab = true,
  }) async {
    Emoji? selectedEmoji;
    final isIOS = foundation.defaultTargetPlatform == TargetPlatform.iOS;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: height + MediaQuery.of(context).padding.bottom,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar (iOS-style on iOS)
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isIOS ? CupertinoColors.systemGrey3 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Emoji picker with Apple emojis on iOS
            Expanded(
              child: EmojiPickerWidget(
                height: height,
                enableSkinTones: enableSkinTones,
                showRecentsTab: showRecentsTab,
                onEmojiSelected: (emoji) {
                  selectedEmoji = emoji;
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );

    return selectedEmoji;
  }
}

/// AppleEmojiText - Helper widget to display text with Apple-style emojis
///
/// This widget ensures emojis are rendered with Apple's emoji font on iOS.
///
/// Usage:
/// ```dart
/// AppleEmojiText(
///   text: 'Hello 👋 World 🌍',
///   style: TextStyle(fontSize: 16),
/// )
/// ```
class AppleEmojiText extends StatelessWidget {
  const AppleEmojiText({
    required this.text,
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final isIOS = foundation.defaultTargetPlatform == TargetPlatform.iOS;

    // On iOS, use default system font which includes Apple Color Emoji
    // On other platforms, use default emoji rendering
    return Text(
      text,
      style: isIOS
          ? (style ?? const TextStyle()).copyWith(
              fontFamily: '.SF UI Text', // iOS system font with emoji support
            )
          : style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
