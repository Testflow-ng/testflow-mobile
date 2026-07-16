import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../onboarding_pages.dart';

class OnboardingTextBlock extends StatelessWidget {
  final OnboardingPageData page;
  final int pageIndex;

  const OnboardingTextBlock({
    super.key,
    required this.page,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.15),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Column(
        key: ValueKey(pageIndex),
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            page.title,
            style: textTheme.displaySmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppDimens.space3),
          Text(
            page.subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.75),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
