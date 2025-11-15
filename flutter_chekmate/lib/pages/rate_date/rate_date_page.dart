import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/constants/app_constants.dart';
import 'package:flutter_chekmate/core/providers/auth_providers.dart';
import 'package:flutter_chekmate/core/utils/platform_utils.dart';
import 'package:flutter_chekmate/features/posts/presentation/providers/posts_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

/// Rate Your Date page - Full-screen rating experience
/// Core feature of ChekMate Dating Experience Platform
///
/// Features:
/// - Share and rate your dating experiences
/// - WOW, GTFOH, ChekMate rating system
/// - Full-screen experience (no bottom navigation)
/// - Custom header
/// - NavigationWidget for quick navigation
class RateDatePage extends ConsumerStatefulWidget {
  const RateDatePage({super.key});

  @override
  ConsumerState<RateDatePage> createState() => _RateDatePageState();
}

class _RateDatePageState extends ConsumerState<RateDatePage> {
  int _currentCardIndex = 0;
  bool _isCardFlipped = false;

  final List<Map<String, dynamic>> _mockDates = [
    {
      'id': '1',
      'name': 'Alex Johnson',
      'age': 28,
      'location': 'New York, NY',
      'imageUrl': 'https://i.pravatar.cc/400?img=1',
      'dateDetails': 'Coffee at Central Perk',
      'dateTime': '2 days ago',
    },
    {
      'id': '2',
      'name': 'Sarah Williams',
      'age': 26,
      'location': 'Los Angeles, CA',
      'imageUrl': 'https://i.pravatar.cc/400?img=2',
      'dateDetails': 'Dinner at The Ivy',
      'dateTime': '1 week ago',
    },
    {
      'id': '3',
      'name': 'Michael Chen',
      'age': 30,
      'location': 'San Francisco, CA',
      'imageUrl': 'https://i.pravatar.cc/400?img=3',
      'dateDetails': 'Walk in Golden Gate Park',
      'dateTime': '2 weeks ago',
    },
  ];

  // Use ChekMate's official rating system from app_constants.dart
  final List<Map<String, dynamic>> _ratingOptions = [
    {
      'id': 'WOW',
      'title': '⭐ WOW',
      'subtitle': AppConstants.ratingDescriptions['WOW'],
      'color': Colors.green,
      'icon': Icons.star_rounded,
    },
    {
      'id': 'GTFOH',
      'title': '🚫 GTFOH',
      'subtitle': AppConstants.ratingDescriptions['GTFOH'],
      'color': Colors.red,
      'icon': Icons.block_rounded,
    },
    {
      'id': 'ChekMate',
      'title': '♟️ ChekMate',
      'subtitle': AppConstants.ratingDescriptions['ChekMate'],
      'color': const Color(0xFFF5A623),
      'icon': Icons.emoji_events_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: _currentCardIndex < _mockDates.length
                  ? _buildRatingCard(theme)
                  : _buildCompletionScreen(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          const SizedBox(width: 8),
          Text(
            'Share Your Experience',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '${_currentCardIndex + 1}/${_mockDates.length}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard(ThemeData theme) {
    final date = _mockDates[_currentCardIndex];
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = PlatformUtils.isWeb;

    // Responsive card width
    final cardWidth = isWeb
        ? (screenWidth > 1200
            ? 400.0
            : screenWidth > 800
                ? 350.0
                : screenWidth * 0.85)
        : 320.0;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isWeb ? 32 : 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Card
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isCardFlipped = !_isCardFlipped;
                  });
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    final rotate =
                        Tween(begin: 0.0, end: 1.0).animate(animation);
                    return AnimatedBuilder(
                      animation: rotate,
                      builder: (context, child) {
                        final angle = rotate.value * 3.14159;
                        return Transform(
                          transform: Matrix4.rotationY(angle),
                          alignment: Alignment.center,
                          child: child,
                        );
                      },
                      child: child,
                    );
                  },
                  child: _isCardFlipped
                      ? _buildCardBack(date, theme, cardWidth)
                      : _buildCardFront(date, theme, cardWidth),
                ),
              ),
              const SizedBox(height: 32),
              // Rating Options
              if (!_isCardFlipped) _buildRatingOptions(theme, cardWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront(
      Map<String, dynamic> date, ThemeData theme, double cardWidth) {
    final cardHeight = cardWidth * 1.25; // Maintain aspect ratio

    return Container(
      key: const ValueKey('front'),
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.network(
              date['imageUrl'] as String,
              fit: BoxFit.cover,
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            // Info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${date['name']}, ${date['age']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date['location'] as String,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        date['dateDetails'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tap to flip hint
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flip, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Tap to flip',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(
      Map<String, dynamic> date, ThemeData theme, double cardWidth) {
    final cardHeight = cardWidth * 1.25; // Maintain aspect ratio

    return Container(
      key: const ValueKey('back'),
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.calendar_today,
              'When',
              date['dateTime'] as String,
            ),
            _buildDetailRow(
              Icons.location_on,
              'Where',
              date['dateDetails'] as String,
            ),
            _buildDetailRow(
              Icons.person,
              'Who',
              '${date['name']}, ${date['age']}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingOptions(ThemeData theme, double cardWidth) {
    final isWeb = PlatformUtils.isWeb;
    final buttonWidth = isWeb ? cardWidth : 280.0;

    return Column(
      children: _ratingOptions.map((option) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            width: buttonWidth,
            child: ElevatedButton(
              onPressed: () => _handleRating(option['id'] as String),
              style: ElevatedButton.styleFrom(
                backgroundColor: option['color'] as Color,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: Size(buttonWidth, 60),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(option['icon'] as IconData, size: isWeb ? 28 : 24),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option['title'] as String,
                          style: TextStyle(
                            fontSize: isWeb ? 18 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          option['subtitle'] as String,
                          style: TextStyle(fontSize: isWeb ? 13 : 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompletionScreen(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          Text(
            'All Caught Up!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ve rated all your recent dates',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRating(String ratingId) async {
    try {
      // Get Firestore instance
      final firestore = ref.read(firestoreProvider);

      // Get current user
      final user = ref.read(authStateProvider).value;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get current date being rated
      final currentDate = _mockDates[_currentCardIndex];

      // Create rating document
      final ratingData = {
        'id': const Uuid().v4(),
        'userId': user.uid,
        'dateId': currentDate['id'],
        'dateName': currentDate['name'],
        'rating': ratingId, // 'spill', 'sip', 'lukewarm', 'cold'
        'createdAt': Timestamp.now(),
      };

      // Save to Firestore ratings collection
      await firestore.collection('ratings').add(ratingData);

      // Move to next card
      setState(() {
        _currentCardIndex++;
        _isCardFlipped = false;
      });

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rating saved!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } on Exception catch (e) {
      // Show error feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save rating: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
