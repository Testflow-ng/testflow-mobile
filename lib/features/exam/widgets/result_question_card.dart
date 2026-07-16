import 'package:flutter/material.dart';
import '../../../core/models/exam.dart';
import '../../../core/theme/theme.dart';

class ResultQuestionCard extends StatelessWidget {
  final ResultQuestion question;

  const ResultQuestionCard({super.key, required this.question});

  static const _letters = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusIcon(question: question),
              const SizedBox(width: AppDimens.space3),
              Expanded(
                child: Text(
                  'Q${question.index + 1}. ${question.stem}',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space4),
          for (var i = 0; i < question.options.length; i++)
            _OptionRow(
              letter: i < _letters.length ? _letters[i] : '${i + 1}',
              text: question.options[i],
              isCorrect: i == question.correctOption,
              isChosen: i == question.selectedOption,
            ),
          if (question.explanation != null &&
              question.explanation!.trim().isNotEmpty) ...[
            const SizedBox(height: AppDimens.space3),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimens.space3),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explanation',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    question.explanation!,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final ResultQuestion question;

  const _StatusIcon({required this.question});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = question.isCorrect
        ? (AppColors.success, Icons.check_rounded)
        : question.wasAnswered
            ? (AppColors.danger, Icons.close_rounded)
            : (AppColors.neutral, Icons.remove_rounded);

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: AppDimens.iconSm, color: color),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String letter;
  final String text;
  final bool isCorrect;
  final bool isChosen;

  const _OptionRow({
    required this.letter,
    required this.text,
    required this.isCorrect,
    required this.isChosen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color? highlight;
    if (isCorrect) {
      highlight = AppColors.success;
    } else if (isChosen) {
      highlight = AppColors.danger;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            letter,
            style: theme.textTheme.labelLarge?.copyWith(
              color: highlight ?? theme.colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppDimens.space3),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: highlight ?? theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: highlight != null ? FontWeight.w600 : null,
              ),
            ),
          ),
          if (isCorrect)
            const Icon(Icons.check_rounded,
                size: AppDimens.iconSm, color: AppColors.success)
          else if (isChosen)
            const Icon(Icons.close_rounded,
                size: AppDimens.iconSm, color: AppColors.danger),
        ],
      ),
    );
  }
}
