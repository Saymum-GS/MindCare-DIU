import '../../../shared/models/content_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';

class ContentDetailScreen extends StatelessWidget {
  final ContentItem content;

  const ContentDetailScreen({super.key, required this.content});

  Future<void> _launchUrl(BuildContext context) async {
    if (content.url == null || content.url!.isEmpty) return;

    final uri = Uri.parse(content.url!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        title: Text(content.title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (content.displayImageUrl.isNotEmpty)
              Image.network(
                content.displayImageUrl,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: isDark ? AppColors.darkSurface : AppColors.gray200,
                  child: Icon(Icons.broken_image,
                      size: 64,
                      color: isDark ? AppColors.gray600 : AppColors.gray400),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: isDark ? Colors.white : AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    content.description,
                    style: TextStyle(
                      fontSize: 20,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (content.type == ContentType.video && content.url != null)
                    FilledButton.icon(
                      icon: const Icon(Icons.play_circle_outlined),
                      label: const Text('Watch on YouTube'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () async {
                        final uri = Uri.parse(content.url!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                    )
                  else if (content.type == ContentType.article &&
                      content.bodyText != null) ...[
                    Text(
                      content.bodyText!,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.8,
                        color: isDark ? AppColors.gray300 : AppColors.gray800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ] else if (content.url != null) ...[
                    OutlinedButton.icon(
                      onPressed: () => _launchUrl(context),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open External Resource'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
