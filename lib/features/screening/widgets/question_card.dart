import 'package:flutter/material.dart';
import 'package:mindcare_diu/l10n/app_localizations.dart';

class QuestionCard extends StatefulWidget {
  final String question;
  final ValueChanged<int> onAnswer;

  const QuestionCard({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  int? _selectedValue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final minContentHeight =
            constraints.maxHeight > 40 ? constraints.maxHeight - 40 : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minContentHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.question,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _AnswerCard(
                    text: l10n.notAtAll,
                    value: 0,
                    isSelected: _selectedValue == 0,
                    onTap: () => _handleAnswerTap(0),
                  ),
                  const SizedBox(height: 10),
                  _AnswerCard(
                    text: l10n.severalDays,
                    value: 1,
                    isSelected: _selectedValue == 1,
                    onTap: () => _handleAnswerTap(1),
                  ),
                  const SizedBox(height: 10),
                  _AnswerCard(
                    text: l10n.moreThanHalfDays,
                    value: 2,
                    isSelected: _selectedValue == 2,
                    onTap: () => _handleAnswerTap(2),
                  ),
                  const SizedBox(height: 10),
                  _AnswerCard(
                    text: l10n.nearlyEveryDay,
                    value: 3,
                    isSelected: _selectedValue == 3,
                    onTap: () => _handleAnswerTap(3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _selectedValue == null
                        ? 'Tap an answer to continue.'
                        : 'Selected - moving to the next question.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleAnswerTap(int value) {
    if (_selectedValue != null) return;
    setState(() => _selectedValue = value);
    // Auto-advance after a short delay for a frictionless UX
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        widget.onAnswer(value);
      }
    });
  }
}

class _AnswerCard extends StatelessWidget {
  final String text;
  final int value;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnswerCard({
    required this.text,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected
          ? colorScheme.primary.withValues(alpha: 0.1)
          : colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected ? colorScheme.primary : colorScheme.outline,
                    width: isSelected ? 6 : 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
