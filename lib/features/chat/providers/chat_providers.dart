// lib/features/chat/providers/chat_providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/chat_repository.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../shared/models/chat_session_model.dart';

final chatRepositoryProvider =
    Provider<ChatRepository>((ref) => ChatRepository());

// VOLUNTEER
final waitingVolunteerSessionsProvider = StreamProvider<List<ChatSession>>(
    (ref) => ref.watch(chatRepositoryProvider).watchWaitingVolunteerSessions());

final activeVolunteerSessionsProvider = StreamProvider<List<ChatSession>>(
    (ref) => ref.watch(chatRepositoryProvider).watchActiveVolunteerSessions());

final pastVolunteerSessionsProvider = StreamProvider<List<ChatSession>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection(FirestorePaths.chatSessions)
      .where('volunteerUid', isEqualTo: uid)
      .snapshots()
      .map((s) {
    final docs = s.docs
        .map((d) => ChatSession.fromFirestore(d))
        .where((session) => session.status == 'ended')
        .toList();
    docs.sort((a, b) {
      final timeA = a.startedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final timeB = b.startedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return timeB.compareTo(timeA); // descending
    });
    return docs;
  });
});

// PSYCHOLOGIST
final urgentCrisisSessionsProvider = StreamProvider<List<ChatSession>>(
    (ref) =>
        ref.watch(chatRepositoryProvider).watchUrgentCrisisSessions());

final standardConsultationRequestsProvider = StreamProvider<List<ChatSession>>(
    (ref) =>
        ref.watch(chatRepositoryProvider).watchStandardConsultationRequests());

final activePsychologistSessionsProvider =
    StreamProvider<List<ChatSession>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection(FirestorePaths.chatSessions)
      .where('psychologistUid', isEqualTo: uid)
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map((s) => s.docs.map((d) => ChatSession.fromFirestore(d)).toList());
});

final pastPsychologistSessionsProvider =
    StreamProvider<List<ChatSession>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection(FirestorePaths.chatSessions)
      .where('psychologistUid', isEqualTo: uid)
      .snapshots()
      .map((s) {
    final docs = s.docs
        .map((d) => ChatSession.fromFirestore(d))
        .where((session) => session.status == 'ended')
        .toList();
    docs.sort((a, b) {
      final timeA = a.startedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final timeB = b.startedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return timeB.compareTo(timeA); // descending
    });
    return docs;
  });
});

// STUDENT
final studentActiveChatProvider = StreamProvider<ChatSession?>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection(FirestorePaths.chatSessions)
      .where('studentUid', isEqualTo: uid)
      .where('status', whereIn: ['waiting', 'active', 'escalated'])
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isEmpty) return null;
        // Sort manually to get the most recent one just in case
        final docs =
            snapshot.docs.map((d) => ChatSession.fromFirestore(d)).toList();
        docs.sort((a, b) => (b.startedAt ?? DateTime.now())
            .compareTo(a.startedAt ?? DateTime.now()));
        return docs.first;
      });
});
