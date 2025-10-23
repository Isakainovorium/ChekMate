import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// Flippable Profile Card - converted from FlippableProfileCard.tsx
/// Card that flips to show date story and rating options
class FlippableProfileCard extends StatefulWidget {
  const FlippableProfileCard({
    required this.id, required this.name, required this.avatar, required this.gender, required this.years, required this.location, required this.dateStory, required this.dateLocation, required this.dateActivity, required this.onRate, super.key,
    this.dateRating = 0,
    this.totalRatings = 0,
    this.wowCount = 0,
    this.gtfohCount = 0,
    this.chekmateCount = 0,
    this.userRating,
  });
  final String id;
  final String name;
  final String avatar;
  final String gender;
  final int years;
  final String location;
  final String dateStory;
  final String dateLocation;
  final String dateActivity;
  final double dateRating;
  final int totalRatings;
  final int wowCount;
  final int gtfohCount;
  final int chekmateCount;
  final String? userRating;
  final void Function(String, String) onRate;

  @override
  State<FlippableProfileCard> createState() => _FlippableProfileCardState();
}

class _FlippableProfileCardState extends State<FlippableProfileCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFlipped = false;
  bool _hasRated = false;
  String? _selectedRating;

  @override
  void initState() {
    super.initState();
    _hasRated = widget.userRating != null;
    _selectedRating = widget.userRating;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _handleRate(String rating) {
    if (_hasRated) return;
    setState(() {
      _selectedRating = rating;
      _hasRated = true;
    });
    widget.onRate(widget.id, rating);
  }

  int _getRatingPercentage(int count) {
    return widget.totalRatings > 0
        ? ((count / widget.totalRatings) * 100).round()
        : 0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * 3.14159;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: angle < 1.5708
                ? _buildFrontSide()
                : Transform(
                    transform: Matrix4.identity()..rotateY(3.14159),
                    alignment: Alignment.center,
                    child: _buildBackSide(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFrontSide() {
    return GestureDetector(
      onTap: _flip,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    widget.avatar,
                    height: 192,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.star, size: 16, color: Colors.white),
                  ),
                ),
                if (widget.totalRatings > 0)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4,),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '⭐ ${widget.dateRating.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.favorite,
                              size: 12, color: Colors.grey,),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.years}y',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500,),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 12, color: Colors.grey.shade600,),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.location,
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade600,),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Tap to see date story & rate',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              shape: BoxShape.circle,),),
                      const SizedBox(width: 4),
                      Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,),),
                      const SizedBox(width: 4),
                      Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              shape: BoxShape.circle,),),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '⭐ Tap anywhere to flip',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackSide() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary.withValues(alpha: 0.1), Colors.pink.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(widget.avatar),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.name}\'s Date',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600,),
                      ),
                      Text(
                        widget.dateActivity,
                        style: TextStyle(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            fontSize: 12,),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _flip,
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 12, color: Colors.grey.shade600,),
                      const SizedBox(width: 4),
                      Text(widget.dateLocation,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600,),),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.dateStory, style: const TextStyle(fontSize: 14)),
                  if (widget.totalRatings > 0) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Community Ratings (${widget.totalRatings} votes)',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500,),),
                          const SizedBox(height: 8),
                          _buildRatingStat(
                              '🤩 WOW!', widget.wowCount, Colors.green,),
                          _buildRatingStat('👑 CheKMate!', widget.chekmateCount,
                              AppColors.primary,),
                          _buildRatingStat(
                              '🚫 GTFOH!', widget.gtfohCount, Colors.red,),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _hasRated ? 'Thanks for rating!' : 'How was this date?',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500,),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildRatingButton('wow', '🤩 WOW!', Colors.green),
                  const SizedBox(height: AppSpacing.xs),
                  _buildRatingButton(
                      'chekmate', '👑 CheKMate!', AppColors.primary,),
                  const SizedBox(height: AppSpacing.xs),
                  _buildRatingButton('gtfoh', '🚫 GTFOH!', Colors.red),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStat(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label ($count)', style: const TextStyle(fontSize: 12)),
          Text('${_getRatingPercentage(count)}%',
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w600,),),
        ],
      ),
    );
  }

  Widget _buildRatingButton(String rating, String label, Color color) {
    final isSelected = _selectedRating == rating;
    final isDisabled = _hasRated;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : () => _handleRate(rating),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? color
              : (isDisabled ? Colors.grey.shade100 : color.withValues(alpha: 0.2)),
          foregroundColor: isSelected
              ? Colors.white
              : (isDisabled ? Colors.grey.shade400 : color),
          padding: const EdgeInsets.all(AppSpacing.sm),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }
}
