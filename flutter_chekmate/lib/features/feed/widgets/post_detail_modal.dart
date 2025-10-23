import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// Post Detail Modal - converted from PostDetailModal.tsx
/// Full-screen view of a post with actions
class PostDetailModal extends StatelessWidget {
  const PostDetailModal({
    required this.username, required this.avatar, required this.content, super.key,
    this.image,
  });
  final String username;
  final String avatar;
  final String content;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          _buildStories(),
          _buildPostContent(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'C',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Search here ...',
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildStories() {
    final stories = List.generate(6,
        (i) => 'https://images.unsplash.com/photo-1618590067690-2db34a87750a',);

    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Stories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Text(
                      'Sort by Time',
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    Icon(Icons.keyboard_arrow_down,
                        size: 16, color: Colors.grey.shade600,),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: stories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  return Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        image: DecorationImage(
                          image: NetworkImage(stories[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostContent() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(avatar),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  username,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600,),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              content,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            if (image != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  image!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.md),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Row(
            children: [
              Expanded(
                  child: _buildActionButton(Icons.bookmark_outline, 'Chek'),),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                  child: _buildActionButton(
                      Icons.share_outlined, 'Share with friends',),),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildActionButton(Icons.filter_alt_outlined, 'Share to story'),
          const SizedBox(height: AppSpacing.sm),
          _buildActionButton(Icons.upload_outlined, 'Share Via...'),
          const SizedBox(height: AppSpacing.sm),
          _buildActionButton(Icons.person_add_outlined, 'Follow $username'),
          const SizedBox(height: AppSpacing.sm),
          _buildActionButton(Icons.people_outline, 'Find Friends'),
          const SizedBox(height: AppSpacing.sm),
          _buildActionButton(Icons.info_outline, 'Privacy Policy'),
          const SizedBox(height: AppSpacing.sm),
          _buildActionButton(Icons.info_outline, 'Terms and conditions'),
          const SizedBox(height: AppSpacing.xxl),
        ]),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
