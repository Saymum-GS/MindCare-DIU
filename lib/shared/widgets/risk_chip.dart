import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// Consistent risk level chips used on multiple screens
class RiskChip extends StatelessWidget {
  final String level; // 'green', 'yellow', 'red'

  const RiskChip({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final data = switch (level) {
      'red' => (
          bg: isDark ? AppColors.riskRedBgDark : AppColors.riskRedBg,
          fg: isDark ? AppColors.riskRedFgDark : AppColors.riskRedFg,
          icon: Icons.warning_rounded,
          label: 'High Risk',
        ),
      'yellow' => (
          bg: isDark ? AppColors.riskYellowBgDark : AppColors.riskYellowBg,
          fg: isDark ? AppColors.riskYellowFgDark : AppColors.riskYellowFg,
          icon: Icons.info_outline,
          label: 'Moderate',
        ),
      _ => (
          bg: isDark ? AppColors.riskGreenBgDark : AppColors.riskGreenBg,
          fg: isDark ? AppColors.riskGreenFgDark : AppColors.riskGreenFg,
          icon: Icons.check_circle_outline,
          label: 'Low Risk',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: data.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, color: data.fg, size: 13),
          const SizedBox(width: 5),
          Text(data.label,
              style: TextStyle(
                  color: data.fg, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
