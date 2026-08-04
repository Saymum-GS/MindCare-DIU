import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindcare_diu/l10n/app_localizations.dart';
import '../../../core/utils/responsive_util.dart';
import '../../../core/utils/risk_engine.dart';
import '../auth/providers/auth_providers.dart';
import '../../shared/data/audit_repository.dart';
import 'providers/screening_providers.dart';
import 'widgets/question_card.dart';
import 'widgets/q9_interstitial_card.dart';
import '../../../shared/widgets/app_loading_state.dart';

class ScreeningScreen extends ConsumerStatefulWidget {
  final String instrument; // 'PHQ9' or 'GAD7'

  const ScreeningScreen({super.key, required this.instrument});

  @override
  ConsumerState<ScreeningScreen> createState() => _ScreeningScreenState();
}

class _ScreeningScreenState extends ConsumerState<ScreeningScreen> {
  final PageController _pageController = PageController();
  final List<int> _answers = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> _getQuestions(AppLocalizations l10n) {
    if (widget.instrument == 'PHQ9') {
      return [
        l10n.phq9Q1,
        l10n.phq9Q2,
        l10n.phq9Q3,
        l10n.phq9Q4,
        l10n.phq9Q5,
        l10n.phq9Q6,
        l10n.phq9Q7,
        l10n.phq9Q8,
        l10n.phq9Q9,
      ];
    } else {
      return [
        l10n.gad7Q1,
        l10n.gad7Q2,
        l10n.gad7Q3,
        l10n.gad7Q4,
        l10n.gad7Q5,
        l10n.gad7Q6,
        l10n.gad7Q7,
      ];
    }
  }

  void _onAnswer(int value, int totalQuestions) async {
    if (_isSaving) return;
    HapticFeedback.lightImpact();

    // CRITICAL SAFETY: PHQ9 Q9 (index 8) with any non-zero answer
    final currentIndex =
        _answers.length; // index of question being answered NOW
    final isPHQ9 = widget.instrument == 'PHQ9';

    setState(() => _answers.add(value));

    if (isPHQ9 && currentIndex == 8 && value > 0) {
      // Q9 > 0 means suicidal ideation - save as RED and go to crisis
      _saveAndGoToCrisis();
      return;
    }

    if (_answers.length == totalQuestions) {
      _saveAndComplete();
      return;
    }

    // Show Q9 interstitial BEFORE Q9 (after answering Q8, index 7)
    if (isPHQ9 && currentIndex == 7) {
      // Q8 just answered — move to interstitial page (page index 8)
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _saveAndGoToCrisis() async {
    setState(() => _isSaving = true);
    final user = ref.read(currentUserProvider).valueOrNull;
    final pseudonym = user?.pseudonym ?? 'Student';

    try {
      final result = RiskEngine.scorePHQ9(_answers);
      final repository = ref.read(screeningRepositoryProvider);
      final screeningId = await repository.saveScreening(
        instrument: 'PHQ9',
        answers: _answers,
        result: result,
        pseudonym: pseudonym,
      );

      // Audit Log
      await AuditRepository().logAction(
        action: 'screening.completed',
        targetUid: user?.uid,
        targetCollection: 'screenings',
        targetDocId: screeningId,
        metadata: {
          'instrument': 'PHQ9',
          'riskLevel': 'red',
          'suicidal': true,
        },
      );
    } catch (_) {}
    if (mounted) context.go('/crisis');
  }

  Future<void> _saveAndComplete() async {
    setState(() => _isSaving = true);
    final user = ref.read(currentUserProvider).valueOrNull;
    final pseudonym = user?.pseudonym ?? 'Student';

    try {
      final result = widget.instrument == 'PHQ9'
          ? RiskEngine.scorePHQ9(_answers)
          : RiskEngine.scoreGAD7(_answers);

      final repository = ref.read(screeningRepositoryProvider);
      final screeningId = await repository.saveScreening(
        instrument: widget.instrument,
        answers: _answers,
        result: result,
        pseudonym: pseudonym,
      );

      // Audit Log
      await AuditRepository().logAction(
        action: 'screening.completed',
        targetUid: user?.uid,
        targetCollection: 'screenings',
        targetDocId: screeningId,
        metadata: {
          'instrument': widget.instrument,
          'riskLevel': result.riskLevel.name,
          'score': result.totalScore,
        },
      );

      if (mounted) {
        context.go('/screening-result', extra: result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving result: $e')),
        );
      }
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final questions = _getQuestions(l10n);
    final totalPages =
        widget.instrument == 'PHQ9' ? questions.length + 1 : questions.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, size: context.rs(24)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.questionOf(
              _answers.length +
                  (widget.instrument == 'PHQ9' && _answers.length > 8 ? 0 : 1),
              questions.length),
          style: TextStyle(fontSize: context.rf(17)),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(context.rs(4)),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            tween: Tween<double>(
              begin: 0,
              end: _answers.length / questions.length,
            ),
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              color: Theme.of(context).colorScheme.primary,
              minHeight: context.rs(4),
            ),
          ),
        ),
      ),
      body: _isSaving
          ? Center(child: AppLoadingState(itemCount: 1, height: context.rs(120)))
          : PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalPages,
              itemBuilder: (context, index) {
                if (widget.instrument == 'PHQ9') {
                  if (index == 8) {
                    return Q9InterstitialCard(
                      onContinue: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeInOut,
                        );
                      },
                    );
                  }
                  final questionIndex = index > 8 ? index - 1 : index;
                  return QuestionCard(
                    question: questions[questionIndex],
                    onAnswer: (v) => _onAnswer(v, questions.length),
                  );
                }

                return QuestionCard(
                  question: questions[index],
                  onAnswer: (v) => _onAnswer(v, questions.length),
                );
              },
            ),
    );
  }
}
