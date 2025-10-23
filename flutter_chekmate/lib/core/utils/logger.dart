import 'package:flutter/foundation.dart';

/// Simple logger utility for debugging and error tracking
class Logger {
  static const String _prefix = '[ChekMate]';
  
  /// Log debug message
  static void debug(String message, [dynamic data]) {
    if (kDebugMode) {
      debugPrint('$_prefix [DEBUG] $message ${data != null ? ': $data' : ''}');
    }
  }
  
  /// Log info message
  static void info(String message, [dynamic data]) {
    if (kDebugMode) {
      debugPrint('$_prefix [INFO] $message ${data != null ? ': $data' : ''}');
    }
  }
  
  /// Log warning message
  static void warning(String message, [dynamic data]) {
    if (kDebugMode) {
      debugPrint('$_prefix [WARNING] $message ${data != null ? ': $data' : ''}');
    }
  }
  
  /// Log error message
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('$_prefix [ERROR] $message ${error != null ? ': $error' : ''}');
      if (stackTrace != null) {
        debugPrint('$_prefix [STACK] $stackTrace');
      }
    }
  }
}
