import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/exam.dart';
import '../../core/providers/data_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';
import '../home/widgets/stat_card.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress'), centerTitle: false),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(statsProvider);
          try {
            await ref.read(statsProvider.future);
          } catch (_) {}
        },
        child: AsyncView(
          value: stats,
          onRetry: () => ref.invalidate(statsProvider),
          builder: (data) {
            if (data.totalExams == 0) {
              return const EmptyView(
                icon: Icons.insights_rounded,
                title: 'Nothing to show yet',
                message:
                    'Take your first exam and your analytics will appear here.',
              );
            }
            return _ProgressBody(stats: data);
          },
        ),
      ),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  final StudentStats stats;

  const _ProgressBody({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accuracy = stats.totalAnswered == 0
        ? 0
        : ((stats.totalCorrect / stats.totalAnswered) * 100).round();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Exams taken',
                value: '${stats.totalExams}',
                icon: Icons.assignment_turned_in_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppDimens.space3),
            Expanded(
              child: StatCard(
                label: 'Average score',
                value: '${stats.averageScore}%',
                icon: Icons.speed_rounded,
                color: AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.space3),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Best score',
                value: '${stats.bestScore}%',
                icon: Icons.emoji_events_outlined,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: AppDimens.space3),
            Expanded(
              child: StatCard(
                label: 'Accuracy',
                value: '$accuracy%',
                icon: Icons.track_changes_rounded,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.space6),
        Text('By subject', style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppDimens.space4),
        for (final subject in stats.perSubject) ...[
          _SubjectBar(stats: subject),
          const SizedBox(height: AppDimens.space3),
        ],
      ],
    );
  }
}

class _SubjectBar extends StatelessWidget {
  final SubjectStats stats;

  const _SubjectBar({required this.stats});

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
            children: [
              Expanded(
                child: Text(stats.subjectCode,
                    style: theme.textTheme.titleMedium),
              ),
              Text(
                '${stats.attempts} attempt${stats.attempts == 1 ? '' : 's'}',
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space3),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            child: LinearProgressIndicator(
              value: stats.averageScore / 100,
              minHeight: 6,
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.08),
            ),
          ),
          const SizedBox(height: AppDimens.space2),
          Row(
            children: [
              Text('Avg ${stats.averageScore}%',
                  style: theme.textTheme.labelMedium),
              const Spacer(),
              Text('Best ${stats.bestScore}%',
                  style: theme.textTheme.labelMedium),
            ],
          ),
        ],
      ),
    );
  }
}
