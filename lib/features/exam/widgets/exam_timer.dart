import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class ExamTimer extends StatelessWidget {
  final int secondsLeft;

  const ExamTimer({super.key, required this.secondsLeft});

  String get _label {
    final hours = secondsLeft ~/ 3600;
    final minutes = (secondsLeft % 3600) ~/ 60;
    final seconds = secondsLeft % 60;
    String pad(int n) => n.toString().padLeft(2, '0');
    return hours > 0
        ? '$hours:${pad(minutes)}:${pad(seconds)}'
        : '${pad(minutes)}:${pad(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLow = secondsLeft <= 60;
    final color = isLow ? AppColors.danger : theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space3,
        vertical: AppDimens.space1,
      ),
      decoration: BoxDecoration(
        color: isLow
            ? AppColors.danger.withOpacity(0.1)
            : theme.colorScheme.onSurface.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: AppDimens.iconSm, color: color),
          const SizedBox(width: 6),
          Text(
            _label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
