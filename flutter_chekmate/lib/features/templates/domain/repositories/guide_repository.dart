import '../../models/guide_model.dart';

/// Repository for managing community guides and user guide interactions
abstract class GuideRepository {
  // ===== GUIDE OPERATIONS =====

  /// Get all published guides
  Future<List<Guide>> getAllGuides({
    int limit = 50,
    int offset = 0,
    GuideCategory? category,
    GuideDifficulty? difficulty,
    List<String>? tags,
  });

  /// Get popular guides by helpful votes
  Future<List<Guide>> getPopularGuides({
    int limit = 20,
  });

  /// Get trending guides by recent views/helpful votes
  Future<List<Guide>> getTrendingGuides({
    int limit = 10,
    Duration? timeWindow,
  });

  /// Get guides by author/user
  Future<List<Guide>> getGuidesByAuthor({
    required String authorId,
    int limit = 20,
    int offset = 0,
  });

  /// Get guide by ID
  Future<Guide> getGuideById({
    required String guideId,
  });

  /// Search guides by query
  Future<List<Guide>> searchGuides({
    required String query,
    int limit = 20,
    int offset = 0,
    GuideCategory? category,
    GuideDifficulty? difficulty,
  });

  /// Create new guide (community contribution)
  Future<Guide> createGuide({
    required Guide guide,
  });

  /// Update guide (only by author)
  Future<Guide> updateGuide({
    required String guideId,
    required Guide guide,
  });

  /// Delete guide (only by author/admin)
  Future<void> deleteGuide({
    required String guideId,
  });

  /// Publish guide (admin approval required for feature)
  Future<Guide> publishGuide({
    required String guideId,
  });

  // ===== USER GUIDE INTERACTIONS =====

  /// Start reading a guide (creates UserGuide instance)
  Future<UserGuide> startGuide({
    required String guideId,
    required String userId,
  });

  /// Update user guide progress
  Future<UserGuide> updateGuideProgress({
    required String userGuideId,
    double progress,
    List<String>? completedSections,
    Map<String, String>? notes,
  });

  /// Get user's guide instances
  Future<List<UserGuide>> getUserGuides({
    required String userId,
    bool? completed,
    GuideCategory? category,
    int limit = 20,
    int offset = 0,
  });

  /// Get specific user guide instance
  Future<UserGuide> getUserGuide({
    required String userGuideId,
  });

  /// Bookmark section in guide
  Future<void> bookmarkSection({
    required String userGuideId,
    required String sectionId,
  });

  /// Remove bookmark from section
  Future<void> removeBookmark({
    required String userGuideId,
    required String sectionId,
  });

  /// Rate and review guide
  Future<UserGuide> rateGuide({
    required String userGuideId,
    int rating,
    String? review,
  });

  /// Enable/disable guide reminders
  Future<void> toggleGuideReminders({
    required String userGuideId,
    bool enabled,
  });

  /// Delete user's guide instance
  Future<void> deleteUserGuide({
    required String userGuideId,
  });

  // ===== GUIDE VOTING AND MODERATION =====

  /// Vote on guide helpfulness
  Future<GuideVote> voteOnGuide({
    required String guideId,
    required String userId,
    required bool isHelpful,
    int? rating, // 1-5 stars
    String? reviewComment,
  });

  /// Get guide votes
  Future<List<GuideVote>> getGuideVotes({
    required String guideId,
    int limit = 50,
  });

  /// Get user's votes
  Future<List<GuideVote>> getUserVotes({
    required String userId,
    int limit = 50,
  });

  /// Remove user's vote on guide
  Future<void> removeGuideVote({
    required String guideId,
    required String userId,
  });

  // ===== RECOMMENDATION SYSTEM =====

  /// Get recommended guides for user
  Future<List<Guide>> getRecommendedGuides({
    required String userId,
    int limit = 10,
  });

  /// Get related guides
  Future<List<Guide>> getRelatedGuides({
    required String guideId,
    int limit = 5,
  });

  /// Track guide analytics
  Future<void> trackGuideUsage({
    required String guideId,
    required String userId,
    String action, // 'viewed', 'started', 'completed', 'shared'
    String? sectionId,
  });

  // ===== GUIDE STATISTICS =====

  /// Get guide usage statistics
  Future<Map<String, dynamic>> getGuideStatistics({
    required String guideId,
  });

  /// Get overall user guide statistics
  Future<Map<String, dynamic>> getUserGuideStatistics({
    required String userId,
  });

  /// Get community guide statistics
  Future<Map<String, dynamic>> getCommunityGuideStatistics();

  // ===== MODERATION AND ADMIN =====

  /// Get guides pending moderation
  Future<List<Guide>> getPendingGuides({
    int limit = 50,
  });

  /// Moderate guide (approve/reject)
  Future<Guide> moderateGuide({
    required String guideId,
    bool approved,
    String? moderatorNotes,
  });

  /// Feature guide in recommended section
  Future<Guide> featureGuide({
    required String guideId,
    bool featured,
  });

  // ===== CACHING AND OFFLINE =====

  /// Preload popular guides for offline use
  Future<void> preloadPopularGuides();

  /// Sync user guide progress when online
  Future<void> syncUserGuideProgress();

  /// Clear guide cache
  Future<void> clearGuideCache();
}
