// lib/features/auth/data/auth_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/constants/firestore_paths.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<UserCredential> signInAnonymously() => _auth.signInAnonymously();

  Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> createAccount(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> linkEmailPassword(
      String email, String password) async {
    final cred = await _auth.currentUser!.linkWithCredential(
        EmailAuthProvider.credential(email: email, password: password));

    final doc =
        await _db.collection(FirestorePaths.users).doc(cred.user!.uid).get();
    final data = doc.data() ?? {};
    final displayName = data['displayName'] as String? ?? '';
    final pseudonym = data['pseudonym'] as String? ?? '';
    final needsProfile = displayName.isEmpty ||
        displayName == pseudonym ||
        displayName == 'User';

    // Update Firestore to sync state
    await _db.collection(FirestorePaths.users).doc(cred.user!.uid).update({
      'email': email,
      'isAnonymous': false,
      if (needsProfile) 'profileCompletionNeeded': true,
    });
    return cred;
  }

  /// Updates the user's display name in both Firestore and Firebase Auth
  /// so that identity stays consistent across all surfaces.
  Future<void> updateDisplayName(String uid, String newName) async {
    await _db.collection(FirestorePaths.users).doc(uid).update({
      'displayName': newName,
    });
    // Keep Firebase Auth profile in sync
    await _auth.currentUser?.updateDisplayName(newName);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> createUserDocument({
    required String uid,
    required String role,
    required String displayName,
    required String pseudonym,
    String? email,
    bool isAnonymous = true,
  }) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    final data = <String, dynamic>{
      'uid': uid,
      'role': role,
      'displayName': displayName,
      'pseudonym': pseudonym,
      'email': email,
      'isAnonymous': isAnonymous,
      'isActive': true,
      'onboardingComplete': true,
      'fcmToken': fcmToken,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
      'consentGiven': true,
      'consentVersion': '2026-01',
    };
    if (role == 'student') {
      data['isDiuStudent'] = false;
      data['studentIdVerified'] = false;
      data['latestRiskLevel'] = null;
    }
    if (role == 'volunteer') {
      data['isOnline'] = false;
      data['totalChatsCompleted'] = 0;
    }
    if (role == 'psychologist') {
      data['isOnCall'] = false;
      data['isVerified'] = false;
      data['sessionFeeExternal'] = 1500;
      data['sessionFeeDiu'] = 0;
      data['specialties'] = [];
    }
    await _db.collection(FirestorePaths.users).doc(uid).set(data);
  }

  Future<void> updateFcmToken(String uid) async {
    final token = await FirebaseMessaging.instance.getToken();
    await _db.collection(FirestorePaths.users).doc(uid).update({
      'fcmToken': token,
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot> watchUserDoc(String uid) =>
      _db.collection(FirestorePaths.users).doc(uid).snapshots();
}
