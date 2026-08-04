// lib/shared/models/incident_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentModel {
  final String id;
  final String triggerType; // screening | keyword | manual
  final String studentUid;
  final String studentPseudonym;
  final String riskLevel; // yellow | red
  final String description;
  final String? relatedSessionId;
  final String? relatedScreeningId;
  final String? assignedPsychologistUid;
  final String status; // open | acknowledged | resolved
  final DateTime? createdAt;
  final DateTime? acknowledgedAt;
  final DateTime? resolvedAt;
  final String? resolutionNote;

  const IncidentModel({
    required this.id,
    required this.triggerType,
    required this.studentUid,
    required this.studentPseudonym,
    required this.riskLevel,
    required this.description,
    this.relatedSessionId,
    this.relatedScreeningId,
    this.assignedPsychologistUid,
    required this.status,
    this.createdAt,
    this.acknowledgedAt,
    this.resolvedAt,
    this.resolutionNote,
  });

  factory IncidentModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return IncidentModel(
      id: doc.id,
      triggerType: d['triggerType'] as String? ?? 'manual',
      studentUid: d['studentUid'] as String? ?? '',
      studentPseudonym: d['studentPseudonym'] as String? ?? 'Unknown',
      riskLevel: d['riskLevel'] as String? ?? 'red',
      description: d['description'] as String? ?? '',
      relatedSessionId: d['relatedSessionId'] as String?,
      relatedScreeningId: d['relatedScreeningId'] as String?,
      assignedPsychologistUid: d['assignedPsychologistUid'] as String?,
      status: d['status'] as String? ?? 'open',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      acknowledgedAt: (d['acknowledgedAt'] as Timestamp?)?.toDate(),
      resolvedAt: (d['resolvedAt'] as Timestamp?)?.toDate(),
      resolutionNote: d['resolutionNote'] as String?,
    );
  }
}
