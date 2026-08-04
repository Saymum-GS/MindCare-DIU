// lib/features/content/data/content_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../shared/models/content_model.dart';

class ContentRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<ContentItem>> watchPublishedContent() {
    return _db
        .collection(FirestorePaths.content)
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map((s) {
      final items = s.docs.map((d) => ContentItem.fromFirestore(d)).toList();
      items.sort((a, b) => a.order.compareTo(b.order));
      return items;
    });
  }

  Stream<List<ContentItem>> watchAllContent() {
    return _db
        .collection(FirestorePaths.content)
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map((d) => ContentItem.fromFirestore(d)).toList());
  }

  Future<void> createContent(Map<String, dynamic> data) async {
    await _db.collection(FirestorePaths.content).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateContent(String id, Map<String, dynamic> data) async {
    await _db.collection(FirestorePaths.content).doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteContent(String id) async {
    await _db.collection(FirestorePaths.content).doc(id).delete();
  }

  Future<void> togglePublished(String id, bool isPublished) async {
    await _db.collection(FirestorePaths.content).doc(id).update({
      'isPublished': isPublished,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
