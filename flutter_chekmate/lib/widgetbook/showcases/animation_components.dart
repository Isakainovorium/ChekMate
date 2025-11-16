import 'package:flutter/material.dart' hide AnimatedScale;
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_chekmate/shared/ui/animations/micro_interactions.dart';
import 'package:widgetbook/widgetbook.dart';

/// Animation Components Showcases
///
/// Interactive showcases for all animation components:
/// 1. AnimatedFadeIn
/// 2. AnimatedSlideIn
/// 3. AnimatedScale
/// 4. AnimatedButton
/// 5. AnimatedCard
/// 6. HeroImage
/// 7. HeroAvatar
/// 8. TikTokPageTransition
/// 9. SlidePageRoute
/// 10. FadePageRoute
/// 11. BounceAnimation
/// 12. PulseAnimation
/// 13. ShakeAnimation
/// 14. TypingIndicator
class AnimationComponentShowcases {
  static List<WidgetbookComponent> get showcases => [
        // AnimatedFadeIn
        WidgetbookComponent(
          name: 'AnimatedFadeIn',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AnimatedFadeIn(
                duration: Duration(
                  milliseconds: context.knobs.int.slider(
                    label: 'Duration (ms)',
                    initialValue: 300,
                    min: 100,
                    max: 1000,
                  ),
                ),
                child: Container(
                  width: 200,
                  height: 100,
                  color: Colors.blue,
                  child: const Center(child: Text('Fade In')),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Curve',
              builder: (context) => AnimatedFadeIn(
                curve: Curves.easeOut,
                child: Container(
                  width: 200,
                  height: 100,
                  color: Colors.green,
                  child: const Center(child: Text('Ease Out')),
                ),
              ),
            ),
          ],
        ),

        // AnimatedSlideIn
        WidgetbookComponent(
          name: 'AnimatedSlideIn',
          useCases: [
            WidgetbookUseCase(
              name: 'From Bottom',
              builder: (context) => AnimatedSlideIn(
                direction: AxisDirection.up,
                child: Container(
                  width: 200,
                  height: 100,
                  color: Colors.orange,
                  child: const Center(child: Text('Slide Up')),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'From Right',
              builder: (context) => AnimatedSlideIn(
                direction: AxisDirection.left,
                child: Container(
                  width: 200,
                  height: 100,
                  color: Colors.purple,
                  child: const Center(child: Text('Slide Left')),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'From Top',
              builder: (context) => AnimatedSlideIn(
                direction: AxisDirection.down,
                child: Container(
                  width: 200,
                  height: 100,
                  color: Colors.teal,
                  child: const Center(child: Text('Slide Down')),
                ),
              ),
            ),
          ],
        ),

        // AnimatedScale
        WidgetbookComponent(
          name: 'AnimatedScale',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => Transform.scale(
                scale: context.knobs.double.slider(
                  label: 'Scale',
                  initialValue: 1.0,
                  min: 0.5,
                  max: 2.0,
                ),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                  child: const Center(child: Text('Scale')),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Animation',
              builder: (context) => TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.2),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.blue,
                      child: const Center(child: Text('Scaled')),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        // AnimatedButton
        WidgetbookComponent(
          name: 'AnimatedButton',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AnimatedButton(
                onTap: () {},
                scaleFactor: context.knobs.double.slider(
                  label: 'Scale Factor',
                  initialValue: 0.95,
                  min: 0.8,
                  max: 1.0,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Press Me', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Icon',
              builder: (context) => AnimatedButton(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite, color: Colors.white),
                ),
              ),
            ),
          ],
        ),

        // AnimatedCard
        WidgetbookComponent(
          name: 'AnimatedCard',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AnimatedCard(
                elevation: context.knobs.double.slider(
                  label: 'Elevation',
                  initialValue: 2.0,
                  min: 0.0,
                  max: 8.0,
                ),
                child: Container(
                  width: 200,
                  height: 150,
                  padding: const EdgeInsets.all(16),
                  child: const Center(child: Text('Hover or Tap')),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Interactive',
              builder: (context) => AnimatedCard(
                onTap: () {},
                child: Container(
                  width: 200,
                  height: 150,
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app, size: 48),
                      SizedBox(height: 8),
                      Text('Tap Me'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // HeroImage
        WidgetbookComponent(
          name: 'HeroImage',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => HeroImage(
                tag: 'hero-image-1',
                image: const NetworkImage('https://picsum.photos/200/200'),
                width: context.knobs.double.slider(
                  label: 'Width',
                  initialValue: 150,
                  min: 50,
                  max: 300,
                ),
                height: 150,
              ),
            ),
            WidgetbookUseCase(
              name: 'Square',
              builder: (context) => const HeroImage(
                tag: 'hero-image-2',
                image: NetworkImage('https://picsum.photos/200/200'),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),

        // HeroAvatar
        WidgetbookComponent(
          name: 'HeroAvatar',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => HeroAvatar(
                tag: 'hero-avatar-1',
                imageUrl: 'https://i.pravatar.cc/150?img=1',
                radius: context.knobs.double.slider(
                  label: 'Radius',
                  initialValue: 60,
                  min: 40,
                  max: 120,
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Large',
              builder: (context) => const HeroAvatar(
                tag: 'hero-avatar-2',
                imageUrl: 'https://i.pravatar.cc/150?img=2',
                radius: 80,
              ),
            ),
          ],
        ),

        // TikTokPageTransition
        WidgetbookComponent(
          name: 'TikTokPageTransition',
          useCases: [
            WidgetbookUseCase(
              name: 'Slide Up',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      TikTokPageTransition(
                        type: TikTokTransitionType.slideUp,
                        child: Scaffold(
                          appBar: AppBar(title: const Text('Slide Up')),
                          body: const Center(child: Text('Slid up from bottom')),
                        ),
                      ).createRoute(context),
                    );
                  },
                  child: const Text('Show Slide Up Transition'),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Fade',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      TikTokPageTransition(
                        type: TikTokTransitionType.fade,
                        child: Scaffold(
                          appBar: AppBar(title: const Text('Fade')),
                          body: const Center(child: Text('Faded in')),
                        ),
                      ).createRoute(context),
                    );
                  },
                  child: const Text('Show Fade Transition'),
                ),
              ),
            ),
          ],
        ),

        // SlidePageRoute
        WidgetbookComponent(
          name: 'SlidePageRoute',
          useCases: [
            WidgetbookUseCase(
              name: 'From Left',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      SlidePageRoute(
                        direction: AxisDirection.left,
                        page: Scaffold(
                          appBar: AppBar(title: const Text('Slide Left')),
                          body: const Center(child: Text('Slid from left')),
                        ),
                      ),
                    );
                  },
                  child: const Text('Show Slide Left Route'),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'From Right',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      SlidePageRoute(
                        direction: AxisDirection.right,
                        page: Scaffold(
                          appBar: AppBar(title: const Text('Slide Right')),
                          body: const Center(child: Text('Slid from right')),
                        ),
                      ),
                    );
                  },
                  child: const Text('Show Slide Right Route'),
                ),
              ),
            ),
          ],
        ),

        // FadePageRoute
        WidgetbookComponent(
          name: 'FadePageRoute',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      FadePageRoute(
                        page: Scaffold(
                          appBar: AppBar(title: const Text('Fade')),
                          body: const Center(child: Text('Faded in')),
                        ),
                      ),
                    );
                  },
                  child: const Text('Show Fade Route'),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Custom Duration',
              builder: (context) => Center(
                child: AppButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      FadePageRoute(
                        duration: const Duration(milliseconds: 500),
                        page: Scaffold(
                          appBar: AppBar(title: const Text('Slow Fade')),
                          body: const Center(child: Text('Slow fade transition')),
                        ),
                      ),
                    );
                  },
                  child: const Text('Show Slow Fade'),
                ),
              ),
            ),
          ],
        ),

        // BounceAnimation
        WidgetbookComponent(
          name: 'BounceAnimation',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => BounceAnimation(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite, color: Colors.white, size: 48),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Scale',
              builder: (context) => BounceAnimation(
                scale: context.knobs.double.slider(
                  label: 'Scale',
                  initialValue: 1.2,
                  min: 1.0,
                  max: 2.0,
                ),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.green,
                  child: const Center(child: Text('Bounce')),
                ),
              ),
            ),
          ],
        ),

        // PulseAnimation
        WidgetbookComponent(
          name: 'PulseAnimation',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => PulseAnimation(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications, color: Colors.white, size: 48),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Color',
              builder: (context) => PulseAnimation(
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.orange,
                  child: const Center(child: Text('Pulse')),
                ),
              ),
            ),
          ],
        ),

        // ShakeAnimation
        WidgetbookComponent(
          name: 'ShakeAnimation',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => ShakeAnimation(
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('Shake Me', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Triggered',
              builder: (context) => ShakeAnimation(
                trigger: context.knobs.boolean(
                  label: 'Trigger Shake',
                  initialValue: false,
                ),
                child: Container(
                  width: 150,
                  height: 50,
                  color: Colors.orange,
                  child: const Center(child: Text('Shake')),
                ),
              ),
            ),
          ],
        ),

        // TypingIndicator
        WidgetbookComponent(
          name: 'TypingIndicator',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => TypingIndicator(
                size: context.knobs.double.slider(
                  label: 'Size',
                  initialValue: 8.0,
                  min: 4.0,
                  max: 16.0,
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Color',
              builder: (context) => const TypingIndicator(
                color: Colors.blue,
                size: 10.0,
              ),
            ),
            WidgetbookUseCase(
              name: 'Large',
              builder: (context) => const TypingIndicator(
                size: 12.0,
                spacing: 6.0,
              ),
            ),
          ],
        ),
      ];
}

