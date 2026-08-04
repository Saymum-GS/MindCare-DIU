import '../../../shared/models/user_model.dart';
// lib/features/admin/data/admin_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../shared/models/incident_model.dart';
import '../../../shared/models/audit_log_model.dart';

class AdminRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<UserModel>> watchAllUsers() {
    return _db
        .collection(FirestorePaths.users)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  Stream<List<IncidentModel>> watchIncidents({String? status}) {
    var query = _db
        .collection(FirestorePaths.incidents)
        .orderBy('createdAt', descending: true);
    if (status != null) query = query.where('status', isEqualTo: status);
    return query
        .snapshots()
        .map((s) => s.docs.map((d) => IncidentModel.fromFirestore(d)).toList());
  }

  Stream<List<AuditLogModel>> watchAuditLogs() {
    return _db
        .collection(FirestorePaths.auditLogs)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((s) => s.docs.map((d) => AuditLogModel.fromFirestore(d)).toList());
  }

  Stream<List<UserModel>> watchPendingVerifications() {
    return _db
        .collection(FirestorePaths.users)
        .where('role', isEqualTo: 'student')
        .where('studentIdVerified', isEqualTo: false)
        .where('isAnonymous', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  Future<void> toggleUserActive(String uid, bool isActive) async {
    await _db
        .collection(FirestorePaths.users)
        .doc(uid)
        .update({'isActive': isActive});
  }

  Future<void> updateDiuStatus(String uid, bool isDiuStudent) async {
    await _db.collection(FirestorePaths.users).doc(uid).update({
      'isDiuStudent': isDiuStudent,
      'studentIdVerified': true, // Mark as reviewed so they leave the pending queue
    });
  }

  Future<void> updateUserRole(String uid, String role) async {
    final Map<String, dynamic> data = {'role': role};
    if (role == 'student') {
      data['isDiuStudent'] = false;
      data['studentIdVerified'] = false;
      data['latestRiskLevel'] = null;
    } else if (role == 'volunteer') {
      data['isOnline'] = false;
      data['totalChatsCompleted'] = 0;
    } else if (role == 'psychologist') {
      data['isOnCall'] = false;
      data['isVerified'] = true;
      data['sessionFeeExternal'] = 1500;
      data['sessionFeeDiu'] = 0;
      data['specialties'] = [];
    }
    await _db.collection(FirestorePaths.users).doc(uid).update(data);
  }

  Future<void> updatePsychologistVerification(
      String uid, bool isVerified) async {
    await _db
        .collection(FirestorePaths.users)
        .doc(uid)
        .update({'isVerified': isVerified});
  }

  Future<void> updateVolunteerBadgeLevel(String uid, String badgeLevel) async {
    await _db
        .collection(FirestorePaths.users)
        .doc(uid)
        .update({'badgeLevel': badgeLevel});
  }

  Future<void> acknowledgeIncident(String incidentId) async {
    await _db.collection(FirestorePaths.incidents).doc(incidentId).update({
      'status': 'acknowledged',
      'acknowledgedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resolveIncident(String incidentId, String note) async {
    await _db.collection(FirestorePaths.incidents).doc(incidentId).update({
      'status': 'resolved',
      'resolvedAt': FieldValue.serverTimestamp(),
      'resolutionNote': note,
    });
  }

  Future<void> deleteUser(String uid) async {
    // Note: Deleting the Firestore document effectively orphans the Auth user 
    // and revokes all access. The client will be automatically logged out by RoleScaffold.
    await _db.collection(FirestorePaths.users).doc(uid).delete();
  }

  Stream<List<UserModel>> watchUsersByRole(String role) {
    return _db
        .collection(FirestorePaths.users)
        .where('role', isEqualTo: role)
        .snapshots()
        .map((s) => s.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  Future<void> deleteAllAnonymousUsers() async {
    final query = await _db.collection(FirestorePaths.users).where('isAnonymous', isEqualTo: true).get();
    final batch = _db.batch();
    for (final doc in query.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> fixAdminEmail() async {
    final query = await _db.collection(FirestorePaths.users).where('email', isEqualTo: 'storm.mgss@gmail.com').get();
    for (final doc in query.docs) {
      await doc.reference.update({'email': 'saymum22205101780@diu.edu.bd'});
    }
  }

  Future<void> seedSelfCareResources() async {
    final contents = [
      {
        'title': 'Understanding Anxiety and Panic',
        'description': 'A comprehensive guide to understanding why we feel anxious and how to manage panic attacks effectively.',
        'type': 'article',
        'bodyText': 'Anxiety is a normal human emotion, but when it becomes overwhelming, it can interfere with daily life. Panic attacks are sudden periods of intense fear that may include palpitations, sweating, shaking, shortness of breath, numbness, or a feeling that something terrible is going to happen.\n\nGrounding techniques such as the 5-4-3-2-1 method can be incredibly helpful: acknowledge 5 things you see, 4 things you can touch, 3 things you can hear, 2 things you can smell, and 1 thing you can taste.',
        'imageUrl': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&q=80',
        'order': 1,
        'isPublished': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'title': '10-Minute Guided Meditation for Stress',
        'description': 'Take a short break to reset your nervous system with this guided mindfulness practice.',
        'type': 'video',
        'url': 'https://www.youtube.com/watch?v=ZToicYcHIOU',
        'imageUrl': 'https://img.youtube.com/vi/ZToicYcHIOU/maxresdefault.jpg',
        'order': 2,
        'isPublished': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'The Importance of Sleep Hygiene',
        'description': 'Learn how your sleep environment and habits affect your mental health.',
        'type': 'article',
        'bodyText': 'Good sleep hygiene is essential for mental and physical health. It involves behaviors and environmental factors that precede sleep and may interfere with sleep.\n\nTo improve your sleep hygiene:\n1. Maintain a regular sleep schedule.\n2. Create a restful environment (cool, dark, quiet).\n3. Avoid screens 1 hour before bed.\n4. Limit caffeine intake in the afternoon.',
        'imageUrl': 'https://images.unsplash.com/photo-1511295742362-92c96b12a818?auto=format&fit=crop&q=80',
        'order': 3,
        'isPublished': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }
    ];

    for (final item in contents) {
      await _db.collection(FirestorePaths.content).add(item);
    }
  }
}
