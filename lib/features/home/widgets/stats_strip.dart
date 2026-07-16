import 'package:flutter/material.dart';
import '../../../core/models/exam.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

class StatsStrip extends StatelessWidget {
  final StudentStats stats;

  const StatsStrip({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final divider = Container(
      width: 1,
      height: 36,
      color: (isDark ? Colors.white : AppColors.gray900).withOpacity(0.06),
    );

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.space4),
      child: Row(
        children: [
          _Cell(label: 'Exams', value: '${stats.totalExams}'),
          divider,
          _Cell(label: 'Average', value: '${stats.averageScore}%'),
          divider,
          _Cell(label: 'Best', value: '${stats.bestScore}%'),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String label;
  final String value;

  const _Cell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}
