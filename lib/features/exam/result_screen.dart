import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/exam.dart';
import '../../core/providers/api_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';
import 'widgets/result_question_card.dart';

final _resultProvider =
    FutureProvider.autoDispose.family<ExamResult, String>((ref, id) {
  return ref.watch(examRepositoryProvider).getResult(id);
});

class ResultScreen extends ConsumerWidget {
  final String sessionId;

  const ResultScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(_resultProvider(sessionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: AsyncView(
        value: result,
        onRetry: () => ref.invalidate(_resultProvider(sessionId)),
        builder: (data) => _ResultBody(result: data),
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  final ExamResult result;

  const _ResultBody({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      children: [
        _ScoreHero(result: result),
        const SizedBox(height: AppDimens.space6),
        Text('Review', style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppDimens.space4),
        for (final question in result.questions) ...[
          ResultQuestionCard(question: question),
          const SizedBox(height: AppDimens.space3),
        ],
        const SizedBox(height: AppDimens.space4),
        AppButton(
          label: 'Back to Home',
          isFullWidth: true,
          onPressed: () => context.go(AppRoutes.home),
        ),
        const SizedBox(height: AppDimens.space6),
      ],
    );
  }
}

class _ScoreHero extends StatelessWidget {
  final ExamResult result;

  const _ScoreHero({required this.result});

  Color get _scoreColor {
    if (result.score >= 70) return AppColors.success;
    if (result.score >= 50) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 128,
            height: 128,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: result.score / 100,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                  color: _scoreColor,
                  backgroundColor:
                      theme.colorScheme.onSurface.withOpacity(0.08),
                ),
                Center(
                  child: Text(
                    '${result.score}%',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.space5),
          Text(
            result.subjectCode,
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: AppDimens.space1),
          Text(
            '${result.correctCount} of ${result.totalQuestions} correct',
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
