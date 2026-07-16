import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/exam.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';
import '../history/history_screen.dart' show SessionTile;
import 'widgets/quote_card.dart';
import 'widgets/resume_card.dart';
import 'widgets/stats_strip.dart';
import 'widgets/verify_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(statsProvider);
    ref.invalidate(sessionsProvider);
    try {
      await Future.wait([
        ref.read(statsProvider.future),
        ref.read(sessionsProvider.future),
      ]);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    if (auth.isGuest || auth.user == null) return const _GuestHome();

    final user = auth.user!;
    final stats = ref.watch(statsProvider);
    final sessions = ref.watch(sessionsProvider);
    final theme = Theme.of(context);

    final inProgress = sessions.valueOrNull
        ?.where((session) => session.isInProgress)
        .firstOrNull;
    final recent = sessions.valueOrNull
            ?.where((session) => !session.isInProgress)
            .take(3)
            .toList() ??
        const <SessionSummary>[];

    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(size: 28),
        actions: [
          if (user.streakCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: AppDimens.space2),
              child: _StreakChip(count: user.streakCount),
            ),
          Padding(
            padding: const EdgeInsets.only(right: AppDimens.screenPadding),
            child: GestureDetector(
              onTap: () => context.go(AppRoutes.profile),
              child: _Avatar(name: user.fullName),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          children: [
            Text(
              '$_greeting,\n${user.firstName}',
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: AppDimens.space5),
            if (!user.isEmailVerified) ...[
              const VerifyBanner(),
              const SizedBox(height: AppDimens.space4),
            ],
            if (inProgress != null) ...[
              ResumeCard(session: inProgress),
              const SizedBox(height: AppDimens.space4),
            ],
            const QuoteCard(),
            const SizedBox(height: AppDimens.space4),
            _StartCbtCard(onTap: () => context.go(AppRoutes.practice)),
            const SizedBox(height: AppDimens.space7),
            Row(
              children: [
                Expanded(
                  child: Text('Your activity',
                      style: theme.textTheme.headlineSmall),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.progress),
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space3),
            stats.maybeWhen(
              data: (s) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.space4),
                child: StatsStrip(stats: s),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            if (recent.isNotEmpty) ...[
              for (final session in recent) ...[
                SessionTile(session: session),
                const SizedBox(height: AppDimens.space3),
              ],
            ] else
              const EmptyView(
                icon: Icons.rocket_launch_outlined,
                title: 'No exams yet',
                message: 'Your recent exams will show up here.',
              ),
            const SizedBox(height: AppDimens.space6),
          ],
        ),
      ),
    );
  }
}

class _StartCbtCard extends StatelessWidget {
  final VoidCallback onTap;

  const _StartCbtCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      color: theme.colorScheme.primary,
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimens.space5),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start a CBT practice',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppDimens.space1),
                Text(
                  'Timed exams with real past questions',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  final int count;

  const _StreakChip({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 14,
            color: AppColors.warning,
          ),
          const SizedBox(width: 3),
          Text(
            '$count',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;

  const _Avatar({required this.name});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.isEmpty ? '?' : parts.first[0].toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary.withOpacity(0.12),
      ),
      child: Text(
        _initials,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _GuestHome extends ConsumerWidget {
  const _GuestHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const AppLogo(size: 28)),
      body: EmptyView(
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
    );
  }
}
