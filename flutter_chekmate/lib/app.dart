import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/router/app_router_enhanced.dart';
import 'package:flutter_chekmate/core/theme/app_theme.dart';
// import 'package:flutter_chekmate/features/auth/providers/auth_provider.dart'; // For future auth routing
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChekMateApp extends ConsumerWidget {
  const ChekMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterEnhancedProvider);
    // Note: authState available for future authentication-based routing
    // final authState = ref.watch(authStateProvider);

    return MaterialApp.router(
      title: 'ChekMate',
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Router Configuration
      routerConfig: router,

      // Builder for global overlays
      builder: (context, child) {
        return MediaQuery(
          // Ensure text scaling doesn't break the UI
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
                  minScaleFactor: 0.8,
                  maxScaleFactor: 1.2,
                ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
