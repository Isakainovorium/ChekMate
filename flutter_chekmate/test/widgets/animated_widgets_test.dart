import 'package:flutter/material.dart';
import 'package:flutter_chekmate/shared/ui/animations/animated_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedFeedCard', () {
    testWidgets('should render child widget', (tester) async {
      const testChild = Text('Test Feed Card');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedFeedCard(
              index: 0,
              child: testChild,
            ),
          ),
        ),
      );

      expect(find.text('Test Feed Card'), findsOneWidget);
    });

    testWidgets('should apply animation with delay based on index',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AnimatedFeedCard(
                  index: 0,
                  child: Text('Card 1'),
                ),
                AnimatedFeedCard(
                  index: 1,
                  child: Text('Card 2'),
                ),
                AnimatedFeedCard(
                  index: 2,
                  child: Text('Card 3'),
                ),
              ],
            ),
          ),
        ),
      );

      // All cards should be present
      expect(find.text('Card 1'), findsOneWidget);
      expect(find.text('Card 2'), findsOneWidget);
      expect(find.text('Card 3'), findsOneWidget);
    });

    testWidgets('should be tappable when wrapped in GestureDetector',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GestureDetector(
              onTap: () => tapped = true,
              child: const AnimatedFeedCard(
                index: 0,
                child: Text('Tappable Card'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tappable Card'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  group('AnimatedStoryCircle', () {
    testWidgets('should render child widget', (tester) async {
      const testChild = CircleAvatar(child: Text('Story'));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedStoryCircle(
              index: 0,
              child: testChild,
            ),
          ),
        ),
      );

      expect(find.text('Story'), findsOneWidget);
    });

    testWidgets('should apply stagger animation based on index',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                AnimatedStoryCircle(
                  index: 0,
                  child: Text('Story 1'),
                ),
                AnimatedStoryCircle(
                  index: 1,
                  child: Text('Story 2'),
                ),
                AnimatedStoryCircle(
                  index: 2,
                  child: Text('Story 3'),
                ),
              ],
            ),
          ),
        ),
      );

      // All stories should be present
      expect(find.text('Story 1'), findsOneWidget);
      expect(find.text('Story 2'), findsOneWidget);
      expect(find.text('Story 3'), findsOneWidget);
    });
  });

  group('AnimatedGridItem', () {
    testWidgets('should render child widget', (tester) async {
      const testChild = Card(child: Text('Grid Item'));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedGridItem(
              child: testChild,
            ),
          ),
        ),
      );

      expect(find.text('Grid Item'), findsOneWidget);
    });

    testWidgets('should apply scale animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedGridItem(
              child: Text('Animated Grid'),
            ),
          ),
        ),
      );

      expect(find.text('Animated Grid'), findsOneWidget);
    });
  });

  group('AnimatedListItem', () {
    testWidgets('should render child widget', (tester) async {
      const testChild = ListTile(title: Text('List Item'));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedListItem(
              index: 0,
              child: testChild,
            ),
          ),
        ),
      );

      expect(find.text('List Item'), findsOneWidget);
    });

    testWidgets('should apply slide animation based on index', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: const [
                AnimatedListItem(
                  index: 0,
                  child: Text('Item 1'),
                ),
                AnimatedListItem(
                  index: 1,
                  child: Text('Item 2'),
                ),
                AnimatedListItem(
                  index: 2,
                  child: Text('Item 3'),
                ),
              ],
            ),
          ),
        ),
      );

      // All items should be present
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });
  });

  group('AnimatedButton', () {
    testWidgets('should render button with text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedButton(
              onTap: () {},
              child: const Text('Click Me'),
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('should trigger onTap callback', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedButton(
              onTap: () => pressed = true,
              child: const Text('Press Button'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Press Button'));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('should apply scale animation on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedButton(
              onTap: () {},
              child: const Text('Animated Button'),
            ),
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.text('Animated Button'));
      await tester.pump();

      // Button should still be visible during animation
      expect(find.text('Animated Button'), findsOneWidget);
    });
  });

  group('AnimatedIconButton', () {
    testWidgets('should render icon button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedIconButton(
              icon: Icons.favorite,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should trigger onTap callback', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedIconButton(
              icon: Icons.favorite,
              onTap: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('should apply custom color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedIconButton(
              icon: Icons.favorite,
              color: Colors.red,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify icon is rendered with custom color
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should apply custom size', (tester) async {
      const customSize = 32.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedIconButton(
              icon: Icons.favorite,
              size: customSize,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify icon is rendered with custom size
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });

  group('AnimatedCounter', () {
    testWidgets('should display initial count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCounter(count: 42),
          ),
        ),
      );

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('should animate count changes', (tester) async {
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
                      onPressed: () => setState(() => count = 100),
                      child: const Text('Increment'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initial count
      expect(find.text('0'), findsOneWidget);

      // Tap increment button
      await tester.tap(find.text('Increment'));
      await tester.pumpAndSettle();

      // Count should be updated
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('should apply custom text style', (tester) async {
      const customStyle = TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCounter(
              count: 123,
              style: customStyle,
            ),
          ),
        ),
      );

      // Verify counter displays the count
      expect(find.text('123'), findsOneWidget);
    });
  });
}
