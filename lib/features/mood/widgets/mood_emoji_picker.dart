import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MoodEmojiPicker extends StatelessWidget {
  final int? selectedScore;
  final ValueChanged<int> onSelected;

  const MoodEmojiPicker({
    super.key,
    this.selectedScore,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _EmojiItem(
              score: 1,
              emoji: '😢',
              label: 'Terrible',
              isSelected: selectedScore == 1,
              onTap: () => onSelected(1)),
          const SizedBox(width: 8),
          _EmojiItem(
              score: 2,
              emoji: '🙁',
              label: 'Bad',
              isSelected: selectedScore == 2,
              onTap: () => onSelected(2)),
          const SizedBox(width: 8),
          _EmojiItem(
              score: 3,
              emoji: '😐',
              label: 'Okay',
              isSelected: selectedScore == 3,
              onTap: () => onSelected(3)),
          const SizedBox(width: 8),
          _EmojiItem(
              score: 4,
              emoji: '🙂',
              label: 'Good',
              isSelected: selectedScore == 4,
              onTap: () => onSelected(4)),
          const SizedBox(width: 8),
          _EmojiItem(
              score: 5,
              emoji: '😃',
              label: 'Great',
              isSelected: selectedScore == 5,
              onTap: () => onSelected(5)),
        ],
      ),
    );
  }
}

class _EmojiItem extends StatelessWidget {
  final int score;
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmojiItem({
    required this.score,
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedScale(
      scale: isSelected ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        isSelected ? colorScheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
