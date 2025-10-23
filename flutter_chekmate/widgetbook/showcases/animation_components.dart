import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:widgetbook/widgetbook.dart';

/// Animation Components Showcases
///
/// Interactive showcases for all animation-related components:
/// 1. TikTokAnimations
/// 2. AnimatedWidgets
/// 3. PageTransitions
/// 4. HeroAnimations
/// 5. SharedElementTransitions
class AnimationComponentShowcases {
  static List<WidgetbookComponent> get showcases => [
        // TikTokAnimations
        WidgetbookComponent(
          name: 'TikTokAnimations',
          useCases: [
            WidgetbookUseCase(
              name: 'Fade In',
              builder: (context) => Container(
                padding: const EdgeInsets.all(16),
                child: const Text('Fade In Animation')
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 600)),
              ),
            ),
            WidgetbookUseCase(
              name: 'Slide In',
              builder: (context) => Container(
                padding: const EdgeInsets.all(16),
                child: const Text('Slide In Animation')
                    .animate()
                    .slideX(begin: -1, end: 0),
              ),
            ),
            WidgetbookUseCase(
              name: 'Scale',
              builder: (context) => Container(
                padding: const EdgeInsets.all(16),
                child: const Text('Scale Animation')
                    .animate()
                    .scale(begin: const Offset(0, 0), end: const Offset(1, 1)),
              ),
            ),
          ],
        ),

        // AnimatedWidgets
        WidgetbookComponent(
          name: 'AnimatedWidgets',
          useCases: [
            WidgetbookUseCase(
              name: 'AnimatedFeedCard',
              builder: (context) => const AnimatedFeedCard(
                child: AppCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Animated Feed Card'),
                  ),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'AnimatedStoryCircle',
              builder: (context) => const AnimatedStoryCircle(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      NetworkImage('https://i.pravatar.cc/150?img=1'),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'AnimatedButton',
              builder: (context) => AnimatedButton(
                onTap: () {},
                child: const Text('Animated Button'),
              ),
            ),
            WidgetbookUseCase(
              name: 'AnimatedCounter',
              builder: (context) => AnimatedCounter(
                count: context.knobs.int.slider(
                  label: 'Count',
                  initialValue: 100,
                  max: 1000,
                ),
              ),
            ),
          ],
        ),

        // PageTransitions
        WidgetbookComponent(
          name: 'PageTransitions',
          useCases: [
            WidgetbookUseCase(
              name: 'Slide Transition',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      TikTokPageRoute<void>(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: const Text('New Page')),
                          body: const Center(child: Text('Slide Transition')),
                        ),
                      ),
                    );
                  },
                  child: const Text('Show Slide Transition'),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Fade Transition',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      FadeThroughPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: const Text('New Page')),
                          body: const Center(child: Text('Fade Transition')),
                        ),
                      ),
                    );
                  },
                  child: const Text('Show Fade Transition'),
                ),
              ),
            ),
          ],
        ),

        // HeroAnimations
        WidgetbookComponent(
          name: 'HeroAnimations',
          useCases: [
            WidgetbookUseCase(
              name: 'Hero Image',
              builder: (context) => Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: const Text('Hero Detail')),
                          body: Center(
                            child: Hero(
                              tag: 'hero-image',
                              child: Image.network(
                                'https://picsum.photos/400/400',
                                width: 300,
                                height: 300,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'hero-image',
                    child: Image.network(
                      'https://picsum.photos/400/400',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // SharedElementTransitions
        WidgetbookComponent(
          name: 'SharedElementTransitions',
          useCases: [
            WidgetbookUseCase(
              name: 'Shared Axis',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      SharedAxisPageRoute<void>(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: const Text('Shared Axis')),
                          body: const Center(
                            child: Text('Shared Axis Transition'),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Show Shared Axis'),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Fade Through',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      FadeThroughPageRoute<void>(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: const Text('Fade Through')),
                          body: const Center(
                            child: Text('Fade Through Transition'),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Show Fade Through'),
                ),
              ),
            ),
          ],
        ),
      ];
}
