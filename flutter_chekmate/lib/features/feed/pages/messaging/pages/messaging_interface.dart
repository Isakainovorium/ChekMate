import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// Messaging Interface - converted from MessagingInterface.tsx
/// Full-screen chat conversation view
class MessagingInterface extends StatefulWidget {
  const MessagingInterface({
    required this.recipientName,
    required this.recipientUsername,
    required this.recipientAvatar,
    super.key,
  });
  final String recipientName;
  final String recipientUsername;
  final String recipientAvatar;

  @override
  State<MessagingInterface> createState() => _MessagingInterfaceState();
}

class _MessagingInterfaceState extends State<MessagingInterface> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      text: 'Hey! I saw your latest video, it was amazing! 😍',
      timestamp: '2h ago',
      isOwn: false,
    ),
    ChatMessage(
      id: '2',
      text: 'Thank you so much! I really appreciate that 💕',
      timestamp: '2h ago',
      isOwn: true,
    ),
    ChatMessage(
      id: '3',
      text:
          'The way you told that story was so engaging. I was on the edge of my seat the whole time!',
      timestamp: '1h ago',
      isOwn: false,
    ),
    ChatMessage(
      id: '4',
      text:
          'That means the world to me! I put a lot of effort into making it compelling',
      timestamp: '1h ago',
      isOwn: true,
    ),
  ];

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().toString(),
          text: _messageController.text.trim(),
          timestamp: 'Just now',
          isOwn: true,
        ),
      );
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.close, color: Colors.black),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(widget.recipientAvatar),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.recipientName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                widget.recipientUsername,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            if (kDebugMode) {
              debugPrint('Video call initiated');
            }
            _startVideoCall();
          },
          icon: Icon(Icons.videocam_outlined, color: Colors.grey.shade600),
        ),
        IconButton(
          onPressed: () {
            if (kDebugMode) {
              debugPrint('Voice call initiated');
            }
            _startVoiceCall();
          },
          icon: Icon(Icons.mic_outlined, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment:
            message.isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: message.isOwn ? AppColors.primary : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: message.isOwn ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.timestamp,
                  style: TextStyle(
                    fontSize: 10,
                    color: message.isOwn
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Message ${widget.recipientName}...',
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
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Call functionality methods
  void _startVideoCall() {
    if (kDebugMode) {
      debugPrint('Starting video call with ${widget.recipientName}');
    }

    // Show video call dialog
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Video Call'),
        content: Text('Start video call with ${widget.recipientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In production, integrate with video calling service
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Video call with ${widget.recipientName} would start here',
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Start Call'),
          ),
        ],
      ),
    );
  }

  void _startVoiceCall() {
    if (kDebugMode) {
      debugPrint('Starting voice call with ${widget.recipientName}');
    }

    // Show voice call dialog
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Voice Call'),
        content: Text('Start voice call with ${widget.recipientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In production, integrate with voice calling service
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Voice call with ${widget.recipientName} would start here',
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Start Call'),
          ),
        ],
      ),
    );
  }
}

/// Chat message model
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isOwn,
  });
  final String id;
  final String text;
  final String timestamp;
  final bool isOwn;
}
