import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for connectivity status
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Provider for checking if device is online
final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (result) => result != ConnectivityResult.none,
    loading: () => true,
    error: (_, __) => false,
  );
});

/// Provider for app theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

/// Provider for current navigation index
final navigationIndexProvider = StateProvider<int>((ref) {
  return 0;
});

/// Provider for loading state
final loadingProvider = StateProvider<bool>((ref) {
  return false;
});

/// Provider for error messages
final errorMessageProvider = StateProvider<String?>((ref) {
  return null;
});
