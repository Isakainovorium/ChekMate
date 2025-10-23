import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// Video Card Widget - converted from VideoCard.tsx
/// Card displaying video thumbnail with metadata
class VideoCardWidget extends StatelessWidget {
  const VideoCardWidget({
    required this.id,
    required this.thumbnail,
    required this.title,
    required this.views,
    super.key,
    this.isChecked = false,
    this.onClick,
  });

  final String id;
  final String thumbnail;
  final String title;
  final String views;
  final bool isChecked;
  final VoidCallback? onClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: AppAspectRatio(
        aspectRatio: 9 / 16,
        child: AppCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video thumbnail
                Image.network(
                  thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade800,
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                // Dark overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
                // Cheked badge
                if (isChecked)
                  const Positioned(
                    top: 12,
                    left: 12,
                    child: AppBadge(
                      label: 'Cheked',
                    ),
                  ),
                // Content overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.play_arrow,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              views,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
