import 'package:flutter/material.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_chekmate/features/posts/domain/entities/reaction_entity.dart';
import 'package:flutter_chekmate/features/posts/presentation/widgets/reaction_button.dart';
import 'package:flutter_chekmate/features/posts/presentation/widgets/share_post_button.dart';

/// PostActionsBar - Presentation Layer Widget
///
/// A comprehensive action bar for posts that includes:
/// - Like button
/// - Comment button
/// - Share button
/// - Reaction button
/// - Bookmark button
///
/// This widget demonstrates the integration of share and reaction features.
///
/// Clean Architecture: Presentation Layer
class PostActionsBar extends StatelessWidget {
  const PostActionsBar({
    required this.post,
    required this.currentUserId,
    required this.reactions,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onReactionAdded,
    required this.onReactionRemoved,
    required this.onBookmark,
    super.key,
    this.showReactions = true,
    this.showShare = true,
    this.showBookmark = true,
  });

  final PostEntity post;
  final String currentUserId;
  final List<ReactionSummary> reactions;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final void Function(String emoji) onReactionAdded;
  final void Function(String emoji) onReactionRemoved;
  final VoidCallback onBookmark;
  final bool showReactions;
  final bool showShare;
  final bool showBookmark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLiked = post.isLikedBy(currentUserId);
    final isBookmarked = post.isBookmarkedBy(currentUserId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Like button
          InkWell(
            onTap: onLike,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: isLiked ? Colors.red : theme.iconTheme.color,
                  ),
                  if (post.likes > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      _formatCount(post.likes),
                      style: TextStyle(
                        fontSize: 12,
                        color: isLiked ? Colors.red : theme.iconTheme.color,
                        fontWeight: isLiked ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Comment button
          InkWell(
            onTap: onComment,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 20,
                    color: theme.iconTheme.color,
                  ),
                  if (post.comments > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      _formatCount(post.comments),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.iconTheme.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Reaction button
          if (showReactions)
            ReactionButton(
              reactions: reactions,
              currentUserId: currentUserId,
              onReactionAdded: onReactionAdded,
              onReactionRemoved: onReactionRemoved,
            ),

          const Spacer(),

          // Share button
          if (showShare)
            SharePostButton(
              post: post,
              onShare: onShare,
            ),

          // Bookmark button
          if (showBookmark)
            InkWell(
              onTap: onBookmark,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  size: 20,
                  color:
                      isBookmarked ? theme.primaryColor : theme.iconTheme.color,
                ),
              ),
            ),
        ],
      ),
    );
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

/// PostActionsBarExample - Example usage of PostActionsBar
///
/// This widget demonstrates how to use the PostActionsBar with all features.
class PostActionsBarExample extends StatefulWidget {
  const PostActionsBarExample({super.key});

  @override
  State<PostActionsBarExample> createState() => _PostActionsBarExampleState();
}

class _PostActionsBarExampleState extends State<PostActionsBarExample> {
  late PostEntity _post;
  final String _currentUserId = 'user123';
  List<ReactionSummary> _reactions = [];

  @override
  void initState() {
    super.initState();
    _post = PostEntity(
      id: 'post1',
      userId: 'user456',
      username: 'johndoe',
      userAvatar: 'https://example.com/avatar.jpg',
      content: 'Check out this amazing post with share and reactions!',
      images: const [],
      likes: 42,
      comments: 15,
      shares: 8,
      cheks: 0,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      isVerified: true,
      likedBy: const [],
      bookmarkedBy: const [],
    );

    _reactions = [
      const ReactionSummary(
        emoji: '❤️',
        count: 12,
        userIds: ['user1', 'user2', 'user3'],
        usernames: ['Alice', 'Bob', 'Charlie'],
      ),
      const ReactionSummary(
        emoji: '😂',
        count: 5,
        userIds: ['user4', 'user5'],
        usernames: ['David', 'Eve'],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Actions Bar Example'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Post content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(_post.userAvatar),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _post.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_post.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                              ],
                            ],
                          ),
                          Text(
                            _post.timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(_post.content),
                ],
              ),
            ),

            const Divider(height: 1),

            // Actions bar
            PostActionsBar(
              post: _post,
              currentUserId: _currentUserId,
              reactions: _reactions,
              onLike: _handleLike,
              onComment: _handleComment,
              onShare: _handleShare,
              onReactionAdded: _handleReactionAdded,
              onReactionRemoved: _handleReactionRemoved,
              onBookmark: _handleBookmark,
            ),

            const Divider(height: 1),

            // Reaction summary
            if (_reactions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _reactions.map((reaction) {
                    return Chip(
                      avatar: Text(
                        reaction.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      label: Text(
                        '${reaction.count} • ${reaction.getReactedByText(_currentUserId)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleLike() {
    setState(() {
      final isLiked = _post.isLikedBy(_currentUserId);
      if (isLiked) {
        _post = _post.copyWith(
          likes: _post.likes - 1,
          likedBy: _post.likedBy.where((id) => id != _currentUserId).toList(),
        );
      } else {
        _post = _post.copyWith(
          likes: _post.likes + 1,
          likedBy: [..._post.likedBy, _currentUserId],
        );
      }
    });
  }

  void _handleComment() {
    // Navigate to comments
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening comments...')),
    );
  }

  void _handleShare() {
    setState(() {
      _post = _post.copyWith(shares: _post.shares + 1);
    });
  }

  void _handleReactionAdded(String emoji) {
    setState(() {
      final existingIndex = _reactions.indexWhere((r) => r.emoji == emoji);
      if (existingIndex >= 0) {
        _reactions[existingIndex] = _reactions[existingIndex].copyWith(
          count: _reactions[existingIndex].count + 1,
          userIds: [..._reactions[existingIndex].userIds, _currentUserId],
          usernames: [..._reactions[existingIndex].usernames, 'You'],
        );
      } else {
        _reactions.add(
          ReactionSummary(
            emoji: emoji,
            count: 1,
            userIds: [_currentUserId],
            usernames: ['You'],
          ),
        );
      }
    });
  }

  void _handleReactionRemoved(String emoji) {
    setState(() {
      final existingIndex = _reactions.indexWhere((r) => r.emoji == emoji);
      if (existingIndex >= 0) {
        if (_reactions[existingIndex].count == 1) {
          _reactions.removeAt(existingIndex);
        } else {
          _reactions[existingIndex] = _reactions[existingIndex].copyWith(
            count: _reactions[existingIndex].count - 1,
            userIds: _reactions[existingIndex]
                .userIds
                .where((id) => id != _currentUserId)
                .toList(),
            usernames: _reactions[existingIndex]
                .usernames
                .where((name) => name != 'You')
                .toList(),
          );
        }
      }
    });
  }

  void _handleBookmark() {
    setState(() {
      final isBookmarked = _post.isBookmarkedBy(_currentUserId);
      if (isBookmarked) {
        _post = _post.copyWith(
          bookmarkedBy:
              _post.bookmarkedBy.where((id) => id != _currentUserId).toList(),
        );
      } else {
        _post = _post.copyWith(
          bookmarkedBy: [..._post.bookmarkedBy, _currentUserId],
        );
      }
    });
  }
}
