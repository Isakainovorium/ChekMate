import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// Shared Element Transitions Example
///
/// Demonstrates all shared element transitions and hero animations.
class SharedElementExamplePage extends StatelessWidget {
  const SharedElementExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Element Transitions'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Hero Animations Section
          _buildSectionHeader('Hero Animations'),
          const SizedBox(height: AppSpacing.sm),
          _buildHeroExamples(context),
          const SizedBox(height: AppSpacing.lg),

          // OpenContainer Section
          _buildSectionHeader('OpenContainer Transitions'),
          const SizedBox(height: AppSpacing.sm),
          _buildOpenContainerExamples(context),
          const SizedBox(height: AppSpacing.lg),

          // Page Transitions Section
          _buildSectionHeader('Page Transitions'),
          const SizedBox(height: AppSpacing.sm),
          _buildPageTransitionExamples(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildHeroExamples(BuildContext context) {
    return Column(
      children: [
        // Hero Image Example
        AppCard(
          child: ListTile(
            leading: HeroImage(
              tag: 'hero-image-example',
              imageUrl: 'https://picsum.photos/200',
              width: 50,
              height: 50,
              borderRadius: BorderRadius.circular(8),
            ),
            title: const Text('Hero Image'),
            subtitle: const Text('Tap to see image transition'),
            onTap: () => _showHeroImageDetail(context),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Hero Avatar Example
        AppCard(
          child: ListTile(
            leading: const HeroAvatar(
              tag: 'hero-avatar-example',
              imageUrl: 'https://picsum.photos/200',
              radius: 25,
              name: 'John Doe',
            ),
            title: const Text('Hero Avatar'),
            subtitle: const Text('Tap to see avatar transition'),
            onTap: () => _showHeroAvatarDetail(context),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Hero Card Example
        HeroCard(
          tag: 'hero-card-example',
          child: InkWell(
            onTap: () => _showHeroCardDetail(context),
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hero Card',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text('Tap to see card transition'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOpenContainerExamples(BuildContext context) {
    return Column(
      children: [
        // Fade Transition
        AppOpenContainer(
          closedBuilder: (context, action) => AppCard(
            child: InkWell(
              onTap: action,
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(Icons.animation, color: AppColors.primary),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fade Transition',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Tap to see fade transition',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          openBuilder: (context, action) => const _DetailPage(
            title: 'Fade Transition',
            description: 'This page faded in smoothly',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Fade Through Transition
        AppOpenContainer(
          transitionType: ContainerTransitionType.fadeThrough,
          closedBuilder: (context, action) => AppCard(
            child: InkWell(
              onTap: action,
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz, color: AppColors.primary),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fade Through Transition',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Tap to see fade through transition',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          openBuilder: (context, action) => const _DetailPage(
            title: 'Fade Through Transition',
            description: 'This page faded through smoothly',
          ),
        ),
      ],
    );
  }

  Widget _buildPageTransitionExamples(BuildContext context) {
    return Column(
      children: [
        AppCard(
          child: ListTile(
            leading: const Icon(Icons.arrow_forward, color: AppColors.primary),
            title: const Text('Shared Axis (Horizontal)'),
            subtitle: const Text('Slide from right'),
            onTap: () => Navigator.push(
              context,
              SharedAxisPageRoute<dynamic>(
                builder: (context) => const _DetailPage(
                  title: 'Shared Axis Horizontal',
                  description: 'Slid in from the right',
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: ListTile(
            leading: const Icon(Icons.arrow_upward, color: AppColors.primary),
            title: const Text('Shared Axis (Vertical)'),
            subtitle: const Text('Slide from bottom'),
            onTap: () => Navigator.push(
              context,
              SharedAxisPageRoute<dynamic>(
                builder: (context) => const _DetailPage(
                  title: 'Shared Axis Vertical',
                  description: 'Slid in from the bottom',
                ),
                transitionType: SharedAxisTransitionType.vertical,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: ListTile(
            leading: const Icon(Icons.layers, color: AppColors.primary),
            title: const Text('Fade Through'),
            subtitle: const Text('Fade through transition'),
            onTap: () => Navigator.push(
              context,
              FadeThroughPageRoute<dynamic>(
                builder: (context) => const _DetailPage(
                  title: 'Fade Through',
                  description: 'Faded through smoothly',
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: ListTile(
            leading: const Icon(Icons.zoom_in, color: AppColors.primary),
            title: const Text('Fade Scale'),
            subtitle: const Text('Fade and scale transition'),
            onTap: () => Navigator.push(
              context,
              FadeScalePageRoute<dynamic>(
                builder: (context) => const _DetailPage(
                  title: 'Fade Scale',
                  description: 'Faded and scaled in',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showHeroImageDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<dynamic>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Hero Image Detail')),
          body: Center(
            child: HeroImage(
              tag: 'hero-image-example',
              imageUrl: 'https://picsum.photos/200',
              width: 300,
              height: 300,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  void _showHeroAvatarDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<dynamic>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Hero Avatar Detail')),
          body: const Center(
            child: HeroAvatar(
              tag: 'hero-avatar-example',
              imageUrl: 'https://picsum.photos/200',
              radius: 100,
              name: 'John Doe',
            ),
          ),
        ),
      ),
    );
  }

  void _showHeroCardDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<dynamic>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Hero Card Detail')),
          body: const Center(
            child: HeroCard(
              tag: 'hero-card-example',
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hero Card Detail',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text('This card transitioned smoothly!'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Detail Page for Examples
class _DetailPage extends StatelessWidget {
  const _DetailPage({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                description,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
