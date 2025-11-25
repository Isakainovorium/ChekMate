import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';

import '../../models/story_template_model.dart';

/// Template card component for the template selector
class TemplateCard extends StatelessWidget {
  final StoryTemplate template;
  final VoidCallback? onTap;
  final bool isSelected;

  const TemplateCard({
    super.key,
    required this.template,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? AppColors.primary
              .withValues(alpha: 0.1) // Golden orange tint when selected
          : AppColors.surface,
      elevation: isSelected ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : AppColors.border, // Golden border when selected
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and category indicator
              Row(
                children: [
                  // Template icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(
                              int.parse(template.color.replaceAll('#', '0xFF')))
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconForTemplate(template),
                      color: Color(
                          int.parse(template.color.replaceAll('#', '0xFF'))),
                      size: 24,
                    ),
                  ),

                  const Spacer(),

                  // Time estimate badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${template.estimatedMinutes}min',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                template.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Description
              Text(
                template.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Bottom row: difficulty and rating
              Row(
                children: [
                  // Difficulty badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(template.difficulty)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      template.difficulty,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getDifficultyColor(template.difficulty),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Rating
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.warning, // Gold star rating
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '4.${template.usageCount % 10}', // Mock rating based on usage
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Usage count (if significant)
              if (template.usageCount > 500)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${template.usageCount} stories created',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForTemplate(StoryTemplate template) {
    // Map template IDs to appropriate icons
    switch (template.id) {
      case 'first_date_red_flags':
        return Icons.warning; // Red flag warning
      case 'ghosting_recovery':
        return Icons.blur_on; // Simulated ghost effect
      case 'success_stories':
        return Icons.celebration; // Celebration/party
      case 'pattern_recognition':
        return Icons.analytics; // Analytics/data
      case 'long_distance_dating':
        return Icons.flight; // Airplane for travel
      default:
        return Icons.description; // Default document icon
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.success; // Green for easy
      case 'intermediate':
        return AppColors.warning; // Orange for medium
      case 'advanced':
        return AppColors.error; // Red for hard
      default:
        return AppColors.textSecondary;
    }
  }
}
