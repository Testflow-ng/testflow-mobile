import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/router/app_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../shared/widgets/widgets.dart';
import 'widgets/welcome_hero.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continueAsGuest() {
    ref.read(authProvider.notifier).continueAsGuest();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          const Expanded(flex: 11, child: WelcomeHero()),
          Expanded(
            flex: 9,
            child: SafeArea(
              top: false,
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.screenPadding,
                      0,
                      AppDimens.screenPadding,
                      AppDimens.space4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Ace every exam\nwith confidence',
                          style: theme.textTheme.displaySmall,
                        ),
                        const SizedBox(height: AppDimens.space3),
                        Text(
                          'Practice real CBT exams, track your performance, and improve every day.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            height: 1.55,
                          ),
                        ),
                        const Spacer(),
                        AppButton(
                          label: 'Create Account',
                          isFullWidth: true,
                          onPressed: () => context.go(AppRoutes.register),
                        ),
                        const SizedBox(height: AppDimens.space3),
                        AppButton(
                          label: 'Sign In',
                          variant: AppButtonVariant.outline,
                          isFullWidth: true,
                          onPressed: () => context.go(AppRoutes.login),
                        ),
                        const SizedBox(height: AppDimens.space2),
                        AppButton(
                          label: 'Continue as Guest',
                          variant: AppButtonVariant.ghost,
                          onPressed: _continueAsGuest,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
