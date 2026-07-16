import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../shared/widgets/widgets.dart';

// Feature card model
class _FeatureCard {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String tag;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.tag,
  });
}

const _featureCards = [
  _FeatureCard(
    title: 'CBT Practice',
    subtitle: 'Simulate real exam conditions with timed sessions',
    icon: Icons.quiz_rounded,
    color: AppColors.primary,
    tag: 'Coming Soon',
  ),
  _FeatureCard(
    title: 'Mock Exams',
    subtitle: 'Full-length mock exams across all courses',
    icon: Icons.assignment_outlined,
    color: AppColors.secondary,
    tag: 'Coming Soon',
  ),
  _FeatureCard(
    title: 'Past Questions',
    subtitle: 'Curated past exam questions with answers',
    icon: Icons.history_edu_rounded,
    color: Color(0xFF0EA5E9),
    tag: 'Coming Soon',
  ),
  _FeatureCard(
    title: 'Performance Analytics',
    subtitle: 'Deep insights into your exam performance',
    icon: Icons.bar_chart_rounded,
    color: Color(0xFF16A34A),
    tag: 'Coming Soon',
  ),
  _FeatureCard(
    title: 'Leaderboard',
    subtitle: 'Compete with students across your school',
    icon: Icons.emoji_events_rounded,
    color: Color(0xFFF59E0B),
    tag: 'Coming Soon',
  ),
  _FeatureCard(
    title: 'AI Study Assistant',
    subtitle: 'Get personalized study help powered by AI',
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFF7C3AED),
    tag: 'Coming Soon',
  ),
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = ref.watch(authProvider);
    final displayName = auth.displayName ?? 'there';
    final greeting = _getGreeting();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ────────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 160,
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenPadding,
                  0,
                  AppDimens.screenPadding,
                  AppDimens.space4,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppLogo(size: AppDimens.logoSm),
                        const Spacer(),
                        // Notification bell
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                            border: Border.all(color: theme.colorScheme.outline),
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.space4),
                    Text(
                      '$greeting,',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    Text(
                      displayName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontFamily: 'BricolageGrotesque',
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Under Development Banner ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.screenPadding,
                AppDimens.space4,
                AppDimens.screenPadding,
                0,
              ),
              child: _DevBanner(),
            ),
          ),

          // ─── Section Header ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.screenPadding,
                AppDimens.space6,
                AppDimens.screenPadding,
                AppDimens.space4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features Preview',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: 'BricolageGrotesque',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Here\'s what\'s coming to TestFlow',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          // ─── Feature Cards Grid ──────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.88,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _FeatureCardWidget(
                    card: _featureCards[index],
                    delay: Duration(milliseconds: index * 80),
                  );
                },
                childCount: _featureCards.length,
              ),
            ),
          ),

          // ─── Footer spacer ────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimens.space8),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

class _DevBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.12),
            AppColors.secondary.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: const Text('🚀', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TestFlow is under active development',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'More amazing features are coming soon. Stay tuned for updates!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                    height: 1.5,
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

class _FeatureCardWidget extends StatefulWidget {
  final _FeatureCard card;
  final Duration delay;

  const _FeatureCardWidget({required this.card, required this.delay});

  @override
  State<_FeatureCardWidget> createState() => _FeatureCardWidgetState();
}

class _FeatureCardWidgetState extends State<_FeatureCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: _CardContent(card: widget.card),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final _FeatureCard card;
  const _CardContent({required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: card.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Icon(card.icon, color: card.color, size: 24),
          ),
          const Spacer(),

          // Title
          Text(
            card.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Subtitle
          Text(
            card.subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimens.space3),

          // Coming soon badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: card.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              border: Border.all(
                color: card.color.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: card.color,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  card.tag,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: card.color,
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
