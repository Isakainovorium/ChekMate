import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// Top app header - converted from Header.tsx
///
/// Features:
/// - ChekMate logo/title
/// - Search bar
/// - Auto-hide on scroll down
/// - Show on scroll up
/// - Sticky positioning
class HeaderWidget extends StatefulWidget {
  const HeaderWidget({
    super.key,
    this.scrollController,
    this.onSearch,
  });
  final ScrollController? scrollController;
  final void Function(String)? onSearch;

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  bool _isVisible = true;
  double _lastScrollOffset = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentScrollOffset = widget.scrollController?.offset ?? 0;

    // Only hide/show if scrolled past threshold
    if (currentScrollOffset > 100) {
      // Scrolling down - hide header
      if (currentScrollOffset > _lastScrollOffset && _isVisible) {
        setState(() {
          _isVisible = false;
        });
      }
      // Scrolling up - show header
      else if (currentScrollOffset < _lastScrollOffset && !_isVisible) {
        setState(() {
          _isVisible = true;
        });
      }
    } else {
      // At top - always show
      if (!_isVisible) {
        setState(() {
          _isVisible = true;
        });
      }
    }

    _lastScrollOffset = currentScrollOffset;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(
        0,
        _isVisible ? 0 : -100,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade100,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                // Logo/Title
                const Text(
                  'ChekMate',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                // Search bar
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: widget.onSearch,
                      decoration: InputDecoration(
                        hintText: 'Search here ...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 18,
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
