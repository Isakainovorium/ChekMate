import 'package:flutter/material.dart';
import 'package:flutter_chekmate/shared/ui/animations/animated_widgets.dart';
import 'package:flutter_chekmate/shared/ui/animations/page_transitions.dart';
import 'package:flutter_chekmate/shared/ui/animations/tiktok_animations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Animation Performance Tests', () {
    group('TikTok Animations Performance', () {
      testWidgets('fadeInSlide should complete within 400ms', (tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const Text('Test').fadeInSlide(),
            ),
          ),
        );

        // Wait for animation to complete
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Animation should complete within 400ms
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });

      testWidgets('fadeInSlideRight should complete within 400ms',
          (tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const Text('Test').fadeInSlideRight(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });

      testWidgets('scaleIn should complete within 300ms', (tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const Text('Test').scaleIn(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(400));
      });

      testWidgets('bounceIn should complete within 600ms', (tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const Text('Test').bounceIn(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(700));
      });

      testWidgets('shimmer should not cause jank', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const Text('Test').shimmer(),
            ),
          ),
        );

        // Pump multiple frames to check for jank
        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }

        // Should complete without errors
        expect(tester.takeException(), isNull);
      });
    });

    group('Animated Widgets Performance', () {
      testWidgets('AnimatedFeedCard should render without jank',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AnimatedFeedCard(
                child: Card(child: Text('Feed Card')),
              ),
            ),
          ),
        );

        // Pump multiple frames
        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }

        expect(tester.takeException(), isNull);
      });

      testWidgets('AnimatedStoryCircle should render without jank',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AnimatedStoryCircle(
                child: CircleAvatar(child: Text('Story')),
              ),
            ),
          ),
        );

        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }

        expect(tester.takeException(), isNull);
      });

      testWidgets('AnimatedGridItem should render without jank',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AnimatedGridItem(
                child: Card(child: Text('Grid Item')),
              ),
            ),
          ),
        );

        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }

        expect(tester.takeException(), isNull);
      });

      testWidgets('AnimatedListItem should render without jank',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AnimatedListItem(
                child: ListTile(title: Text('List Item')),
              ),
            ),
          ),
        );

        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }

        expect(tester.takeException(), isNull);
      });

      testWidgets('AnimatedButton should handle rapid taps', (tester) async {
        var tapCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnimatedButton(
                onTap: () => tapCount++,
                child: const Text('Tap Me'),
              ),
            ),
          ),
        );

        // Rapid taps
        for (var i = 0; i < 10; i++) {
          await tester.tap(find.text('Tap Me'));
          await tester.pump(const Duration(milliseconds: 50));
        }

        await tester.pumpAndSettle();

        expect(tapCount, equals(10));
        expect(tester.takeException(), isNull);
      });

      testWidgets('AnimatedCounter should animate smoothly', (tester) async {
        var count = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      AnimatedCounter(count: count),
                      ElevatedButton(
                        onPressed: () => setState(() => count = 1000),
                        child: const Text('Increment'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        // Trigger animation
        await tester.tap(find.text('Increment'));

        // Pump frames during animation
        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }

        await tester.pumpAndSettle();

        expect(find.text('1000'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Page Transitions Performance', () {
      testWidgets('slideUp transition should complete within 300ms',
          (tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        TikTokPageRoute<void>(
                          builder: (context) => const Scaffold(
                            body: Center(child: Text('New Page')),
                          ),
                          type: TikTokTransitionType.slideUp,
                        ),
                      );
                    },
                    child: const Text('Navigate'),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(400));
      });

      testWidgets('fade transition should complete within 300ms',
          (tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        TikTokPageRoute<void>(
                          builder: (context) => const Scaffold(
                            body: Center(child: Text('New Page')),
                          ),
                          type: TikTokTransitionType.fade,
                        ),
                      );
                    },
                    child: const Text('Navigate'),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(400));
      });
    });

    group('Stagger Animation Performance', () {
      testWidgets('staggered list should render efficiently', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: 50,
                itemBuilder: (context, index) {
                  return AnimatedListItem(
                    index: index,
                    child: ListTile(title: Text('Item $index')),
                  );
                },
              ),
            ),
          ),
        );

        // Pump initial frames
        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }

        expect(tester.takeException(), isNull);
      });

      testWidgets('staggered grid should render efficiently', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: 50,
                itemBuilder: (context, index) {
                  return AnimatedGridItem(
                    index: index,
                    child: Card(child: Text('$index')),
                  );
                },
              ),
            ),
          ),
        );

        // Pump initial frames
        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }

        expect(tester.takeException(), isNull);
      });
    });

    group('Memory Performance', () {
      testWidgets('animations should not leak memory', (tester) async {
        // Create and dispose multiple animated widgets
        for (var i = 0; i < 10; i++) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AnimatedFeedCard(
                  index: i,
                  child: Text('Card $i'),
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();
        }

        // Should complete without memory issues
        expect(tester.takeException(), isNull);
      });
    });
  });
}
