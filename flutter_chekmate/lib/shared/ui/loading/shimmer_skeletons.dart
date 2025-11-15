import 'package:flutter/material.dart';
import 'package:flutter_chekmate/shared/ui/loading/shimmer_loading.dart';

/// Post Feed Shimmer Skeleton
///
/// Displays a loading skeleton for social media posts in the feed.
/// Mimics the structure of a real post with avatar, username, image, and actions.
/// Used for dating experience story feed loading states.
///
/// Date: November 13, 2025
class PostFeedShimmer extends StatelessWidget {
  const PostFeedShimmer({
    super.key,
    this.itemCount = 3,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const _PostItemShimmer(),
    );
  }
}

class _PostItemShimmer extends StatelessWidget {
  const _PostItemShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).cardColor,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (avatar + username)
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                ShimmerCircle(size: 40),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLine(width: 120, height: 14),
                      SizedBox(height: 4),
                      ShimmerLine(width: 80, height: 10),
                    ],
                  ),
                ),
                ShimmerBox(width: 24, height: 24, borderRadius: 12),
              ],
            ),
          ),

          // Post Image (square aspect ratio like Instagram)
          ShimmerImage(
            borderRadius: 0,
          ),

          // Actions (like, comment, share)
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                ShimmerBox(width: 24, height: 24, borderRadius: 12),
                SizedBox(width: 16),
                ShimmerBox(width: 24, height: 24, borderRadius: 12),
                SizedBox(width: 16),
                ShimmerBox(width: 24, height: 24, borderRadius: 12),
                Spacer(),
                ShimmerBox(width: 24, height: 24, borderRadius: 12),
              ],
            ),
          ),

          // Likes count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: ShimmerLine(width: 100),
          ),

          // Caption
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLine(width: double.infinity),
                SizedBox(height: 4),
                ShimmerLine(width: 200),
              ],
            ),
          ),

          // Comments preview
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: ShimmerLine(width: 150, height: 10),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Profile Header Shimmer Skeleton
///
/// Used for dating profile header loading states.
class ProfileHeaderShimmer extends StatelessWidget {
  const ProfileHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile picture
          ShimmerCircle(size: 100),
          SizedBox(height: 16),

          // Username
          ShimmerLine(width: 150, height: 18),
          SizedBox(height: 8),

          // Bio
          ShimmerText(lines: 2),
          SizedBox(height: 16),

          // Stats (posts, followers, following)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatShimmer(),
              _StatShimmer(),
              _StatShimmer(),
            ],
          ),
          SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(child: ShimmerBox(height: 36)),
              SizedBox(width: 8),
              Expanded(child: ShimmerBox(height: 36)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatShimmer extends StatelessWidget {
  const _StatShimmer();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ShimmerLine(width: 40, height: 16),
        SizedBox(height: 4),
        ShimmerLine(width: 60),
      ],
    );
  }
}

/// Message List Shimmer Skeleton
///
/// Used for dating community message list loading states.
class MessageListShimmer extends StatelessWidget {
  const MessageListShimmer({
    super.key,
    this.itemCount = 10,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const _MessageItemShimmer(),
    );
  }
}

class _MessageItemShimmer extends StatelessWidget {
  const _MessageItemShimmer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ShimmerCircle(size: 56),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLine(width: 120, height: 14),
                SizedBox(height: 6),
                ShimmerLine(width: double.infinity),
              ],
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerLine(width: 40, height: 10),
              SizedBox(height: 6),
              ShimmerCircle(size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

/// Story Circle Shimmer Skeleton
///
/// Used for dating story circle loading states.
class StoryCircleShimmer extends StatelessWidget {
  const StoryCircleShimmer({
    super.key,
    this.itemCount = 8,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(
            left: index == 0 ? 16 : 8,
            right: index == itemCount - 1 ? 16 : 0,
          ),
          child: const Column(
            children: [
              ShimmerCircle(size: 64),
              SizedBox(height: 4),
              ShimmerLine(width: 60, height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid Photo Shimmer Skeleton (for profile photo grid)
///
/// Used for dating profile photo grid loading states.
class GridPhotoShimmer extends StatelessWidget {
  const GridPhotoShimmer({
    super.key,
    this.itemCount = 9,
    this.crossAxisCount = 3,
  });

  final int itemCount;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerImage(
        borderRadius: 0,
      ),
    );
  }
}

/// Comment Shimmer Skeleton
///
/// Used for dating story comment loading states.
class CommentShimmer extends StatelessWidget {
  const CommentShimmer({
    super.key,
    this.itemCount = 5,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerCircle(size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLine(width: 100),
                  SizedBox(height: 4),
                  ShimmerText(lines: 2, lineHeight: 10),
                  SizedBox(height: 4),
                  ShimmerLine(width: 60, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Search Result Shimmer Skeleton
///
/// Used for dating content search result loading states.
class SearchResultShimmer extends StatelessWidget {
  const SearchResultShimmer({
    super.key,
    this.itemCount = 8,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerListItem(
        hasTrailing: true,
      ),
    );
  }
}


