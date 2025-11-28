import 'package:flutter/material.dart';

import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/core/theme/app_theme.dart';
import 'package:flutter_chekmate/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_chekmate/features/messages/domain/entities/conversation_entity.dart';
import 'package:flutter_chekmate/features/messages/presentation/providers/messages_providers.dart';
import 'package:flutter_chekmate/shared/ui/animations/widget_animations.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:flutter_chekmate/shared/utils/hero_tags.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Messages page - Shows list of conversations with search using design system components
/// Enhanced with staggered animations and hero transitions
class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  // ignore: unused_field
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sprint 2 - Task 2.1.2: Use theme-aware background
      backgroundColor: Theme.of(context).surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        // Sprint 3 - Task 3.2.2: Added tooltip to new message button
        actions: [
          AppButton(
            onPressed: () => _startNewConversation(),
            variant: AppButtonVariant.text,
            size: AppButtonSize.sm,
            tooltip: 'New message',
            semanticLabel: 'Start a new conversation',
            child: const Icon(Icons.edit, color: AppColors.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: Colors.white,
            child: AppInput(
              hint: 'Search conversations...',
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.textSecondary),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Conversations List - Real data with shimmer loading
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final currentUserId = ref.watch(currentUserIdProvider) ?? '';
                final conversationsAsync =
                    ref.watch(conversationsStreamProvider(currentUserId));

                return conversationsAsync.when(
                  data: (conversations) {
                    if (conversations.isEmpty) {
                      return AppEmptyState(
                        icon: Icons.message_outlined,
                        title: 'No conversations yet',
                        message:
                            'Start a new conversation to connect with others!',
                        action: AppButton(
                          onPressed: _startNewConversation,
                          child: const Text('Start Conversation'),
                        ),
                      );
                    }

                    return AppScrollArea(
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final conversation = conversations[index];
                          return _ConversationTile(
                            conversation: conversation,
                            onTap: () => _openConversation(conversation.id),
                          ).staggeredFadeIn(
                            index: index,
                            staggerDelay: const Duration(milliseconds: 80),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const MessageListShimmer(itemCount: 5),
                  error: (error, stack) => AppEmptyState(
                    type: AppEmptyStateType.noConnection,
                    title: 'Error loading conversations',
                    message: error.toString(),
                    action: AppButton(
                      onPressed: () => ref
                          .refresh(conversationsStreamProvider(currentUserId)),
                      child: const Text('Retry'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _startNewConversation() {
    // Navigate to user selection or search
  }

  void _openConversation(String conversationId) {
    // Navigate to chat page with conversation ID
    context.push('/chat/$conversationId');
  }
}

/// Conversation Tile Widget using design system components
class _ConversationTile extends ConsumerWidget {
  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  final ConversationEntity conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.value?.uid ?? '';

    // Get other participant info
    final otherParticipantId =
        conversation.getOtherParticipantId(currentUserId);
    final otherParticipantName =
        conversation.getOtherParticipantName(currentUserId);
    final otherParticipantAvatar =
        conversation.getOtherParticipantAvatar(currentUserId);
    final unreadCount = conversation.getUnreadCount(currentUserId);

    return PremiumCard(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: EdgeInsets.zero,
      borderRadius: 16,
      elevation: 0.6,
      onTap: onTap,
      child: ListTile(
        leading: HeroAvatar(
          tag: HeroTags.messageAvatar(otherParticipantId),
          imageUrl: otherParticipantAvatar,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                otherParticipantName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (unreadCount > 0)
              AppBadge(
                label: unreadCount.toString(),
                variant: AppBadgeVariant.error,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Text(
              conversation.lastMessage,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _formatTimestamp(conversation.lastMessageTimestamp),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: AppButton(
          onPressed: () => _showConversationOptions(context, conversation),
          variant: AppButtonVariant.text,
          size: AppButtonSize.sm,
          child: const Icon(Icons.more_vert, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showConversationOptions(BuildContext context, dynamic conversation) {
    AppSheet.show<void>(
      context: context,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_off),
            title: const Text('Mute conversation'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete conversation'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Block user'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
