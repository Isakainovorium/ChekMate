import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'riverpod_codegen_example.g.dart';

/// Riverpod Code Generation Examples
///
/// This file demonstrates how to use Riverpod code generation to reduce boilerplate.
/// Instead of manually creating providers, we use annotations to generate them automatically.
///
/// Benefits of Code Generation:
/// 1. **Less Boilerplate:** No need to manually create provider instances
/// 2. **Type Safety:** Compile-time type checking for all providers
/// 3. **Auto-Dispose:** Automatic resource cleanup when providers are no longer needed
/// 4. **Family Providers:** Simplified syntax for parameterized providers
/// 5. **Better IDE Support:** Auto-completion and refactoring support
///
/// ## Setup
///
/// 1. Add dependencies to pubspec.yaml:
/// ```yaml
/// dependencies:
///   flutter_riverpod: ^2.4.9
///   riverpod_annotation: ^2.3.3
///
/// dev_dependencies:
///   build_runner: ^2.4.7
///   riverpod_generator: ^2.3.9
///   riverpod_lint: ^2.3.7
/// ```
///
/// 2. Generate code:
/// ```bash
/// # One-time generation
/// flutter pub run build_runner build --delete-conflicting-outputs
///
/// # Watch mode (auto-regenerate on file changes)
/// flutter pub run build_runner watch --delete-conflicting-outputs
/// ```
///
/// ## Examples

// **************************************************************************
// Example 1: Simple Provider
// **************************************************************************

/// Simple provider that returns a constant value.
///
/// Before (manual):
/// ```dart
/// final helloWorldProvider = Provider<String>((ref) => 'Hello World');
/// ```
///
/// After (code generation):
@riverpod
String helloWorld(HelloWorldRef ref) {
  return 'Hello World';
}

// **************************************************************************
// Example 2: Future Provider
// **************************************************************************

/// Future provider that fetches data asynchronously.
///
/// Before (manual):
/// ```dart
/// final fetchDataProvider = FutureProvider<String>((ref) async {
///   await Future.delayed(Duration(seconds: 2));
///   return 'Data loaded';
/// });
/// ```
///
/// After (code generation):
@riverpod
Future<String> fetchData(FetchDataRef ref) async {
  await Future<void>.delayed(const Duration(seconds: 2));
  return 'Data loaded';
}

// **************************************************************************
// Example 3: Stream Provider
// **************************************************************************

/// Stream provider that emits values over time.
///
/// Before (manual):
/// ```dart
/// final counterStreamProvider = StreamProvider<int>((ref) {
///   return Stream.periodic(Duration(seconds: 1), (count) => count);
/// });
/// ```
///
/// After (code generation):
@riverpod
Stream<int> counterStream(CounterStreamRef ref) {
  return Stream.periodic(const Duration(seconds: 1), (count) => count);
}

// **************************************************************************
// Example 4: Family Provider (with parameters)
// **************************************************************************

/// Family provider that accepts parameters.
///
/// Before (manual):
/// ```dart
/// final userByIdProvider = FutureProvider.family<User, String>((ref, userId) async {
///   return await fetchUser(userId);
/// });
/// ```
///
/// After (code generation):
@riverpod
Future<User> userById(UserByIdRef ref, String userId) async {
  // Simulate API call
  await Future<void>.delayed(const Duration(seconds: 1));
  return User(id: userId, name: 'User $userId');
}

// **************************************************************************
// Example 5: Auto-Dispose Provider
// **************************************************************************

/// Auto-dispose provider that cleans up when no longer used.
///
/// Before (manual):
/// ```dart
/// final searchResultsProvider = FutureProvider.autoDispose.family<List<String>, String>((ref, query) async {
///   return await search(query);
/// });
/// ```
///
/// After (code generation):
/// Note: All @riverpod providers are auto-dispose by default!
@riverpod
Future<List<String>> searchResults(SearchResultsRef ref, String query) async {
  if (query.isEmpty) return [];

  // Simulate search
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return ['Result 1 for $query', 'Result 2 for $query', 'Result 3 for $query'];
}

// **************************************************************************
// Example 6: Keep Alive Provider (disable auto-dispose)
// **************************************************************************

/// Keep-alive provider that persists even when not watched.
///
/// Use @Riverpod(keepAlive: true) to disable auto-dispose.
@Riverpod(keepAlive: true)
Future<AppConfig> appConfig(AppConfigRef ref) async {
  // Load app configuration (should persist throughout app lifecycle)
  await Future<void>.delayed(const Duration(seconds: 1));
  return const AppConfig(apiUrl: 'https://api.chekmate.app', version: '1.0.0');
}

// **************************************************************************
// Example 7: Provider with Dependencies
// **************************************************************************

/// Provider that depends on other providers.
@riverpod
Future<UserProfile> userProfile(UserProfileRef ref, String userId) async {
  // Watch other providers
  final user = await ref.watch(userByIdProvider(userId).future);
  final config = await ref.watch(appConfigProvider.future);

  // Combine data from multiple sources
  return UserProfile(
    user: user,
    apiUrl: config.apiUrl,
  );
}

// **************************************************************************
// Example 8: Provider with Lifecycle Hooks
// **************************************************************************

/// Provider with lifecycle management.
@riverpod
Stream<int> timerWithCleanup(TimerWithCleanupRef ref) {
  // Setup
  if (kDebugMode) {
    debugPrint('[Riverpod] Timer started');
  }

  // Cleanup when provider is disposed
  ref.onDispose(() {
    if (kDebugMode) {
      debugPrint('[Riverpod] Timer stopped');
    }
  });

  return Stream.periodic(const Duration(seconds: 1), (count) => count);
}

// **************************************************************************
// Example 9: Provider with Error Handling
// **************************************************************************

/// Provider with built-in error handling.
@riverpod
Future<String> fetchDataWithError(FetchDataWithErrorRef ref) async {
  try {
    await Future<void>.delayed(const Duration(seconds: 1));

    // Simulate random error
    if (DateTime.now().second % 2 == 0) {
      throw Exception('Random error occurred');
    }

    return 'Success!';
  } catch (e) {
    // Re-throw to let Riverpod handle it
    rethrow;
  }
}

// **************************************************************************
// Example 10: Provider with Caching
// **************************************************************************

/// Provider with manual cache control.
@riverpod
Future<List<Post>> cachedPosts(CachedPostsRef ref) async {
  // Keep provider alive for 5 minutes
  final link = ref.keepAlive();

  // Cancel keep-alive after 5 minutes
  Timer(const Duration(minutes: 5), link.close);

  // Fetch posts
  await Future<void>.delayed(const Duration(seconds: 1));
  return [
    const Post(id: '1', title: 'Post 1'),
    const Post(id: '2', title: 'Post 2'),
  ];
}

// **************************************************************************
// Supporting Classes
// **************************************************************************

class User {
  const User({required this.id, required this.name});
  final String id;
  final String name;
}

class AppConfig {
  const AppConfig({required this.apiUrl, required this.version});
  final String apiUrl;
  final String version;
}

class UserProfile {
  const UserProfile({required this.user, required this.apiUrl});
  final User user;
  final String apiUrl;
}

class Post {
  const Post({required this.id, required this.title});
  final String id;
  final String title;
}

// **************************************************************************
// Usage in Widgets
// **************************************************************************

/// Example Widget Usage:
///
/// ```dart
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     // 1. Simple provider
///     final hello = ref.watch(helloWorldProvider);
///     
///     // 2. Future provider
///     final data = ref.watch(fetchDataProvider);
///     
///     // 3. Stream provider
///     final count = ref.watch(counterStreamProvider);
///     
///     // 4. Family provider
///     final user = ref.watch(userByIdProvider('123'));
///     
///     // 5. Search with auto-dispose
///     final results = ref.watch(searchResultsProvider('flutter'));
///     
///     return data.when(
///       data: (value) => Text(value),
///       loading: () => CircularProgressIndicator(),
///       error: (error, stack) => Text('Error: $error'),
///     );
///   }
/// }
/// ```

/// Example: Invalidating/Refreshing Providers
///
/// ```dart
/// class RefreshButton extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     return ElevatedButton(
///       onPressed: () {
///         // Invalidate provider to force refresh
///         ref.invalidate(fetchDataProvider);
///         
///         // Or refresh specific family provider
///         ref.invalidate(userByIdProvider('123'));
///       },
///       child: Text('Refresh'),
///     );
///   }
/// }
/// ```

