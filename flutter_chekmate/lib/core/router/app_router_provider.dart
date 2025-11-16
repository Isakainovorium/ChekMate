import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import 'app_router.dart';

/// App Router Provider
///
/// Riverpod provider that creates and manages the GoRouter instance.
/// The router is configured with all routes, guards, and transitions.
///
/// Date: 11/13/2025
final appRouterProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return AppRouter.createRouter(
    isAuthenticated: () => isAuthenticated,
  );
});

