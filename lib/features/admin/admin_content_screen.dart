import '../../../shared/models/content_model.dart';
// lib/features/admin/admin_content_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_loading_state.dart';

class AdminContentScreen extends StatelessWidget {
  const AdminContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add New Content',
            onPressed: () => _showContentForm(context, null),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(FirestorePaths.content)
            .orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: AppLoadingState(itemCount: 4));
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return AppEmptyState(
              icon: Icons.library_books_outlined,
              title: 'No content yet.',
              message:
                  'Add articles, videos, or audio resources to build the library.',
              buttonText: 'Add First Article',
              onButtonTap: () => _showContentForm(context, null),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final item = ContentItem.fromFirestore(doc);
                  final isPublished = data['isPublished'] as bool? ?? false;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkBorder
                              : AppColors.gray200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _typeColor(item.type).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_typeIcon(item.type),
                            color: _typeColor(item.type), size: 22),
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPublished
                                  ? AppColors.riskGreenBg
                                  : AppColors.riskYellowBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isPublished ? 'Published' : 'Draft',
                              style: TextStyle(
                                fontSize: 11,
                                color: isPublished
                                    ? AppColors.riskGreenFg
                                    : AppColors.riskYellowFg,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(item.type.name,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.darkTextSub
                                      : AppColors.gray500)),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            _showContentForm(context, item);
                          } else if (value == 'toggle') {
                            await FirebaseFirestore.instance
                                .collection(FirestorePaths.content)
                                .doc(doc.id)
                                .update({'isPublished': !isPublished});
                          } else if (value == 'delete') {
                            final confirm = await _confirmDelete(context);
                            if (confirm == true) {
                              await FirebaseFirestore.instance
                                  .collection(FirestorePaths.content)
                                  .doc(doc.id)
                                  .delete();
                            }
                          }
                        },
                        itemBuilder: (c) => [
                          const PopupMenuItem(
                              value: 'edit', child: Text('✏️  Edit')),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Text(
                                isPublished ? '🔒  Unpublish' : '✅  Publish'),
                          ),
                          const PopupMenuItem(
                              value: 'delete',
                              child: Text('🗑️  Delete',
                                  style: TextStyle(color: AppColors.red500))),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _typeIcon(ContentType type) {
    switch (type) {
      case ContentType.article:
        return Icons.article_outlined;
      case ContentType.video:
        return Icons.play_circle_outline;
      case ContentType.audio:
        return Icons.headphones_outlined;
    }
  }

  Color _typeColor(ContentType type) {
    switch (type) {
      case ContentType.article:
        return AppColors.blue500;
      case ContentType.video:
        return AppColors.red500;
      case ContentType.audio:
        return Colors.purple;
    }
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Content'),
        content: const Text(
            'This will permanently delete this content. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.red500),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showContentForm(BuildContext context, ContentItem? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ContentFormSheet(existing: existing),
    );
  }
}

// ─── Content Create / Edit Form ───────────────────────────────────────────────
class _ContentFormSheet extends StatefulWidget {
  final ContentItem? existing;
  const _ContentFormSheet({this.existing});

  @override
  State<_ContentFormSheet> createState() => _ContentFormSheetState();
}

class _ContentFormSheetState extends State<_ContentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late ContentType _type;
  late TextEditingController _title;
  late TextEditingController _description;
  late TextEditingController _bodyText;
  late TextEditingController _url; // YouTube URL for video / audio URL
  late TextEditingController _imageUrl; // Cover image URL (any HTTPS link)
  late TextEditingController _order;
  bool _isPublished = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? ContentType.article;
    _title = TextEditingController(text: e?.title ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _bodyText = TextEditingController(text: e?.bodyText ?? '');
    _url = TextEditingController(text: e?.url ?? '');
    _imageUrl = TextEditingController(text: e?.imageUrl ?? '');
    _order = TextEditingController(text: e?.order.toString() ?? '0');
    _isPublished = e?.isPublished ?? true;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _bodyText.dispose();
    _url.dispose();
    _imageUrl.dispose();
    _order.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final data = {
      'title': _title.text.trim(),
      'description': _description.text.trim(),
      'type': _type.name,
      'bodyText': _type == ContentType.article ? _bodyText.text.trim() : null,
      'url': (_type == ContentType.video || _type == ContentType.audio)
          ? _url.text.trim()
          : null,
      'imageUrl': _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
      'order': int.tryParse(_order.text) ?? 0,
      'isPublished': _isPublished,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.existing == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection(FirestorePaths.content)
            .add(data);
      } else {
        await FirebaseFirestore.instance
            .collection(FirestorePaths.content)
            .doc(widget.existing!.id)
            .update(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.existing == null;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    isNew ? 'Add New Content' : 'Edit Content',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Type Selector
              const Text('Content Type',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SegmentedButton<ContentType>(
                segments: const [
                  ButtonSegment(
                      value: ContentType.article,
                      icon: Icon(Icons.article_outlined),
                      label: Text('Article')),
                  ButtonSegment(
                      value: ContentType.video,
                      icon: Icon(Icons.play_circle_outline),
                      label: Text('Video')),
                  ButtonSegment(
                      value: ContentType.audio,
                      icon: Icon(Icons.headphones),
                      label: Text('Audio')),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'e.g. Understanding Anxiety',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 12),

              // Description / Excerpt
              TextFormField(
                controller: _description,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Short Description *',
                  hintText: 'A brief summary (1-2 sentences)',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 12),

              // Article body
              if (_type == ContentType.article) ...[
                TextFormField(
                  controller: _bodyText,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Article Body *',
                    hintText:
                        'Write the full article content here. You can use plain text or simple markdown.',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => _type == ContentType.article &&
                          (v == null || v.trim().isEmpty)
                      ? 'Article body is required'
                      : null,
                ),
                const SizedBox(height: 12),
              ],

              // URL field for Video / Audio
              if (_type == ContentType.video) ...[
                TextFormField(
                  controller: _url,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'YouTube URL *',
                    hintText:
                        'https://youtu.be/VIDEO_ID or https://www.youtube.com/watch?v=VIDEO_ID',
                    prefixIcon: Icon(Icons.play_circle_fill, color: AppColors.red500),
                  ),
                  validator: (v) {
                    if (_type == ContentType.video &&
                        (v == null || v.trim().isEmpty)) {
                      return 'YouTube URL is required';
                    }
                    if (v != null &&
                        v.isNotEmpty &&
                        !v.contains('youtube') &&
                        !v.contains('youtu.be')) {
                      return 'Must be a YouTube URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.blue50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '💡 Tip: The video thumbnail is auto-generated from the YouTube URL. No upload needed.',
                    style: TextStyle(fontSize: 12, color: AppColors.blue700),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (_type == ContentType.audio) ...[
                TextFormField(
                  controller: _url,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Audio URL *',
                    hintText:
                        'https://soundcloud.com/... or any direct audio link',
                    prefixIcon: Icon(Icons.headphones, color: Colors.purple),
                  ),
                  validator: (v) => _type == ContentType.audio &&
                          (v == null || v.trim().isEmpty)
                      ? 'Audio URL is required'
                      : null,
                ),
                const SizedBox(height: 12),
              ],

              // Cover image URL (optional for all types)
              TextFormField(
                controller: _imageUrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Cover Image URL (optional)',
                  hintText:
                      'https://images.unsplash.com/... or any HTTPS image link',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
              ),
              const SizedBox(height: 12),

              // Display order
              TextFormField(
                controller: _order,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Display Order',
                  hintText: '0 = first, 1 = second, etc.',
                ),
              ),
              const SizedBox(height: 12),

              // Published toggle
              SwitchListTile(
                value: _isPublished,
                onChanged: (v) => setState(() => _isPublished = v),
                title: const Text('Published'),
                subtitle: const Text(
                    'Unpublished content is only visible to admins and psychologists'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),

              // Save button
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(isNew ? 'Add Content' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
