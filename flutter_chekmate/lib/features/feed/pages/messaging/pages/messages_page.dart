import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:go_router/go_router.dart';

/// Messages page - converted from MessagesPage.tsx
/// Shows list of conversations with search
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredConversations = MockConversations.conversations
        .where(
          (c) =>
              c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.username.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: filteredConversations.isEmpty
                ? _buildEmptyState()
                : _buildConversationsList(filteredConversations),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Messages',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => debugPrint('New message'),
                      icon: const Icon(Icons.add),
                    ),
                    IconButton(
                      onPressed: () => debugPrint('More options'),
                      icon: const Icon(Icons.more_horiz),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationsList(List<Conversation> conversations) {
    return ListView.separated(
      itemCount: conversations.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.grey.shade100,
      ),
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return _buildConversationItem(conversation);
      },
    );
  }

  Widget _buildConversationItem(Conversation conversation) {
    return InkWell(
      onTap: () {
        // Navigate to chat route with params
        final name = Uri.encodeComponent(conversation.name);
        final avatar = Uri.encodeComponent(conversation.avatar);
        final userId = Uri.encodeComponent(conversation.id);
        context.go(
          '/chat/${conversation.id}?userId=$userId&userName=$name&userAvatar=$avatar',
        );
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(conversation.avatar),
                ),
                if (conversation.online)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            // Conversation info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        conversation.name,
                        style: TextStyle(
                          fontWeight: conversation.unread
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                      Text(
                        conversation.timestamp,
                        style: TextStyle(
                          fontSize: 12,
                          color: conversation.unread
                              ? AppColors.primary
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: conversation.unread
                                ? Colors.grey.shade900
                                : Colors.grey.shade600,
                            fontWeight: conversation.unread
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'No conversations found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _searchQuery.isEmpty
                ? 'Start a new conversation'
                : 'Try a different search term',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

/// Mock data models
class Conversation {
  Conversation({
    required this.id,
    required this.name,
    required this.username,
    required this.avatar,
    required this.lastMessage,
    required this.timestamp,
    required this.unread,
    this.online = false,
  });
  final String id;
  final String name;
  final String username;
  final String avatar;
  final String lastMessage;
  final String timestamp;
  final bool unread;
  final bool online;
}

class MockConversations {
  static final List<Conversation> conversations = [
    Conversation(
      id: '1',
      name: 'Simone Gabrielle',
      username: '@thatgurlmone',
      avatar: 'https://images.unsplash.com/photo-1618590067690-2db34a87750a',
      lastMessage:
          'That means the world to me! I put a lot of effort into making it compelling',
      timestamp: '1h ago',
      unread: false,
      online: true,
    ),
    Conversation(
      id: '2',
      name: 'Jessica M',
      username: '@jessicam',
      avatar: 'https://images.unsplash.com/photo-1655249493799-9cee4fe983bb',
      lastMessage: 'Hey! Did you see the latest drama? 👀',
      timestamp: '2h ago',
      unread: true,
    ),
    Conversation(
      id: '3',
      name: 'Mike D',
      username: '@miked_official',
      avatar: 'https://images.unsplash.com/photo-1672685667592-0392f458f46f',
      lastMessage: 'Thanks for the advice on cooking dates!',
      timestamp: '5h ago',
      unread: false,
      online: true,
    ),
    Conversation(
      id: '4',
      name: 'Sarah J',
      username: '@sarahj_stories',
      avatar: 'https://images.unsplash.com/photo-1618590067690-2db34a87750a',
      lastMessage: 'Coffee tomorrow?',
      timestamp: 'Yesterday',
      unread: true,
    ),
  ];
}
