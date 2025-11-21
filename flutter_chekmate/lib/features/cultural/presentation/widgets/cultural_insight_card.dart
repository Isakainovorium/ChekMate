import 'package:flutter/material.dart';
import 'package:flutter_chekmate/features/cultural/models/regional_pattern_model.dart';

/// Card displaying cultural insights and patterns
class CulturalInsightCard extends StatelessWidget {
  final RegionalPattern pattern;
  final VoidCallback? onTap;

  const CulturalInsightCard({
    super.key,
    required this.pattern,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildPatternIcon(context),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pattern.patternType.displayName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          pattern.region,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (pattern.trendDirection != null)
                    _buildTrendIndicator(context),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Based on ${pattern.sampleSize} data points',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: pattern.confidenceScore,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getConfidenceColor(pattern.confidenceScore),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Confidence: ${(pattern.confidenceScore * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatternIcon(BuildContext context) {
    IconData icon;
    Color color;

    switch (pattern.patternType) {
      case PatternType.datingBehavior:
        icon = Icons.favorite;
        color = Colors.pink;
        break;
      case PatternType.communicationStyle:
        icon = Icons.chat;
        color = Colors.blue;
        break;
      case PatternType.safetyConcern:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case PatternType.culturalNorm:
        icon = Icons.public;
        color = Colors.purple;
        break;
      default:
        icon = Icons.insights;
        color = Colors.teal;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildTrendIndicator(BuildContext context) {
    final trend = pattern.trendDirection!;
    IconData icon;
    Color color;

    switch (trend) {
      case TrendDirection.increasing:
        icon = Icons.trending_up;
        color = Colors.green;
        break;
      case TrendDirection.decreasing:
        icon = Icons.trending_down;
        color = Colors.red;
        break;
      case TrendDirection.emerging:
        icon = Icons.new_releases;
        color = Colors.amber;
        break;
      default:
        icon = Icons.trending_flat;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 20);
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.5) return Colors.orange;
    return Colors.red;
  }
}
