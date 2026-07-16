import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/user.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: user == null
          ? const _GuestProfile()
          : ListView(
              padding: const EdgeInsets.all(AppDimens.screenPadding),
              children: [
                _ProfileHeader(user: user),
                const SizedBox(height: AppDimens.space6),
                _InfoCard(user: user),
                const SizedBox(height: AppDimens.space6),
                _MenuTile(
                  icon: Icons.edit_outlined,
                  label: 'Edit profile',
                  onTap: () => context.push(AppRoutes.editProfile),
                ),
                _MenuTile(
                  icon: Icons.lock_outline_rounded,
                  label: 'Change password',
                  onTap: () => context.push(AppRoutes.changePassword),
                ),
                if (!user.isEmailVerified)
                  _MenuTile(
                    icon: Icons.mark_email_unread_outlined,
                    label: 'Verify email',
                    onTap: () => context.push(AppRoutes.verifyEmail),
                  ),
                _SignOutTile(),
              ],
            ),
    );
  }
}

class _SignOutTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _MenuTile(
      icon: Icons.logout_rounded,
      label: 'Sign out',
      isDestructive: true,
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sign out'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await ref.read(authProvider.notifier).signOut();
          if (context.mounted) context.go(AppRoutes.welcome);
        }
      },
    );
  }
}

class _GuestProfile extends ConsumerWidget {
  const _GuestProfile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EmptyView(
      icon: Icons.person_outline_rounded,
      title: 'You are browsing as a guest',
      message: 'Create an account to save your progress and take exams.',
      action: AppButton(
        label: 'Create Account',
        onPressed: () async {
          await ref.read(authProvider.notifier).signOut();
          if (context.mounted) context.go(AppRoutes.register);
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User user;

  const _ProfileHeader({required this.user});

  String get _initials {
    final parts = user.fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.isEmpty ? '?' : parts.first[0].toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withOpacity(0.12),
          ),
          child: Text(
            _initials,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.space4),
        Text(user.fullName, style: theme.textTheme.headlineMedium),
        if (user.username != null) ...[
          const SizedBox(height: 2),
          Text('@${user.username}', style: theme.textTheme.bodySmall),
        ],
        if (user.streakCount > 0) ...[
          const SizedBox(height: AppDimens.space3),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.space3,
              vertical: AppDimens.space1,
            ),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            ),
            child: Text(
              '${user.streakCount} day streak',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final User user;

  const _InfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final rows = <(IconData, String, String)>[
      (Icons.email_outlined, 'Email', user.email),
      if (user.matricNumber != null)
        (Icons.badge_outlined, 'Matric number', user.matricNumber!),
      if (user.level != null)
        (Icons.school_outlined, 'Level', '${user.level} level'),
      if (user.department != null)
        (Icons.apartment_outlined, 'Department', user.department!),
    ];

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: (isDark ? Colors.white : AppColors.gray900)
                    .withOpacity(0.06),
              ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.space4),
              child: Row(
                children: [
                  Icon(
                    rows[i].$1,
                    size: AppDimens.iconMd,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                  const SizedBox(width: AppDimens.space4),
                  Text(rows[i].$2, style: theme.textTheme.labelMedium),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      rows[i].$3,
                      style: theme.textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
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

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        isDestructive ? AppColors.danger : theme.colorScheme.onSurface;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.space2),
      leading: Icon(icon, size: AppDimens.iconMd, color: color),
      title: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(color: color),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: theme.colorScheme.onSurface.withOpacity(0.3),
      ),
      onTap: onTap,
    );
  }
}
