import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// Explore Grid Widget
///
/// Displays a masonry-style grid layout similar to Instagram Explore.
/// Shows posts in a staggered grid with 3 columns and minimal spacing.
class ExploreGridWidget extends StatefulWidget {
  const ExploreGridWidget({super.key});

  @override
  State<ExploreGridWidget> createState() => _ExploreGridWidgetState();
}

class _ExploreGridWidgetState extends State<ExploreGridWidget> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return MasonryGridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      padding: const EdgeInsets.all(2),
      itemCount: 20, // Mock data for testing
      itemBuilder: (context, index) {
        // Create varied heights for masonry effect
        final height = 100 + (index % 3) * 50.0;

        return GestureDetector(
          onTap: () {
            // Handle item tap - for now just a no-op
            // In real implementation, this would navigate to post detail
          },
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                // Mock image placeholder
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.withValues(alpha: 0.3),
                        Colors.purple.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Overlay with item number for testing
                Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
