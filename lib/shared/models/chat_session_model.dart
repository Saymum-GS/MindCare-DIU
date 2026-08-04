// lib/shared/models/chat_session_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSession {
  final String id;
  final String studentUid;
  final String? studentPseudonym;
  final String? studentRealName;
  final String? studentDiuId;
  final String? volunteerUid;
  final String? volunteerName;
  final String? psychologistUid;
  final String? psychologistName;
  final String channel; // volunteer | psychologist
  final String status; // waiting | active | escalated | ended
  final String? riskLevel; // green | yellow | red
  final DateTime? startedAt;
  final DateTime? endedAt;
  final bool crisisEscalated;
  final int? rating;
  final String? ratingNote;

  const ChatSession({
    required this.id,
    required this.studentUid,
    this.studentPseudonym,
    this.studentRealName,
    this.studentDiuId,
    this.volunteerUid,
    this.volunteerName,
    this.psychologistUid,
    this.psychologistName,
    required this.channel,
    required this.status,
    this.riskLevel,
    this.startedAt,
    this.endedAt,
    this.crisisEscalated = false,
    this.rating,
    this.ratingNote,
  });

  factory ChatSession.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ChatSession(
      id: doc.id,
      studentUid: d['studentUid'] as String? ?? '',
      studentPseudonym: d['studentPseudonym'] as String?,
      studentRealName: d['studentRealName'] as String?,
      studentDiuId: d['studentDiuId'] as String?,
      volunteerUid: d['volunteerUid'] as String?,
      volunteerName: d['volunteerName'] as String?,
      psychologistUid: d['psychologistUid'] as String?,
      psychologistName: d['psychologistName'] as String?,
      channel: d['channel'] as String? ?? 'volunteer',
      status: d['status'] as String? ?? 'waiting',
      riskLevel: d['riskLevel'] as String?,
      startedAt: (d['startedAt'] as Timestamp?)?.toDate(),
      endedAt: (d['endedAt'] as Timestamp?)?.toDate(),
      crisisEscalated: d['crisisEscalated'] as bool? ?? false,
      rating: (d['rating'] as num?)?.toInt(),
      ratingNote: d['ratingNote'] as String?,
    );
  }
}

class ChatMessage {
  final String id;
  final String senderUid;
  final String senderRole;
  final String senderName;
  final String text;
  final DateTime? createdAt;
  final bool crisisDetected;

  const ChatMessage({
    required this.id,
    required this.senderUid,
    required this.senderRole,
    required this.senderName,
    required this.text,
    this.createdAt,
    this.crisisDetected = false,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderUid: d['senderUid'] as String? ?? '',
      senderRole: d['senderRole'] as String? ?? 'student',
      senderName: d['senderName'] as String? ?? 'User',
      text: d['text'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      crisisDetected: d['crisisDetected'] as bool? ?? false,
    );
  }
}
