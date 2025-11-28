import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';

/// A floating glassmorphic navigation bar.
///
/// Used to replace the standard bottom navigation bar with a modern, premium alternative.
class PremiumGlassNavBar extends StatelessWidget {
  const PremiumGlassNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
    super.key,
    this.height = 70.0,
    this.margin = const EdgeInsets.fromLTRB(24, 0, 24, 24),
  });

  final int currentIndex;
  final List<BottomNavigationBarItem> items;
  final ValueChanged<int> onTap;
  final double height;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: isDark 
                ? Colors.black.withOpacity(0.7) 
                : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: isDark 
                  ? Colors.white.withOpacity(0.1) 
                  : Colors.white.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (index) {
                final isSelected = index == currentIndex;
                final item = items[index];
                
                return GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected 
                              ? (isDark ? Colors.white.withOpacity(0.1) : AppColors.primary.withOpacity(0.1))
                              : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: IconTheme(
                            data: IconThemeData(
                              color: isSelected 
                                ? (isDark ? Colors.white : AppColors.primary)
                                : (isDark ? Colors.white54 : Colors.black45),
                              size: 24,
                            ),
                            child: item.icon is Icon ? item.icon : const Icon(Icons.error),
                          ),
                        ),
                        if (isSelected && item.label != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              item.label!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
