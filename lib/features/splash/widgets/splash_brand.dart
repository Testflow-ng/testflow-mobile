import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class SplashBrand extends StatelessWidget {
  final Animation<double> logoAnimation;
  final Animation<double> textAnimation;

  const SplashBrand({
    super.key,
    required this.logoAnimation,
    required this.textAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1).animate(
            CurvedAnimation(parent: logoAnimation, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(
            opacity: logoAnimation,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              child: Image.asset(
                'assets/images/logo.png',
                width: AppDimens.logoLg,
                height: AppDimens.logoLg,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.space5),
        FadeTransition(
          opacity: textAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.25),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: textAnimation, curve: Curves.easeOutCubic),
            ),
            child: Column(
              children: [
                Text('TestFlow', style: textTheme.displaySmall),
                const SizedBox(height: AppDimens.space2),
                Text(
                  'Practice. Track. Pass.',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
