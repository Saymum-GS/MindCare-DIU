import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class RiskBannerCard extends StatelessWidget {
  final String riskLevel;
  final bool isCompact;

  const RiskBannerCard({
    super.key,
    required this.riskLevel,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (riskLevel == 'green') return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRed = riskLevel == 'red';

    if (isCompact) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: InkWell(
          onTap: () => _handleTap(context, isRed),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isRed
                  ? (isDark ? AppColors.riskRedBgDark : AppColors.riskRedBg)
                  : (isDark
                      ? AppColors.riskYellowBgDark
                      : AppColors.riskYellowBg),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isRed
                    ? (isDark ? AppColors.darkBorder : AppColors.red200)
                    : (isDark ? AppColors.darkBorder : AppColors.amber100),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isRed ? Icons.warning_rounded : Icons.info_outline_rounded,
                  color: isRed
                      ? (isDark ? AppColors.riskRedFgDark : AppColors.riskRedFg)
                      : (isDark
                          ? AppColors.riskYellowFgDark
                          : AppColors.riskYellowFg),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isRed
                        ? 'High level of distress detected. Immediate support is recommended.'
                        : 'Your recent check-in shows moderate distress. Support is available.',
                    style: TextStyle(
                      color: isRed
                          ? (isDark
                              ? AppColors.riskRedFgDark
                              : AppColors.riskRedFg)
                          : (isDark
                              ? AppColors.riskYellowFgDark
                              : AppColors.riskYellowFg),
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isRed
                      ? (isDark ? AppColors.riskRedFgDark : AppColors.riskRedFg)
                      : (isDark
                          ? AppColors.riskYellowFgDark
                          : AppColors.riskYellowFg),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      );
    }

    Color bgColor, fgColor;
    if (isRed) {
      bgColor = isDark ? AppColors.riskRedBgDark : AppColors.red700;
      fgColor = isDark ? AppColors.riskRedFgDark : AppColors.white;
    } else {
      bgColor = isDark ? AppColors.riskYellowBgDark : AppColors.riskYellowBg;
      fgColor = isDark ? AppColors.riskYellowFgDark : AppColors.riskYellowFg;
    }

    final icon = isRed ? Icons.error_outline : Icons.warning_amber_rounded;
    final title = isRed ? 'High Risk Detected' : 'Moderate Risk Detected';
    final subtitle = isRed
        ? 'Please reach out for support immediately.'
        : 'Consider speaking with a peer volunteer.';

    return InkWell(
      onTap: () => _handleTap(context, isRed),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: fgColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: fgColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: fgColor.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: fgColor, size: 16),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, bool isRed) {
    if (isRed) {
      context.push('/crisis');
    } else {
      context.go('/chat-request');
    }
  }
}
