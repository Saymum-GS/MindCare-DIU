import 'package:flutter/material.dart';
import 'package:mindcare_diu/core/theme/app_colors.dart';

enum BadgeStatus { success, warning, error, info, neutral }

class AppStatusBadge extends StatelessWidget {
  final String label;
  final BadgeStatus status;

  const AppStatusBadge({
    super.key,
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color fgColor;

    switch (status) {
      case BadgeStatus.success:
        bgColor = isDark ? AppColors.riskGreenBgDark : AppColors.sage50;
        fgColor = isDark ? AppColors.riskGreenFgDark : AppColors.sage600;
        break;
      case BadgeStatus.warning:
        bgColor = isDark ? AppColors.riskYellowBgDark : AppColors.amber50;
        fgColor = isDark ? AppColors.riskYellowFgDark : AppColors.amber600;
        break;
      case BadgeStatus.error:
        bgColor = isDark ? AppColors.riskRedBgDark : AppColors.red50;
        fgColor = isDark ? AppColors.riskRedFgDark : AppColors.red500;
        break;
      case BadgeStatus.info:
        bgColor = isDark
            ? AppColors.blue900.withValues(alpha: 0.3)
            : AppColors.blue50;
        fgColor = isDark ? AppColors.blue300 : AppColors.blue600;
        break;
      case BadgeStatus.neutral:
        bgColor = isDark ? AppColors.darkSurface3 : AppColors.gray100;
        fgColor = isDark ? AppColors.gray300 : AppColors.gray700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999.0),
      ),
      child: Text(
        label.toUpperCase(),
        style: (Theme.of(context).textTheme.labelSmall ??
                const TextStyle(fontSize: 11))
            .copyWith(
          color: fgColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
