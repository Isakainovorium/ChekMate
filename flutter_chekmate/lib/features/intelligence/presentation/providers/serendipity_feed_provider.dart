import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../posts/domain/entities/post_entity.dart';
import '../../../posts/presentation/providers/posts_providers.dart';
import 'intelligence_providers.dart';

/// Serendipity Feed Provider
/// Provides diverse content recommendations when serendipity mode is enabled
final serendipityFeedProvider = FutureProvider<List<PostEntity>>((ref) async {
  final recommendations =
      await ref.watch(serendipityRecommendationsProvider.future);

  if (recommendations == null || recommendations.contentIds.isEmpty) {
    // Fallback to trending posts if no recommendations yet
    final trending = await ref.watch(trendingPostsProvider.future);
    return trending;
  }

  // Fetch posts by IDs from recommendations
  final datasource = ref.watch(postsRemoteDatasourceProvider);
  final posts = <PostEntity>[];

  for (final contentId in recommendations.contentIds.take(20)) {
    try {
      final post = await datasource.getPostById(contentId);
      posts.add(post);
    } catch (e) {
      // Skip posts that can't be loaded
      continue;
    }
  }

  return posts;
});
