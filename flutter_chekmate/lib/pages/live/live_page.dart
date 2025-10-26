import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// Live streaming page - ChekMate Dating Experience Platform
/// Share and watch live dating experiences, stories, and community discussions
/// NOT for live dating - for sharing experiences and learning from others
class LivePage extends StatefulWidget {
  const LivePage({
    required this.userAvatar,
    super.key,
  });
  final String userAvatar;

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  String _activeCategory = 'all';
  bool _showGoLiveModal = false;

  @override
  Widget build(BuildContext context) {
    final filteredStreams = _activeCategory == 'all'
        ? MockLiveStreams.streams
        : MockLiveStreams.streams
            .where((s) => s.category.toLowerCase().contains(_activeCategory))
            .toList();

    return Stack(
      children: [
        Column(
          children: [
            _buildGoLiveSection(),
            _buildCategoryTabs(),
            _buildLiveStats(filteredStreams),
            Expanded(
              child: filteredStreams.isEmpty
                  ? _buildEmptyState()
                  : _buildLiveStreamsGrid(filteredStreams),
            ),
            _buildTrendingTopics(),
          ],
        ),
        if (_showGoLiveModal) _buildGoLiveModal(),
      ],
    );
  }

  Widget _buildGoLiveSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFEC4899)],
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(widget.userAvatar),
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to share your experience?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Go live and share your dating experiences with the community',
                  style: TextStyle(
                    color: Color(0xFFFECDD3),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          AppButton(
            onPressed: () => setState(() => _showGoLiveModal = true),
            variant: AppButtonVariant.outline,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam, size: 18),
                SizedBox(width: AppSpacing.xs),
                Text('Go Live'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = [
      {'id': 'all', 'label': 'All Live', 'icon': Icons.videocam},
      {'id': 'experiences', 'label': 'Experience Sharing', 'icon': Icons.forum},
      {
        'id': 'advice',
        'label': 'Community Q&A',
        'icon': Icons.chat_bubble_outline,
      },
      {'id': 'stories', 'label': 'Live Stories', 'icon': Icons.people},
    ];

    return AppCard(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: categories.map((category) {
            final isActive = _activeCategory == category['id'];
            return GestureDetector(
              onTap: () =>
                  setState(() => _activeCategory = category['id'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: 16,
                      color:
                          isActive ? AppColors.primary : Colors.grey.shade600,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      category['label'] as String,
                      style: TextStyle(
                        color:
                            isActive ? AppColors.primary : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLiveStats(List<LiveStream> streams) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '🔴 ${streams.length} live streams',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          Text(
            '👀 ${streams.fold(0, (sum, s) => sum + s.viewerCount)} total viewers',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStreamsGrid(List<LiveStream> streams) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.75,
      ),
      itemCount: streams.length,
      itemBuilder: (context, index) => _buildLiveStreamCard(streams[index]),
    );
  }

  Widget _buildLiveStreamCard(LiveStream stream) {
    return GestureDetector(
      onTap: () {
        if (kDebugMode) {
          debugPrint('Open stream: ${stream.id}');
        }
        // Navigate to stream viewer - ready for implementation
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (context) => StreamViewerPage(streamId: stream.id),
        // ));
      },
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(8)),
                      image: DecorationImage(
                        image: NetworkImage(stream.thumbnail),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // LIVE badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Viewer count
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stream.viewers,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Stream info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(stream.avatar),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stream.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          stream.streamer,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
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
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, size: 64, color: Colors.grey),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'No Live Experiences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'No one is sharing experiences live right now.\nBe the first to share your story!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              onPressed: () => setState(() => _showGoLiveModal = true),
              child: const Text('Share Your Experience Live'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingTopics() {
    return AppCard(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trending Experience Topics',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              '#DateExperiences',
              '#RedFlags',
              '#DateStories',
              '#DatingLessons',
              '#ChekMateRatings',
            ]
                .map(
                  (topic) => Chip(
                    label: Text(topic),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoLiveModal() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: AppCard(
          margin: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Go Live',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _showGoLiveModal = false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Share your dating experiences live with the community!\n\nThis feature is coming soon.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                onPressed: () => setState(() => _showGoLiveModal = false),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mock data
class LiveStream {
  LiveStream({
    required this.id,
    required this.streamer,
    required this.username,
    required this.avatar,
    required this.title,
    required this.viewers,
    required this.viewerCount,
    required this.duration,
    required this.category,
    required this.thumbnail,
  });
  final String id;
  final String streamer;
  final String username;
  final String avatar;
  final String title;
  final String viewers;
  final int viewerCount;
  final String duration;
  final String category;
  final String thumbnail;
}

class MockLiveStreams {
  static final List<LiveStream> streams = [
    LiveStream(
      id: '1',
      streamer: 'Sarah - Experience Sharer',
      username: '@sarahshares',
      avatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786',
      title: 'Red Flags I Spotted - My Dating Experience Story',
      viewers: '2.4K',
      viewerCount: 2400,
      duration: '1h 23m',
      category: 'Experience Sharing',
      thumbnail: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2',
    ),
  ];
}
