import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/exam.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(authProvider.select((s) => s.isGuest))) {
      return Scaffold(
        appBar: AppBar(title: const Text('History'), centerTitle: false),
        body: const EmptyView(
          icon: Icons.history_rounded,
          title: 'Sign in to see history',
          message: 'Your exam attempts live in your account.',
        ),
      );
    }

    final sessions = ref.watch(sessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History'), centerTitle: false),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(sessionsProvider);
          try {
            await ref.read(sessionsProvider.future);
          } catch (_) {}
        },
        child: AsyncView(
          value: sessions,
          onRetry: () => ref.invalidate(sessionsProvider),
          builder: (list) {
            if (list.isEmpty) {
              return const EmptyView(
                icon: Icons.history_rounded,
                title: 'No exams yet',
                message:
                    'Your completed exams will show up here. Start one from Home.',
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimens.screenPadding),
              itemCount: list.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimens.space3),
              itemBuilder: (context, index) =>
                  SessionTile(session: list[index]),
            );
          },
        ),
      ),
    );
  }
}

class SessionTile extends StatelessWidget {
  final SessionSummary session;

  const SessionTile({required this.session});

  Color _scoreColor(int score) {
    if (score >= 70) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.danger;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final local = date.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inProgress = session.isInProgress;

    return AppCard(
      onTap: () => context.push(
        inProgress
            ? AppRoutes.exam(session.id)
            : AppRoutes.examResult(session.id),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.subjectCode, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  inProgress
                      ? 'In progress, tap to resume'
                      : '${session.correctCount ?? 0} of ${session.totalQuestions} correct  •  ${_formatDate(session.submittedAt ?? session.startedAt)}',
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
          ),
          if (inProgress)
            Icon(
              Icons.play_circle_outline_rounded,
              color: theme.colorScheme.primary,
            )
          else
            Text(
              '${session.score ?? 0}%',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: _scoreColor(session.score ?? 0),
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}
