import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/animations/animated_widgets.dart';
import 'package:flutter_chekmate/shared/ui/animations/tiktok_animations.dart';

/// TikTok Animations Example Page
///
/// Demonstrates all TikTok-style animations available in the app.
/// This page showcases:
/// - Fade-in animations
/// - Slide animations
/// - Scale animations
/// - Bounce animations
/// - Shimmer effects
/// - Stagger animations
/// - Interactive animations
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => TikTokAnimationsExample(),
///   ),
/// );
/// ```
class TikTokAnimationsExample extends StatefulWidget {
  const TikTokAnimationsExample({super.key});

  @override
  State<TikTokAnimationsExample> createState() =>
      _TikTokAnimationsExampleState();
}

class _TikTokAnimationsExampleState extends State<TikTokAnimationsExample> {
  int _likeCount = 0;
  int _viewCount = 1234;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('TikTok Animations'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildSection(
            'Fade In Slide',
            'Fade in with slide from bottom (TikTok feed entry)',
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Fade In Slide',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).fadeInSlide(),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            'Fade In Slide Right',
            'Fade in with slide from right (TikTok story entry)',
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Fade In Slide Right',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).fadeInSlideRight(),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            'Scale In',
            'Scale in with fade (TikTok like button)',
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Scale In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).scaleIn(),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            'Bounce In',
            'Bounce in animation (TikTok notification)',
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Bounce In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).bounceIn(),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            'Shimmer Effect',
            'Shimmer loading effect (TikTok loading)',
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Shimmer Effect',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).shimmer(),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            'Staggered List',
            'Stagger animation for list items (TikTok feed)',
            Column(
              children: List.generate(
                5,
                (index) => AnimatedFeedCard(
                  index: index,
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'List Item ${index + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            'Staggered Grid',
            'Stagger animation for grid items (TikTok explore)',
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return AnimatedGridItem(
                  index: index,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            'Interactive Buttons',
            'Animated buttons with tap effects',
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedButton(
                  onTap: () {
                    setState(() {
                      _likeCount++;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.white),
                        const SizedBox(width: AppSpacing.sm),
                        AnimatedCounter(
                          count: _likeCount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedIconButton(
                  icon: Icons.share,
                  size: 32,
                  color: AppColors.primary,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share tapped!')),
                    );
                  },
                ),
                AnimatedIconButton(
                  icon: Icons.bookmark_border,
                  size: 32,
                  color: AppColors.primary,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bookmark tapped!')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            'Animated Counter',
            'Number animation (likes, views, etc.)',
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Views',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AnimatedCounter(
                    count: _viewCount,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _viewCount += 100;
                      });
                    },
                    child: const Text('Add 100 Views'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String description, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }
}

