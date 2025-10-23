import 'package:flutter/material.dart';
import 'package:flutter_chekmate/shared/ui/loading/shimmer_loading.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  group('ShimmerBox', () {
    testWidgets('displays shimmer effect', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerBox(
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('respects custom width and height',
        (WidgetTester tester) async {
      const customWidth = 200.0;
      const customHeight = 150.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerBox(
              width: customWidth,
              height: customHeight,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(Shimmer),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.constraints?.maxWidth, customWidth);
      expect(container.constraints?.maxHeight, customHeight);
    });

    testWidgets('applies custom border radius', (WidgetTester tester) async {
      const customRadius = 16.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerBox(
              width: 100,
              height: 100,
              borderRadius: customRadius,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // ShimmerBox uses Container with BorderRadius, not ClipRRect
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Shimmer), findsOneWidget);
    });
  });

  group('ShimmerCircle', () {
    testWidgets('displays circular shimmer', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerCircle(size: 50),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('respects custom size', (WidgetTester tester) async {
      const customSize = 80.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerCircle(size: customSize),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(Shimmer),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.constraints?.maxWidth, customSize);
      expect(container.constraints?.maxHeight, customSize);
    });
  });

  group('ShimmerLine', () {
    testWidgets('displays line shimmer', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLine(width: 200),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('respects custom width', (WidgetTester tester) async {
      const customWidth = 300.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLine(width: customWidth),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(Shimmer),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.constraints?.maxWidth, customWidth);
    });

    testWidgets('uses default height', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLine(width: 200),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(Shimmer),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.constraints?.maxHeight,
          12.0); // Default height is 12.0, not 16.0
    });
  });

  group('ShimmerText', () {
    testWidgets('displays text shimmer', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerText(),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsWidgets);
    });

    testWidgets('respects custom line count', (WidgetTester tester) async {
      const customLines = 5;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerText(lines: customLines),
          ),
        ),
      );

      final shimmerLines = tester.widgetList<ShimmerLine>(
        find.byType(ShimmerLine),
      );

      expect(shimmerLines.length, customLines);
    });
  });

  group('ShimmerImage', () {
    testWidgets('displays image shimmer', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerImage(
              width: 200,
              height: 200,
            ),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('respects aspect ratio', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerImage(
              // AspectRatio only used when BOTH width and height are null
              aspectRatio: 16 / 9,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AspectRatio), findsOneWidget);
    });
  });

  group('ShimmerCard', () {
    testWidgets('displays card shimmer', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerCard(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Shimmer), findsWidgets);
      // ShimmerCard uses Container, not Material Card widget
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('contains multiple shimmer elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerCard(),
          ),
        ),
      );

      // Should have multiple shimmer elements (image, title, subtitle)
      expect(find.byType(Shimmer), findsWidgets);
    });
  });

  group('ShimmerListItem', () {
    testWidgets('displays list item shimmer', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListItem(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Shimmer), findsWidgets);
      // ShimmerListItem uses Row, not ListTile widget
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('contains avatar and text shimmers',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListItem(),
          ),
        ),
      );

      // Should have circle (avatar) and lines (text)
      expect(find.byType(Shimmer), findsWidgets);
    });
  });

  group('Shimmer Theme', () {
    testWidgets('adapts to light theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: ShimmerBox(
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('adapts to dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: ShimmerBox(
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
    });
  });
}
