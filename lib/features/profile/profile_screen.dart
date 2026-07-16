import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/user.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';
import '../home/widgets/stats_strip.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    if (user == null) return const _GuestProfile();

    final theme = Theme.of(context);
    final stats = ref.watch(statsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final notificationsEnabled = ref.watch(notificationsProvider);
    final subjectCount = user.pinnedSubjects.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        children: [
          _ProfileHeader(user: user),
          const SizedBox(height: AppDimens.space5),
          stats.maybeWhen(
            data: (s) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.space5),
              child: StatsStrip(stats: s),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          const _SectionLabel('Account'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Tile(
                  icon: Icons.person_outline_rounded,
                  color: theme.colorScheme.primary,
                  title: 'Edit profile',
                  subtitle: user.email,
                  onTap: () => context.push(AppRoutes.editProfile),
                ),
                const _TileDivider(),
                _Tile(
                  icon: Icons.menu_book_outlined,
                  color: AppColors.secondary,
                  title: 'My subjects',
                  subtitle: subjectCount == 0
                      ? 'Choose your subject combination'
                      : '$subjectCount subject${subjectCount == 1 ? '' : 's'} selected',
                  onTap: () => context.push(AppRoutes.subjectSetup),
                ),
                const _TileDivider(),
                _Tile(
                  icon: Icons.lock_outline_rounded,
                  color: AppColors.info,
                  title: 'Change password',
                  onTap: () => context.push(AppRoutes.changePassword),
                ),
                if (!user.isEmailVerified) ...[
                  const _TileDivider(),
                  _Tile(
                    icon: Icons.mark_email_unread_outlined,
                    color: AppColors.warning,
                    title: 'Verify email',
                    subtitle: 'Required for graded exams',
                    onTap: () => context.push(AppRoutes.verifyEmail),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppDimens.space5),
          const _SectionLabel('Preferences'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SwitchTile(
                  icon: Icons.dark_mode_outlined,
                  color: AppColors.secondary,
                  title: 'Dark mode',
                  value: themeMode == ThemeMode.dark,
                  onChanged: (v) => ref
                      .read(themeModeProvider.notifier)
                      .setTheme(v ? ThemeMode.dark : ThemeMode.light),
                ),
                const _TileDivider(),
                _SwitchTile(
                  icon: Icons.notifications_outlined,
                  color: AppColors.info,
                  title: 'Push notifications',
                  value: notificationsEnabled,
                  onChanged: (_) =>
                      ref.read(notificationsProvider.notifier).toggle(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.space5),
          const _SectionLabel('About'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Tile(
                  icon: Icons.privacy_tip_outlined,
                  color: AppColors.success,
                  title: 'Privacy policy',
                  onTap: () => _launchUrl(
                    'https://ferousco-dev.github.io/testflow-policy/privacy.html',
                  ),
                ),
                const _TileDivider(),
                _Tile(
                  icon: Icons.description_outlined,
                  color: theme.colorScheme.primary,
                  title: 'Terms of service',
                  onTap: () => _launchUrl(
                    'https://ferousco-dev.github.io/testflow-policy/terms.html',
                  ),
                ),
                const _TileDivider(),
                _Tile(
                  icon: Icons.support_agent_outlined,
                  color: AppColors.warning,
                  title: 'Contact support',
                  onTap: () => _launchUrl('mailto:feranmioresajo@gmail.com'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.space5),
          AppCard(
            padding: EdgeInsets.zero,
            child: _Tile(
              icon: Icons.logout_rounded,
              color: AppColors.danger,
              title: 'Sign out',
              titleColor: AppColors.danger,
              onTap: () => _confirmSignOut(context, ref),
            ),
          ),
          const SizedBox(height: AppDimens.space5),
          const _VersionFooter(),
          const SizedBox(height: AppDimens.space6),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
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
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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

    return AppCard(
      padding: const EdgeInsets.all(AppDimens.space5),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withOpacity(0.12),
            ),
            child: Text(
              _initials,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
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
                  user.fullName,
                  style: theme.textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.username != null) ...[
                  const SizedBox(height: 2),
                  Text('@${user.username}', style: theme.textTheme.labelMedium),
                ],
                const SizedBox(height: AppDimens.space2),
                Row(
                  children: [
                    _Badge(
                      icon: user.isEmailVerified
                          ? Icons.verified_rounded
                          : Icons.error_outline_rounded,
                      label: user.isEmailVerified ? 'Verified' : 'Unverified',
                      color: user.isEmailVerified
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                    if (user.streakCount > 0) ...[
                      const SizedBox(width: AppDimens.space2),
                      _Badge(
                        icon: Icons.local_fire_department_rounded,
                        label: '${user.streakCount} day streak',
                        color: AppColors.warning,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimens.space2,
        bottom: AppDimens.space3,
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space4,
        vertical: 2,
      ),
      leading: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: Icon(icon, size: AppDimens.iconMd, color: color),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(color: titleColor),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: theme.textTheme.labelMedium)
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: theme.colorScheme.onSurface.withOpacity(0.3),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space4,
        vertical: 2,
      ),
      leading: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: Icon(icon, size: AppDimens.iconMd, color: color),
      ),
      title: Text(title, style: theme.textTheme.titleSmall),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      indent: AppDimens.space4 + 38 + AppDimens.space4,
      color: (isDark ? Colors.white : AppColors.gray900).withOpacity(0.06),
    );
  }
}

class _VersionFooter extends StatelessWidget {
  const _VersionFooter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '';
        return Column(
          children: [
            const AppLogo(size: 22, withWordmark: false),
            const SizedBox(height: AppDimens.space2),
            Text(
              version.isEmpty
                  ? 'TestFlow by Eddyrus Media'
                  : 'TestFlow v$version  •  By Eddyrus Media',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall,
            ),
          ],
        );
      },
    );
  }
}

class _GuestProfile extends ConsumerWidget {
  const _GuestProfile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: false),
      body: EmptyView(
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
      ),
    );
  }
}
