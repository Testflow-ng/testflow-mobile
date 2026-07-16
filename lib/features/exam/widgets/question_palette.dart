import 'package:flutter/material.dart';
import '../../../core/models/exam.dart';
import '../../../core/theme/theme.dart';

class QuestionPalette extends StatelessWidget {
  final List<ExamQuestion> questions;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const QuestionPalette({
    super.key,
    required this.questions,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Questions', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppDimens.space2),
            Wrap(
              spacing: AppDimens.space2,
              runSpacing: AppDimens.space2,
              children: [
                const _LegendDot(color: AppColors.success, label: 'Answered'),
                const _LegendDot(color: AppColors.warning, label: 'Marked'),
                _LegendDot(
                  color: theme.colorScheme.onSurface.withOpacity(0.15),
                  label: 'Unanswered',
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space5),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: AppDimens.space2,
                  runSpacing: AppDimens.space2,
                  children: [
                    for (final question in questions)
                      _PaletteCell(
                        number: question.index + 1,
                        isCurrent: question.index == currentIndex,
                        isAnswered: question.selectedOption != null,
                        isMarked: question.markedForReview,
                        onTap: () {
                          Navigator.of(context).pop();
                          onSelect(question.index);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteCell extends StatelessWidget {
  final int number;
  final bool isCurrent;
  final bool isAnswered;
  final bool isMarked;
  final VoidCallback onTap;

  const _PaletteCell({
    required this.number,
    required this.isCurrent,
    required this.isAnswered,
    required this.isMarked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color background;
    final Color foreground;
    if (isMarked) {
      background = AppColors.warning.withOpacity(0.15);
      foreground = AppColors.warning;
    } else if (isAnswered) {
      background = AppColors.success.withOpacity(0.15);
      foreground = AppColors.success;
    } else {
      background = theme.colorScheme.onSurface.withOpacity(0.06);
      foreground = theme.colorScheme.onSurface.withOpacity(0.6);
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            border: isCurrent
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Text(
            '$number',
            style: theme.textTheme.labelLarge?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(width: AppDimens.space3),
      ],
    );
  }
}
