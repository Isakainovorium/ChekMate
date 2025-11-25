import 'package:flutter/material.dart';

/// Post Detail Modal - Shows detailed view of a post
class PostDetailModal extends StatelessWidget {
  const PostDetailModal({
    required this.username,
    required this.avatar,
    required this.content,
    super.key,
  });

  final String username;
  final String avatar;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(avatar),
              radius: 50,
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

