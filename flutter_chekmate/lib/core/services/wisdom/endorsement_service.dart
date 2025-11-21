import 'package:flutter_chekmate/features/wisdom/models/endorsement_model.dart';
import 'package:flutter_chekmate/features/wisdom/models/wisdom_score_model.dart';

/// Service for managing endorsements and badges
class EndorsementService {
  static final EndorsementService _instance = EndorsementService._internal();
  static EndorsementService get instance => _instance;

  EndorsementService._internal();

  // Endorsement costs (in tokens)
  static const Map<EndorsementBadge, int> _endorsementCosts = {
    EndorsementBadge.relationshipCoach: 50,
    EndorsementBadge.compatibilityExpert: 50,
    EndorsementBadge.safetyAdvocate: 40,
    EndorsementBadge.communicationMaster: 50,
    EndorsementBadge.emotionalGuide: 45,
    EndorsementBadge.conflictResolver: 50,
    EndorsementBadge.culturalBridge: 45,
    EndorsementBadge.mentorExtraordinaire: 100,
  };

  // Endorsement requirements (wisdom score)
  static const Map<EndorsementBadge, double> _endorsementRequirements = {
    EndorsementBadge.relationshipCoach: 6.5,
    EndorsementBadge.compatibilityExpert: 6.5,
    EndorsementBadge.safetyAdvocate: 6.0,
    EndorsementBadge.communicationMaster: 6.5,
    EndorsementBadge.emotionalGuide: 6.0,
    EndorsementBadge.conflictResolver: 6.5,
    EndorsementBadge.culturalBridge: 6.0,
    EndorsementBadge.mentorExtraordinaire: 8.5,
  };

  // Endorsement duration (days)
  static const int _endorsementDurationDays = 365;

  /// Get cost for endorsement
  int getEndorsementCost(EndorsementBadge badge) {
    return _endorsementCosts[badge] ?? 50;
  }

  /// Get requirement for endorsement
  double getEndorsementRequirement(EndorsementBadge badge) {
    return _endorsementRequirements[badge] ?? 6.0;
  }

  /// Check if user can receive endorsement
  bool canReceiveEndorsement({
    required double wisdomScore,
    required EndorsementBadge badge,
  }) {
    return wisdomScore >= getEndorsementRequirement(badge);
  }

  /// Check if user can give endorsement
  bool canGiveEndorsement({
    required int userTokens,
    required EndorsementBadge badge,
    required double endorserWisdomScore,
  }) {
    final cost = getEndorsementCost(badge);
    final minWisdomScore = 5.0; // Minimum to endorse others

    return userTokens >= cost && endorserWisdomScore >= minWisdomScore;
  }

  /// Calculate endorsement expiration date
  DateTime calculateExpirationDate() {
    return DateTime.now().add(Duration(days: _endorsementDurationDays));
  }

  /// Get badge color based on rarity
  String getBadgeColor(EndorsementBadge badge) {
    switch (badge) {
      case EndorsementBadge.relationshipCoach:
        return '#FF6B6B'; // Red
      case EndorsementBadge.compatibilityExpert:
        return '#4ECDC4'; // Teal
      case EndorsementBadge.safetyAdvocate:
        return '#FFE66D'; // Yellow
      case EndorsementBadge.communicationMaster:
        return '#95E1D3'; // Mint
      case EndorsementBadge.emotionalGuide:
        return '#F38181'; // Pink
      case EndorsementBadge.conflictResolver:
        return '#AA96DA'; // Purple
      case EndorsementBadge.culturalBridge:
        return '#FCBAD3'; // Light Pink
      case EndorsementBadge.mentorExtraordinaire:
        return '#FFD700'; // Gold
    }
  }

  /// Get badge icon
  String getBadgeIcon(EndorsementBadge badge) {
    switch (badge) {
      case EndorsementBadge.relationshipCoach:
        return 'favorite';
      case EndorsementBadge.compatibilityExpert:
        return 'favorite_border';
      case EndorsementBadge.safetyAdvocate:
        return 'security';
      case EndorsementBadge.communicationMaster:
        return 'chat';
      case EndorsementBadge.emotionalGuide:
        return 'sentiment_very_satisfied';
      case EndorsementBadge.conflictResolver:
        return 'handshake';
      case EndorsementBadge.culturalBridge:
        return 'public';
      case EndorsementBadge.mentorExtraordinaire:
        return 'star';
    }
  }

  /// Get related category for badge
  WisdomCategory getRelatedCategory(EndorsementBadge badge) {
    switch (badge) {
      case EndorsementBadge.relationshipCoach:
        return WisdomCategory.relationshipSkills;
      case EndorsementBadge.compatibilityExpert:
        return WisdomCategory.datingStrategy;
      case EndorsementBadge.safetyAdvocate:
        return WisdomCategory.safetyAwareness;
      case EndorsementBadge.communicationMaster:
        return WisdomCategory.communication;
      case EndorsementBadge.emotionalGuide:
        return WisdomCategory.emotionalIntelligence;
      case EndorsementBadge.conflictResolver:
        return WisdomCategory.conflictResolution;
      case EndorsementBadge.culturalBridge:
        return WisdomCategory.culturalSensitivity;
      case EndorsementBadge.mentorExtraordinaire:
        return WisdomCategory.selfAwareness;
    }
  }

  /// Get all badges for category
  List<EndorsementBadge> getBadgesForCategory(WisdomCategory category) {
    return _endorsementCosts.keys
        .where((badge) => getRelatedCategory(badge) == category)
        .toList();
  }

  /// Calculate endorsement strength
  double calculateEndorsementStrength({
    required int endorserCount,
    required double endorserAverageWisdomScore,
  }) {
    // More endorsers = stronger
    // Higher endorser wisdom = stronger
    final endorserBonus = (endorserCount / 10).clamp(0, 1).toDouble();
    final wisdomBonus = (endorserAverageWisdomScore / 10).clamp(0, 1).toDouble();

    return ((endorserBonus * 0.6) + (wisdomBonus * 0.4)).clamp(0, 1).toDouble();
  }

  /// Get endorsement tier
  String getEndorsementTier(int endorserCount) {
    if (endorserCount >= 50) {
      return 'legendary';
    } else if (endorserCount >= 20) {
      return 'epic';
    } else if (endorserCount >= 10) {
      return 'rare';
    } else if (endorserCount >= 3) {
      return 'uncommon';
    } else {
      return 'common';
    }
  }

  /// Check if endorsement is still valid
  bool isEndorsementValid(Endorsement endorsement) {
    if (!endorsement.isActive) return false;
    if (endorsement.isExpired) return false;
    if (endorsement.endorserCount == 0) return false;

    return true;
  }

  /// Calculate endorsement impact on wisdom score
  double calculateEndorsementImpact({
    required List<Endorsement> endorsements,
  }) {
    if (endorsements.isEmpty) return 0;

    double totalImpact = 0;

    for (final endorsement in endorsements) {
      if (isEndorsementValid(endorsement)) {
        final strength = calculateEndorsementStrength(
          endorserCount: endorsement.endorserCount,
          endorserAverageWisdomScore: 7.0, // Placeholder
        );
        totalImpact += strength * 0.5; // Max 0.5 points per endorsement
      }
    }

    return totalImpact.clamp(0, 2).toDouble();
  }
}
