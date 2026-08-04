import 'package:flutter/material.dart';
import 'package:mindcare_diu/l10n/app_localizations.dart';
import '../../../core/utils/risk_engine.dart';
import '../../../core/theme/app_colors.dart';

class RiskResultCard extends StatelessWidget {
  final RiskResult result;

  const RiskResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Color bgColor;
    Color textColor = Colors.white;
    String label;
    IconData icon;

    switch (result.riskLevel) {
      case RiskLevel.green:
        bgColor = AppColors.riskGreenBg;
        label = l10n.lowRisk;
        icon = Icons.check_circle_outline;
        break;
      case RiskLevel.yellow:
        bgColor = AppColors.riskYellowBg;
        textColor = AppColors.gray900;
        label = l10n.moderateRisk;
        icon = Icons.warning_amber_rounded;
        break;
      case RiskLevel.red:
        bgColor = AppColors.riskRedBg;
        label = l10n.highRisk;
        icon = Icons.error_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 64, color: textColor),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '${l10n.yourScore}: ${result.totalScore} - ${result.severity.toUpperCase()}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
