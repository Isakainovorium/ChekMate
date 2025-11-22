import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppChart - Comprehensive charting with multiple types and data binding
class AppChart extends StatefulWidget {
  const AppChart({
    required this.data, required this.type, super.key,
    this.title,
    this.subtitle,
    this.width,
    this.height = 300,
    this.showLegend = true,
    this.showGrid = true,
    this.showLabels = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.colors,
    this.onDataPointTap,
  });

  final AppChartData data;
  final AppChartType type;
  final String? title;
  final String? subtitle;
  final double? width;
  final double height;
  final bool showLegend;
  final bool showGrid;
  final bool showLabels;
  final bool animate;
  final Duration animationDuration;
  final List<Color>? colors;
  final void Function(AppChartDataPoint)? onDataPointTap;

  @override
  State<AppChart> createState() => _AppChartState();
}

class _AppChartState extends State<AppChart> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.animate) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and subtitle
          if (widget.title != null || widget.subtitle != null) ...[
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          
          // Chart content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: widget.animate
                  ? AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) => _buildChart(_animation.toARGB32()),
                    )
                  : _buildChart(1.0),
            ),
          ),
          
          // Legend
          if (widget.showLegend && widget.data.series.length > 1) ...[
            _ChartLegend(
              series: widget.data.series,
              colors: _getColors(theme),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChart(double progress) {
    switch (widget.type) {
      case AppChartType.line:
        return _LineChart(
          data: widget.data,
          colors: _getColors(Theme.of(context)),
          showGrid: widget.showGrid,
          showLabels: widget.showLabels,
          progress: progress,
          onDataPointTap: widget.onDataPointTap,
        );
      case AppChartType.bar:
        return _BarChart(
          data: widget.data,
          colors: _getColors(Theme.of(context)),
          showGrid: widget.showGrid,
          showLabels: widget.showLabels,
          progress: progress,
          onDataPointTap: widget.onDataPointTap,
        );
      case AppChartType.pie:
        return _PieChart(
          data: widget.data,
          colors: _getColors(Theme.of(context)),
          showLabels: widget.showLabels,
          progress: progress,
          onDataPointTap: widget.onDataPointTap,
        );
      case AppChartType.area:
        return _AreaChart(
          data: widget.data,
          colors: _getColors(Theme.of(context)),
          showGrid: widget.showGrid,
          showLabels: widget.showLabels,
          progress: progress,
          onDataPointTap: widget.onDataPointTap,
        );
    }
  }

  List<Color> _getColors(ThemeData theme) {
    if (widget.colors != null) return widget.colors!;
    
    return [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({
    required this.data,
    required this.colors,
    required this.showGrid,
    required this.showLabels,
    required this.progress,
    this.onDataPointTap,
  });

  final AppChartData data;
  final List<Color> colors;
  final bool showGrid;
  final bool showLabels;
  final double progress;
  final void Function(AppChartDataPoint)? onDataPointTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(
        data: data,
        colors: colors,
        showGrid: showGrid,
        showLabels: showLabels,
        progress: progress,
        theme: Theme.of(context),
      ),
      child: GestureDetector(
        onTapUp: (details) => _handleTap(details.localPosition),
      ),
    );
  }

  void _handleTap(Offset position) {
    // Implementation for tap handling would go here
    // This would calculate which data point was tapped
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({
    required this.data,
    required this.colors,
    required this.showGrid,
    required this.showLabels,
    required this.progress,
    this.onDataPointTap,
  });

  final AppChartData data;
  final List<Color> colors;
  final bool showGrid;
  final bool showLabels;
  final double progress;
  final void Function(AppChartDataPoint)? onDataPointTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarChartPainter(
        data: data,
        colors: colors,
        showGrid: showGrid,
        showLabels: showLabels,
        progress: progress,
        theme: Theme.of(context),
      ),
    );
  }
}

class _PieChart extends StatelessWidget {
  const _PieChart({
    required this.data,
    required this.colors,
    required this.showLabels,
    required this.progress,
    this.onDataPointTap,
  });

  final AppChartData data;
  final List<Color> colors;
  final bool showLabels;
  final double progress;
  final void Function(AppChartDataPoint)? onDataPointTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PieChartPainter(
        data: data,
        colors: colors,
        showLabels: showLabels,
        progress: progress,
        theme: Theme.of(context),
      ),
    );
  }
}

class _AreaChart extends StatelessWidget {
  const _AreaChart({
    required this.data,
    required this.colors,
    required this.showGrid,
    required this.showLabels,
    required this.progress,
    this.onDataPointTap,
  });

  final AppChartData data;
  final List<Color> colors;
  final bool showGrid;
  final bool showLabels;
  final double progress;
  final void Function(AppChartDataPoint)? onDataPointTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AreaChartPainter(
        data: data,
        colors: colors,
        showGrid: showGrid,
        showLabels: showLabels,
        progress: progress,
        theme: Theme.of(context),
      ),
    );
  }
}

// Chart Painters
class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.data,
    required this.colors,
    required this.showGrid,
    required this.showLabels,
    required this.progress,
    required this.theme,
  });

  final AppChartData data;
  final List<Color> colors;
  final bool showGrid;
  final bool showLabels;
  final double progress;
  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.series.isEmpty) return;

    final chartArea = Rect.fromLTWH(
      showLabels ? 40 : 10,
      10,
      size.width - (showLabels ? 50 : 20),
      size.height - (showLabels ? 50 : 20),
    );

    // Draw grid
    if (showGrid) {
      _drawGrid(canvas, chartArea);
    }

    // Draw lines for each series
    for (var seriesIndex = 0; seriesIndex < data.series.length; seriesIndex++) {
      final series = data.series[seriesIndex];
      final color = colors[seriesIndex % colors.length];
      
      _drawLineSeries(canvas, chartArea, series, color);
    }

    // Draw labels
    if (showLabels) {
      _drawLabels(canvas, chartArea);
    }
  }

  void _drawGrid(Canvas canvas, Rect chartArea) {
    final gridPaint = Paint()
      ..color = theme.colorScheme.outline.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    // Vertical grid lines
    for (var i = 0; i <= 5; i++) {
      final x = chartArea.left + (chartArea.width / 5) * i;
      canvas.drawLine(
        Offset(x, chartArea.top),
        Offset(x, chartArea.bottom),
        gridPaint,
      );
    }

    // Horizontal grid lines
    for (var i = 0; i <= 5; i++) {
      final y = chartArea.top + (chartArea.height / 5) * i;
      canvas.drawLine(
        Offset(chartArea.left, y),
        Offset(chartArea.right, y),
        gridPaint,
      );
    }
  }

  void _drawLineSeries(Canvas canvas, Rect chartArea, AppChartSeries series, Color color) {
    if (series.dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final maxValue = data.maxValue;
    final minValue = data.minValue;
    final valueRange = maxValue - minValue;

    for (var i = 0; i < series.dataPoints.length; i++) {
      final point = series.dataPoints[i];
      final x = chartArea.left + (i / (series.dataPoints.length - 1)) * chartArea.width;
      final normalizedValue = valueRange > 0 ? (point.value - minValue) / valueRange : 0.5;
      final y = chartArea.bottom - (normalizedValue * chartArea.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Apply progress animation
    if (progress < 1.0) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(
        chartArea.left,
        chartArea.top,
        chartArea.width * progress,
        chartArea.height,
      ),);
    }

    canvas.drawPath(path, paint);

    if (progress < 1.0) {
      canvas.restore();
    }
  }

  void _drawLabels(Canvas canvas, Rect chartArea) {
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    
    if (textStyle == null) return;

    // Y-axis labels
    for (var i = 0; i <= 5; i++) {
      final value = data.minValue + (data.maxValue - data.minValue) * (1 - i / 5);
      final y = chartArea.top + (chartArea.height / 5) * i;
      
      final textPainter = TextPainter(
        text: TextSpan(text: value.toStringAsFixed(0), style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data ||
           oldDelegate.progress != progress ||
           oldDelegate.showGrid != showGrid ||
           oldDelegate.showLabels != showLabels;
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.data,
    required this.colors,
    required this.showGrid,
    required this.showLabels,
    required this.progress,
    required this.theme,
  });

  final AppChartData data;
  final List<Color> colors;
  final bool showGrid;
  final bool showLabels;
  final double progress;
  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.series.isEmpty) return;

    final chartArea = Rect.fromLTWH(
      showLabels ? 40 : 10,
      10,
      size.width - (showLabels ? 50 : 20),
      size.height - (showLabels ? 50 : 20),
    );

    if (showGrid) {
      _drawGrid(canvas, chartArea);
    }

    _drawBars(canvas, chartArea);

    if (showLabels) {
      _drawLabels(canvas, chartArea);
    }
  }

  void _drawGrid(Canvas canvas, Rect chartArea) {
    final gridPaint = Paint()
      ..color = theme.colorScheme.outline.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    for (var i = 0; i <= 5; i++) {
      final y = chartArea.top + (chartArea.height / 5) * i;
      canvas.drawLine(
        Offset(chartArea.left, y),
        Offset(chartArea.right, y),
        gridPaint,
      );
    }
  }

  void _drawBars(Canvas canvas, Rect chartArea) {
    if (data.series.isEmpty) return;

    final series = data.series.first;
    final barCount = series.dataPoints.length;
    final barWidth = chartArea.width / barCount * 0.8;
    final barSpacing = chartArea.width / barCount * 0.2;

    for (var i = 0; i < series.dataPoints.length; i++) {
      final point = series.dataPoints[i];
      final color = colors[i % colors.length];
      
      final x = chartArea.left + (chartArea.width / barCount) * i + barSpacing / 2;
      final normalizedValue = (point.value - data.minValue) / (data.maxValue - data.minValue);
      final barHeight = chartArea.height * normalizedValue * progress;
      
      final rect = Rect.fromLTWH(
        x,
        chartArea.bottom - barHeight,
        barWidth,
        barHeight,
      );

      final paint = Paint()..color = color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint,
      );
    }
  }

  void _drawLabels(Canvas canvas, Rect chartArea) {
    // Similar to line chart labels implementation
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.data != data ||
           oldDelegate.progress != progress;
  }
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter({
    required this.data,
    required this.colors,
    required this.showLabels,
    required this.progress,
    required this.theme,
  });

  final AppChartData data;
  final List<Color> colors;
  final bool showLabels;
  final double progress;
  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.series.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width < size.height ? size.width : size.height) / 2 - 20;

    final series = data.series.first;
    final total = series.dataPoints.fold(0.0, (sum, point) => sum + point.toARGB32());
    
    var startAngle = -90 * (3.14159 / 180); // Start from top

    for (var i = 0; i < series.dataPoints.length; i++) {
      final point = series.dataPoints[i];
      final sweepAngle = (point.value / total) * 2 * 3.14159 * progress;
      final color = colors[i % colors.length];

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.data != data ||
           oldDelegate.progress != progress;
  }
}

class _AreaChartPainter extends CustomPainter {
  _AreaChartPainter({
    required this.data,
    required this.colors,
    required this.showGrid,
    required this.showLabels,
    required this.progress,
    required this.theme,
  });

  final AppChartData data;
  final List<Color> colors;
  final bool showGrid;
  final bool showLabels;
  final double progress;
  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    // Similar to line chart but with filled areas
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter oldDelegate) {
    return oldDelegate.data != data ||
           oldDelegate.progress != progress;
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({
    required this.series,
    required this.colors,
  });

  final List<AppChartSeries> series;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        children: series.asMap().entries.map((entry) {
          final index = entry.key;
          final seriesData = entry.value;
          final color = colors[index % colors.length];
          
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                seriesData.name,
                style: theme.textTheme.bodySmall,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// Data classes
class AppChartData {
  const AppChartData({
    required this.series,
    this.categories = const [],
  });

  final List<AppChartSeries> series;
  final List<String> categories;

  double get maxValue {
    var max = double.negativeInfinity;
    for (final series in this.series) {
      for (final point in series.dataPoints) {
        if (point.value > max) max = point.value;
      }
    }
    return max == double.negativeInfinity ? 0 : max;
  }

  double get minValue {
    var min = double.infinity;
    for (final series in this.series) {
      for (final point in series.dataPoints) {
        if (point.value < min) min = point.value;
      }
    }
    return min == double.infinity ? 0 : min;
  }
}

class AppChartSeries {
  const AppChartSeries({
    required this.name,
    required this.dataPoints,
  });

  final String name;
  final List<AppChartDataPoint> dataPoints;
}

class AppChartDataPoint {
  const AppChartDataPoint({
    required this.value,
    this.label,
    this.category,
  });

  final double value;
  final String? label;
  final String? category;
}

enum AppChartType { line, bar, pie, area }
