import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/notification_model.dart';
import '../constants/firestore_paths.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send a notification to a specific user
  Future<void> sendNotification({
    required String recipientUid,
    required String title,
    required String body,
    required String type,
    String? relatedId,
  }) async {
    try {
      await _firestore
          .collection(FirestorePaths.users)
          .doc(recipientUid)
          .collection('notifications')
          .add({
        'title': title,
        'body': body,
        'type': type,
        if (relatedId != null) 'relatedId': relatedId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail or log in a real app to not block the main action
      debugPrint('Failed to send notification: $e');
    }
  }

  /// Send a notification to multiple users (e.g., all volunteers or all admins)
  /// using a single O(1) write to a role_alerts collection to save Firestore quotas.
  Future<void> sendToRole({
    required String role,
    required String title,
    required String body,
    required String type,
    String? relatedId,
  }) async {
    try {
      await _firestore.collection('role_alerts').add({
        'targetRole': role,
        'title': title,
        'body': body,
        'type': type,
        if (relatedId != null) 'relatedId': relatedId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to send notification to role $role: $e');
    }
  }

  /// Watch notifications for a specific user
  Stream<List<NotificationModel>> watchNotifications(String uid) {
    return _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Watch unread count
  Stream<int> watchUnreadCount(String uid) {
    return _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Watch alerts for a specific role
  Stream<List<Map<String, dynamic>>> watchRoleAlerts(String role) {
    return _firestore
        .collection('role_alerts')
        .where('targetRole', isEqualTo: role)
        .where('createdAt', isGreaterThan: Timestamp.now()) // Only new ones
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  /// Mark a notification as read
  Future<void> markAsRead(String uid, String notificationId) async {
    await _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Mark all as read
  Future<void> markAllAsRead(String uid) async {
    final snap = await _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    if (snap.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}

// Provider for easy access
final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

final notificationsProvider = StreamProvider.autoDispose
    .family<List<NotificationModel>, String>((ref, uid) {
  final service = ref.watch(notificationServiceProvider);
  return service.watchNotifications(uid);
});

final unreadCountProvider =
    StreamProvider.autoDispose.family<int, String>((ref, uid) {
  final service = ref.watch(notificationServiceProvider);
  return service.watchUnreadCount(uid);
});
