import 'package:flutter/material.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/reaction_entity.dart';
import 'package:flutter_chekmate/shared/ui/emoji/emoji_picker_widget.dart';

/// ReactionButton - Presentation Layer Widget
///
/// A button that allows users to react to a post with emojis.
/// Shows emoji picker when tapped and displays reaction summary.
/// **Uses Apple-style emojis on iOS devices for native look and feel.**
///
/// Features:
/// - Emoji picker integration with **Apple emoji rendering on iOS**
/// - Reaction summary display
/// - Quick reactions (8 common emojis: ❤️😂😮😢😡👍🔥🎉)
/// - Reaction count display
/// - User reaction highlighting
/// - Platform-specific emoji rendering (Apple emojis on iOS)
///
/// Clean Architecture: Presentation Layer
class ReactionButton extends StatefulWidget {
  const ReactionButton({
    required this.reactions,
    required this.currentUserId,
    required this.onReactionAdded,
    required this.onReactionRemoved,
    super.key,
    this.iconSize = 20,
    this.showCount = true,
    this.color,
  });

  final List<ReactionSummary> reactions;
  final String currentUserId;
  final void Function(String emoji) onReactionAdded;
  final void Function(String emoji) onReactionRemoved;
  final double iconSize;
  final bool showCount;
  final Color? color;

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.iconTheme.color ?? Colors.grey;

    // Check if user has reacted
    final userReaction = widget.reactions.firstWhere(
      (r) => r.hasUserReacted(widget.currentUserId),
      orElse: () => const ReactionSummary(
        emoji: '',
        count: 0,
        userIds: [],
        usernames: [],
      ),
    );

    final hasReacted = userReaction.emoji.isNotEmpty;
    final totalReactions =
        widget.reactions.fold<int>(0, (sum, r) => sum + r.count);

    return InkWell(
      onTap: _showReactionPicker,
      onLongPress: _showReactionPicker,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasReacted)
              Text(
                userReaction.emoji,
                style: TextStyle(fontSize: widget.iconSize),
              )
            else
              Icon(
                Icons.add_reaction_outlined,
                size: widget.iconSize,
                color: color,
              ),
            if (widget.showCount && totalReactions > 0) ...[
              const SizedBox(width: 4),
              Text(
                _formatCount(totalReactions),
                style: TextStyle(
                  fontSize: 12,
                  color: hasReacted ? theme.primaryColor : color,
                  fontWeight: hasReacted ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showReactionPicker() async {
    // Show quick reactions or full picker
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReactionPickerSheet(
        reactions: widget.reactions,
        currentUserId: widget.currentUserId,
        onQuickReaction: (emoji) {
          Navigator.of(context).pop(emoji);
        },
      ),
    );

    if (result != null && mounted) {
      // Check if user already reacted with this emoji
      final existingReaction = widget.reactions.firstWhere(
        (r) => r.emoji == result && r.hasUserReacted(widget.currentUserId),
        orElse: () => const ReactionSummary(
          emoji: '',
          count: 0,
          userIds: [],
          usernames: [],
        ),
      );

      if (existingReaction.emoji.isNotEmpty) {
        // Remove reaction
        widget.onReactionRemoved(result);
      } else {
        // Add reaction
        widget.onReactionAdded(result);
      }
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }
}

/// _ReactionPickerSheet - Internal widget for reaction picker bottom sheet
class _ReactionPickerSheet extends StatefulWidget {
  const _ReactionPickerSheet({
    required this.reactions,
    required this.currentUserId,
    required this.onQuickReaction,
  });

  final List<ReactionSummary> reactions;
  final String currentUserId;
  final void Function(String emoji) onQuickReaction;

  @override
  State<_ReactionPickerSheet> createState() => _ReactionPickerSheetState();
}

class _ReactionPickerSheetState extends State<_ReactionPickerSheet> {
  bool _showFullPicker = false;

  // Quick reaction emojis (most common)
  static const _quickReactions = [
    '❤️',
    '😂',
    '😮',
    '😢',
    '😡',
    '👍',
    '🔥',
    '🎉',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          if (!_showFullPicker) ...[
            // Quick reactions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Reactions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _quickReactions.map((emoji) {
                      final reaction = widget.reactions.firstWhere(
                        (r) => r.emoji == emoji,
                        orElse: () => ReactionSummary(
                          emoji: emoji,
                          count: 0,
                          userIds: const [],
                          usernames: const [],
                        ),
                      );

                      final hasReacted =
                          reaction.hasUserReacted(widget.currentUserId);

                      return _QuickReactionChip(
                        emoji: emoji,
                        count: reaction.count,
                        isSelected: hasReacted,
                        onTap: () => widget.onQuickReaction(emoji),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showFullPicker = true;
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('More Reactions'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ] else ...[
            // Full emoji picker
            SizedBox(
              height: 300,
              child: EmojiPickerWidget(
                height: 300,
                onEmojiSelected: (emoji) {
                  widget.onQuickReaction(emoji.emoji);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// _QuickReactionChip - Internal widget for quick reaction chips
class _QuickReactionChip extends StatelessWidget {
  const _QuickReactionChip({
    required this.emoji,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withValues(alpha: 0.1)
              : theme.cardColor,
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? theme.primaryColor : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
