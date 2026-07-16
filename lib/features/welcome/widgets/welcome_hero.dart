import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

class WelcomeHero extends StatelessWidget {
  const WelcomeHero({super.key});

  static const _image = 'assets/images/welcome_hero.webp';

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).scaffoldBackgroundColor;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          _image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const _HeroFallback(),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.6, 1.0],
              colors: [background.withOpacity(0), background],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.gray100,
      alignment: Alignment.center,
      child: const AppLogo(size: AppDimens.logoXl, withWordmark: false),
    );
  }
}
