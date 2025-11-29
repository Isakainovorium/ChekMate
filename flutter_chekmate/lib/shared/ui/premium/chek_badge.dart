import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';

/// Gender enum for chess piece selection
enum UserGender {
  male,    // King piece
  female,  // Queen piece
  other,   // Queen piece (default)
}

/// ChekBadge - The signature "Chek" verification badge
/// 
/// Displays a gold checkmark with optional chess piece indicator
/// based on user gender (King for male, Queen for female/other).
/// 
/// Features:
/// - Gradient gold checkmark
/// - Optional glow effect
/// - Chess piece silhouette overlay
/// - Animated pulse option
class ChekBadge extends StatelessWidget {
  const ChekBadge({
    super.key,
    this.size = 24,
    this.showGlow = true,
    this.gender,
    this.isAnimated = false,
  });

  final double size;
  final bool showGlow;
  final UserGender? gender;
  final bool isAnimated;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.chekGradient,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.chekGlow.withOpacity(0.6),
                  blurRadius: size * 0.4,
                  spreadRadius: size * 0.1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          Icons.check_rounded,
          size: size * 0.6,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// ChessPieceIndicator - Shows King or Queen based on user gender
/// 
/// King (♔) for male users - Navy blue
/// Queen (♕) for female/other users - Gold
class ChessPieceIndicator extends StatelessWidget {
  const ChessPieceIndicator({
    required this.gender,
    super.key,
    this.size = 20,
    this.showBackground = true,
  });

  final UserGender gender;
  final double size;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final isKing = gender == UserGender.male;
    final color = isKing ? AppColors.kingPiece : AppColors.queenPiece;
    final gradient = isKing ? AppColors.kingGradient : AppColors.queenGradient;

    if (showBackground) {
      return Container(
        width: size + 8,
        height: size + 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            isKing ? '♔' : '♕',
            style: TextStyle(
              fontSize: size * 0.7,
              color: Colors.white,
              height: 1,
            ),
          ),
        ),
      );
    }

    return Text(
      isKing ? '♔' : '♕',
      style: TextStyle(
        fontSize: size,
        color: color,
        height: 1,
      ),
    );
  }
}

/// ChekBadgeWithPiece - Combined Chek badge with chess piece indicator
/// 
/// Shows the gold Chek badge with a small chess piece overlay
class ChekBadgeWithPiece extends StatelessWidget {
  const ChekBadgeWithPiece({
    required this.gender,
    super.key,
    this.size = 32,
    this.showGlow = true,
  });

  final UserGender gender;
  final double size;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.3,
      height: size * 1.3,
      child: Stack(
        children: [
          // Main Chek badge
          Positioned(
            left: 0,
            top: 0,
            child: ChekBadge(
              size: size,
              showGlow: showGlow,
            ),
          ),
          // Chess piece indicator (bottom right)
          Positioned(
            right: 0,
            bottom: 0,
            child: ChessPieceIndicator(
              gender: gender,
              size: size * 0.5,
              showBackground: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// VerifiedUserBadge - Shows verification status with chess piece
/// 
/// For verified users, shows gold Chek + chess piece
/// For unverified users, shows just the chess piece
class VerifiedUserBadge extends StatelessWidget {
  const VerifiedUserBadge({
    required this.gender,
    super.key,
    this.isVerified = false,
    this.size = 24,
  });

  final UserGender gender;
  final bool isVerified;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return ChekBadgeWithPiece(
        gender: gender,
        size: size,
        showGlow: true,
      );
    }

    return ChessPieceIndicator(
      gender: gender,
      size: size,
      showBackground: false,
    );
  }
}
