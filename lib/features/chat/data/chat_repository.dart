// lib/features/chat/data/chat_repository.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../shared/models/chat_session_model.dart';
import '../../../core/services/notification_service.dart';

class ChatRepository {
  final _db = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  Future<String> createChatRequest({
    String channel = 'volunteer',
    required String studentPseudonym,
    required String riskLevel,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await _db.collection(FirestorePaths.users).doc(uid).get();
    final realName = userDoc.data()?['displayName'] as String?;
    final studentId = userDoc.data()?['studentId'] as String?;

    final isClinical = channel == 'psychologist';

    final ref = await _db.collection(FirestorePaths.chatSessions).add({
      'studentUid': uid,
      'studentPseudonym': studentPseudonym,
      'studentRealName': isClinical ? realName : null,
      'studentDiuId': isClinical ? studentId : null,
      'volunteerUid': null,
      'volunteerName': null,
      'psychologistUid': null,
      'channel': channel,
      'status': 'waiting',
      'riskLevel': riskLevel,
      'screeningRef': null,
      'startedAt': FieldValue.serverTimestamp(),
      'endedAt': null,
      'durationMinutes': 0,
      'summary': null,
      'crisisEscalated': false,
      'escalatedAt': null,
      'rating': null,
      'ratingNote': null,
    });

    // Notify the requested role
    await _notificationService.sendToRole(
      role: channel == 'psychologist' ? 'psychologist' : 'volunteer',
      title: 'New Chat Request',
      body: 'A student ($studentPseudonym) is waiting for support.',
      type: 'chat',
      relatedId: ref.id,
    );

    // Add initial system message
    await _db
        .collection(FirestorePaths.chatSessions)
        .doc(ref.id)
        .collection('messages')
        .add({
      'senderUid': 'system',
      'senderRole': 'system',
      'senderName': 'System',
      'text': 'Support request received. Please wait for a supporter to join.',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return ref.id;
  }

  Future<void> acceptChat(String sessionId) async {
    final user = FirebaseAuth.instance.currentUser!;
    final userDoc =
        await _db.collection(FirestorePaths.users).doc(user.uid).get();
    final displayName =
        userDoc.data()?['displayName'] as String? ?? 'Supporter';
    final role = userDoc.data()?['role'] as String?;

    final sessionRef = _db.collection(FirestorePaths.chatSessions).doc(sessionId);

    await _db.runTransaction((transaction) async {
      final sessionSnap = await transaction.get(sessionRef);
      if (!sessionSnap.exists) {
        throw Exception('Chat session does not exist.');
      }
      final data = sessionSnap.data()!;
      
      if (data['status'] != 'waiting' && data['status'] != 'escalated') {
        throw Exception('This chat has already been accepted or is no longer available.');
      }

      if (role == 'psychologist') {
        transaction.update(sessionRef, {
          'psychologistUid': user.uid,
          'psychologistName': displayName,
          'status': 'active',
        });
      } else {
        transaction.update(sessionRef, {
          'volunteerUid': user.uid,
          'volunteerName': displayName,
          'status': 'active',
        });
      }
    });

    final sessionDocAfter = await sessionRef.get();
    final studentUid = sessionDocAfter.data()?['studentUid'] as String?;

    final joinedName = role == 'psychologist' ? 'Psychologist $displayName' : 'Volunteer $displayName';
    
    await _db
        .collection(FirestorePaths.chatSessions)
        .doc(sessionId)
        .collection('messages')
        .add({
      'senderUid': 'system',
      'senderRole': 'system',
      'senderName': 'System',
      'text': '$joinedName has joined the chat.',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (studentUid != null) {
      await _notificationService.sendNotification(
        recipientUid: studentUid,
        title: '${role == 'psychologist' ? 'Psychologist' : 'Volunteer'} Joined',
        body: '$joinedName has joined your chat session.',
        type: 'chat',
        relatedId: sessionId,
      );
    }
  }

  Future<void> sendMessage({
    required String sessionId,
    required String text,
    required String senderRole,
    required String senderName,
    bool crisisDetected = false,
    String? crisisKeyword,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _db
        .collection(FirestorePaths.chatSessions)
        .doc(sessionId)
        .collection('messages')
        .add({
      'senderUid': uid,
      'senderRole': senderRole,
      'senderName': senderName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'crisisDetected': crisisDetected,
      'crisisKeyword': crisisKeyword,
    });
  }

  Stream<List<ChatMessage>> watchMessages(String sessionId) {
    return _db
        .collection(FirestorePaths.chatSessions)
        .doc(sessionId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ChatMessage.fromFirestore(d)).toList());
  }

  Stream<ChatSession> watchSession(String sessionId) => _db
      .collection(FirestorePaths.chatSessions)
      .doc(sessionId)
      .snapshots()
      .map((d) => ChatSession.fromFirestore(d));

  Stream<List<ChatSession>> watchWaitingVolunteerSessions() {
    return _db
        .collection(FirestorePaths.chatSessions)
        .where('status', isEqualTo: 'waiting')
        .where('channel', isEqualTo: 'volunteer')
        .orderBy('startedAt')
        .snapshots()
        .map((s) => s.docs.map((d) => ChatSession.fromFirestore(d)).toList());
  }

  Stream<List<ChatSession>> watchActiveVolunteerSessions() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _db
        .collection(FirestorePaths.chatSessions)
        .where('volunteerUid', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((s) => s.docs.map((d) => ChatSession.fromFirestore(d)).toList());
  }

  Stream<List<ChatSession>> watchUrgentCrisisSessions() {
    return _db
        .collection(FirestorePaths.chatSessions)
        .where('status', isEqualTo: 'escalated')
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => ChatSession.fromFirestore(d)).toList();
      list.sort((a, b) => (a.startedAt ?? DateTime.now())
          .compareTo(b.startedAt ?? DateTime.now()));
      return list;
    });
  }

  Stream<List<ChatSession>> watchStandardConsultationRequests() {
    return _db
        .collection(FirestorePaths.chatSessions)
        .where('status', isEqualTo: 'waiting')
        .where('channel', isEqualTo: 'psychologist')
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => ChatSession.fromFirestore(d)).toList();
      list.sort((a, b) => (a.startedAt ?? DateTime.now())
          .compareTo(b.startedAt ?? DateTime.now()));
      return list;
    });
  }

  Future<void> endSession(String sessionId, {String? summary}) async {
    await _db.collection(FirestorePaths.chatSessions).doc(sessionId).update({
      'status': 'ended',
      'endedAt': FieldValue.serverTimestamp(),
      if (summary != null) 'summary': summary,
    });
  }

  Future<void> deleteSessionForEveryone(String sessionId) async {
    await _db.collection(FirestorePaths.chatSessions).doc(sessionId).update({
      'status': 'deleted',
    });
  }

  Future<void> submitRating(String sessionId, int rating, String? note) async {
    await _db.collection(FirestorePaths.chatSessions).doc(sessionId).update({
      'rating': rating,
      'ratingNote': note,
    });
  }

  Future<void> escalateManually(String sessionId) async {
    await _db.collection(FirestorePaths.chatSessions).doc(sessionId).update({
      'status': 'escalated',
      'crisisEscalated': true,
      'escalatedAt': FieldValue.serverTimestamp(),
    });

    final sessionDoc =
        await _db.collection(FirestorePaths.chatSessions).doc(sessionId).get();
    final data = sessionDoc.data() as Map<String, dynamic>;

    await _db.collection(FirestorePaths.incidents).add({
      'triggerType': 'manual',
      'studentUid': data['studentUid'],
      'studentPseudonym': data['studentPseudonym'],
      'riskLevel': 'red',
      'description': 'Manual escalation in chat session $sessionId',
      'relatedSessionId': sessionId,
      'relatedScreeningId': null,
      'assignedPsychologistUid': null,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
      'acknowledgedAt': null,
      'resolvedAt': null,
      'resolutionNote': null,
    });

    // Notify psychologists of the escalation
    await _notificationService.sendToRole(
      role: 'psychologist',
      title: 'Chat Escalation',
      body: 'A volunteer escalated a chat session due to a crisis.',
      type: 'crisis',
      relatedId: sessionId,
    );
  }

  Future<void> triggerClinicalEmergency(String sessionId) async {
    await _db.collection(FirestorePaths.chatSessions).doc(sessionId).update({
      'crisisEscalated': true,
      'emergencyTriggered': true,
      'emergencyTriggeredAt': FieldValue.serverTimestamp(),
    });

    final sessionDoc =
        await _db.collection(FirestorePaths.chatSessions).doc(sessionId).get();
    final data = sessionDoc.data() as Map<String, dynamic>;

    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'psychologist';

    await _db.collection(FirestorePaths.incidents).add({
      'triggerType': 'clinical_emergency',
      'studentUid': data['studentUid'],
      'studentPseudonym': data['studentPseudonym'],
      'riskLevel': 'red',
      'description': 'EMERGENCY PROTOCOL triggered by Psychologist in session $sessionId',
      'relatedSessionId': sessionId,
      'relatedScreeningId': null,
      'assignedPsychologistUid': uid,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
      'acknowledgedAt': null,
      'resolvedAt': null,
      'resolutionNote': null,
    });

    await _db
        .collection(FirestorePaths.chatSessions)
        .doc(sessionId)
        .collection('messages')
        .add({
      'senderUid': 'system',
      'senderRole': 'system',
      'senderName': 'System',
      'text': '🚨 CLINICAL EMERGENCY PROTOCOL INITIATED: Campus emergency response and clinical administration have been alerted.',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _notificationService.sendToRole(
      role: 'admin',
      title: '🚨 CLINICAL EMERGENCY PROTOCOL',
      body: 'A psychologist initiated emergency protocol in chat session $sessionId.',
      type: 'crisis',
      relatedId: sessionId,
    );
  }

  Stream<List<ChatSession>> watchChatHistory(String uid, String role) {
    Query query = _db.collection(FirestorePaths.chatSessions);
    
    if (role == 'student') {
      query = query.where('studentUid', isEqualTo: uid);
    } else if (role == 'volunteer') {
      query = query.where('volunteerUid', isEqualTo: uid);
    } else if (role == 'psychologist') {
      query = query.where('psychologistUid', isEqualTo: uid);
    } else {
      // admin or other roles see all, or maybe we just return empty if they shouldn't see it
      return Stream.value([]);
    }

    // We only want chats that are no longer active/waiting, OR we can just fetch all
    // and let the UI filter them. The user wants "previous chats with CRUD functionality".
    // We will just order by startedAt descending. Firestore might require an index if we combine where and orderBy.
    // To avoid index issues, we just do where() and sort locally.
    
    return query.snapshots().map((s) {
      final docs = s.docs.map((d) => ChatSession.fromFirestore(d)).toList();
      docs.sort((a, b) => (b.startedAt ?? DateTime.now()).compareTo(a.startedAt ?? DateTime.now()));
      return docs;
    });
  }
}
