import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/theme/theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _version = '0.1.0';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = info.version);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider);
    final displayName = auth.displayName ?? 'TestFlow User';
    final email = auth.email ?? 'guest@testflow.app';
    final initials = _initials(displayName);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Profile',
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
                children: [
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: AppShadows.primaryGlow(AppColors.primary),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'BricolageGrotesque',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.space4),

                  // Name
                  Text(
                    displayName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: 'BricolageGrotesque',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Email
                  Text(
                    email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),

                  if (auth.isGuest) ...[
                    const SizedBox(height: AppDimens.space3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                      ),
                      child: const Text(
                        '⚡ Guest Mode',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppDimens.space6),

                  // Info cards
                  _InfoSection(
                    title: 'Account',
                    items: [
                      _InfoItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Display Name',
                        value: displayName,
                        color: AppColors.primary,
                      ),
                      _InfoItem(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: email,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimens.space4),

                  _InfoSection(
                    title: 'App Info',
                    items: [
                      _InfoItem(
                        icon: Icons.info_outline_rounded,
                        label: 'Version',
                        value: 'v$_version',
                        color: AppColors.neutral,
                      ),
                      _InfoItem(
                        icon: Icons.business_rounded,
                        label: 'Developer',
                        value: 'Eddyrus Media',
                        color: AppColors.info,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimens.space4),

                  // About section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimens.space5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.08),
                          AppColors.secondary.withOpacity(0.04),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppLogo(size: 28),
                        const SizedBox(height: AppDimens.space3),
                        Text(
                          'About TestFlow',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'BricolageGrotesque',
                          ),
                        ),
                        const SizedBox(height: AppDimens.space2),
                        Text(
                          'TestFlow is a premium CBT platform designed to help students ace their university courses through rigorous, timed simulations and intelligent analytics.\n\nThis is Version 0.1.0 — an early preview that introduces the TestFlow brand. The full CBT experience is coming soon.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.7,
                            color: theme.colorScheme.onSurface.withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimens.space6),

                  // Sign out button
                  if (!auth.isGuest)
                    AppButton(
                      label: 'Sign Out',
                      variant: AppButtonVariant.outline,
                      isFullWidth: true,
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      onPressed: () async {
                        await ref.read(authProvider.notifier).signOut();
                        if (context.mounted) context.go(AppRoutes.welcome);
                      },
                    )
                  else
                    AppButton(
                      label: 'Create Account',
                      isFullWidth: true,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      onPressed: () => context.go(AppRoutes.register),
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

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;

  const _InfoSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.45),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
