import 'package:flutter/material.dart';

import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/animations/micro_interactions.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
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
      backgroundColor: Colors.grey.shade50,
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
        actions: [
          AppButton(
            onPressed: () => _startNewConversation(),
            variant: AppButtonVariant.text,
            size: AppButtonSize.sm,
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

          // Conversations List - Demo version with staggered animations
          Expanded(
            child: AppScrollArea(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: 3, // Demo conversations
                itemBuilder: (context, index) {
                  return _DemoConversationTile(
                    index: index,
                    onTap: () => _openDemoConversation(index),
                  ).staggeredFadeIn(
                    index: index,
                    delay: const Duration(milliseconds: 80),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startNewConversation() {
    // Navigate to user selection or search
  }

  void _openDemoConversation(int index) {
    final demoUsers = [
      {
        'id': 'user1',
        'name': 'Alice Johnson',
        'avatar': 'https://via.placeholder.com/60',
      },
      {
        'id': 'user2',
        'name': 'Bob Smith',
        'avatar': 'https://via.placeholder.com/60',
      },
      {
        'id': 'user3',
        'name': 'Carol Davis',
        'avatar': 'https://via.placeholder.com/60',
      },
    ];

    final user = demoUsers[index];
    context.push(
      '/chat/demo_$index',
      extra: {
        'otherUserId': user['id'],
        'otherUserName': user['name'],
        'otherUserAvatar': user['avatar'],
      },
    );
  }
}

/// Demo Conversation Tile Widget using design system components
class _DemoConversationTile extends StatelessWidget {
  const _DemoConversationTile({
    required this.index,
    required this.onTap,
  });

  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final demoData = [
      {
        'name': 'Alice Johnson',
        'avatar': 'https://via.placeholder.com/60',
        'lastMessage': 'Hey! How are you doing?',
        'time': '2h ago',
        'unreadCount': 2,
        'isOnline': true,
      },
      {
        'name': 'Bob Smith',
        'avatar': 'https://via.placeholder.com/60',
        'lastMessage': 'Thanks for the help yesterday!',
        'time': '1d ago',
        'unreadCount': 0,
        'isOnline': false,
      },
      {
        'name': 'Carol Davis',
        'avatar': 'https://via.placeholder.com/60',
        'lastMessage': 'See you at the meeting tomorrow',
        'time': '3d ago',
        'unreadCount': 1,
        'isOnline': true,
      },
    ];

    final data = demoData[index];

    return AppCard(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Stack(
          children: [
            HeroAvatar(
              tag: HeroTags.messageAvatar(data['id'] as String),
              imageUrl: data['avatar'] as String,
              name: data['name'] as String,
            ),
            if (data['isOnline'] as bool)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                data['name'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if ((data['unreadCount'] as int) > 0)
              AppBadge(
                label: (data['unreadCount'] as int).toString(),
                variant: AppBadgeVariant.error,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Text(
              data['lastMessage'] as String,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              data['time'] as String,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: AppButton(
          onPressed: () => _showConversationOptions(context, data),
          variant: AppButtonVariant.text,
          size: AppButtonSize.sm,
          child: const Icon(Icons.more_vert, color: AppColors.textSecondary),
        ),
      ),
    );
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
