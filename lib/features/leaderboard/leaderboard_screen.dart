import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/subject.dart';
import '../../core/providers/data_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

class LeaderboardScreen extends ConsumerWidget {
  final Subject subject;

  const LeaderboardScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider(subject.id));

    return Scaffold(
      appBar: AppBar(title: Text('${subject.code} Leaderboard')),
      body: AsyncView(
        value: leaderboard,
        onRetry: () => ref.invalidate(leaderboardProvider(subject.id)),
        builder: (entries) {
          if (entries.isEmpty) {
            return const EmptyView(
              icon: Icons.leaderboard_outlined,
              title: 'No scores yet',
              message: 'Be the first on this leaderboard by taking an exam.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppDimens.screenPadding),
            itemCount: entries.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimens.space3),
            itemBuilder: (context, index) =>
                _LeaderboardTile(rank: index + 1, entry: entries[index]),
          );
        },
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;

  const _LeaderboardTile({required this.rank, required this.entry});

  Color? get _rankColor => switch (rank) {
        1 => const Color(0xFFD4A017),
        2 => const Color(0xFF9CA3AF),
        3 => const Color(0xFFB0713D),
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final name = entry.username != null && entry.username!.isNotEmpty
        ? '@${entry.username}'
        : entry.fullName;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (_rankColor ?? theme.colorScheme.onSurface)
                  .withOpacity(0.1),
            ),
            child: Text(
              '$rank',
              style: theme.textTheme.labelLarge?.copyWith(
                color: _rankColor ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.totalQuestions} questions  •  ${entry.timeTaken} min',
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
          ),
          Text(
            '${entry.score}%',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
