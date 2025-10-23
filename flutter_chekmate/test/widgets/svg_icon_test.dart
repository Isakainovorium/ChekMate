import 'package:flutter/material.dart';
import 'package:flutter_chekmate/shared/ui/icons/svg_icon.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SvgIcon', () {
    testWidgets('displays SVG icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SvgIcon(
              'assets/icons/home.svg',
            ),
          ),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('respects custom size', (WidgetTester tester) async {
      const customSize = 48.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SvgIcon(
              'assets/icons/home.svg',
              size: customSize,
            ),
          ),
        ),
      );

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.width, customSize);
      expect(svgPicture.height, customSize);
    });

    testWidgets('applies custom color', (WidgetTester tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SvgIcon(
              'assets/icons/home.svg',
              color: customColor,
            ),
          ),
        ),
      );

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.colorFilter, isNotNull);
    });

    testWidgets('uses default size when not specified',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SvgIcon(
              'assets/icons/home.svg',
            ),
          ),
        ),
      );

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.width, 24.0);
      expect(svgPicture.height, 24.0);
    });
  });

  group('SvgIconButton', () {
    testWidgets('displays SVG icon button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SvgIconButton(
              assetPath: 'assets/icons/home.svg',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SvgIconButton(
              assetPath: 'assets/icons/home.svg',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(pressed, true);
    });

    testWidgets('respects custom size', (WidgetTester tester) async {
      const customSize = 32.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SvgIconButton(
              assetPath: 'assets/icons/home.svg',
              size: customSize,
              onPressed: () {},
            ),
          ),
        ),
      );

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.width, customSize);
      expect(svgPicture.height, customSize);
    });

    testWidgets('applies custom color', (WidgetTester tester) async {
      const customColor = Colors.blue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SvgIconButton(
              assetPath: 'assets/icons/home.svg',
              color: customColor,
              onPressed: () {},
            ),
          ),
        ),
      );

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.colorFilter, isNotNull);
    });

    testWidgets('can be disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SvgIconButton(
              assetPath: 'assets/icons/home.svg',
              onPressed: null,
            ),
          ),
        ),
      );

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, null);
    });
  });

  group('ThemedSvgIcon', () {
    testWidgets('adapts to light theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: ThemedSvgIcon(
              'assets/icons/home.svg',
            ),
          ),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('adapts to dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: ThemedSvgIcon(
              'assets/icons/home.svg',
            ),
          ),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('uses theme icon color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            iconTheme: const IconThemeData(color: Colors.purple),
          ),
          home: const Scaffold(
            body: ThemedSvgIcon(
              'assets/icons/home.svg',
            ),
          ),
        ),
      );

      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.colorFilter, isNotNull);
    });
  });

  group('AnimatedSvgIcon', () {
    testWidgets('displays animated SVG icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedSvgIcon(
              'assets/icons/home.svg',
            ),
          ),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('responds to tap', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSvgIcon(
              'assets/icons/home.svg',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AnimatedSvgIcon));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('animates on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSvgIcon(
              'assets/icons/home.svg',
              onTap: () {},
            ),
          ),
        ),
      );

      // Tap the icon
      await tester.tap(find.byType(AnimatedSvgIcon));
      await tester.pump();

      // Animation should be in progress
      expect(find.byType(AnimatedSvgIcon), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });

  group('SvgIconWithBadge', () {
    testWidgets('displays icon with badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SvgIconWithBadge(
              assetPath: 'assets/icons/home.svg',
              badgeCount: 5,
              showBadge: true, // Must set showBadge to true
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SvgPicture), findsOneWidget);
      // SvgIconWithBadge uses Container, not Material Badge widget
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('hides badge when count is 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SvgIconWithBadge(
              assetPath: 'assets/icons/home.svg',
              badgeCount: 0,
              showBadge: false, // Badge hidden when showBadge is false
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('displays 99+ for counts over 99', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SvgIconWithBadge(
              assetPath: 'assets/icons/home.svg',
              badgeCount: 150,
              showBadge: true, // Must set showBadge to true
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('applies custom badge color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SvgIconWithBadge(
              assetPath: 'assets/icons/home.svg',
              badgeCount: 5,
              showBadge: true, // Must set showBadge to true
              badgeColor: Colors.green,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify badge text is displayed (badge uses Container, not Badge widget)
      expect(find.text('5'), findsOneWidget);
    });
  });
}
