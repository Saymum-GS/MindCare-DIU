// lib/shared/models/content_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum ContentType { article, video, audio }

class ContentItem {
  final String id;
  final String title;
  final String description;
  final ContentType type;
  final String? url;
  final String? bodyText;
  final String? imageUrl;
  final int order;
  final bool isPublished;
  final DateTime? createdAt;

  const ContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.url,
    this.bodyText,
    this.imageUrl,
    required this.order,
    this.isPublished = true,
    this.createdAt,
  });

  String? get youtubeVideoId {
    if (type != ContentType.video || url == null) return null;
    final uri = Uri.tryParse(url!);
    if (uri == null) return null;
    if (uri.host == 'youtu.be') {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    return uri.queryParameters['v'];
  }

  String? get youtubeThumbnailUrl {
    final vid = youtubeVideoId;
    if (vid == null) return null;
    return 'https://img.youtube.com/vi/$vid/mqdefault.jpg';
  }

  String get displayImageUrl {
    if (imageUrl != null && imageUrl!.isNotEmpty) return imageUrl!;
    if (youtubeThumbnailUrl != null) return youtubeThumbnailUrl!;
    return '';
  }

  factory ContentItem.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ContentItem(
      id: doc.id,
      title: d['title'] as String? ?? 'Untitled',
      description: d['description'] as String? ?? '',
      type: ContentType.values.firstWhere(
        (e) => e.name == (d['type'] as String?),
        orElse: () => ContentType.article,
      ),
      url: d['url'] as String?,
      bodyText: d['bodyText'] as String?,
      imageUrl: d['imageUrl'] as String?,
      order: (d['order'] as num?)?.toInt() ?? 0,
      isPublished: d['isPublished'] as bool? ?? true,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'type': type.name,
        'url': url,
        'bodyText': bodyText,
        'imageUrl': imageUrl,
        'order': order,
        'isPublished': isPublished,
      };
}
