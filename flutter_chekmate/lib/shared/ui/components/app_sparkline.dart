import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppSparkline - Inline mini charts for trends and quick data visualization
class AppSparkline extends StatelessWidget {
  const AppSparkline({
    required this.data,
    super.key,
    this.width = 100,
    this.height = 30,
    this.lineColor,
    this.fillColor,
    this.strokeWidth = 2.0,
    this.showFill = false,
    this.showDots = false,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  final List<double> data;
  final double width;
  final double height;
  final Color? lineColor;
  final Color? fillColor;
  final double strokeWidth;
  final bool showFill;
  final bool showDots;
  final bool animate;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (data.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              'No data',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: animate
          ? TweenAnimationBuilder<double>(
              duration: animationDuration,
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeInOut,
              builder: (context, progress, child) {
                return CustomPaint(
                  painter: _SparklinePainter(
                    data: data,
                    lineColor: lineColor ?? theme.colorScheme.primary,
                    fillColor: fillColor ??
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                    strokeWidth: strokeWidth,
                    showFill: showFill,
                    showDots: showDots,
                    progress: progress,
                  ),
                );
              },
            )
          : CustomPaint(
              painter: _SparklinePainter(
                data: data,
                lineColor: lineColor ?? theme.colorScheme.primary,
                fillColor: fillColor ??
                    theme.colorScheme.primary.withValues(alpha: 0.2),
                strokeWidth: strokeWidth,
                showFill: showFill,
                showDots: showDots,
                progress: 1.0,
              ),
            ),
    );
  }
}

/// AppTrendSparkline - Sparkline with trend indicator
class AppTrendSparkline extends StatelessWidget {
  const AppTrendSparkline({
    required this.data,
    super.key,
    this.width = 120,
    this.height = 40,
    this.showTrendIcon = true,
    this.showPercentage = true,
    this.label,
  });

  final List<double> data;
  final double width;
  final double height;
  final bool showTrendIcon;
  final bool showPercentage;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trend = _calculateTrend();
    final trendColor = _getTrendColor(theme, trend);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Row(
          children: [
            AppSparkline(
              data: data,
              width: width - (showTrendIcon || showPercentage ? 40 : 0),
              height: height,
              lineColor: trendColor,
              fillColor: trendColor.withValues(alpha: 0.1),
              showFill: true,
            ),
            if (showTrendIcon || showPercentage) ...[
              const SizedBox(width: AppSpacing.sm),
              Column(
                children: [
                  if (showTrendIcon)
                    Icon(
                      _getTrendIcon(trend),
                      size: 16,
                      color: trendColor,
                    ),
                  if (showPercentage) ...[
                    if (showTrendIcon) const SizedBox(height: 2),
                    Text(
                      '${trend.percentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: trendColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  _SparklineTrend _calculateTrend() {
    if (data.length < 2) {
      return const _SparklineTrend(
        direction: TrendDirection.neutral,
        percentage: 0.0,
      );
    }

    final first = data.first;
    final last = data.last;

    if (first == 0) {
      return _SparklineTrend(
        direction: last > 0 ? TrendDirection.up : TrendDirection.down,
        percentage: 100.0,
      );
    }

    final percentage = ((last - first) / first) * 100;
    final direction = percentage > 0.5
        ? TrendDirection.up
        : percentage < -0.5
            ? TrendDirection.down
            : TrendDirection.neutral;

    return _SparklineTrend(direction: direction, percentage: percentage.abs());
  }

  Color _getTrendColor(ThemeData theme, _SparklineTrend trend) {
    switch (trend.direction) {
      case TrendDirection.up:
        return Colors.green;
      case TrendDirection.down:
        return Colors.red;
      case TrendDirection.neutral:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  IconData _getTrendIcon(_SparklineTrend trend) {
    switch (trend.direction) {
      case TrendDirection.up:
        return Icons.trending_up;
      case TrendDirection.down:
        return Icons.trending_down;
      case TrendDirection.neutral:
        return Icons.trending_flat;
    }
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
    required this.strokeWidth,
    required this.showFill,
    required this.showDots,
    required this.progress,
  });

  final List<double> data;
  final Color lineColor;
  final Color fillColor;
  final double strokeWidth;
  final bool showFill;
  final bool showDots;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    // Calculate data bounds
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final valueRange = maxValue - minValue;

    if (valueRange == 0) {
      // Draw flat line for constant data
      final y = size.height / 2;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width * progress, y),
        paint,
      );
      return;
    }

    // Create path for line
    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = (data[i] - minValue) / valueRange;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        if (showFill) {
          fillPath.moveTo(x, size.height);
          fillPath.lineTo(x, y);
        }
      } else {
        path.lineTo(x, y);
        if (showFill) {
          fillPath.lineTo(x, y);
        }
      }
    }

    // Complete fill path
    if (showFill) {
      fillPath.lineTo(size.width, size.height);
      fillPath.close();
    }

    // Apply progress animation by clipping
    if (progress < 1.0) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));
    }

    // Draw fill
    if (showFill) {
      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw line
    canvas.drawPath(path, paint);

    // Draw dots
    if (showDots) {
      final dotPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;

      for (var i = 0; i < data.length; i++) {
        final x = (i / (data.length - 1)) * size.width;
        final normalizedValue = (data[i] - minValue) / valueRange;
        final y = size.height - (normalizedValue * size.height);

        canvas.drawCircle(Offset(x, y), strokeWidth, dotPaint);
      }
    }

    if (progress < 1.0) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.showFill != showFill ||
        oldDelegate.showDots != showDots ||
        oldDelegate.progress != progress;
  }
}

/// AppSparklineGroup - Multiple sparklines for comparison
class AppSparklineGroup extends StatelessWidget {
  const AppSparklineGroup({
    required this.sparklines,
    super.key,
    this.spacing = AppSpacing.md,
    this.direction = Axis.vertical,
  });

  final List<AppSparklineData> sparklines;
  final double spacing;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final children = sparklines
        .map(
          (sparkline) => AppTrendSparkline(
            data: sparkline.data,
            label: sparkline.label,
            width: sparkline.width ?? 120,
            height: sparkline.height ?? 40,
            showTrendIcon: sparkline.showTrendIcon ?? true,
            showPercentage: sparkline.showPercentage ?? true,
          ),
        )
        .toList();

    if (direction == Axis.vertical) {
      return Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) SizedBox(height: spacing),
          ],
        ],
      );
    } else {
      return Row(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) SizedBox(width: spacing),
          ],
        ],
      );
    }
  }
}

/// Data classes
class AppSparklineData {
  const AppSparklineData({
    required this.data,
    required this.label,
    this.width,
    this.height,
    this.showTrendIcon,
    this.showPercentage,
  });

  final List<double> data;
  final String label;
  final double? width;
  final double? height;
  final bool? showTrendIcon;
  final bool? showPercentage;
}

class _SparklineTrend {
  const _SparklineTrend({
    required this.direction,
    required this.percentage,
  });

  final TrendDirection direction;
  final double percentage;
}

enum TrendDirection { up, down, neutral }
