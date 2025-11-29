import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/localization/app_localizations.dart';
import 'package:flutter_chekmate/core/router/app_router_enhanced.dart';
import 'package:flutter_chekmate/core/theme/app_theme.dart';
import 'package:flutter_chekmate/shared/ui/components/app_error_boundary.dart';
import 'package:flutter_chekmate/shared/ui/components/app_notification_banner.dart';
// import 'package:flutter_chekmate/features/auth/providers/auth_provider.dart'; // For future auth routing
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChekMateApp extends ConsumerWidget {
  const ChekMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterEnhancedProvider);
    final currentLocale = ref.watch(languageProvider);
    // Note: authState available for future authentication-based routing
    // final authState = ref.watch(authStateProvider);

    return MaterialApp.router(
      title: 'ChekMate',
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Localization Configuration - Top 30 languages
      locale: currentLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,

      // Router Configuration
      routerConfig: router,

      // Builder for global overlays and error boundary
      builder: (context, child) {
        return AppErrorBoundary(
          enableReporting: true,
          onError: (details) {
            // Show error notification to user
            AppNotificationBanner.show(
              context: context,
              message: 'An error occurred. Please try again.',
              type: AppNotificationBannerType.error,
              duration: const Duration(seconds: 5),
            );
          },
          child: MediaQuery(
            // Sprint 1 - Task 1.4.1: Allow text scaling up to 2.0 for accessibility
            // WCAG 2.1 requires support for 200% text scaling
            data: MediaQuery.of(context).copyWith(
              textScaler: MediaQuery.of(context).textScaler.clamp(
                    minScaleFactor: 0.8,
                    maxScaleFactor: 2.0,
                  ),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
