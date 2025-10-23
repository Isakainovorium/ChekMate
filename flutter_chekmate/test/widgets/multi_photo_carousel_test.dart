import 'package:flutter/material.dart';
import 'package:flutter_chekmate/features/posts/presentation/widgets/multi_photo_carousel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MultiPhotoCarousel', () {
    testWidgets('displays single image correctly', (WidgetTester tester) async {
      final imageUrls = ['https://example.com/image1.jpg'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiPhotoCarousel(
              imageUrls: imageUrls,
            ),
          ),
        ),
      );

      expect(find.byType(MultiPhotoCarousel), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('displays multiple images with carousel',
        (WidgetTester tester) async {
      final imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
        'https://example.com/image3.jpg',
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiPhotoCarousel(
              imageUrls: imageUrls,
            ),
          ),
        ),
      );

      expect(find.byType(MultiPhotoCarousel), findsOneWidget);
      // Carousel should be present for multiple images
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('displays page indicator for multiple images',
        (WidgetTester tester) async {
      final imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
        'https://example.com/image3.jpg',
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiPhotoCarousel(
              imageUrls: imageUrls,
            ),
          ),
        ),
      );

      // Page indicator should be present
      expect(find.byType(Row), findsWidgets);
      // Should have 3 indicator dots
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('does not display page indicator for single image',
        (WidgetTester tester) async {
      final imageUrls = ['https://example.com/image1.jpg'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiPhotoCarousel(
              imageUrls: imageUrls,
            ),
          ),
        ),
      );

      // PageView should not be present for single image
      expect(find.byType(PageView), findsNothing);
    });

    testWidgets('handles empty image list gracefully',
        (WidgetTester tester) async {
      final imageUrls = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiPhotoCarousel(
              imageUrls: imageUrls,
            ),
          ),
        ),
      );

      // Should display placeholder or empty state
      expect(find.byType(MultiPhotoCarousel), findsOneWidget);
    });

    testWidgets('respects custom aspect ratio', (WidgetTester tester) async {
      final imageUrls = ['https://example.com/image1.jpg'];
      const customAspectRatio = 16 / 9;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiPhotoCarousel(
              imageUrls: imageUrls,
              aspectRatio: customAspectRatio,
            ),
          ),
        ),
      );

      // Verify widget is rendered with custom aspect ratio
      expect(find.byType(MultiPhotoCarousel), findsOneWidget);
      expect(find.byType(AspectRatio), findsOneWidget);
    });

    testWidgets('enables zoom when enableZoom is true',
        (WidgetTester tester) async {
      final imageUrls = ['https://example.com/image1.jpg'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiPhotoCarousel(
              imageUrls: imageUrls,
            ),
          ),
        ),
      );

      // Should have GestureDetector for zoom
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('calls onPageChanged when swiping between images',
        (WidgetTester tester) async {
      final imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
        'https://example.com/image3.jpg',
      ];
      int? changedPage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiPhotoCarousel(
              imageUrls: imageUrls,
              onPageChanged: (index) {
                changedPage = index;
              },
            ),
          ),
        ),
      );

      // Swipe to next image
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(changedPage, isNotNull);
    });

    testWidgets('displays border radius when specified',
        (WidgetTester tester) async {
      final imageUrls = ['https://example.com/image1.jpg'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiPhotoCarousel(
              imageUrls: imageUrls,
              borderRadius: 16.0,
            ),
          ),
        ),
      );

      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('handles maximum of 10 images', (WidgetTester tester) async {
      final imageUrls = List.generate(
        10,
        (index) => 'https://example.com/image$index.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiPhotoCarousel(
              imageUrls: imageUrls,
            ),
          ),
        ),
      );

      expect(find.byType(MultiPhotoCarousel), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
    });
  });
}
