import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// Post Input Widget - converted from PostInputBar.tsx
/// Quick post creation input bar
class PostInputWidget extends StatefulWidget {
  const PostInputWidget({
    required this.userAvatar,
    required this.onCreatePost,
    super.key,
    this.placeholder = "What's on your mind?",
  });
  final String userAvatar;
  final void Function(String) onCreatePost;
  final String placeholder;

  @override
  State<PostInputWidget> createState() => _PostInputWidgetState();
}

class _PostInputWidgetState extends State<PostInputWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _showExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onCreatePost(_controller.text.trim());
      _controller.clear();
      setState(() => _showExpanded = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(widget.userAvatar),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  onTap: () => setState(() => _showExpanded = true),
                  onChanged: (_) => setState(() {}),
                  maxLines: _showExpanded ? 3 : 1,
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(AppSpacing.sm),
                  ),
                ),
                if (_showExpanded) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _buildExpandedOptions(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedOptions() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildActionButton(Icons.camera_alt, 'Photo'),
                const SizedBox(width: AppSpacing.md),
                _buildActionButton(Icons.image, 'Gallery'),
                const SizedBox(width: AppSpacing.md),
                _buildActionButton(Icons.emoji_emotions, 'Feeling'),
                const SizedBox(width: AppSpacing.md),
                _buildActionButton(Icons.location_on, 'Location'),
              ],
            ),
            if (_controller.text.isNotEmpty)
              Text(
                '${_controller.text.length}/280',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                _controller.clear();
                setState(() => _showExpanded = false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            ElevatedButton(
              onPressed: _controller.text.trim().isEmpty ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade200,
                disabledForegroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Post',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return InkWell(
      onTap: () => debugPrint('Action: $label'),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
