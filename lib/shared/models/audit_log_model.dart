// lib/shared/models/audit_log_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLogModel {
  final String id;
  final String actorUid;
  final String actorRole;
  final String action;
  final String? targetUid;
  final String? targetCollection;
  final String? targetDocId;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;

  const AuditLogModel({
    required this.id,
    required this.actorUid,
    required this.actorRole,
    required this.action,
    this.targetUid,
    this.targetCollection,
    this.targetDocId,
    this.metadata = const {},
    this.createdAt,
  });

  factory AuditLogModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AuditLogModel(
      id: doc.id,
      actorUid: d['actorUid'] as String? ?? 'system',
      actorRole: d['actorRole'] as String? ?? 'system',
      action: d['action'] as String? ?? 'unknown',
      targetUid: d['targetUid'] as String?,
      targetCollection: d['targetCollection'] as String?,
      targetDocId: d['targetDocId'] as String?,
      metadata: (d['metadata'] as Map<String, dynamic>?) ?? {},
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
