import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cache Service - Offline-first caching with Hive
/// 
/// Provides persistent local storage for:
/// - User data
/// - Posts/Feed
/// - Messages
/// - Stories
/// - Settings
/// - API responses
class CacheService {
  static const String _userBox = 'user_cache';
  static const String _postsBox = 'posts_cache';
  static const String _messagesBox = 'messages_cache';
  static const String _storiesBox = 'stories_cache';
  static const String _settingsBox = 'settings_cache';
  static const String _apiBox = 'api_cache';

  static bool _initialized = false;

  /// Initialize Hive and open all boxes
  static Future<void> init() async {
    if (_initialized) return;
    
    await Hive.initFlutter();
    
    // Open all cache boxes
    await Future.wait([
      Hive.openBox(_userBox),
      Hive.openBox(_postsBox),
      Hive.openBox(_messagesBox),
      Hive.openBox(_storiesBox),
      Hive.openBox(_settingsBox),
      Hive.openBox(_apiBox),
    ]);
    
    _initialized = true;
  }

  // ==================== USER CACHE ====================

  /// Cache current user data
  static Future<void> cacheUser(Map<String, dynamic> userData) async {
    final box = Hive.box(_userBox);
    await box.put('current_user', jsonEncode(userData));
    await box.put('cached_at', DateTime.now().toIso8601String());
  }

  /// Get cached user data
  static Map<String, dynamic>? getCachedUser() {
    final box = Hive.box(_userBox);
    final data = box.get('current_user');
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  /// Cache user profile by ID
  static Future<void> cacheUserProfile(String userId, Map<String, dynamic> profile) async {
    final box = Hive.box(_userBox);
    await box.put('profile_$userId', jsonEncode(profile));
  }

  /// Get cached user profile
  static Map<String, dynamic>? getCachedUserProfile(String userId) {
    final box = Hive.box(_userBox);
    final data = box.get('profile_$userId');
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  // ==================== POSTS CACHE ====================

  /// Cache feed posts
  static Future<void> cacheFeedPosts(List<Map<String, dynamic>> posts) async {
    final box = Hive.box(_postsBox);
    await box.put('feed_posts', jsonEncode(posts));
    await box.put('feed_cached_at', DateTime.now().toIso8601String());
  }

  /// Get cached feed posts
  static List<Map<String, dynamic>> getCachedFeedPosts() {
    final box = Hive.box(_postsBox);
    final data = box.get('feed_posts');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.cast<Map<String, dynamic>>();
  }

  /// Check if feed cache is fresh (within 5 minutes)
  static bool isFeedCacheFresh() {
    final box = Hive.box(_postsBox);
    final cachedAt = box.get('feed_cached_at');
    if (cachedAt == null) return false;
    final cacheTime = DateTime.parse(cachedAt);
    return DateTime.now().difference(cacheTime).inMinutes < 5;
  }

  /// Cache single post
  static Future<void> cachePost(String postId, Map<String, dynamic> post) async {
    final box = Hive.box(_postsBox);
    await box.put('post_$postId', jsonEncode(post));
  }

  /// Get cached post
  static Map<String, dynamic>? getCachedPost(String postId) {
    final box = Hive.box(_postsBox);
    final data = box.get('post_$postId');
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  // ==================== MESSAGES CACHE ====================

  /// Cache conversations list
  static Future<void> cacheConversations(List<Map<String, dynamic>> conversations) async {
    final box = Hive.box(_messagesBox);
    await box.put('conversations', jsonEncode(conversations));
    await box.put('conversations_cached_at', DateTime.now().toIso8601String());
  }

  /// Get cached conversations
  static List<Map<String, dynamic>> getCachedConversations() {
    final box = Hive.box(_messagesBox);
    final data = box.get('conversations');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.cast<Map<String, dynamic>>();
  }

  /// Cache messages for a conversation
  static Future<void> cacheMessages(String conversationId, List<Map<String, dynamic>> messages) async {
    final box = Hive.box(_messagesBox);
    await box.put('messages_$conversationId', jsonEncode(messages));
  }

  /// Get cached messages
  static List<Map<String, dynamic>> getCachedMessages(String conversationId) {
    final box = Hive.box(_messagesBox);
    final data = box.get('messages_$conversationId');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.cast<Map<String, dynamic>>();
  }

  // ==================== STORIES CACHE ====================

  /// Cache stories
  static Future<void> cacheStories(List<Map<String, dynamic>> stories) async {
    final box = Hive.box(_storiesBox);
    await box.put('stories', jsonEncode(stories));
    await box.put('stories_cached_at', DateTime.now().toIso8601String());
  }

  /// Get cached stories
  static List<Map<String, dynamic>> getCachedStories() {
    final box = Hive.box(_storiesBox);
    final data = box.get('stories');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.cast<Map<String, dynamic>>();
  }

  // ==================== SETTINGS CACHE ====================

  /// Save setting
  static Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(_settingsBox);
    if (value is Map || value is List) {
      await box.put(key, jsonEncode(value));
    } else {
      await box.put(key, value);
    }
  }

  /// Get setting
  static T? getSetting<T>(String key, {T? defaultValue}) {
    final box = Hive.box(_settingsBox);
    final value = box.get(key, defaultValue: defaultValue);
    return value as T?;
  }

  /// Get selected language
  static String getLanguage() {
    return getSetting<String>('language') ?? 'en';
  }

  /// Set selected language
  static Future<void> setLanguage(String languageCode) async {
    await saveSetting('language', languageCode);
  }

  // ==================== API CACHE ====================

  /// Cache API response with TTL
  static Future<void> cacheApiResponse(
    String endpoint, 
    Map<String, dynamic> response, {
    Duration ttl = const Duration(minutes: 15),
  }) async {
    final box = Hive.box(_apiBox);
    final cacheData = {
      'data': response,
      'cached_at': DateTime.now().toIso8601String(),
      'ttl_minutes': ttl.inMinutes,
    };
    await box.put(endpoint, jsonEncode(cacheData));
  }

  /// Get cached API response (returns null if expired)
  static Map<String, dynamic>? getCachedApiResponse(String endpoint) {
    final box = Hive.box(_apiBox);
    final data = box.get(endpoint);
    if (data == null) return null;
    
    final cacheData = jsonDecode(data) as Map<String, dynamic>;
    final cachedAt = DateTime.parse(cacheData['cached_at'] as String);
    final ttlMinutes = cacheData['ttl_minutes'] as int;
    
    // Check if cache is expired
    if (DateTime.now().difference(cachedAt).inMinutes > ttlMinutes) {
      // Cache expired, remove it
      box.delete(endpoint);
      return null;
    }
    
    return cacheData['data'] as Map<String, dynamic>;
  }

  // ==================== CACHE MANAGEMENT ====================

  /// Clear all caches
  static Future<void> clearAll() async {
    await Future.wait([
      Hive.box(_userBox).clear(),
      Hive.box(_postsBox).clear(),
      Hive.box(_messagesBox).clear(),
      Hive.box(_storiesBox).clear(),
      Hive.box(_apiBox).clear(),
    ]);
  }

  /// Clear user-specific data (on logout)
  static Future<void> clearUserData() async {
    await Future.wait([
      Hive.box(_userBox).clear(),
      Hive.box(_postsBox).clear(),
      Hive.box(_messagesBox).clear(),
      Hive.box(_storiesBox).clear(),
    ]);
  }

  /// Get cache size in bytes
  static int getCacheSize() {
    int size = 0;
    for (final boxName in [_userBox, _postsBox, _messagesBox, _storiesBox, _settingsBox, _apiBox]) {
      final box = Hive.box(boxName);
      for (final key in box.keys) {
        final value = box.get(key);
        if (value is String) {
          size += value.length;
        }
      }
    }
    return size;
  }

  /// Get human-readable cache size
  static String getCacheSizeFormatted() {
    final bytes = getCacheSize();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Cache Service Provider
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

/// Cached User Provider - Returns cached user while Firebase loads
final cachedUserProvider = Provider<Map<String, dynamic>?>((ref) {
  return CacheService.getCachedUser();
});

/// Cached Feed Provider
final cachedFeedProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return CacheService.getCachedFeedPosts();
});

/// Is Feed Cache Fresh Provider
final isFeedCacheFreshProvider = Provider<bool>((ref) {
  return CacheService.isFeedCacheFresh();
});
