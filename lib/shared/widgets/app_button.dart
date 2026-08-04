import 'package:flutter/material.dart';
import 'package:mindcare_diu/core/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isSecondary) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.blue500))
            : (icon != null ? Icon(icon) : const SizedBox.shrink()),
        label: Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, height: 1.0)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.gray300),
          foregroundColor: isDark ? Colors.white : AppColors.gray900,
        ),
      );
    }

    return FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
          : (icon != null ? Icon(icon) : const SizedBox.shrink()),
      label: Text(label,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, height: 1.0)),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.blue500,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
    );
  }
}
