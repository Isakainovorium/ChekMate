import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/config/environment_config.dart';
import 'package:flutter_chekmate/core/services/file_picker_service.dart';
import 'package:flutter_chekmate/core/services/http_client_service.dart';
import 'package:flutter_chekmate/shared/ui/animations/animated_widgets.dart';
import 'package:flutter_chekmate/shared/ui/animations/page_transitions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 5 Integration Tests', () {
    // EnvironmentConfig.current defaults to development environment

    group('Animation Integration', () {
      testWidgets('Feed page with animations should load correctly',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return AnimatedFeedCard(
                    index: index,
                    child: Card(
                      child: ListTile(
                        title: Text('Post $index'),
                        subtitle: const Text('This is a test post'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        // Wait for animations to complete
        await tester.pumpAndSettle();

        // All posts should be visible
        expect(find.text('Post 0'), findsOneWidget);
        expect(find.text('Post 1'), findsOneWidget);
      });

      testWidgets('Stories with animations should load correctly',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return AnimatedStoryCircle(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          radius: 30,
                          child: Text('$index'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Stories should be visible
        expect(find.text('0'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
      });

      testWidgets('Page transitions should work correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          TikTokPageRoute<void>(
                            pageBuilder: (context, animation, secondaryAnimation) => const Scaffold(
                              body: Center(child: Text('Second Page')),
                            ),
                            type: TikTokTransitionType.slideUp,
                          ),
                        );
                      },
                      child: const Text('Navigate'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        // Tap navigate button
        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();

        // Should be on second page
        expect(find.text('Second Page'), findsOneWidget);
        expect(find.text('Navigate'), findsNothing);

        // Navigate back
        await tester.pageBack();
        await tester.pumpAndSettle();

        // Should be back on first page
        expect(find.text('Navigate'), findsOneWidget);
        expect(find.text('Second Page'), findsNothing);
      });

      testWidgets('Multiple animations should work together', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const AnimatedFeedCard(
                    index: 0,
                    child: Card(child: Text('Feed Card')),
                  ),
                  AnimatedButton(
                    onTap: () {},
                    child: const Text('Action Button'),
                  ),
                  const AnimatedCounter(count: 42),
                ],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Feed Card'), findsOneWidget);
        expect(find.text('Action Button'), findsOneWidget);
        expect(find.text('42'), findsOneWidget);
      });
    });

    group('HTTP Client Integration', () {
      test('HttpClientService should be initialized', () {
        final httpClient = HttpClientService.instance;
        expect(httpClient, isNotNull);
        expect(httpClient.dio, isNotNull);
      });

      test('HttpClientService should have correct configuration', () {
        final httpClient = HttpClientService.instance;
        final baseUrl = httpClient.dio.options.baseUrl;

        expect(baseUrl, equals(EnvironmentConfig.current.apiBaseUrl));
      });

      test('HttpClientService should have all interceptors', () {
        final httpClient = HttpClientService.instance;
        final interceptors = httpClient.dio.interceptors;

        // Should have 4 interceptors
        expect(interceptors.length, equals(4));
      });
    });

    group('File Picker Integration', () {
      test('File type helpers should work correctly', () {
        // Test image detection
        expect(
          FilePickerService.isImage(File('photo.jpg')),
          isTrue,
        );

        expect(
          FilePickerService.isImage(File('document.pdf')),
          isFalse,
        );

        // Test video detection
        expect(
          FilePickerService.isVideo(File('video.mp4')),
          isTrue,
        );

        expect(
          FilePickerService.isVideo(File('photo.jpg')),
          isFalse,
        );

        // Test document detection
        expect(
          FilePickerService.isDocument(File('document.pdf')),
          isTrue,
        );

        expect(
          FilePickerService.isDocument(File('photo.jpg')),
          isFalse,
        );
      });

      test('File extension helpers should work correctly', () {
        expect(
          FilePickerService.getFileExtension(File('document.pdf')),
          equals('pdf'),
        );

        expect(
          FilePickerService.getFileExtension(File('photo.jpg')),
          equals('jpg'),
        );

        expect(
          FilePickerService.getFileExtension(File('video.mp4')),
          equals('mp4'),
        );
      });
    });

    group('End-to-End Scenarios', () {
      testWidgets('Complete user flow with animations', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  appBar: AppBar(title: const Text('ChekMate')),
                  body: ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return AnimatedFeedCard(
                        index: index,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              TikTokPageRoute<void>(
                                pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
                                  appBar: AppBar(title: Text('Post $index')),
                                  body: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Post $index Details'),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AnimatedIconButton(
                                              icon: Icons.favorite,
                                              onTap: () {},
                                            ),
                                            const SizedBox(width: 20),
                                            AnimatedIconButton(
                                              icon: Icons.share,
                                              onTap: () {},
                                            ),
                                            const SizedBox(width: 20),
                                            AnimatedIconButton(
                                              icon: Icons.bookmark,
                                              onTap: () {},
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        const AnimatedCounter(count: 1234),
                                      ],
                                    ),
                                  ),
                                ),
                                type: TikTokTransitionType.slideUp,
                              ),
                            );
                          },
                          child: Card(
                            child: ListTile(
                              title: Text('Post $index'),
                              subtitle: const Text('Tap to view details'),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify feed is loaded
        expect(find.text('Post 0'), findsOneWidget);

        // Tap on first post
        await tester.tap(find.text('Post 0'));
        await tester.pumpAndSettle();

        // Verify detail page is shown
        expect(find.text('Post 0 Details'), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsOneWidget);
        expect(find.text('1234'), findsOneWidget);

        // Tap like button
        await tester.tap(find.byIcon(Icons.favorite));
        await tester.pumpAndSettle();

        // Navigate back
        await tester.pageBack();
        await tester.pumpAndSettle();

        // Verify back on feed
        expect(find.text('Post 0'), findsOneWidget);
      });

      testWidgets('Rapid navigation should work smoothly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          TikTokPageRoute<void>(
                            pageBuilder: (context, animation, secondaryAnimation) => const Scaffold(
                              body: Center(child: Text('Page 2')),
                            ),
                            type: TikTokTransitionType.fade,
                          ),
                        );
                      },
                      child: const Text('Navigate'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        // Rapid navigation
        for (var i = 0; i < 5; i++) {
          await tester.tap(find.text('Navigate'));
          await tester.pumpAndSettle();
          await tester.pageBack();
          await tester.pumpAndSettle();
        }

        // Should still be functional
        expect(find.text('Navigate'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
