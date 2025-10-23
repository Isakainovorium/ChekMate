import 'package:flutter/material.dart';
import 'package:flutter_chekmate/shared/ui/animations/interactive_animations.dart';
import 'package:flutter_chekmate/shared/ui/animations/lottie_animations.dart';
import 'package:flutter_chekmate/shared/ui/loading/shimmer_loading.dart';
import 'package:flutter_chekmate/shared/ui/loading/shimmer_skeletons.dart';

/// Loading & Animation Examples
///
/// Demonstrates all shimmer loading states and Lottie animations
/// available in the ChekMate app.
class LoadingAnimationExamples extends StatefulWidget {
  const LoadingAnimationExamples({super.key});

  @override
  State<LoadingAnimationExamples> createState() =>
      _LoadingAnimationExamplesState();
}

class _LoadingAnimationExamplesState extends State<LoadingAnimationExamples> {
  bool _isLiked = false;
  bool _isBookmarked = false;
  int _likeCount = 42;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading & Animations'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Shimmer Loading States',
            [
              _buildExample(
                'Basic Shimmer Components',
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 200, height: 20),
                    SizedBox(height: 8),
                    ShimmerCircle(size: 50),
                    SizedBox(height: 8),
                    ShimmerLine(width: 150),
                    SizedBox(height: 8),
                    ShimmerText(),
                  ],
                ),
              ),
              _buildExample(
                'Post Feed Skeleton',
                const SizedBox(
                  height: 400,
                  child: PostFeedShimmer(itemCount: 1),
                ),
              ),
              _buildExample(
                'Profile Header Skeleton',
                const ProfileHeaderShimmer(),
              ),
              _buildExample(
                'Message List Skeleton',
                const SizedBox(
                  height: 300,
                  child: MessageListShimmer(itemCount: 3),
                ),
              ),
              _buildExample(
                'Story Circles Skeleton',
                const StoryCircleShimmer(itemCount: 5),
              ),
              _buildExample(
                'Grid Photos Skeleton',
                const SizedBox(
                  height: 300,
                  child: GridPhotoShimmer(itemCount: 6),
                ),
              ),
              _buildExample(
                'Comment Skeleton',
                const SizedBox(
                  height: 200,
                  child: CommentShimmer(itemCount: 2),
                ),
              ),
              _buildExample(
                'Search Results Skeleton',
                const SizedBox(
                  height: 300,
                  child: SearchResultShimmer(itemCount: 3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSection(
            'Lottie Animations',
            [
              _buildExample(
                'Loading Animation',
                const LoadingAnimation(
                  message: 'Loading...',
                ),
              ),
              _buildExample(
                'Success Animation',
                const SuccessAnimation(
                  size: 120,
                  message: 'Success!',
                ),
              ),
              _buildExample(
                'Error Animation',
                const ErrorAnimation(
                  size: 120,
                  message: 'Something went wrong',
                ),
              ),
              _buildExample(
                'Empty State',
                EmptyStateAnimation(
                  size: 150,
                  title: 'No Posts Yet',
                  message: 'Start sharing your moments!',
                  actionButton: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Create Post'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSection(
            'Interactive Animations',
            [
              _buildExample(
                'Animated Like Button',
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedLikeButton(
                      isLiked: _isLiked,
                      likeCount: _likeCount,
                      size: 40,
                      onTap: () {
                        setState(() {
                          _isLiked = !_isLiked;
                          _likeCount += _isLiked ? 1 : -1;
                        });
                      },
                    ),
                  ],
                ),
              ),
              _buildExample(
                'Animated Bookmark Button',
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBookmarkButton(
                      isBookmarked: _isBookmarked,
                      size: 40,
                      onTap: () {
                        setState(() {
                          _isBookmarked = !_isBookmarked;
                        });
                      },
                    ),
                  ],
                ),
              ),
              _buildExample(
                'Checkmark Animation',
                const AnimatedCheckmark(size: 80),
              ),
              _buildExample(
                'Confetti Animation',
                const ConfettiAnimation(size: 200),
              ),
              _buildExample(
                'Swipe Indicators',
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SwipeIndicatorAnimation(
                      size: 60,
                    ),
                    SwipeIndicatorAnimation(
                      direction: SwipeDirection.left,
                      size: 60,
                    ),
                    SwipeIndicatorAnimation(
                      direction: SwipeDirection.right,
                      size: 60,
                    ),
                  ],
                ),
              ),
              _buildExample(
                'Pulsing Animation',
                PulsingAnimation(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> examples) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...examples,
      ],
    );
  }

  Widget _buildExample(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: child,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Usage Examples in Real Screens
///
/// Shows how to integrate shimmer and animations into actual app screens.
class LoadingStateExample extends StatefulWidget {
  const LoadingStateExample({super.key});

  @override
  State<LoadingStateExample> createState() => _LoadingStateExampleState();
}

class _LoadingStateExampleState extends State<LoadingStateExample> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const PostFeedShimmer()
          : ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => _buildPostItem(index),
            ),
    );
  }

  Widget _buildPostItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
            ),
            title: Text('User $index'),
            subtitle: const Text('2 hours ago'),
            trailing: const Icon(Icons.more_vert),
          ),
          // Image
          Image.network(
            'https://picsum.photos/400/400?random=$index',
            width: double.infinity,
            height: 400,
            fit: BoxFit.cover,
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                AnimatedLikeButton(
                  isLiked: index % 2 == 0,
                  likeCount: 42 + index,
                  onTap: () {},
                ),
                const SizedBox(width: 16),
                const Icon(Icons.comment_outlined),
                const SizedBox(width: 16),
                const Icon(Icons.send_outlined),
                const Spacer(),
                AnimatedBookmarkButton(
                  isBookmarked: index % 3 == 0,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

