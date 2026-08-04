import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/firestore_paths.dart';
import '../models/audit_log_model.dart';

class AuditRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> logAction({
    required String action,
    String? targetUid,
    String? targetCollection,
    String? targetDocId,
    Map<String, dynamic>? metadata,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Fetch actor role and pseudonym from Firestore
    final userDoc =
        await _db.collection(FirestorePaths.users).doc(user.uid).get();
    final role = userDoc.data()?['role'] as String? ?? 'unknown';

    try {
      await _db.collection(FirestorePaths.auditLogs).add({
        'actorUid': user.uid,
        'actorRole': role,
        'action': action,
        'targetUid': targetUid,
        'targetCollection': targetCollection,
        'targetDocId': targetDocId,
        'metadata': metadata ?? {},
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Audit logging should not crash the main flow
      // ignore: avoid_print
      debugPrint('Audit log failed: $e');
    }
  }

  Stream<List<AuditLogModel>> watchAuditLogs() {
    return _db
        .collection(FirestorePaths.auditLogs)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((s) => s.docs.map((d) => AuditLogModel.fromFirestore(d)).toList());
  }
}
