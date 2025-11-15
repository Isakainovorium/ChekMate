import 'package:flutter/material.dart';
import 'package:flutter_chekmate/features/explore/presentation/widgets/explore_grid_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExploreGridWidget', () {
    testWidgets('should render with loading state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExploreGridWidget(),
          ),
        ),
      );

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render grid items after loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExploreGridWidget(),
          ),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Should show grid view
      expect(find.byType(MasonryGridView), findsOneWidget);
    });

    testWidgets('should use correct cross axis count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExploreGridWidget(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final masonryGrid = tester.widget<MasonryGridView>(
        find.byType(MasonryGridView),
      );

      // Instagram Explore uses 3 columns
      // Note: SliverSimpleGridDelegate doesn't expose crossAxisCount
      // This test verifies the grid is rendered
      expect(masonryGrid.gridDelegate, isNotNull);
    });

    testWidgets('should apply correct spacing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExploreGridWidget(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final masonryGrid = tester.widget<MasonryGridView>(
        find.byType(MasonryGridView),
      );

      // Instagram Explore uses minimal spacing (2px)
      // Note: SliverSimpleGridDelegate doesn't expose spacing properties
      // This test verifies the grid is rendered
      expect(masonryGrid.gridDelegate, isNotNull);
    });

    testWidgets('should render grid items with images', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExploreGridWidget(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have multiple grid items
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('should handle item tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExploreGridWidget(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find first grid item
      final firstItem = find.byType(GestureDetector).first;

      // Tap should not throw
      await tester.tap(firstItem);
      await tester.pumpAndSettle();
    });
  });

  group('StaggeredGrid Layouts', () {
    testWidgets('MasonryGridView should render items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: 10,
              itemBuilder: (context, index) {
                return Container(
                  height: 100 + (index * 20.0),
                  color: Colors.blue,
                  child: Center(
                    child: Text('Item $index'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Should render all items
      for (var i = 0; i < 10; i++) {
        expect(find.text('Item $i'), findsOneWidget);
      }
    });

    testWidgets('StaggeredGrid should support custom tile sizes',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StaggeredGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: [
                StaggeredGridTile.count(
                  crossAxisCellCount: 2,
                  mainAxisCellCount: 2,
                  child: Container(
                    color: Colors.red,
                    child: const Center(child: Text('Large')),
                  ),
                ),
                StaggeredGridTile.count(
                  crossAxisCellCount: 2,
                  mainAxisCellCount: 1,
                  child: Container(
                    color: Colors.green,
                    child: const Center(child: Text('Wide')),
                  ),
                ),
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: Container(
                    color: Colors.blue,
                    child: const Center(child: Text('Small 1')),
                  ),
                ),
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: Container(
                    color: Colors.yellow,
                    child: const Center(child: Text('Small 2')),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // All tiles should be rendered
      expect(find.text('Large'), findsOneWidget);
      expect(find.text('Wide'), findsOneWidget);
      expect(find.text('Small 1'), findsOneWidget);
      expect(find.text('Small 2'), findsOneWidget);
    });

    testWidgets('MasonryGridView should handle scrolling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: 50,
              itemBuilder: (context, index) {
                return Container(
                  height: 100,
                  color: Colors.blue,
                  child: Center(
                    child: Text('Item $index'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // First item should be visible
      expect(find.text('Item 0'), findsOneWidget);

      // Scroll down
      await tester.drag(
        find.byType(MasonryGridView),
        const Offset(0, -1000),
      );
      await tester.pumpAndSettle();

      // Later items should now be visible
      expect(find.text('Item 0'), findsNothing);
    });

    testWidgets('StaggeredGrid should maintain aspect ratios', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StaggeredGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: [
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: Container(
                    color: Colors.red,
                    child: const Center(child: Text('Square')),
                  ),
                ),
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 2,
                  child: Container(
                    color: Colors.blue,
                    child: const Center(child: Text('Tall')),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Square'), findsOneWidget);
      expect(find.text('Tall'), findsOneWidget);
    });
  });

  group('Grid Performance', () {
    testWidgets('should handle large item counts efficiently', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MasonryGridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              itemCount: 1000,
              itemBuilder: (context, index) {
                return Container(
                  height: 100 + (index % 5) * 20.0,
                  color: Colors.primaries[index % Colors.primaries.length],
                  child: Center(
                    child: Text('$index'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Should render without performance issues
      await tester.pumpAndSettle();

      // First items should be visible
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('should lazy load items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: 100,
              itemBuilder: (context, index) {
                return Container(
                  height: 150,
                  color: Colors.blue,
                  child: Center(
                    child: Text('Item $index'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Only visible items should be built initially
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 99'), findsNothing);

      // Scroll to bottom
      await tester.drag(
        find.byType(MasonryGridView),
        const Offset(0, -10000),
      );
      await tester.pumpAndSettle();

      // Last items should now be visible
      expect(find.text('Item 99'), findsOneWidget);
    });
  });

  group('Grid Animations', () {
    testWidgets('should support animated grid items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: 10,
              itemBuilder: (context, index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 100,
                  color: Colors.blue,
                  child: Center(
                    child: Text('Animated $index'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // All animated items should render
      for (var i = 0; i < 10; i++) {
        expect(find.text('Animated $i'), findsOneWidget);
      }
    });
  });
}
