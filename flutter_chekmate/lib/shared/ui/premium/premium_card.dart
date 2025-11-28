import 'package:flutter/material.dart';

/// A premium card container with soft, diffused shadows and super-rounded corners.
///
/// Implements "Option 2" of the visual upgrade plan.
class PremiumCard extends StatelessWidget {
  const PremiumCard({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius = 24.0,
    this.elevation = 1.0,
    this.color,
    this.gradient,
    this.border,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  
  /// Controls the intensity of the shadow. 
  /// 0 = Flat, 1 = Subtle Floating, 2 = High Floating
  final double elevation;
  
  final Color? color;
  final Gradient? gradient;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = color ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);

    Widget content = Container(
      padding: padding,
      width: double.infinity,
      decoration: BoxDecoration(
        color: gradient == null ? backgroundColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
          width: 1,
        ),
        boxShadow: _getPremiumShadows(isDark, elevation),
      ),
      child: child,
    );

    if (onTap != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: content,
          ),
        ),
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: content,
    );
  }

  List<BoxShadow> _getPremiumShadows(bool isDark, double intensity) {
    if (intensity <= 0) return [];

    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.2 * intensity),
          blurRadius: 12 * intensity,
          offset: Offset(0, 4 * intensity),
          spreadRadius: 0,
        ),
      ];
    }

    return [
      // Ambient shadow (soft glow)
      BoxShadow(
        color: const Color(0xFF64748B).withOpacity(0.04 * intensity),
        blurRadius: 24 * intensity,
        offset: const Offset(0, 8),
        spreadRadius: 0,
      ),
      // Direct shadow (grounding)
      BoxShadow(
        color: const Color(0xFF64748B).withOpacity(0.08 * intensity),
        blurRadius: 8 * intensity,
        offset: Offset(0, 4 * intensity),
        spreadRadius: -2,
      ),
    ];
  }
}
