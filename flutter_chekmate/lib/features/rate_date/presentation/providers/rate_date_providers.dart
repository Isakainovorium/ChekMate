import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chekmate/core/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rate Date Providers - Real Firebase Implementation
/// Fetches dates to rate and manages ratings

/// Date Experience Entity
class DateExperience {
  const DateExperience({
    required this.id,
    required this.userId,
    required this.partnerName,
    this.partnerAge,
    required this.location,
    required this.dateDetails,
    required this.dateTime,
    this.imageUrl,
    this.notes,
    this.isRated = false,
    this.rating,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String partnerName;
  final int? partnerAge;
  final String location;
  final String dateDetails;
  final DateTime dateTime;
  final String? imageUrl;
  final String? notes;
  final bool isRated;
  final String? rating;
  final DateTime createdAt;

  factory DateExperience.fromFirestore(Map<String, dynamic> data, String id) {
    return DateExperience(
      id: id,
      userId: data['userId'] as String,
      partnerName: data['partnerName'] as String,
      partnerAge: data['partnerAge'] as int?,
      location: data['location'] as String? ?? '',
      dateDetails: data['dateDetails'] as String? ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] as String?,
      notes: data['notes'] as String?,
      isRated: data['isRated'] as bool? ?? false,
      rating: data['rating'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'partnerName': partnerName,
      'partnerAge': partnerAge,
      'location': location,
      'dateDetails': dateDetails,
      'dateTime': Timestamp.fromDate(dateTime),
      'imageUrl': imageUrl,
      'notes': notes,
      'isRated': isRated,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  DateExperience copyWith({
    String? id,
    String? userId,
    String? partnerName,
    int? partnerAge,
    String? location,
    String? dateDetails,
    DateTime? dateTime,
    String? imageUrl,
    String? notes,
    bool? isRated,
    String? rating,
    DateTime? createdAt,
  }) {
    return DateExperience(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partnerName: partnerName ?? this.partnerName,
      partnerAge: partnerAge ?? this.partnerAge,
      location: location ?? this.location,
      dateDetails: dateDetails ?? this.dateDetails,
      dateTime: dateTime ?? this.dateTime,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
      isRated: isRated ?? this.isRated,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Format date time for display
  String get formattedDateTime {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (diff.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }
}

/// Firestore collection reference
final _dateExperiencesCollection = FirebaseFirestore.instance.collection('date_experiences');
final _ratingsCollection = FirebaseFirestore.instance.collection('ratings');

/// Stream of unrated date experiences for current user
final unratedDateExperiencesProvider = StreamProvider<List<DateExperience>>((ref) {
  final currentUserId = ref.watch(currentUserIdProvider).value;
  
  if (currentUserId == null) {
    return Stream.value([]);
  }

  return _dateExperiencesCollection
      .where('userId', isEqualTo: currentUserId)
      .where('isRated', isEqualTo: false)
      .orderBy('dateTime', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return DateExperience.fromFirestore(doc.data(), doc.id);
        }).toList();
      });
});

/// Stream of all date experiences for current user
final allDateExperiencesProvider = StreamProvider<List<DateExperience>>((ref) {
  final currentUserId = ref.watch(currentUserIdProvider).value;
  
  if (currentUserId == null) {
    return Stream.value([]);
  }

  return _dateExperiencesCollection
      .where('userId', isEqualTo: currentUserId)
      .orderBy('dateTime', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return DateExperience.fromFirestore(doc.data(), doc.id);
        }).toList();
      });
});

/// Create a new date experience
final createDateExperienceProvider = Provider((ref) {
  return CreateDateExperienceUseCase(ref);
});

class CreateDateExperienceUseCase {
  CreateDateExperienceUseCase(this.ref);
  final Ref ref;

  Future<String> call({
    required String partnerName,
    int? partnerAge,
    required String location,
    required String dateDetails,
    required DateTime dateTime,
    String? imageUrl,
    String? notes,
  }) async {
    final currentUserId = ref.read(currentUserIdProvider).value;
    if (currentUserId == null) throw Exception('User not authenticated');

    final docRef = await _dateExperiencesCollection.add({
      'userId': currentUserId,
      'partnerName': partnerName,
      'partnerAge': partnerAge,
      'location': location,
      'dateDetails': dateDetails,
      'dateTime': Timestamp.fromDate(dateTime),
      'imageUrl': imageUrl,
      'notes': notes,
      'isRated': false,
      'rating': null,
      'createdAt': Timestamp.now(),
    });

    return docRef.id;
  }
}

/// Rate a date experience
final rateDateExperienceProvider = Provider((ref) {
  return RateDateExperienceUseCase(ref);
});

class RateDateExperienceUseCase {
  RateDateExperienceUseCase(this.ref);
  final Ref ref;

  Future<void> call({
    required String dateExperienceId,
    required String rating,
    String? review,
  }) async {
    final currentUserId = ref.read(currentUserIdProvider).value;
    if (currentUserId == null) throw Exception('User not authenticated');

    final batch = FirebaseFirestore.instance.batch();

    // Update the date experience as rated
    batch.update(_dateExperiencesCollection.doc(dateExperienceId), {
      'isRated': true,
      'rating': rating,
      'ratedAt': Timestamp.now(),
    });

    // Create a rating record
    final ratingRef = _ratingsCollection.doc();
    batch.set(ratingRef, {
      'id': ratingRef.id,
      'userId': currentUserId,
      'dateExperienceId': dateExperienceId,
      'rating': rating,
      'review': review,
      'createdAt': Timestamp.now(),
    });

    await batch.commit();
  }
}

/// Delete a date experience
final deleteDateExperienceProvider = Provider((ref) {
  return DeleteDateExperienceUseCase();
});

class DeleteDateExperienceUseCase {
  Future<void> call(String dateExperienceId) async {
    await _dateExperiencesCollection.doc(dateExperienceId).delete();
  }
}

/// Get rating statistics for current user
final ratingStatsProvider = StreamProvider<Map<String, int>>((ref) {
  final currentUserId = ref.watch(currentUserIdProvider).value;
  
  if (currentUserId == null) {
    return Stream.value({});
  }

  return _ratingsCollection
      .where('userId', isEqualTo: currentUserId)
      .snapshots()
      .map((snapshot) {
        final stats = <String, int>{
          'WOW': 0,
          'GTFOH': 0,
          'ChekMate': 0,
          'total': 0,
        };

        for (final doc in snapshot.docs) {
          final rating = doc.data()['rating'] as String?;
          if (rating != null && stats.containsKey(rating)) {
            stats[rating] = (stats[rating] ?? 0) + 1;
          }
          stats['total'] = (stats['total'] ?? 0) + 1;
        }

        return stats;
      });
});
