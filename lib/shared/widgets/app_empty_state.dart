import 'package:flutter/material.dart';
import 'package:mindcare_diu/core/theme/app_colors.dart';

class AppEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonTap;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.buttonText,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface2 : AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: isDark ? AppColors.gray400 : AppColors.gray500,
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonTap != null) ...[
              const SizedBox(height: 32.0),
              FilledButton(
                onPressed: onButtonTap,
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
