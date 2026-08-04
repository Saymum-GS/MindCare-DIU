import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'chat', 'booking', 'crisis', 'system'
  final String? relatedId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(
      Map<String, dynamic> map, String documentId) {
    return NotificationModel(
      id: documentId,
      title: map['title'] as String? ?? 'Notification',
      body: map['body'] as String? ?? '',
      type: map['type'] as String? ?? 'system',
      relatedId: map['relatedId'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      if (relatedId != null) 'relatedId': relatedId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
