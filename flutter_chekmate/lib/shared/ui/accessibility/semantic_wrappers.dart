import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Semantic Wrappers for Accessibility
///
/// These widgets enforce accessibility by requiring semantic labels
/// for all interactive and informational elements.
///
/// Usage:
/// ```dart
/// SemanticAction(
///   label: 'Like post',
///   hint: 'Double tap to like this post',
///   onTap: _handleLike,
///   child: Icon(Icons.favorite),
/// )
/// ```
///
/// Sprint 1 - Task 1.1.1
/// Date: November 28, 2025

/// Wrapper for interactive elements (buttons, tappable areas)
class SemanticAction extends StatelessWidget {
  const SemanticAction({
    required this.label,
    required this.onTap,
    required this.child,
    super.key,
    this.hint,
    this.isButton = true,
    this.isSelected,
    this.isEnabled = true,
    this.isToggled,
    this.onLongPress,
    this.excludeSemantics = false,
  });

  /// The accessibility label read by screen readers
  final String label;

  /// Optional hint providing additional context
  final String? hint;

  /// The tap handler
  final VoidCallback? onTap;

  /// Optional long press handler
  final VoidCallback? onLongPress;

  /// The child widget to wrap
  final Widget child;

  /// Whether this is a button (default: true)
  final bool isButton;

  /// Whether this element is currently selected (for toggles)
  final bool? isSelected;

  /// Whether this element is enabled
  final bool isEnabled;

  /// Whether this element is toggled on/off
  final bool? isToggled;

  /// Whether to exclude child semantics
  final bool excludeSemantics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      selected: isSelected,
      enabled: isEnabled,
      toggled: isToggled,
      onTap: isEnabled ? onTap : null,
      onLongPress: isEnabled ? onLongPress : null,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }
}

/// Wrapper for informational/label elements
class SemanticLabel extends StatelessWidget {
  const SemanticLabel({
    required this.label,
    required this.child,
    super.key,
    this.isHeader = false,
    this.isImage = false,
    this.isLink = false,
    this.excludeSemantics = true,
  });

  /// The accessibility label
  final String label;

  /// The child widget
  final Widget child;

  /// Whether this is a header element
  final bool isHeader;

  /// Whether this represents an image
  final bool isImage;

  /// Whether this is a link
  final bool isLink;

  /// Whether to exclude child semantics (default: true for labels)
  final bool excludeSemantics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      header: isHeader,
      image: isImage,
      link: isLink,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }
}

/// Wrapper for screen regions (navigation, content areas)
class SemanticRegion extends StatelessWidget {
  const SemanticRegion({
    required this.label,
    required this.child,
    super.key,
    this.isLiveRegion = false,
    this.sortKey,
  });

  /// The region label
  final String label;

  /// The child widget
  final Widget child;

  /// Whether this is a live region (announces changes)
  final bool isLiveRegion;

  /// Optional sort key for focus order
  final SemanticsSortKey? sortKey;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      container: true,
      liveRegion: isLiveRegion,
      sortKey: sortKey,
      child: child,
    );
  }
}

/// Wrapper for list items with index information
class SemanticListItem extends StatelessWidget {
  const SemanticListItem({
    required this.label,
    required this.index,
    required this.total,
    required this.child,
    super.key,
  });

  /// The item label
  final String label;

  /// The item index (0-based)
  final int index;

  /// Total number of items
  final int total;

  /// The child widget
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label, item ${index + 1} of $total',
      child: child,
    );
  }
}

/// Wrapper to exclude decorative elements from accessibility tree
class SemanticExclude extends StatelessWidget {
  const SemanticExclude({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: child,
    );
  }
}

/// Wrapper for images with alt text
class SemanticImage extends StatelessWidget {
  const SemanticImage({
    required this.label,
    required this.child,
    super.key,
    this.isDecorative = false,
  });

  /// Alt text for the image
  final String label;

  /// The image widget
  final Widget child;

  /// Whether this is a decorative image (excluded from accessibility)
  final bool isDecorative;

  @override
  Widget build(BuildContext context) {
    if (isDecorative) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(
      label: label,
      image: true,
      child: child,
    );
  }
}

/// Extension to easily add semantics to any widget
extension SemanticExtensions on Widget {
  /// Wrap with action semantics
  Widget withSemanticAction({
    required String label,
    required VoidCallback onTap,
    String? hint,
    bool isSelected = false,
  }) {
    return SemanticAction(
      label: label,
      hint: hint,
      onTap: onTap,
      isSelected: isSelected,
      child: this,
    );
  }

  /// Wrap with label semantics
  Widget withSemanticLabel(String label, {bool isHeader = false}) {
    return SemanticLabel(
      label: label,
      isHeader: isHeader,
      child: this,
    );
  }

  /// Exclude from accessibility tree
  Widget excludeFromSemantics() {
    return SemanticExclude(child: this);
  }
}
