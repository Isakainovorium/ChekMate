import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';

/// Authentication state provider
/// 
/// This provider should be replaced with actual auth state provider
/// when authentication is implemented. For now, it returns false
/// to allow access to auth routes.
/// 
/// TODO: Replace with actual auth state provider
final authStateProvider = StateProvider<bool>((ref) {
  // Placeholder: Always return false for now
  // This will be replaced with actual Firebase Auth state
  return false;
});

/// App Router Provider
/// 
/// Riverpod provider that creates and manages the GoRouter instance.
/// The router is configured with all routes, guards, and transitions.
/// 
/// Date: 11/13/2025
final appRouterProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(authStateProvider);

  return AppRouter.createRouter(
    isAuthenticated: () => isAuthenticated,
  );
});

