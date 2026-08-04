// lib/features/screening/data/screening_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/utils/risk_engine.dart';
import '../../../core/services/notification_service.dart';

class ScreeningRepository {
  final _db = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  Future<String> saveScreening({
    required String instrument,
    required List<int> answers,
    required RiskResult result,
    required String pseudonym,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final batch = _db.batch();

    final screeningRef = _db.collection(FirestorePaths.screenings).doc();
    final userRef = _db.collection(FirestorePaths.users).doc(uid);

    batch.set(screeningRef, {
      'studentUid': uid,
      'pseudonym': pseudonym,
      'instrument': instrument,
      'answers': answers,
      'totalScore': result.totalScore,
      'severity': result.severity,
      'riskLevel': result.riskLevel.name,
      'suicidalIdeationFlagged': result.suicidalIdeationFlagged,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(userRef, {
      'latestRiskLevel': result.riskLevel.name,
      'latestScreeningAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    if (result.riskLevel == RiskLevel.red) {
      await _notificationService.sendToRole(
        role: 'admin',
        title: 'High Risk Alert',
        body:
            'A student ($pseudonym) has registered a high-risk (Red) screening result.',
        type: 'crisis',
        relatedId: screeningRef.id,
      );
    }

    return screeningRef.id;
  }

  Stream<List<QueryDocumentSnapshot>> watchMyScreenings() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _db
        .collection(FirestorePaths.screenings)
        .where('studentUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs);
  }
}
