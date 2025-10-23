import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    this.size = 24,
    this.color,
    super.key,
  });
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    required this.isLoading,
    required this.child,
    this.message,
    super.key,
  });
  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LoadingIndicator(size: 48, color: Colors.white),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
