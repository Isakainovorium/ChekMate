import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// AppErrorBoundary - Comprehensive error handling and recovery
class AppErrorBoundary extends StatefulWidget {
  const AppErrorBoundary({
    required this.child,
    super.key,
    this.onError,
    this.errorBuilder,
    this.showStackTrace = false,
    this.enableReporting = true,
  });

  final Widget child;
  final void Function(FlutterErrorDetails)? onError;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final bool showStackTrace;
  final bool enableReporting;

  @override
  State<AppErrorBoundary> createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends State<AppErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();

    // Set up global error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        setState(() {
          _error = details.exception;
          _stackTrace = details.stack;
        });
      }

      widget.onError?.call(details);

      if (widget.enableReporting) {
        _reportError(details.exception, details.stack);
      }
    };
  }

  void _reportError(Object error, StackTrace? stackTrace) {
    // Implement error reporting (Firebase Crashlytics, Sentry, etc.)
    debugPrint('Error reported: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _retry() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(context, _error!, _stackTrace) ??
          AppErrorWidget(
            error: _error!,
            stackTrace: _stackTrace,
            onRetry: _retry,
            showStackTrace: widget.showStackTrace,
          );
    }

    return widget.child;
  }
}

/// AppErrorWidget - Default error display widget
class AppErrorWidget extends StatefulWidget {
  const AppErrorWidget({
    required this.error,
    super.key,
    this.stackTrace,
    this.onRetry,
    this.showStackTrace = false,
    this.title,
    this.message,
  });

  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;
  final bool showStackTrace;
  final String? title;
  final String? message;

  @override
  State<AppErrorWidget> createState() => _AppErrorWidgetState();
}

class _AppErrorWidgetState extends State<AppErrorWidget> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorType = _getErrorType(widget.error);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Icon(
                _getErrorIcon(errorType),
                size: 80,
                color: theme.colorScheme.error,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Error title
              Text(
                widget.title ?? _getErrorTitle(errorType),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.md),

              // Error message
              Text(
                widget.message ?? _getErrorMessage(errorType),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.onRetry != null) ...[
                    AppButton(
                      onPressed: widget.onRetry,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, size: 18),
                          SizedBox(width: AppSpacing.xs),
                          Text('Try Again'),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  AppButton(
                    variant: AppButtonVariant.outline,
                    onPressed: () => _reportIssue(context),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bug_report, size: 18),
                        SizedBox(width: AppSpacing.xs),
                        Text('Report Issue'),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Show details toggle
              if (widget.showStackTrace || widget.stackTrace != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showDetails = !_showDetails;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_showDetails ? 'Hide Details' : 'Show Details'),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        _showDetails ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                      ),
                    ],
                  ),
                ),

              // Error details
              if (_showDetails) ...[
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Error Details',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            widget.error.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        if (widget.stackTrace != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Stack Trace',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            width: double.infinity,
                            height: 200,
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SingleChildScrollView(
                              child: SelectableText(
                                widget.stackTrace.toString(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  AppErrorType _getErrorType(Object error) {
    if (error.toString().contains('network') ||
        error.toString().contains('connection') ||
        error.toString().contains('timeout')) {
      return AppErrorType.network;
    } else if (error.toString().contains('permission') ||
        error.toString().contains('unauthorized')) {
      return AppErrorType.permission;
    } else if (error.toString().contains('not found') ||
        error.toString().contains('404')) {
      return AppErrorType.notFound;
    } else {
      return AppErrorType.generic;
    }
  }

  IconData _getErrorIcon(AppErrorType type) {
    switch (type) {
      case AppErrorType.network:
        return Icons.wifi_off;
      case AppErrorType.permission:
        return Icons.lock;
      case AppErrorType.notFound:
        return Icons.search_off;
      case AppErrorType.generic:
        return Icons.error_outline;
    }
  }

  String _getErrorTitle(AppErrorType type) {
    switch (type) {
      case AppErrorType.network:
        return 'Connection Problem';
      case AppErrorType.permission:
        return 'Access Denied';
      case AppErrorType.notFound:
        return 'Not Found';
      case AppErrorType.generic:
        return 'Something Went Wrong';
    }
  }

  String _getErrorMessage(AppErrorType type) {
    switch (type) {
      case AppErrorType.network:
        return 'Please check your internet connection and try again.';
      case AppErrorType.permission:
        return 'You don\'t have permission to access this resource.';
      case AppErrorType.notFound:
        return 'The requested resource could not be found.';
      case AppErrorType.generic:
        return 'An unexpected error occurred. Please try again later.';
    }
  }

  void _reportIssue(BuildContext context) {
    AppBottomSheet.show<void>(
      context: context,
      title: const Text('Report Issue'),
      content: const AppErrorReportForm(),
    );
  }
}

/// AppErrorReportForm - Form for reporting errors
class AppErrorReportForm extends StatefulWidget {
  const AppErrorReportForm({super.key});

  @override
  State<AppErrorReportForm> createState() => _AppErrorReportFormState();
}

class _AppErrorReportFormState extends State<AppErrorReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppInput(
            controller: _emailController,
            label: 'Email (optional)',
            hint: 'your.email@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextarea(
            controller: _descriptionController,
            label: 'Describe what happened',
            hint:
                'Please describe what you were doing when the error occurred...',
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please describe the issue';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  variant: AppButtonVariant.outline,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppLoadingButton(
                  onPressed: _submitReport,
                  isLoading: _isSubmitting,
                  loadingText: 'Sending...',
                  child: const Text('Send Report'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate API call
      await Future<void>.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pop(context);
        AppSnackBarNotification.show(
          context,
          message: 'Error report sent successfully',
          type: AppNotificationBannerType.success,
        );
      }
    } on Exception {
      if (mounted) {
        AppSnackBarNotification.show(
          context,
          message: 'Failed to send report. Please try again.',
          type: AppNotificationBannerType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

/// AppNetworkErrorWidget - Specific widget for network errors
class AppNetworkErrorWidget extends StatelessWidget {
  const AppNetworkErrorWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  final VoidCallback? onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Internet Connection',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message ?? 'Please check your connection and try again.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                onPressed: onRetry,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 18),
                    SizedBox(width: AppSpacing.xs),
                    Text('Try Again'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// AppErrorSnackBar - Error display in snackbar
class AppErrorSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: duration,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}

/// Error types for categorization
enum AppErrorType {
  network,
  permission,
  notFound,
  generic,
}
