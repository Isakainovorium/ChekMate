import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router_provider.dart';
import 'firebase_options.dart';

/// Main entry point for ChekMate application
/// 
/// Initializes Firebase, sets up Riverpod ProviderScope,
/// configures error handling, and initializes the router.
/// 
/// Date: 11/13/2025
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await _initializeFirebase();
    await _initializeServices();
  } catch (e, stackTrace) {
    _handleInitializationError(e, stackTrace);
    return;
  }

  runApp(
    const ProviderScope(
      child: ChekMateApp(),
    ),
  );
}

/// Initializes Firebase with platform-specific options
Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

/// Initializes application services
/// 
/// Placeholder for future service initialization
Future<void> _initializeServices() async {
  // Future service initialization can be added here
  // Examples: Analytics, Crashlytics, Remote Config, etc.
}

/// Handles initialization errors gracefully
void _handleInitializationError(Object error, StackTrace stackTrace) {
  debugPrint('Initialization Error: $error');
  debugPrint('Stack Trace: $stackTrace');
  
  // In production, this could send to crash reporting service
  // For now, we log and prevent app from starting
}

/// Root application widget
/// 
/// Configures MaterialApp with GoRouter for navigation,
/// theme, and localization support.
class ChekMateApp extends ConsumerWidget {
  const ChekMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'ChekMate',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
    );
  }
}

