import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/theme.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final notificationsEnabled = ref.watch(notificationsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Settings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: 'BricolageGrotesque',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ─── Appearance ───────────────────────────────────────────
                  _SectionHeader(label: 'Appearance'),
                  _SettingsCard(
                    children: [
                      _ToggleTile(
                        icon: Icons.dark_mode_outlined,
                        iconColor: AppColors.secondary,
                        title: 'Dark Mode',
                        subtitle: 'Switch to the dark theme',
                        value: themeMode == ThemeMode.dark,
                        onChanged: (v) {
                          ref.read(themeModeProvider.notifier)
                              .setTheme(v ? ThemeMode.dark : ThemeMode.light);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimens.space4),

                  // ─── Notifications ────────────────────────────────────────
                  _SectionHeader(label: 'Notifications'),
                  _SettingsCard(
                    children: [
                      _ToggleTile(
                        icon: Icons.notifications_outlined,
                        iconColor: AppColors.info,
                        title: 'Push Notifications',
                        subtitle: 'Receive updates and reminders',
                        value: notificationsEnabled,
                        onChanged: (_) =>
                            ref.read(notificationsProvider.notifier).toggle(),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimens.space4),

                  // ─── Legal ────────────────────────────────────────────────
                  _SectionHeader(label: 'Legal'),
                  _SettingsCard(
                    children: [
                      _NavigationTile(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: AppColors.success,
                        title: 'Privacy Policy',
                        onTap: () => _launchUrl('https://ferousco-dev.github.io/testflow-policy/privacy.html'),
                      ),
                      _Divider(isDark: isDark),
                      _NavigationTile(
                        icon: Icons.description_outlined,
                        iconColor: AppColors.primary,
                        title: 'Terms of Service',
                        onTap: () => _launchUrl('https://ferousco-dev.github.io/testflow-policy/terms.html'),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimens.space4),

                  // ─── Support ──────────────────────────────────────────────
                  _SectionHeader(label: 'Support'),
                  _SettingsCard(
                    children: [
                      _NavigationTile(
                        icon: Icons.support_agent_outlined,
                        iconColor: AppColors.warning,
                        title: 'Contact Support',
                        subtitle: 'Get help from our team',
                        onTap: () => _launchUrl('mailto:support@testflow.app'),
                      ),
                      _Divider(isDark: isDark),
                      _NavigationTile(
                        icon: Icons.star_outline_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        title: 'Rate TestFlow',
                        subtitle: 'Help us with a 5-star review',
                        onTap: () {},
                      ),
                      _Divider(isDark: isDark),
                      _NavigationTile(
                        icon: Icons.share_outlined,
                        iconColor: AppColors.info,
                        title: 'Share with Friends',
                        subtitle: 'Spread the word about TestFlow',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimens.space6),

                  // Version footer
                  Center(
                    child: Column(
                      children: [
                        const AppLogo(size: 24),
                        const SizedBox(height: 8),
                        Text(
                          'Version 0.1.0 • By Eddyrus Media',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.35),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '© ${DateTime.now().year} Eddyrus Media. All rights reserved.',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withOpacity(0.25),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimens.space8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space4,
        vertical: AppDimens.space3,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.45),
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _NavigationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space4,
          vertical: AppDimens.space4,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.45),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 56,
      endIndent: 0,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }
}
