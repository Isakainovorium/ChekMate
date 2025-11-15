import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_chekmate/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ChekMateApp());

    // Verify that the app title appears
    expect(find.text('Welcome to ChekMate'), findsOneWidget);
  });

  testWidgets('Get Started button exists', (WidgetTester tester) async {
    await tester.pumpWidget(const ChekMateApp());

    // Verify button exists
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Navigation bar has 4 items', (WidgetTester tester) async {
    await tester.pumpWidget(const ChekMateApp());

    // Verify navigation items
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Matches'), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}

