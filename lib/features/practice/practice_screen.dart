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
import '../home/widgets/start_exam_sheet.dart';
import '../home/widgets/subject_tile.dart';
import '../home/widgets/verify_banner.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    if (auth.isGuest || auth.user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Practice'), centerTitle: false),
        body: EmptyView(
          icon: Icons.lock_outline_rounded,
          title: 'Create a free account',
          message: 'You need an account to take CBT practice exams.',
          action: AppButton(
            label: 'Create Account',
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) context.go(AppRoutes.register);
            },
          ),
        ),
      );
    }

    final user = auth.user!;
    final subjects = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Edit my subjects',
            onPressed: () => context.push(AppRoutes.subjectSetup),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(subjectsProvider);
          try {
            await ref.read(subjectsProvider.future);
          } catch (_) {}
        },
        child: AsyncView(
          value: subjects,
          onRetry: () => ref.invalidate(subjectsProvider),
          builder: (list) => _SubjectList(
            subjects: list,
            pinnedIds: user.pinnedSubjects,
            showVerifyBanner: !user.isEmailVerified,
          ),
        ),
      ),
    );
  }
}

class _SubjectList extends ConsumerWidget {
  final List<Subject> subjects;
  final List<String> pinnedIds;
  final bool showVerifyBanner;

  const _SubjectList({
    required this.subjects,
    required this.pinnedIds,
    required this.showVerifyBanner,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (subjects.isEmpty) {
      return const EmptyView(
        icon: Icons.menu_book_outlined,
        title: 'No subjects yet',
        message: 'Subjects will appear here once they are published.',
      );
    }

    final sorted = [...subjects]..sort((a, b) {
        final aPinned = pinnedIds.contains(a.id) ? 0 : 1;
        final bPinned = pinnedIds.contains(b.id) ? 0 : 1;
        if (aPinned != bPinned) return aPinned - bPinned;
        return a.code.compareTo(b.code);
      });

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      itemCount: sorted.length + (showVerifyBanner ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.space3),
      itemBuilder: (context, index) {
        if (showVerifyBanner && index == 0) return const VerifyBanner();
        final subject = sorted[index - (showVerifyBanner ? 1 : 0)];
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
