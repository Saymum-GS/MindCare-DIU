import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/mood_repository.dart';

final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  return MoodRepository();
});

final moodHistoryProvider = StreamProvider<List<MoodEntry>>((ref) {
  final repo = ref.watch(moodRepositoryProvider);
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();

  return repo.watchRecentMoods();
});
