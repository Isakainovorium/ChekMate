import 'package:flutter/material.dart';

/// Optimistic Action Handler
///
/// Provides a pattern for optimistic UI updates with automatic rollback
/// on failure. Essential for actions like likes, bookmarks, and ratings
/// where immediate feedback is expected.
///
/// Usage:
/// ```dart
/// final action = OptimisticAction<bool>(
///   currentValue: _isLiked,
///   optimisticValue: !_isLiked,
///   action: () => _postService.toggleLike(postId),
///   onUpdate: (value) => setState(() => _isLiked = value),
///   onError: (error) => _showErrorSnackBar('Failed to like'),
/// );
/// await action.execute();
/// ```
///
/// Sprint 2 - Task 2.2.1
/// Date: November 28, 2025

/// Generic optimistic action handler
class OptimisticAction<T> {
  OptimisticAction({
    required this.currentValue,
    required this.optimisticValue,
    required this.action,
    required this.onUpdate,
    this.onError,
    this.onSuccess,
  });

  /// The current value before the action
  final T currentValue;

  /// The optimistic value to show immediately
  final T optimisticValue;

  /// The async action to perform
  final Future<T> Function() action;

  /// Callback to update the UI
  final void Function(T value) onUpdate;

  /// Optional callback on error (receives error and rollback value)
  final void Function(Object error, T rollbackValue)? onError;

  /// Optional callback on success
  final void Function(T result)? onSuccess;

  /// Execute the optimistic action
  Future<void> execute() async {
    // 1. Apply optimistic update immediately
    onUpdate(optimisticValue);

    try {
      // 2. Perform the actual action
      final result = await action();

      // 3. Update with actual result
      onUpdate(result);

      // 4. Call success callback if provided
      onSuccess?.call(result);
    } catch (error) {
      // 5. Rollback on failure
      onUpdate(currentValue);

      // 6. Call error callback if provided
      onError?.call(error, currentValue);

      // Re-throw if no error handler
      if (onError == null) {
        rethrow;
      }
    }
  }
}

/// Specialized optimistic action for toggle states (like, bookmark, etc.)
class OptimisticToggle {
  OptimisticToggle({
    required this.isActive,
    required this.count,
    required this.toggleAction,
    required this.onStateChange,
    this.onError,
  });

  /// Current active state
  final bool isActive;

  /// Current count (likes, bookmarks, etc.)
  final int count;

  /// The async toggle action
  final Future<bool> Function() toggleAction;

  /// Callback to update both state and count
  final void Function({required bool isActive, required int count}) onStateChange;

  /// Optional error callback
  final void Function(Object error)? onError;

  /// Execute the toggle
  Future<void> execute() async {
    final previousState = isActive;
    final previousCount = count;

    // Optimistic update
    onStateChange(
      isActive: !isActive,
      count: isActive ? count - 1 : count + 1,
    );

    try {
      final result = await toggleAction();
      // Update with actual result if different
      if (result != !previousState) {
        onStateChange(
          isActive: result,
          count: result ? previousCount + 1 : previousCount - 1,
        );
      }
    } catch (error) {
      // Rollback
      onStateChange(
        isActive: previousState,
        count: previousCount,
      );
      onError?.call(error);
    }
  }
}

/// Mixin to add optimistic action support to StatefulWidgets
mixin OptimisticActionMixin<T extends StatefulWidget> on State<T> {
  /// Execute an optimistic action with automatic error handling
  Future<void> executeOptimistic<V>({
    required V currentValue,
    required V optimisticValue,
    required Future<V> Function() action,
    required void Function(V) onUpdate,
    String? errorMessage,
  }) async {
    final optimisticAction = OptimisticAction<V>(
      currentValue: currentValue,
      optimisticValue: optimisticValue,
      action: action,
      onUpdate: onUpdate,
      onError: (error, _) {
        if (mounted && errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () => executeOptimistic(
                  currentValue: currentValue,
                  optimisticValue: optimisticValue,
                  action: action,
                  onUpdate: onUpdate,
                  errorMessage: errorMessage,
                ),
              ),
            ),
          );
        }
      },
    );

    await optimisticAction.execute();
  }

  /// Execute an optimistic toggle with automatic error handling
  Future<void> executeOptimisticToggle({
    required bool isActive,
    required int count,
    required Future<bool> Function() toggleAction,
    required void Function({required bool isActive, required int count}) onStateChange,
    String? errorMessage,
  }) async {
    final toggle = OptimisticToggle(
      isActive: isActive,
      count: count,
      toggleAction: toggleAction,
      onStateChange: onStateChange,
      onError: (error) {
        if (mounted && errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () => executeOptimisticToggle(
                  isActive: isActive,
                  count: count,
                  toggleAction: toggleAction,
                  onStateChange: onStateChange,
                  errorMessage: errorMessage,
                ),
              ),
            ),
          );
        }
      },
    );

    await toggle.execute();
  }
}
