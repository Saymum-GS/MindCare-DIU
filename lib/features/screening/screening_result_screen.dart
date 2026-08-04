// lib/features/screening/screening_result_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/responsive_util.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/risk_engine.dart';

class ScreeningResultScreen extends StatelessWidget {
  final RiskResult result;
  const ScreeningResultScreen({super.key, required this.result});

  Color get _ringColor => result.riskLevel == RiskLevel.red
      ? AppColors.red500
      : result.riskLevel == RiskLevel.yellow
          ? AppColors.amber500
          : AppColors.sage600;

  Color get _bgColor => result.riskLevel == RiskLevel.red
      ? AppColors.riskRedBg
      : result.riskLevel == RiskLevel.yellow
          ? AppColors.riskYellowBg
          : AppColors.riskGreenBg;

  String get _severityLabel => RiskEngine.severityDisplayLabel(result.severity);
  String get _riskLabel => RiskEngine.riskLevelDisplayLabel(result.riskLevel);

  @override
  Widget build(BuildContext context) {
    final score = result.totalScore;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Result', style: TextStyle(fontSize: context.rf(17))),
        leading: IconButton(
            icon: Icon(Icons.close, size: context.rs(24)), onPressed: () => context.go('/home')),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.rs(24)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: context.rs(8)),
                  // Screening Contextual Artwork
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: context.rs(140)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(context.rs(24)),
                      child: Image.asset(
                        result.riskLevel == RiskLevel.red ||
                                result.riskLevel == RiskLevel.yellow
                            ? 'assets/images/screening_risk.png'
                            : 'assets/images/screening_safe.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: context.rs(24)),
                  // Score ring
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, t, child) {
                      final maxScore = result.instrument == 'GAD7' ? 21 : 27;
                      return SizedBox(
                        width: context.rs(160),
                        height: context.rs(160),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: context.rs(160),
                              height: context.rs(160),
                              child: CircularProgressIndicator(
                                value: t * (score / maxScore),
                                strokeWidth: context.rs(12),
                                backgroundColor: AppColors.gray200,
                                color: _ringColor,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('${(t * score).toInt()}',
                                      style: GoogleFonts.outfit(
                                          fontSize: context.rf(40),
                                          fontWeight: FontWeight.w800,
                                          color: _ringColor)),
                                  Text('of $maxScore',
                                      style: TextStyle(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppColors.darkTextSub
                                              : AppColors.gray500,
                                          fontSize: context.rf(13))),
                                ]),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: context.rs(24)),
                  // Severity
                  Text(_severityLabel,
                      style: GoogleFonts.dmSerifDisplay(
                          fontSize: context.rf(28),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkText
                              : AppColors.gray900),
                      textAlign: TextAlign.center),
                  SizedBox(height: context.rs(8)),
                  // Risk badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: context.rs(16), vertical: context.rs(6)),
                    decoration: BoxDecoration(
                        color: _bgColor,
                        borderRadius: BorderRadius.circular(context.rs(20))),
                    child: Text(_riskLabel,
                        style: TextStyle(
                            color: _ringColor,
                            fontWeight: FontWeight.w700,
                            fontSize: context.rf(13))),
                  ),
                  SizedBox(height: context.rs(24)),
                  // Recommended action
                  Container(
                    padding: EdgeInsets.all(context.rs(16)),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkSurface2
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(context.rs(16)),
                      border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkBorder
                              : AppColors.gray200),
                    ),
                    child: Text(
                      RiskEngine.recommendedAction(result.riskLevel, result.instrument),
                      style: TextStyle(
                          fontSize: context.rf(14),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextSub
                              : AppColors.gray700,
                          height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: context.rs(32)),
                  // CTA buttons
                  if (result.riskLevel == RiskLevel.red) ...[
                    FilledButton.icon(
                      onPressed: () => context.push('/crisis'),
                      icon: Icon(Icons.shield_outlined, size: context.rs(20)),
                      label: const Text('Get Crisis Help'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.red500,
                        minimumSize: Size(double.infinity, context.rs(56)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.rs(16))),
                      ),
                    ),
                    SizedBox(height: context.rs(12)),
                    OutlinedButton(
                      onPressed: () => context.go('/chat-request'),
                      style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, context.rs(56)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.rs(16)))),
                      child: const Text('Talk to a Volunteer'),
                    ),
                  ] else if (result.riskLevel == RiskLevel.yellow) ...[
                    FilledButton(
                      onPressed: () => context.go('/chat-request'),
                      style: FilledButton.styleFrom(
                          minimumSize: Size(double.infinity, context.rs(56)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.rs(16)))),
                      child: const Text('Talk to a Volunteer'),
                    ),
                    SizedBox(height: context.rs(12)),
                    OutlinedButton(
                      onPressed: () => context.push('/psychologists'),
                      style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, context.rs(56)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.rs(16)))),
                      child: const Text('Book a Session'),
                    ),
                  ] else ...[
                    FilledButton(
                      onPressed: () => context.go('/content'),
                      style: FilledButton.styleFrom(
                        minimumSize: Size(double.infinity, context.rs(56)),
                        backgroundColor: AppColors.riskGreenFg,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.rs(16))),
                      ),
                      child: const Text('Explore Self-Care Resources'),
                    ),
                    SizedBox(height: context.rs(12)),
                    OutlinedButton(
                      onPressed: () => context.go('/home'),
                      style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, context.rs(56)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.rs(16)))),
                      child: const Text('Return to Home'),
                    ),
                  ],
                  SizedBox(height: context.rs(12)),
                  TextButton(
                    onPressed: () => context.push('/screening-history'),
                    child: Text('View past screenings', style: TextStyle(fontSize: context.rf(14))),
                  ),
                  SizedBox(height: context.rs(8)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
