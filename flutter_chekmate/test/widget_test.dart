// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_chekmate/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Mock network images to prevent HTTP requests during testing
    await mockNetworkImagesFor(() async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        const ProviderScope(
          child:
              ChekMateApp(), // ChekMateApp is the correct class name from app.dart
        ),
      );

      // Verify that the app loads without throwing an exception
      // Use pump instead of pumpAndSettle to avoid waiting for network images
      await tester.pump();

      // Basic smoke test - just ensure the app doesn't crash
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
