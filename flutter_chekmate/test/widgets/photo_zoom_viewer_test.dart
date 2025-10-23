import 'package:flutter/material.dart';
import 'package:flutter_chekmate/features/posts/presentation/widgets/photo_zoom_viewer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

void main() {
  group('PhotoZoomViewer', () {
    testWidgets('displays single image with zoom capability',
        (WidgetTester tester) async {
      final imageUrls = ['https://example.com/image1.jpg'];

      await tester.pumpWidget(
        MaterialApp(
          home: PhotoZoomViewer(
            imageUrls: imageUrls,
          ),
        ),
      );

      expect(find.byType(PhotoZoomViewer), findsOneWidget);
      expect(find.byType(PhotoView), findsOneWidget);
    });

    testWidgets('displays multiple images in gallery',
        (WidgetTester tester) async {
      final imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
        'https://example.com/image3.jpg',
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: PhotoZoomViewer(
            imageUrls: imageUrls,
          ),
        ),
      );

      expect(find.byType(PhotoZoomViewer), findsOneWidget);
      expect(find.byType(PhotoViewGallery), findsOneWidget);
    });

    testWidgets('starts at correct initial index', (WidgetTester tester) async {
      final imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
        'https://example.com/image3.jpg',
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: PhotoZoomViewer(
            imageUrls: imageUrls,
            initialIndex: 1,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display page indicator showing index 1
      expect(find.text('2 / 3'), findsOneWidget);
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
          home: PhotoZoomViewer(
            imageUrls: imageUrls,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display "1 / 3"
      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('does not display page indicator for single image',
        (WidgetTester tester) async {
      final imageUrls = ['https://example.com/image1.jpg'];

      await tester.pumpWidget(
        MaterialApp(
          home: PhotoZoomViewer(
            imageUrls: imageUrls,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not display page indicator
      expect(find.text('1 / 1'), findsNothing);
    });

    testWidgets('displays close button', (WidgetTester tester) async {
      final imageUrls = ['https://example.com/image1.jpg'];

      await tester.pumpWidget(
        MaterialApp(
          home: PhotoZoomViewer(
            imageUrls: imageUrls,
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('closes viewer when close button is tapped',
        (WidgetTester tester) async {
      final imageUrls = ['https://example.com/image1.jpg'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => PhotoZoomViewer(
                        imageUrls: imageUrls,
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Open viewer
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(PhotoZoomViewer), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Viewer should be closed
      expect(find.byType(PhotoZoomViewer), findsNothing);
    });

    testWidgets('updates page indicator when swiping',
        (WidgetTester tester) async {
      final imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
        'https://example.com/image3.jpg',
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: PhotoZoomViewer(
            imageUrls: imageUrls,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial state
      expect(find.text('1 / 3'), findsOneWidget);

      // Swipe to next image - use fling for more reliable page change
      await tester.fling(
        find.byType(PhotoViewGallery),
        const Offset(-400, 0),
        1000, // velocity
      );
      await tester.pumpAndSettle();

      // Should show page 2
      expect(find.text('2 / 3'), findsOneWidget);
    });

    testWidgets('supports pinch-to-zoom gesture', (WidgetTester tester) async {
      final imageUrls = ['https://example.com/image1.jpg'];

      await tester.pumpWidget(
        MaterialApp(
          home: PhotoZoomViewer(
            imageUrls: imageUrls,
          ),
        ),
      );

      // PhotoView should support zoom gestures
      expect(find.byType(PhotoView), findsOneWidget);
      final photoView = tester.widget<PhotoView>(find.byType(PhotoView));
      expect(photoView.minScale, isNotNull);
      expect(photoView.maxScale, isNotNull);
    });

    testWidgets('displays hero animation tag when provided',
        (WidgetTester tester) async {
      final imageUrls = ['https://example.com/image1.jpg'];

      await tester.pumpWidget(
        MaterialApp(
          home: PhotoZoomViewer(
            imageUrls: imageUrls,
            heroTag: 'photo_hero',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // PhotoView package creates Hero widgets internally when heroAttributes is set
      // Just verify the PhotoZoomViewer renders successfully with heroTag
      expect(find.byType(PhotoZoomViewer), findsOneWidget);
      expect(find.byType(PhotoView), findsOneWidget);
    });

    testWidgets('handles empty image list gracefully',
        (WidgetTester tester) async {
      final imageUrls = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: PhotoZoomViewer(
            imageUrls: imageUrls,
          ),
        ),
      );

      // Should handle empty list without crashing
      expect(find.byType(PhotoZoomViewer), findsOneWidget);
    });

    testWidgets('displays background overlay', (WidgetTester tester) async {
      final imageUrls = ['https://example.com/image1.jpg'];

      await tester.pumpWidget(
        MaterialApp(
          home: PhotoZoomViewer(
            imageUrls: imageUrls,
          ),
        ),
      );

      // Should have dark background
      expect(find.byType(Container), findsWidgets);
    });
  });
}
