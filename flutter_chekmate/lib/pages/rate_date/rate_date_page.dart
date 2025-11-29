import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/constants/app_constants.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/utils/platform_utils.dart';
import 'package:flutter_chekmate/features/rate_date/presentation/providers/rate_date_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Rate Your Date page - Core feature of ChekMate
/// 
/// Integrated experience with full app navigation access.
/// Users can rate their dating experiences using WOW/GTFOH/ChekMate system.
///
/// Features:
/// - Share and rate dating experiences from Firebase
/// - WOW, GTFOH, ChekMate rating system
/// - Integrated with app navigation (bottom nav available)
/// - Add new date experiences
/// - Access to settings and other app features
class RateDatePage extends ConsumerStatefulWidget {
  const RateDatePage({
    super.key,
    this.showBottomNav = true,
  });

  /// Whether to show bottom navigation (true when embedded in MainNavigation)
  final bool showBottomNav;

  @override
  ConsumerState<RateDatePage> createState() => _RateDatePageState();
}

class _RateDatePageState extends ConsumerState<RateDatePage> {
  int _currentCardIndex = 0;
  bool _isCardFlipped = false;

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
      'color': AppColors.primary,
      'icon': Icons.emoji_events_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateExperiencesAsync = ref.watch(unratedDateExperiencesProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: dateExperiencesAsync.when(
          data: (dates) => Column(
            children: [
              _buildHeader(theme, dates.length),
              Expanded(
                child: dates.isEmpty
                    ? _buildEmptyState(theme)
                    : _currentCardIndex < dates.length
                        ? _buildRatingCard(theme, dates[_currentCardIndex])
                        : _buildCompletionScreen(theme),
              ),
            ],
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading dates: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(unratedDateExperiencesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDateDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Date'),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, int totalDates) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Home button for quick navigation
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Home',
            onPressed: () => context.go('/'),
          ),
          const SizedBox(width: 4),
          // Title with chess piece icon
          Icon(Icons.favorite, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text(
            'Rate Your Date',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (totalDates > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_currentCardIndex + 1}/$totalDates',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          // Settings/More options
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More options',
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  context.push('/settings');
                  break;
                case 'history':
                  _showRatingHistory(context);
                  break;
                case 'help':
                  _showHelpDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'history',
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Rating History'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text('How it works'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRatingHistory(BuildContext context) {
    final statsAsync = ref.read(ratingStatsProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text(
                  'Your Rating History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            statsAsync.when(
              data: (stats) => Column(
                children: [
                  _buildHistoryTile('⭐ WOW', stats['WOW'] ?? 0, Colors.green),
                  _buildHistoryTile('🚫 GTFOH', stats['GTFOH'] ?? 0, Colors.red),
                  _buildHistoryTile('♟️ ChekMate', stats['ChekMate'] ?? 0, AppColors.primary),
                  const Divider(height: 32),
                  _buildHistoryTile('Total Ratings', stats['total'] ?? 0, Colors.grey),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Unable to load history'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.primary),
            const SizedBox(width: 12),
            const Text('How Rate Your Date Works'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Add Your Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Tap the "Add Date" button to log a dating experience.'),
              SizedBox(height: 16),
              Text(
                '2. Rate Your Experience',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Choose from three ratings:'),
              SizedBox(height: 8),
              Text('⭐ WOW - Amazing date, highly recommend!'),
              Text('🚫 GTFOH - Bad experience, warning to others'),
              Text('♟️ ChekMate - You outsmarted a tricky situation'),
              SizedBox(height: 16),
              Text(
                '3. Share with Community',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Your ratings help others navigate the dating world with transparency.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No Dates to Rate',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your dating experiences to rate them and share with the community!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddDateDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Date'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCard(ThemeData theme, DateExperience date) {
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
                    final rotate = Tween(begin: 0.0, end: 1.0).animate(animation);
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
              if (!_isCardFlipped) _buildRatingOptions(theme, cardWidth, date),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront(DateExperience date, ThemeData theme, double cardWidth) {
    final cardHeight = cardWidth * 1.25;

    return Container(
      key: const ValueKey('front'),
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
            // Background image or gradient
            if (date.imageUrl != null && date.imageUrl!.isNotEmpty)
              Image.network(
                date.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultBackground(),
              )
            else
              _buildDefaultBackground(),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            date.partnerAge != null
                                ? '${date.partnerName}, ${date.partnerAge}'
                                : date.partnerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            date.formattedDateTime,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          date.location,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        date.dateDetails,
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
                  color: Colors.black.withOpacity(0.5),
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

  Widget _buildDefaultBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.favorite,
          size: 80,
          color: Colors.white24,
        ),
      ),
    );
  }

  Widget _buildCardBack(DateExperience date, ThemeData theme, double cardWidth) {
    final cardHeight = cardWidth * 1.25;

    return Container(
      key: const ValueKey('back'),
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.info_outline, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  'Date Details',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow(
              Icons.calendar_today,
              'When',
              date.formattedDateTime,
            ),
            _buildDetailRow(
              Icons.location_on,
              'Where',
              date.location,
            ),
            _buildDetailRow(
              Icons.restaurant,
              'Activity',
              date.dateDetails,
            ),
            _buildDetailRow(
              Icons.person,
              'With',
              date.partnerAge != null
                  ? '${date.partnerName}, ${date.partnerAge}'
                  : date.partnerName,
            ),
            if (date.notes != null && date.notes!.isNotEmpty) ...[
              const Divider(height: 32),
              Text(
                'Notes',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                date.notes!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
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
          Icon(icon, size: 20, color: AppColors.primary),
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

  Widget _buildRatingOptions(ThemeData theme, double cardWidth, DateExperience date) {
    final isWeb = PlatformUtils.isWeb;
    final buttonWidth = isWeb ? cardWidth : 280.0;

    return Column(
      children: _ratingOptions.map((option) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            width: buttonWidth,
            child: ElevatedButton(
              onPressed: () => _handleRating(option['id'] as String, date),
              style: ElevatedButton.styleFrom(
                backgroundColor: option['color'] as Color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
    final statsAsync = ref.watch(ratingStatsProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
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
            // Rating stats
            statsAsync.when(
              data: (stats) => _buildStatsRow(stats),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddDateDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Date'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(Map<String, int> stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatChip('⭐ WOW', stats['WOW'] ?? 0, Colors.green),
        const SizedBox(width: 12),
        _buildStatChip('🚫 GTFOH', stats['GTFOH'] ?? 0, Colors.red),
        const SizedBox(width: 12),
        _buildStatChip('♟️ ChekMate', stats['ChekMate'] ?? 0, AppColors.primary),
      ],
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRating(String ratingId, DateExperience date) async {
    try {
      await ref.read(rateDateExperienceProvider).call(
        dateExperienceId: date.id,
        rating: ratingId,
      );

      // Move to next card
      setState(() {
        _currentCardIndex++;
        _isCardFlipped = false;
      });

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Rated as $ratingId!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } on Exception catch (e) {
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

  void _showAddDateDialog(BuildContext context) {
    final partnerNameController = TextEditingController();
    final partnerAgeController = TextEditingController();
    final locationController = TextEditingController();
    final detailsController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'Add Date Experience',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: partnerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Partner Name *',
                    hintText: 'Who did you go on a date with?',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: partnerAgeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Partner Age (optional)',
                    prefixIcon: Icon(Icons.cake),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location *',
                    hintText: 'Where was the date?',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: detailsController,
                  decoration: const InputDecoration(
                    labelText: 'Date Activity *',
                    hintText: 'What did you do?',
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date'),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      selectedDate = picked;
                      (context as Element).markNeedsBuild();
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Any additional details...',
                    prefixIcon: Icon(Icons.note),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (partnerNameController.text.isEmpty ||
                          locationController.text.isEmpty ||
                          detailsController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in required fields'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      try {
                        await ref.read(createDateExperienceProvider).call(
                          partnerName: partnerNameController.text,
                          partnerAge: int.tryParse(partnerAgeController.text),
                          location: locationController.text,
                          dateDetails: detailsController.text,
                          dateTime: selectedDate,
                          notes: notesController.text.isEmpty
                              ? null
                              : notesController.text,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Date experience added!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Reset to show new date
                          setState(() {
                            _currentCardIndex = 0;
                          });
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Add Date Experience'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
