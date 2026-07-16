import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/router/app_router.dart';
import 'widgets/splash_brand.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoAnimation;
  late final Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    _logoAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.55, curve: Curves.easeOut),
    );
    _textAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1, curve: Curves.easeOut),
    );
    _start();
  }

  Future<void> _start() async {
    await Future.wait([
      _controller.forward(),
      ref.read(authProvider.notifier).bootstrap(),
    ]);
    await Future.delayed(const Duration(milliseconds: 400));
    _navigate();
  }

  void _navigate() {
    if (!mounted) return;
    final onboardingDone = ref.read(onboardingProvider);
    final authState = ref.read(authProvider);

    if (!onboardingDone) {
      context.go(AppRoutes.onboarding);
    } else if (authState.isAuthenticated && authState.needsUsername) {
      context.go(AppRoutes.usernameSetup);
    } else if (authState.isAuthenticated || authState.isGuest) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.welcome);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: SplashBrand(
              logoAnimation: _logoAnimation,
              textAnimation: _textAnimation,
            ),
          ),
          Positioned(
            bottom: AppDimens.space8,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textAnimation,
              child: Text(
                'By Eddyrus Media',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
