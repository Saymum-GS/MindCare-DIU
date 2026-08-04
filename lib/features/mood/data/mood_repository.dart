// lib/features/mood/data/mood_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/firestore_paths.dart';

class MoodEntry {
  final String id;
  final String mood;
  final int moodScore;
  final String? note;
  final DateTime? createdAt;

  const MoodEntry({
    required this.id,
    required this.mood,
    required this.moodScore,
    this.note,
    this.createdAt,
  });

  factory MoodEntry.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MoodEntry(
      id: doc.id,
      mood: d['mood'] as String? ?? 'okay',
      moodScore: (d['moodScore'] as num?)?.toInt() ?? 3,
      note: d['note'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class MoodRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> logMood(String mood, int score, {String? note}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection(FirestorePaths.moodEntries).add({
      'studentUid': uid,
      'mood': mood,
      'moodScore': score,
      'note': note?.isEmpty == true ? null : note,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<MoodEntry>> watchRecentMoods({int limit = 30}) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _db
        .collection(FirestorePaths.moodEntries)
        .where('studentUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => MoodEntry.fromFirestore(d)).toList());
  }
}
