import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/subject.dart';
import '../../core/providers/api_providers.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';
import 'widgets/home_header.dart';
import 'widgets/resume_card.dart';
import 'widgets/start_exam_sheet.dart';
import 'widgets/stats_strip.dart';
import 'widgets/subject_tile.dart';
import 'widgets/verify_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(subjectsProvider);
    ref.invalidate(statsProvider);
    ref.invalidate(sessionsProvider);
    try {
      await Future.wait([
        ref.read(subjectsProvider.future),
        ref.read(statsProvider.future),
        ref.read(sessionsProvider.future),
      ]);
    } catch (_) {
      // Errors are surfaced by the providers themselves.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    if (auth.isGuest || auth.user == null) return const _GuestHome();

    final user = auth.user!;
    final subjects = ref.watch(subjectsProvider);
    final stats = ref.watch(statsProvider);
    final sessions = ref.watch(sessionsProvider);
    final theme = Theme.of(context);

    final inProgress = sessions.valueOrNull
        ?.where((session) => session.isInProgress)
        .firstOrNull;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppDimens.screenPadding),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    HomeHeader(user: user),
                    const SizedBox(height: AppDimens.space6),
                    if (!user.isEmailVerified) ...[
                      const VerifyBanner(),
                      const SizedBox(height: AppDimens.space4),
                    ],
                    if (inProgress != null) ...[
                      ResumeCard(session: inProgress),
                      const SizedBox(height: AppDimens.space4),
                    ],
                    stats.maybeWhen(
                      data: (s) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppDimens.space6),
                        child: StatsStrip(stats: s),
                      ),
                      orElse: () => const SizedBox(height: AppDimens.space2),
                    ),
                    Text('Subjects', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: AppDimens.space4),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenPadding,
                  0,
                  AppDimens.screenPadding,
                  AppDimens.space7,
                ),
                sliver: subjects.when(
                  data: (list) => _SubjectList(
                    subjects: list,
                    pinnedIds: user.pinnedSubjects,
                  ),
                  loading: () => const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppDimens.space7),
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  ),
                  error: (error, _) => SliverToBoxAdapter(
                    child: ErrorView(
                      message: error.toString(),
                      onRetry: () => ref.invalidate(subjectsProvider),
                    ),
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

class _SubjectList extends ConsumerWidget {
  final List<Subject> subjects;
  final List<String> pinnedIds;

  const _SubjectList({required this.subjects, required this.pinnedIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (subjects.isEmpty) {
      return const SliverToBoxAdapter(
        child: EmptyView(
          icon: Icons.menu_book_outlined,
          title: 'No subjects yet',
          message: 'Subjects will appear here once they are published.',
        ),
      );
    }

    final sorted = [...subjects]..sort((a, b) {
        final aPinned = pinnedIds.contains(a.id) ? 0 : 1;
        final bPinned = pinnedIds.contains(b.id) ? 0 : 1;
        if (aPinned != bPinned) return aPinned - bPinned;
        return a.code.compareTo(b.code);
      });

    return SliverList.separated(
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.space3),
      itemBuilder: (context, index) {
        final subject = sorted[index];
        return SubjectTile(
          subject: subject,
          isPinned: pinnedIds.contains(subject.id),
          onTap: () => showStartExamSheet(context, subject),
          onTogglePin: () async {
            try {
              await ref.read(subjectRepositoryProvider).togglePin(subject.id);
              await ref.read(authProvider.notifier).refreshMe();
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not update pin')),
                );
              }
            }
          },
        );
      },
    );
  }
}

class _GuestHome extends ConsumerWidget {
  const _GuestHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: EmptyView(
          icon: Icons.lock_outline_rounded,
          title: 'Create a free account',
          message:
              'Guest mode lets you look around, but you need an account to take exams and track progress.',
          action: AppButton(
            label: 'Create Account',
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) context.go(AppRoutes.register);
            },
          ),
        ),
      ),
    );
  }
}
